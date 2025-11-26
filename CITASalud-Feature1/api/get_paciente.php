<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Incluir la clase de la base de datos
include_once '../config/db.php';

// Crear una instancia de la base de datos y obtener la conexión
$database = new Database();
$db = $database->getConnection();

// Obtener el numero_documento de la solicitud GET
$numero_documento = isset($_GET['numero_documento']) ? trim($_GET['numero_documento']) : '';

// Si no se proporcionó un ID, salir con un error
if (empty($numero_documento)) {
    http_response_code(400);
    echo json_encode(array("message" => "Número de documento no proporcionado."));
    die();
}

// Consulta SQL para seleccionar los datos del paciente
// Se busca por numero_documento pero se devuelve el id_paciente
$query = "SELECT id_paciente, nombre, apellido, correo FROM pacientes WHERE numero_documento = ? LIMIT 0,1";

// Preparar la consulta
$stmt = $db->prepare($query);

// Asignar el numero_documento al placeholder
$stmt->bindParam(1, $numero_documento);

// Ejecutar la consulta
$stmt->execute();

// Contar el número de filas encontradas
$num = $stmt->rowCount();

// Si se encontró al paciente
if ($num > 0) {
    // Obtener la fila de datos
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Devolver los datos en formato JSON
    http_response_code(200);
    echo json_encode($row);
} else {
    // Si no se encontró al paciente
    http_response_code(404);
    echo json_encode(array("message" => "Paciente no encontrado."));
}
?>