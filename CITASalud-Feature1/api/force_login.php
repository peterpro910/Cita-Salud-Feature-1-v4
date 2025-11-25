<?php
// api/force_login.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
require_once '../config/db.php';
require_once '../models/Paciente.php';

session_start();

$database = new Database();
$db = $database->getConnection();
$paciente_model = new Paciente($db);
$data = json_decode(file_get_contents("php://input"));

$documento = $data->documento ?? '';
$password = $data->password ?? '';

if (empty($documento) || empty($password)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Datos incompletos."]);
    exit();
}

$paciente = $paciente_model->findByDocumento($documento);
// Usar SHA-256 para compatibilidad con la DB actual
$password_hash_check = hash('sha256', $password);

// Re-verificar credenciales (para asegurar que el request no fue alterado)
if (!$paciente || $password_hash_check !== $paciente->contrasena_hash) {
    http_response_code(401);
    echo json_encode(["success" => false, "message" => "Error de seguridad al forzar la sesión."]);
    exit();
}

// 1. Sobrescribir la sesión
session_regenerate_id(true); 
$_SESSION['paciente_documento'] = $paciente->documento;
$_SESSION['paciente_nombre_completo'] = $paciente->nombre . ' ' . $paciente->apellido;
$_SESSION['last_activity'] = time(); 
$_SESSION['login_time'] = time(); 
$_SESSION['user_id_rol'] = $paciente->id_rol;

// 2. Actualizar la sesión activa en la DB con el nuevo session_id
$paciente->setActiveSession(session_id());
$paciente->resetIntentos();

http_response_code(200);
echo json_encode([
    "success" => true,
    "message" => "Bienvenido/a CITASalud {$paciente->nombre} {$paciente->apellido}, la sesión anterior ha sido cerrada y has iniciado sesión exitosamente.",
    // Datos del paciente para guardar globalmente en el cliente (sessionStorage)
    "user_id_rol" => $paciente->id_rol,
    "id_paciente" => $paciente->id_paciente,
    "nombre_paciente" => $paciente->nombre . ' ' . $paciente->apellido
]);
?>