<?php
// controllers/horarios_controller.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Horario.php';

$database = new Database();
$db = $database->getConnection();
$horario = new Horario($db);

if (!isset($_GET['profesional_id']) || !isset($_GET['id_paciente'])) {
    http_response_code(400); // Bad Request
    echo json_encode(array("message" => "Faltan los parámetros de profesional o paciente."));
    exit();
}

$profesional_id = $_GET['profesional_id'];
$paciente_id = $_GET['id_paciente'];

$stmt = $horario->getHorariosDisponiblesPorProfesional($profesional_id, $paciente_id);
$num = $stmt->rowCount();

if ($num > 0) {
    $horarios_arr = array();
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $horario_item = array(
            "id_horario" => $row['id_horario'],
            "fecha" => $row['fecha'],
            "hora" => $row['hora']
        );
        array_push($horarios_arr, $horario_item);
    }
    http_response_code(200);
    echo json_encode($horarios_arr);
} else {
    http_response_code(404); // Not Found
    echo json_encode(array("message" => "No se encontraron horarios disponibles para este profesional."));
}
?>