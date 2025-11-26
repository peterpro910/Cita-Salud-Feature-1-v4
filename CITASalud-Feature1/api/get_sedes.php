<?php
// api/get_sedes.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *"); // Permite solicitudes de cualquier origen


if (!isset($_GET['especialidad_id'])) {
    http_response_code(400); // Bad Request
    echo json_encode(array("message" => "Falta el ID de la especialidad."));
    exit();
}

require_once __DIR__ . '/../controllers/sedes_controller.php';
?>