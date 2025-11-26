<?php
// /api/get_especialidades_paciente.php
// Este script consulta las especialidades y el conteo de citas activas para un paciente.

// Configuración de seguridad y headers
ob_start();
ini_set('display_errors', 0); // Oculta errores al público
ini_set('display_startup_errors', 0);
error_reporting(E_ALL);

header('Content-Type: application/json; charset=UTF-8');
header("Access-Control-Allow-Origin: *"); 
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// ==========================================================
// ➡️ LÓGICA DE CONEXIÓN (Tomada de get_citas_paciente.php)
// ==========================================================
include_once '../config/db.php';

$database = new Database();
$db = $database->getConnection();
// La variable de conexión activa es $db
// ==========================================================


// 1. Obtener id_paciente de la URL
if (!isset($_GET['id_paciente']) || empty($_GET['id_paciente'])) {
    http_response_code(400); 
    ob_end_clean();
    echo json_encode(array("message" => "ID de paciente es requerido."));
    die();
}

$id_paciente = intval($_GET['id_paciente']);

if (!$db) {
    http_response_code(500);
    ob_end_clean();
    echo json_encode(["message" => "Error de conexión a la base de datos."]);
    die();
}

try {
    // 2. Consulta SQL para obtener especialidades y contarlas
    // Solo incluye citas Agendadas (1) y Modificadas (2)
    $query = "
        SELECT 
            c.id_especialidad, 
            e.nombre_especialidad, 
            COUNT(c.id_cita) AS total_citas
        FROM 
            citas c
        JOIN 
            especialidades e ON c.id_especialidad = e.id_especialidad
        WHERE 
            c.id_paciente = :id_paciente AND c.id_estado IN (1, 2)
        GROUP BY 
            c.id_especialidad, e.nombre_especialidad
        ORDER BY 
            e.nombre_especialidad ASC
    ";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id_paciente', $id_paciente, PDO::PARAM_INT);
    $stmt->execute();
    
    $especialidades = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 3. Devolver la respuesta JSON
    http_response_code(200);
    $response = ["especialidades" => $especialidades];

} catch (PDOException $e) {
    http_response_code(500);
    $response = array("message" => "Error de base de datos: " . $e->getMessage());
} catch (Exception $e) {
    http_response_code(500); 
    $response = array("message" => "Error del servidor: " . $e->getMessage());
}

ob_end_clean();
echo json_encode($response);
?>