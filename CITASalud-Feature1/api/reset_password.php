<?php
// api/reset_password.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
require_once './../config/db.php';
require_once './../models/Paciente.php';

$database = new Database();
$db = $database->getConnection();
$paciente_model = new Paciente($db);
$data = json_decode(file_get_contents("php://input"));

$documento = $data->documento ?? '';
$token = $data->token ?? '';
$new_password = $data->new_password ?? '';
$confirm_password = $data->confirm_password ?? '';

if (empty($documento) || empty($token) || empty($new_password) || empty($confirm_password)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Todos los campos son requeridos."]);
    exit();
}

if ($new_password !== $confirm_password) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "La nueva contraseña y su confirmación no coinciden."]);
    exit();
}

// 1. Validación de complejidad de contraseña (Criterio de Aceptación)
if (strlen($new_password) < 7 || strlen($new_password) > 16) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "La contraseña debe tener entre 7 y 16 caracteres."]);
    exit();
}
if (!preg_match('/[A-Z]/', $new_password)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "La contraseña debe contener al menos una letra mayúscula."]);
    exit();
}
if (!preg_match('/[a-z]/', $new_password)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "La contraseña debe contener al menos una letra minúscula."]);
    exit();
}
if (!preg_match('/[0-9]/', $new_password)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "La contraseña debe contener al menos un número."]);
    exit();
}
if (!preg_match('/[!@#$%^&*()_+={}\[\]|\\:;"\'<>,.?\/~`]/', $new_password)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "La contraseña debe contener al menos un carácter especial."]);
    exit();
}

// 2. Verificar Token y Paciente
$paciente = $paciente_model->findByDocumento($documento);

if (!$paciente || $paciente->reset_token !== $token) {
    http_response_code(401);
    echo json_encode(["success" => false, "message" => "Token inválido o usuario no encontrado."]);
    exit();
}

// 3. Verificar expiración (10 minutos)
if (strtotime($paciente->token_expira) < time()) {
    http_response_code(401);
    echo json_encode(["success" => false, "message" => "El enlace de restablecimiento ha expirado. Por favor, solicite uno nuevo."]);
    exit();
}

// 4. Actualizar contraseña
if ($paciente->updatePassword($new_password)) {
    http_response_code(200);
    echo json_encode(["success" => true, "message" => "Contraseña restablecida exitosamente. Ahora puede iniciar sesión."]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Error al actualizar la contraseña en la base de datos."]);
}
?>