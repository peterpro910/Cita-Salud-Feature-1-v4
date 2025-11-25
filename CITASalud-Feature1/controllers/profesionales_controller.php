<?php
// controllers/profesionales_controller.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Profesional.php';

$database = new Database();
$db = $database->getConnection();
$profesional = new Profesional($db);

$especialidad_id = isset($_GET['especialidad_id']) ? $_GET['especialidad_id'] : die();
$sede_id = isset($_GET['sede_id']) ? $_GET['sede_id'] : die();

// El nombre de la función en el modelo que creamos
$stmt = $profesional->getProfesionalesPorEspecialidadYSede($especialidad_id, $sede_id);
$num = $stmt->rowCount();

if ($num > 0) {
    $profesionales_arr = array();
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        // Corrección clave: Usa las claves del array asociativo $row
        $profesional_item = array(
            "id" => $row['id_profesional'],
            "nombre_completo" => htmlspecialchars_decode($row['nombre']) . " " . htmlspecialchars_decode($row['apellido']),
            "titulo_profesional" => htmlspecialchars_decode($row['titulo_profesional']),
            "anos_experiencia" => htmlspecialchars_decode($row['anos_experiencia']),
            "horarios_disponibles" => (int)$row['horarios_disponibles'] // Aseguramos que sea un entero
        );
        array_push($profesionales_arr, $profesional_item);
    }
    http_response_code(200);
    echo json_encode($profesionales_arr);
} else {
    http_response_code(404);
    echo json_encode(array("message" => "No se encontraron profesionales para esta sede y especialidad."));
}
?>