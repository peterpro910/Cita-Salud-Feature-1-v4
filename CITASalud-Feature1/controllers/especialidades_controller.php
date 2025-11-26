<?php
// controllers/especialidades_controller.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Especialidad.php';

$database = new Database();
$db = $database->getConnection();

$especialidad = new Especialidad($db);

$stmt = $especialidad->getEspecialidadesDisponibles();
$num = $stmt->rowCount();

if ($num > 0) {
    $especialidades_arr = array();
    
    // Aquí está el cambio clave: recorre los resultados y crea un array nuevo con los datos
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $especialidad_item = array(
            "id_especialidad" => $row['id_especialidad'],
            "nombre_especialidad" => $row['nombre_especialidad'],
            "horarios_disponibles" => $row['horarios_disponibles']
        );
        array_push($especialidades_arr, $especialidad_item);
    }
    
    http_response_code(200);
    echo json_encode($especialidades_arr);
} else {
    http_response_code(404);
    echo json_encode(array("message" => "No se encontraron especialidades disponibles."));
}
?>