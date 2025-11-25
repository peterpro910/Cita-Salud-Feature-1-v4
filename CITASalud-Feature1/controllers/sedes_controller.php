<?php
// controllers/sedes_controller.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");

if (!isset($_GET['especialidad_id'])) {
    http_response_code(400); // Bad Request
    echo json_encode(array("message" => "Falta el ID de la especialidad."));
    exit();
}

// Incluye la configuración y el modelo
include_once __DIR__ . '/../config/db.php';
include_once __DIR__ . '/../models/Sede.php';

// Conecta a la base de datos
$database = new Database();
$db = $database->getConnection();

// Instancia el objeto Sede
$sede = new Sede($db);

// Obtiene el ID de la especialidad desde el GET
$especialidad_id = isset($_GET['especialidad_id']) ? $_GET['especialidad_id'] : die();

// Obtiene las sedes para esa especialidad
$stmt = $sede->getSedesPorEspecialidad($especialidad_id);
$num = $stmt->rowCount();

if ($num > 0) {
    $sedes_arr = array();
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $sede_item = array(
            "id" => $row['id_sede'],
            "nombre" => $row['nombre_sede'],
            "direccion" => $row['direccion'],
            "ciudad" => $row['nombre_ciudad']
        );
        array_push($sedes_arr, $sede_item);
    }
    
    // Envía la respuesta en formato JSON
    http_response_code(200);
    echo json_encode($sedes_arr);
} else {
    // Si no hay sedes para la especialidad, envía un mensaje
    http_response_code(404);
    echo json_encode(array("message" => "No se encontraron sedes para esta especialidad."));
}
?>