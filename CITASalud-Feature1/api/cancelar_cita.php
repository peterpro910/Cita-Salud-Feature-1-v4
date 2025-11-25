<?php
// api/cancelar_cita.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Cita.php';
include_once __DIR__ . '/../config/send-email.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    http_response_code(503); 
    echo json_encode(array("message" => "Error de conexión a la base de datos."));
    exit();
}

$data = json_decode(file_get_contents("php://input"));

if (empty($data->id_cita) || empty($data->id_paciente) || empty($data->id_motivo_cancelacion)) {
    http_response_code(400); 
    echo json_encode(array("message" => "Datos incompletos para la cancelación (ID Cita, ID Paciente, o Motivo)."));
    exit();
}

$cita = new Cita($db);
$cita->id_cita = $data->id_cita;
$cita->id_paciente = $data->id_paciente;
$cita->motivo_cancelacion = $data->id_motivo_cancelacion;

try {
    // 1. Obtener detalles de la cita para la validación de 24h
    // Nota: El modelo Cita debe incluir la validación de que la cita pertenece al paciente.
    $detallesCita = $cita->getCitaDetailsForCancellation($cita->id_cita, $cita->id_paciente); 

    if (!$detallesCita) {
        http_response_code(404);
        echo json_encode(array("message" => "La cita no existe, ya fue cancelada, o no le pertenece."));
        exit();
    }
    
    // --- Validar tiempo mínimo de 24 horas (HU-07) ---
    $citaTimestamp = strtotime($detallesCita['fecha'] . ' ' . $detallesCita['hora']);
    $currentTime = time();
    $diferenciaSegundos = $citaTimestamp - $currentTime;
    $segundosMinimo = 24 * 60 * 60; // 86400 segundos (24 horas)

    if ($diferenciaSegundos < $segundosMinimo) {
        http_response_code(403); 
        echo json_encode(array("message" => "No es posible cancelar la cita con menos de 24 horas de anticipación."));
        exit();
    }

    // --- Validar límite mensual (HU-07) ---
    $cancelacionesMes = $cita->countCancellationsThisMonth($cita->id_paciente);
    $LIMITE_MENSUAL = 3;

    if ($cancelacionesMes >= $LIMITE_MENSUAL) {
        http_response_code(403); 
        echo json_encode(array("message" => "Ha alcanzado el límite de " . $LIMITE_MENSUAL . " cancelaciones mensuales. No puede cancelar la cita."));
        exit();
    }
    
    // 3. Ejecutar la cancelación
    if ($cita->cancelarCita($detallesCita['id_horario'])) {
        http_response_code(200);
        
        $cancelaciones_totales_actuales = $cita->countCancellationsThisMonth($cita->id_paciente);
        $cancelaciones_restantes = $LIMITE_MENSUAL - $cancelaciones_totales_actuales;
        $cancelaciones_restantes = max(0, $cancelaciones_restantes);

        // -----------------------------------------------------------------
        // 4. LÓGICA DE OBTENCIÓN DE DATOS Y ENVÍO DE CORREO (Mejorada)
        // -----------------------------------------------------------------
        
        // Consulta unificada y optimizada para todos los detalles del correo
        $queryDetallesCorreo = "
            SELECT 
                p.nombre AS nombre_paciente, p.apellido AS apellido_paciente, p.correo AS correo_paciente,
                pr.nombre AS nombre_profesional, pr.apellido AS apellido_profesional,
                s.nombre_sede AS nombre_sede, s.direccion, 
                c.nombre_ciudad AS ciudad,
                m.nombre_motivo AS motivo_cancelacion_nombre,
                e.nombre_especialidad,
                h.fecha, h.hora /* <-- Ahora sí debe existir gracias al JOIN */
            FROM citas ci
            JOIN pacientes p ON ci.id_paciente = p.id_paciente
            JOIN profesionales pr ON ci.id_profesional = pr.id_profesional
            JOIN especialidades e ON ci.id_especialidad = e.id_especialidad
            JOIN sedes s ON ci.id_sede = s.id_sede
            JOIN ciudades c ON s.id_ciudad = c.id_ciudad
            JOIN motivos_cancelacion m ON m.id_motivo = :motivo_id
            
            -- ¡ESTA LÍNEA ES LA SOLUCIÓN! Asegura que la tabla de horarios esté unida con el alias 'h'
            JOIN horarios_profesionales h ON ci.id_horario = h.id_horario 
            
            WHERE ci.id_cita = :cita_id AND ci.id_paciente = :paciente_id LIMIT 1";

        $stmtDetalles = $db->prepare($queryDetallesCorreo);
        $stmtDetalles->bindParam(':cita_id', $cita->id_cita, PDO::PARAM_INT);
        $stmtDetalles->bindParam(':paciente_id', $cita->id_paciente, PDO::PARAM_INT); // Seguridad extra
        $stmtDetalles->bindParam(':motivo_id', $cita->motivo_cancelacion, PDO::PARAM_INT);
        $stmtDetalles->execute();
        $detallesCorreo = $stmtDetalles->fetch(PDO::FETCH_ASSOC);

        $mensaje_confirmacion = "Cita cancelada correctamente.";
        
        if ($detallesCorreo && function_exists('send_cancellation_email')) {
            
            $paciente_nombre_completo = $detallesCorreo['nombre_paciente'] . ' ' . $detallesCorreo['apellido_paciente'];
            
            $datos_para_email = [
                'profesional' => $detallesCorreo['nombre_profesional'] . ' ' . $detallesCorreo['apellido_profesional'],
                'especialidad' => $detallesCorreo['nombre_especialidad'], 
                'fecha' => date('d/m/Y', strtotime($detallesCorreo['fecha'])),
                'hora' => date('h:i A', strtotime($detallesCorreo['hora'])),
                'sede' => $detallesCorreo['nombre_sede'] . " (" . $detallesCorreo['direccion'] . ", " . $detallesCorreo['ciudad'] . ")",
                'motivo' => $detallesCorreo['motivo_cancelacion_nombre'],
                'cancelaciones_restantes' => $cancelaciones_restantes,
                'limite_mensual' => $LIMITE_MENSUAL
            ];
            
            $email_sent = send_cancellation_email(
                $detallesCorreo['correo_paciente'], 
                $paciente_nombre_completo, 
                $datos_para_email
            );

            if ($email_sent) {
                $mensaje_confirmacion .= " Se ha enviado una confirmación de cancelación a su correo.";
            } else {
                $mensaje_confirmacion .= " (ADVERTENCIA: Falló el envío del correo de confirmación. Revise la configuración SMTP).";
            }
        }

        echo json_encode(array(
            "message" => $mensaje_confirmacion,
            "cancelaciones_restantes" => $cancelaciones_restantes
        ));


    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Error al procesar la cancelación de la cita. Revise los logs del servidor."));
    }

} catch (PDOException $e) {
    http_response_code(500);
    error_log("Error al cancelar cita (API): " . $e->getMessage());
    echo json_encode(array("message" => "Error de base de datos al intentar cancelar. Detalles: " . $e->getMessage()));
} catch (Exception $e) {
    http_response_code(500);
    error_log("Error general (API): " . $e->getMessage());
    echo json_encode(array("message" => "Error interno del servidor."));
}
?>