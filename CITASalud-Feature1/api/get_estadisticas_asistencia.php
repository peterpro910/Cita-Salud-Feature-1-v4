<?php
// api/get_estadisticas_asistencia.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Dependencias
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Cita.php';

// 1. Obtener y validar el ID del paciente
$id_paciente = isset($_GET['id_paciente']) ? (int)$_GET['id_paciente'] : null;

if (empty($id_paciente)) {
    http_response_code(401); 
    echo json_encode(["message" => "Acceso no autorizado o ID de paciente faltante. Solo el paciente autenticado puede ver sus propias estadísticas (Criterio de Aceptación)."]);
    exit();
}

// 2. Inicialización
$database = new Database();
$db = $database->getConnection();
$cita = new Cita($db);

// 🔑 CLAVE: Obtener el parámetro 'mes' de la URL (será null si no se proporciona o es '0')
$mes_filtro = isset($_GET['mes']) ? $_GET['mes'] : null;

try {
    // A. Obtener Totales y Porcentaje (AHORA FILTRADOS POR MES)
    $totales = $cita->getTotalesAsistencia($id_paciente, $mes_filtro); // 🚨 MODIFICADO: Se pasa $mes_filtro
    
    $total_asistidas = (int)$totales['total_asistidas'];
    $total_no_asistidas = (int)$totales['total_no_asistidas'];
    $total_validas = $total_asistidas + $total_no_asistidas;
    
    $porcentaje_cumplimiento = 0;
    if ($total_validas > 0) {
        // Cálculo del Porcentaje de cumplimiento (Criterio de Aceptación)
        $porcentaje_cumplimiento = round(($total_asistidas / $total_validas) * 100, 1);
    }
    
    // B. Obtener Historial Mensual para el Gráfico de Línea
    // 🔑 CAMBIO CLAVE: Pasar el filtro de mes a la función
    $stmt_historial = $cita->getHistorialMensual($id_paciente, $mes_filtro);
    $historial_mensual = $stmt_historial->fetchAll(PDO::FETCH_ASSOC);

    // C. Armar la respuesta JSON final
    $respuesta = [
        "resumen" => [
            "total_asistidas" => $total_asistidas,
            "total_no_asistidas" => $total_no_asistidas,
            "porcentaje_cumplimiento" => $porcentaje_cumplimiento 
        ],
        "graficos" => [
            // Datos para Gráfico Circular y de Barras (Totales filtrados)
            "datos_totales" => [
                ["etiqueta" => "Asistidas", "valor" => $total_asistidas],
                ["etiqueta" => "No Asistidas", "valor" => $total_no_asistidas]
            ],
            // Datos para Gráfico de Línea (Evolución filtrada)
            "historial_mensual" => $historial_mensual
        ]
    ];
    
    http_response_code(200);
    echo json_encode($respuesta);

} catch (PDOException $e) {
    http_response_code(500);
    error_log("Error de BD al obtener estadísticas: " . $e->getMessage());
    echo json_encode(["message" => "Error interno del servidor al consultar estadísticas."]);
}
?>