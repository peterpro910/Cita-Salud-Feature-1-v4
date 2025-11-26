<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Incluir la clase de base de datos
include_once '../config/db.php';

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (
    empty($data->id_paciente) ||
    empty($data->id_profesional) ||
    empty($data->id_sede) ||
    empty($data->id_especialidad) ||
    empty($data->id_horario)
) {
    http_response_code(400); 
    echo json_encode(array("message" => "No se pudo agendar la cita. Faltan datos."));
    die();
}

$db->beginTransaction();

try {
    // 1. Verificar la disponibilidad del horario y bloquear la fila
    $queryVerificar = "SELECT disponible FROM horarios_profesionales WHERE id_horario = ? LIMIT 1 FOR UPDATE";
    $stmtVerificar = $db->prepare($queryVerificar);
    $stmtVerificar->bindParam(1, $data->id_horario, PDO::PARAM_INT);
    $stmtVerificar->execute();
    $horario = $stmtVerificar->fetch(PDO::FETCH_ASSOC);

    if (!$horario || $horario['disponible'] == 0) {
        http_response_code(409); 
        echo json_encode(array("message" => "No es posible agendar la cita, horario sin disponibilidad."));
        $db->rollBack(); 
        die();
    }
    
    // 2. Insertar la nueva cita
    $queryInsertarCita = "INSERT INTO citas (id_paciente, id_profesional, id_sede, id_especialidad, id_horario, id_estado) VALUES (?, ?, ?, ?, ?, ?)";
    $stmtInsertarCita = $db->prepare($queryInsertarCita);

    $id_estado_agendada = 1;

    $stmtInsertarCita->bindParam(1, $data->id_paciente, PDO::PARAM_INT);
    $stmtInsertarCita->bindParam(2, $data->id_profesional, PDO::PARAM_INT);
    $stmtInsertarCita->bindParam(3, $data->id_sede, PDO::PARAM_INT);
    $stmtInsertarCita->bindParam(4, $data->id_especialidad, PDO::PARAM_INT);
    $stmtInsertarCita->bindParam(5, $data->id_horario, PDO::PARAM_INT);
    $stmtInsertarCita->bindParam(6, $id_estado_agendada, PDO::PARAM_INT);
    $stmtInsertarCita->execute();

    $id_cita_agendada = $db->lastInsertId();

    // 3. Insertar en historial
    $queryInsertarHistorial = "INSERT INTO historiales_cita (id_cita, id_estado, observacion) VALUES (?, ?, ?)";
    $stmtInsertarHistorial = $db->prepare($queryInsertarHistorial);
    $observacion = "Cita agendada por el paciente.";
    $stmtInsertarHistorial->bindParam(1, $id_cita_agendada, PDO::PARAM_INT);
    $stmtInsertarHistorial->bindParam(2, $id_estado_agendada, PDO::PARAM_INT);
    $stmtInsertarHistorial->bindParam(3, $observacion);
    $stmtInsertarHistorial->execute();

    // 4. Actualizar el horario a no disponible
    $queryActualizarHorario = "UPDATE horarios_profesionales SET disponible = 0 WHERE id_horario = ?";
    $stmtActualizarHorario = $db->prepare($queryActualizarHorario);
    $stmtActualizarHorario->bindParam(1, $data->id_horario, PDO::PARAM_INT);
    $stmtActualizarHorario->execute();

    $db->commit();
    
    // -----------------------------------------------------------------
    // 5. LÓGICA DE OBTENCIÓN DE DATOS Y ENVÍO DE CORREO (NUEVO CÓDIGO)
    // -----------------------------------------------------------------
    
    // 1. Incluir la utilidad de correo.
    // (Asegúrate de que esta ruta sea correcta para tu 'send-email.php')
    include_once '../config/send-email.php'; 
    $mensaje_correo = ""; 

    // 2. Query CORREGIDA: Usa JOIN con 'ciudades' y selecciona 'nombre_sede' y 'nombre_ciudad'.
    $queryDetalles = "
        SELECT 
            p.nombre AS nombre_paciente, p.apellido AS apellido_paciente, p.correo AS correo_paciente,
            e.nombre_especialidad AS nombre_especialidad,
            pr.nombre AS nombre_profesional, pr.apellido AS apellido_profesional,
            s.nombre_sede AS nombre_sede, s.direccion, 
            c.nombre_ciudad AS ciudad,
            hp.fecha, hp.hora
        FROM citas cita
        JOIN pacientes p ON cita.id_paciente = p.id_paciente
        JOIN profesionales pr ON cita.id_profesional = pr.id_profesional
        JOIN sedes s ON cita.id_sede = s.id_sede
        JOIN especialidades e ON cita.id_especialidad = e.id_especialidad
        JOIN horarios_profesionales hp ON cita.id_horario = hp.id_horario
        JOIN ciudades c ON s.id_ciudad = c.id_ciudad
        WHERE cita.id_cita = ? LIMIT 1";

    $stmtDetalles = $db->prepare($queryDetalles);
    $stmtDetalles->bindParam(1, $id_cita_agendada, PDO::PARAM_INT);
    $stmtDetalles->execute();
    $detallesCita = $stmtDetalles->fetch(PDO::FETCH_ASSOC);
    // 6. PREPARAR Y ENVIAR EL CORREO
    if ($detallesCita && function_exists('send_appointment_email')) {
        
        $paciente_nombre_completo = $detallesCita['nombre_paciente'] . ' ' . $detallesCita['apellido_paciente'];
        
        $datos_para_email = [
            'profesional' => $detallesCita['nombre_profesional'] . ' ' . $detallesCita['apellido_profesional'],
            'especialidad' => $detallesCita['nombre_especialidad'],
            'fecha' => date('d/m/Y', strtotime($detallesCita['fecha'])),
            'hora' => date('h:i A', strtotime($detallesCita['hora'])),
            'sede' => $detallesCita['nombre_sede'] . " (" . $detallesCita['direccion'] . ", " . $detallesCita['ciudad'] . ")"
        ];

        // 3. Llamar a la función de envío de correo
        $email_sent = send_appointment_email(
            $detallesCita['correo_paciente'], 
            $paciente_nombre_completo, 
            $datos_para_email,
            'confirmacion'
        );
        
        $mensaje_correo = $email_sent ? " Se ha enviado una confirmación a su correo." : " (ADVERTENCIA: Falló el envío del correo de confirmación. Revise la configuración SMTP).";
    }

    http_response_code(200); 
    echo json_encode(array("message" => "Cita agendada correctamente."));

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    http_response_code(503); 
    echo json_encode(array("message" => "No se pudo agendar la cita. Error: " . $e->getMessage()));
}