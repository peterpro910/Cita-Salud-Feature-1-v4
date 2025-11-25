<?php
// api/get_cita_detalles.php
// Objetivo: Obtener detalles completos de una cita, incluyendo los IDs originales.
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);



header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Cita.php'; 

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    http_response_code(503); 
    ob_end_clean(); // Limpiar buffer
    echo json_encode(array("message" => "Error de conexión a la base de datos."));
    exit();
}

// ***** INICIO DE CORRECCIÓN: Validar id_paciente *****
$id_cita = isset($_GET['id_cita']) ? intval($_GET['id_cita']) : 0;
$id_paciente = isset($_GET['id_paciente']) ? intval($_GET['id_paciente']) : 0;

if ($id_cita == 0 || $id_paciente == 0) {
    http_response_code(400); 
    ob_end_clean(); // Limpiar buffer
    // Este es el error que estabas viendo
    echo json_encode(array("message" => "ID de cita o ID de paciente no proporcionado o inválido.")); 
    exit();
}
// ***** FIN DE CORRECCIÓN *****

$cita = new Cita($db);

try {
    // Pasamos ambos IDs al método del modelo
    $detalles = $cita->getCitaDetailsForModification($id_cita, $id_paciente); 

    if ($detalles) {
        http_response_code(200);
        ob_end_clean(); // Limpiar buffer
        echo json_encode($detalles);
    } else {
        http_response_code(404);
        ob_end_clean(); // Limpiar buffer
        echo json_encode(array("message" => "Cita no encontrada o no pertenece al paciente."));
    }

} catch (PDOException $e) {
    http_response_code(500);
    ob_end_clean(); // Limpiar buffer
    error_log("Error en get_cita_detalles.php: " . $e->getMessage());
    echo json_encode(array("message" => "Error de base de datos al obtener detalles."));
}
?>