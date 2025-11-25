<?php
// api/validar_modificacion.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Max-Age: 3600");

include_once '../config/db.php';

$database = new Database();
$db = $database->getConnection();

$id_cita = isset($_GET['id_cita']) ? (int)$_GET['id_cita'] : 0;

if ($id_cita <= 0) {
    http_response_code(400); 
    echo json_encode(array("success" => false, "message" => "ID de cita no proporcionado o inválido."));
    exit();
}

$query = "
    SELECT hp.fecha, hp.hora, c.veces_modificada
    FROM citas c
    JOIN horarios_profesionales hp ON c.id_horario = hp.id_horario
    WHERE c.id_cita = ?
    LIMIT 1
";

try {
    $stmt = $db->prepare($query);
    $stmt->bindParam(1, $id_cita, PDO::PARAM_INT);
    $stmt->execute();
    $cita = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$cita) {
        http_response_code(404);
        echo json_encode(array("success" => false, "message" => "Cita no encontrada."));
        exit();
    }

    // 1. Regla: Solo se permite una modificación
    if ($cita['veces_modificada'] >= 1) {
        http_response_code(403);
        echo json_encode(["success" => false, "message" => "Esta cita ya ha sido modificada una vez y no se permite una nueva modificación."]);
        exit();
    }

    // 2. Regla: La fecha ya pasó
    $fecha_hora_cita = $cita['fecha'] . ' ' . $cita['hora'];
    $timestamp_cita = strtotime($fecha_hora_cita);
    $timestamp_ahora = time();

    if ($timestamp_ahora > $timestamp_cita) {
        http_response_code(403); 
        echo json_encode(array("success" => false, "message" => "La cita no se puede modificar porque la fecha ya pasó."));
        exit();
    }

    // 3. Regla: Al menos 48 horas de anticipación
    $timestamp_limite = $timestamp_cita - (48 * 3600);
    if ($timestamp_ahora > $timestamp_limite) {
        http_response_code(403); 
        echo json_encode(array("success" => false, "message" => "No es posible modificar esta cita. Debe hacerlo con al menos 48 horas de antelación."));
        exit();
    }

    // Reglas cumplidas
    http_response_code(200);
    echo json_encode(array("success" => true, "message" => "La cita puede ser modificada."));

} catch (Exception $e) {
    http_response_code(500); 
    echo json_encode(array("success" => false, "message" => "Error interno del servidor: " . $e->getMessage()));
}
?>
