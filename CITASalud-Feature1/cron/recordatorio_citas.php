<?php
// /recordatorio_citas.php (Ejecutado por el Cron Job)

error_reporting(E_ALL);
ini_set('display_errors', 1);

// Incluir la clase de base de datos y la función de correo
include_once(__DIR__ . '/../config/db.php');
require_once(__DIR__ . '/../config/send-email.php'); // Tu script de envío de correo

// 1. Conexión a la base de datos
$database = new Database();
$db = $database->getConnection();

// --- Lógica de Recordatorio ---
try {
    // Definimos la fecha de la cita que buscamos 
    $fecha_recordatorio = date("Y-m-d", strtotime("+1 day"));
    
    // 2. Consulta para obtener citas (incluye detalles del paciente y profesional)
    
    $query = "
        SELECT 
            c.id_cita, 
            p.correo AS paciente_correo, 
            p.nombre AS paciente_nombre, 
            pr.nombre AS profesional_nombre,
            s.nombre_sede AS nombre_sede,
            e.nombre_especialidad AS especialidad_nombre,
            DATE_FORMAT(hp.fecha, '%d/%m/%Y') AS fecha_cita,
            TIME_FORMAT(hp.hora, '%h:%i %p') AS hora_cita
        FROM citas c
        INNER JOIN pacientes p ON c.id_paciente = p.id_paciente
        INNER JOIN profesionales pr ON c.id_profesional = pr.id_profesional
        INNER JOIN sedes s ON c.id_sede = s.id_sede
        INNER JOIN especialidades e ON c.id_especialidad = e.id_especialidad
        INNER JOIN horarios_profesionales hp ON c.id_horario = hp.id_horario
        WHERE hp.fecha = :fecha_recordatorio
        AND c.id_estado = 1
        AND c.recordatorio_enviado = 0 
    ";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':fecha_recordatorio', $fecha_recordatorio);
    $stmt->execute();
    $citas_pendientes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "--- Buscando citas para: {$fecha_recordatorio} ---\n";
    echo "Citas encontradas: " . count($citas_pendientes) . "\n\n";

    $citas_exitosas = 0;
    
    // 3. Iterar y enviar el correo (Llamada a la función ya existente)
    foreach ($citas_pendientes as $cita) {
        $detalles_cita = [
            'profesional' => $cita['profesional_nombre'],
            'especialidad' => $cita['especialidad_nombre'],
            'sede' => $cita['nombre_sede'],
            'fecha' => $cita['fecha_cita'],
            'hora' => $cita['hora_cita']
        ];

        $envio_correo = send_appointment_email(
            $cita['paciente_correo'],
            $cita['paciente_nombre'], 
            $detalles_cita,
            'recordatorio'
        );

        if ($envio_correo === true) {
            // Tarea 110: Actualizar el estado del recordatorio
            $queryUpdate = "UPDATE citas SET recordatorio_enviado = 1 WHERE id_cita = :id_cita";
            $stmtUpdate = $db->prepare($queryUpdate);
            $stmtUpdate->bindParam(':id_cita', $cita['id_cita']);
            $stmtUpdate->execute();
            
            $citas_exitosas++;
            echo "Enviado y actualizado: Cita #" . $cita['id_cita'] . " a " . $cita['paciente_correo'] . "\n";

        } else {
            echo "Falló el envío: Cita #" . $cita['id_cita'] . ". Error: " . $envio_correo . "\n";
        }
    }
    
    echo "\n--- Proceso Finalizado. Correos enviados: {$citas_exitosas} ---\n";

} catch (PDOException $e) {
    echo "Error de Base de Datos: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "Error General: " . $e->getMessage() . "\n";
}
?>