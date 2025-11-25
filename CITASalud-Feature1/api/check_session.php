<?php
// api/check_session.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");
require_once '../config/db.php';
require_once '../models/Paciente.php';

session_start();

$response = ["is_valid" => false];

if (isset($_SESSION['paciente_documento'])) {
    $database = new Database();
    $db = $database->getConnection();
    
    if ($db) {
        $paciente_model = new Paciente($db);
        $paciente = $paciente_model->findByDocumento($_SESSION['paciente_documento']);
        
        // Verifica si el ID de sesión del navegador coincide con el ID activo en la DB.
        if ($paciente && $paciente->session_id_activa === session_id()) {
            $response["is_valid"] = true;
        } else {
            // Si el ID es diferente, limpiar la sesión de PHP (por si acaso).
            session_unset();
            session_destroy();
        }
    }
}

http_response_code(200);
echo json_encode($response);
?>