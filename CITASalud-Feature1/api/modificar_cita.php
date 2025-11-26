<?php
// api/modificar_cita.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$startTime = microtime(true);

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Cita.php';
include_once __DIR__ . '/../config/send-email.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    http_response_code(503);
    echo json_encode(["message" => "Error de conexión a la base de datos."]);
    exit();
}

$data = json_decode(file_get_contents("php://input"));

if (
    empty($data->id_cita) ||
    empty($data->id_paciente) ||
    empty($data->id_horario_original) ||
    empty($data->id_nuevo_horario) ||
    empty($data->id_nueva_sede) ||
    empty($data->id_nuevo_profesional) ||
    empty($data->id_especialidad)
) {
    http_response_code(400);
    echo json_encode(["message" => "Datos incompletos para la modificación."]);
    exit();
}

$cita = new Cita($db);
$cita->id_cita = $data->id_cita;
$cita->id_paciente = $data->id_paciente;
$cita->id_horario_original = $data->id_horario_original;
$cita->id_nuevo_horario = $data->id_nuevo_horario;
$cita->id_nueva_sede = $data->id_nueva_sede;
$cita->id_nuevo_profesional = $data->id_nuevo_profesional;
$cita->id_especialidad = $data->id_especialidad;


try {
    $LIMITE_HORAS = 48;
    $validacion = $cita->validateModificationTime($cita->id_cita, $cita->id_paciente, $LIMITE_HORAS);

    if (!$validacion['success']) {
        http_response_code(403);
        echo json_encode(["message" => $validacion['message']]);
        exit();
    }



    $success = $cita->modificarCita(
        $cita->id_cita,
        $cita->id_paciente,
        $cita->id_horario_original,
        $cita->id_nuevo_horario
    );

    if ($success !== true) {
        http_response_code(500);
        echo json_encode(["message" => $success['error'] ?? "Error desconocido al modificar la cita."]);
        exit();
    }




    // Obtener detalles para el correo
    $detallesCorreo = $cita->getDetailsForModificationEmail();
    $email_sent = false;

    error_log("Detalles para correo: " . print_r($detallesCorreo, true));

    if ($detallesCorreo) {
        $paciente_nombre_completo = $detallesCorreo['nombre_paciente'] . " " . $detallesCorreo['apellido_paciente'];
        $datos_para_email = [
            'especialidad' => $detallesCorreo['nombre_especialidad'],
            'fecha_original' => date('d/m/Y', strtotime($detallesCorreo['fecha_original'])),
            'hora_original' => date('h:i A', strtotime($detallesCorreo['hora_original'])),
            'profesional_original' => $detallesCorreo['original']['nombre_profesional_original'] . ' ' . $detallesCorreo['original']['apellido_profesional_original'],
            'sede_original' => $detallesCorreo['original']['nombre_sede_original'],
            'direccion_sede_original' => $detallesCorreo['original']['direccion_sede_original'],
            'fecha_nueva' => date('d/m/Y', strtotime($detallesCorreo['fecha_nueva'])),
            'hora_nueva' => date('h:i A', strtotime($detallesCorreo['hora_nueva'])),
            'profesional_nuevo' => $detallesCorreo['nuevo']['nombre_profesional'] . ' ' . $detallesCorreo['nuevo']['apellido_profesional'],
            'sede_nueva' => $detallesCorreo['nuevo']['nombre_sede'],
            'direccion_sede_nueva' => $detallesCorreo['nuevo']['direccion_sede'],
            'fecha_modificacion' => date('d/m/Y H:i')
        ];

        $email_sent = send_modification_email(
            $detallesCorreo['correo_paciente'],
            $paciente_nombre_completo,
            $datos_para_email
        );
    }

    $endTime = microtime(true);
    $processingTime = round($endTime - $startTime, 3);

    http_response_code(200);
    echo json_encode([
        "message" => "Cita modificada correctamente. Se ha enviado la confirmación por email.",
        "email_sent" => $email_sent,
        "processing_time_s" => $processingTime,
        "nueva_fecha" => $detallesCorreo['fecha_nueva'],
        "nueva_hora" => $detallesCorreo['hora_nueva'],
        "email" => $detallesCorreo['correo_paciente'],
        'especialidad' => $detallesCorreo['nombre_especialidad']
    ]);


} catch (PDOException $e) {
    http_response_code(500);
    error_log("Error al modificar cita (API): " . $e->getMessage());
    echo json_encode(["message" => "Error de base de datos al intentar modificar. Detalles: " . $e->getMessage()]);
} catch (Exception $e) {
    http_response_code(500);
    error_log("Error interno al modificar cita: " . $e->getMessage());
    echo json_encode(["message" => "Error interno del servidor: " . $e->getMessage()]);
}
?>

