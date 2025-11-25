<?php
// api/count_cancelaciones.php
// Objetivo: Contar las cancelaciones del paciente en el mes actual para mostrar el límite restante (HU-07).

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Cita.php'; 

if (!isset($_GET['id_paciente'])) {
    http_response_code(400); 
    echo json_encode(array("message" => "Falta el parámetro id_paciente."));
    exit();
}

$id_paciente = $_GET['id_paciente'];

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    http_response_code(503); 
    echo json_encode(array("message" => "Error de conexión a la base de datos."));
    exit();
}

$cita = new Cita($db);

try {
    // Obtenemos el total de cancelaciones que ya tiene el paciente este mes
    $cancelaciones = $cita->countCancellationsThisMonth($id_paciente);
    $LIMITE = 3; // Límite establecido en la HU-07
    $restantes = max(0, $LIMITE - $cancelaciones);

    http_response_code(200);
    echo json_encode(array(
        "total_canceladas" => $cancelaciones,
        "limite" => $LIMITE,
        "restantes" => $restantes
    ));
} catch (PDOException $e) {
    http_response_code(500); 
    error_log("Error al contar cancelaciones: " . $e->getMessage());
    echo json_encode(array("message" => "Error al contar cancelaciones."));
}
?>