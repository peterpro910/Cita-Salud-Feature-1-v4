<?php
// api/get_notifications.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Dependencias
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Cita.php';

// 1. Obtener y validar el ID del paciente (debe provenir de la sesión en un entorno real)
$id_paciente = isset($_GET['id_paciente']) ? (int)$_GET['id_paciente'] : null;

if (empty($id_paciente)) {
    http_response_code(401); 
    echo json_encode(["message" => "ID de paciente faltante."]);
    exit();
}

// 2. Inicialización
$database = new Database();
$db = $database->getConnection();
$cita = new Cita($db);

try {
    // A. Obtener las citas próximas usando el nuevo método
    $stmt_citas = $cita->getUpcomingAppointmentNotifications($id_paciente);
    $citas = $stmt_citas->fetchAll(PDO::FETCH_ASSOC);

    if (count($citas) > 0) {
        http_response_code(200);
        echo json_encode([
            "success" => true,
            "count" => count($citas),
            "data" => $citas
        ]);
    } else {
        http_response_code(200);
        echo json_encode([
            "success" => true,
            "count" => 0,
            "data" => [],
            "message" => "No hay citas próximas en las próximas 24 horas."
        ]);
    }

} catch (PDOException $e) {
    http_response_code(500);
    error_log("Error de BD al obtener notificaciones: " . $e->getMessage());
    echo json_encode(["success" => false, "message" => "Error interno del servidor al consultar notificaciones."]);
}
?>