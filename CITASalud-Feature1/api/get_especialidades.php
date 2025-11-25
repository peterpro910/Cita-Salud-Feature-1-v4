<?php
// api/get_especialidades.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *"); // Permite solicitudes de cualquier origen

require_once __DIR__ . '/../controllers/especialidades_controller.php';
?>