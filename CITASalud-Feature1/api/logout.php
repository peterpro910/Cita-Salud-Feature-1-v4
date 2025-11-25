<?php
// api/logout.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
require_once '../config/db.php';
require_once '../models/Paciente.php';

// Iniciar sesión para acceder al ID actual
session_start();

if (isset($_SESSION['paciente_documento'])) {
    $database = new Database();
    $db = $database->getConnection();
    
    if ($db) {
        $paciente_model = new Paciente($db);
        $paciente = $paciente_model->findByDocumento($_SESSION['paciente_documento']);
        
        // Limpiar el registro activo en la base de datos si coincide con la sesión actual
        if ($paciente && $paciente->session_id_activa === session_id()) {
             // 🔑 Establecer el ID activo a NULL
            $paciente->clearActiveSession(); 
        }
    }

    // Limpiar variables de sesión y destruir la sesión de PHP
    session_unset();
    session_destroy();
}

http_response_code(200);
echo json_encode(["success" => true, "message" => "Sesión cerrada correctamente."]);
?>