<?php
// api/login.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
require_once '../config/db.php';
require_once '../models/Paciente.php';

// Iniciar sesión (para gestión de sesión única y variables de sesión)
session_start();

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Error interno del servidor (DB)."]);
    exit();
}

$paciente_model = new Paciente($db);
$data = json_decode(file_get_contents("php://input"));

$documento = $data->documento ?? '';
$password = $data->password ?? '';
$max_intentos = 5;

// 1. Buscar paciente
$paciente = $paciente_model->findByDocumento($documento);

if (!$paciente) {
    // Retardo para prevenir enumeración de usuarios
    sleep(1); 
    http_response_code(401);
    echo json_encode(["success" => false, "message" => "Credenciales inválidas, por favor intente de nuevo."]);
    exit();
}

// 2. Verificar bloqueo
$tiempo_bloqueo = strtotime($paciente->bloqueo_hasta);
if ($tiempo_bloqueo && $tiempo_bloqueo > time()) {
    $tiempo_restante_min = ceil(($tiempo_bloqueo - time()) / 60);
    http_response_code(403);
    echo json_encode(["success" => false, "message" => "Ha excedido los 5 intentos. El inicio de sesión está bloqueado temporalmente por {$tiempo_restante_min} minutos."]);
    exit();
}

// 3. Intentar Login
if ($paciente->login($password)) {
    // Éxito en la autenticación
    
    // Verificar sesión activa única
    if ($paciente->hasActiveSession(session_id())) {
        http_response_code(200); // 200 porque la autenticación es OK, pero requiere acción del cliente (alerta)
        echo json_encode([
            "success" => false, // Login no completado hasta que se decida
            "session_active" => true,
            "documento" => $documento,
            "password" => $password,
            "message" => "Ya tiene una sesión activa en otro dispositivo. ¿Desea cerrar la sesión anterior e iniciar una nueva?"
        ]);
        exit();
    }
    
    // Inicio de sesión exitoso y creación/renovación de la sesión
    session_regenerate_id(true); 
    $_SESSION['paciente_documento'] = $paciente->documento;
    $_SESSION['paciente_nombre_completo'] = $paciente->nombre . ' ' . $paciente->apellido;
    $_SESSION['last_activity'] = time(); 
    $_SESSION['login_time'] = time(); 
    $_SESSION['user_id_rol'] = $paciente->id_rol;

    // Guardar ID de la sesión actual en la DB
    $paciente->setActiveSession(session_id());

    http_response_code(200);
    echo json_encode([
        "success" => true,
        "message" => "Bienvenido/a CITASalud {$paciente->nombre} {$paciente->apellido}, su inicio de sesión ha sido exitoso.",
        // Datos del paciente para guardar globalmente en el cliente (sessionStorage)
        "user_id_rol" => $paciente->id_rol,
        "id_paciente" => $paciente->id_paciente,
        "nombre_paciente" => $paciente->nombre . ' ' . $paciente->apellido
    ]);

} else {
    // Credenciales inválidas
    $intentos_restantes = $max_intentos - $paciente->intentos_fallidos;
    
    // Verificar si el intento fallido resultó en un bloqueo
    if (strtotime($paciente->bloqueo_hasta) > time()) {
        http_response_code(403);
        echo json_encode(["success" => false, "message" => "Ha excedido los 5 intentos. El inicio de sesión está bloqueado temporalmente por 30 minutos."]);
        exit();
    }

    $mensaje_intentos = ($intentos_restantes > 0) 
        ? "Le quedan {$intentos_restantes} intentos antes del bloqueo temporal."
        : "";

    http_response_code(401);
    echo json_encode([
        "success" => false,
        "message" => "Credenciales inválidas, por favor intente de nuevo. {$mensaje_intentos}"
    ]);
}
?>