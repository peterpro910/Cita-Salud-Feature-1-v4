<?php
// Configuración de seguridad y headers
ob_start();
ini_set('display_errors', 0); // Oculta errores al público
ini_set('display_startup_errors', 0);
error_reporting(E_ALL);

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Incluir la clase de base de datos
include_once '../config/db.php';

$database = new Database();
$db = $database->getConnection();

// 1. Obtener id_paciente de la URL
// Nota: En una app real, el ID se obtendría del token de sesión (JWT)
if (!isset($_GET['id_paciente']) || empty($_GET['id_paciente'])) {
    http_response_code(400); 
    ob_end_clean();
    echo json_encode(array("message" => "ID de paciente es requerido."));
    die();
}

$id_paciente = intval($_GET['id_paciente']);

try {
    // 2. Consulta SQL para obtener todos los detalles de la cita
    $query = "
        SELECT 
            c.id_cita,
            c.id_estado,
            c.veces_modificada,
            hp.fecha, 
            hp.hora,
            hp.id_horario AS id_horario_original,
            ec.nombre_estado,
            e.nombre_especialidad,
            pr.nombre AS nombre_profesional, 
            pr.apellido AS apellido_profesional,
            s.nombre_sede, 
            s.direccion AS direccion_sede,
            ci.nombre_ciudad,
            c.id_especialidad,         
            c.id_sede,                 
            c.id_profesional, 
            
            -- Historial de Cancelación
            hc.fecha_cancelacion,
            hc.hora_cancelacion,
            mc.nombre_motivo AS motivo_cancelacion,
            
            -- Historial de Modificación (se toma la fecha/hora anterior de la ÚLTIMA modificación)
            (SELECT hm.fecha_anterior 
             FROM historial_modificaciones hm 
             WHERE hm.id_cita = c.id_cita 
             ORDER BY hm.fecha_modificacion DESC, hm.hora_modificacion DESC 
             LIMIT 1
            ) AS fecha_original,
            (SELECT hm.hora_anterior 
             FROM historial_modificaciones hm 
             WHERE hm.id_cita = c.id_cita 
             ORDER BY hm.fecha_modificacion DESC, hm.hora_modificacion DESC 
             LIMIT 1
            ) AS hora_original
            
        FROM 
            citas c
        JOIN 
            horarios_profesionales hp ON c.id_horario = hp.id_horario
        JOIN 
            estados_cita ec ON c.id_estado = ec.id_estado
        JOIN 
            especialidades e ON c.id_especialidad = e.id_especialidad
        JOIN 
            profesionales pr ON c.id_profesional = pr.id_profesional
        JOIN 
            sedes s ON c.id_sede = s.id_sede
        JOIN 
            ciudades ci ON s.id_ciudad = ci.id_ciudad
        LEFT JOIN
            historial_cancelaciones hc ON c.id_cita = hc.id_cita
        LEFT JOIN
            motivos_cancelacion mc ON hc.id_motivo = mc.id_motivo

        WHERE 
            c.id_paciente = :id_paciente
        ORDER BY 
            hp.fecha DESC, hp.hora DESC;
    ";

    $stmt = $db->prepare($query);
    $stmt->bindParam(':id_paciente', $id_paciente, PDO::PARAM_INT);
    $stmt->execute();
    
    $citas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 3. Respuesta JSON
    http_response_code(200);
    $response = $citas;

} catch (PDOException $e) {
    http_response_code(500); 
    // error_log("Error de DB en get_citas: " . $e->getMessage()); // Para debug en el servidor
    $response = array("message" => "Error de base de datos: " . $e->getMessage());
} catch (Exception $e) {
    http_response_code(500); 
    $response = array("message" => "Error del servidor: " . $e->getMessage());
}

ob_end_clean();
echo json_encode($response);
?>