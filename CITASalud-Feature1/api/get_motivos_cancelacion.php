<?php
// api/get_motivos_cancelacion.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");

require_once __DIR__ . '/../config/db.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    http_response_code(503);
    echo json_encode(array("message" => "Error de conexión a la base de datos."));
    exit();
}

try {
    $query = "SELECT id_motivo AS id, nombre_motivo AS nombre FROM motivos_cancelacion ORDER BY nombre_motivo ASC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $motivos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    http_response_code(200);
    echo json_encode($motivos);

} catch (PDOException $e) {
    http_response_code(500);
    error_log("Error al obtener motivos de cancelación: " . $e->getMessage());
    echo json_encode(array("message" => "Error interno al obtener los motivos."));
}
?>