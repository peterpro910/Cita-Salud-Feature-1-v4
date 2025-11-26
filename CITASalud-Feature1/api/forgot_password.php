<?php
// api/forgot_password.php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
require_once './../config/db.php';
require_once './../models/Paciente.php';
require_once './../config/send-email.php';

$database = new Database();
$db = $database->getConnection();
$paciente_model = new Paciente($db);
$data = json_decode(file_get_contents("php://input"));

$documento = $data->documento ?? '';

// Respuesta de seguridad (evita dar pistas sobre la existencia del usuario)
$respuesta_segura = ["success" => true, "message" => "Si el documento existe en nuestros registros, se ha enviado un correo con las instrucciones de restablecimiento."];

if (empty($documento)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Documento de identidad es requerido."]);
    exit();
}

$paciente = $paciente_model->findByDocumento($documento);

if ($paciente) {
    // Generar un token único y seguro
    $token = bin2hex(random_bytes(32)); 
    
    if ($paciente->saveResetToken($token)) {
        // Enlace de restablecimiento. NOTA: Ajustar esta URL a tu dominio real.
        $reset_link = "http://localhost/CITASalud-Feature1/html/reset_password.html?token={$token}&doc={$documento}"; 

        try {
            $mail = get_mailer_instance();
            $mail->addAddress($paciente->correo, $paciente->nombre . ' ' . $paciente->apellido);
            
            $mail->isHTML(true);
            $mail->Subject = 'Restablecimiento de Contraseña - CITASalud';
            $mail->Body    = "
                <h1>Restablecimiento de Contraseña</h1>
                <p>Hola <strong>{$paciente->nombre}</strong>,</p>
                <p>Recibimos una solicitud para restablecer tu contraseña. Haz clic en el siguiente enlace:</p>
                <p><a href='{$reset_link}' style='color: #007bff;'>Crear Nueva Contraseña</a></p>
                <p><strong>Advertencia:</strong> El enlace expira en 10 minutos.</p>
                <p>Si no solicitaste este cambio, ignora este correo.</p>";

            $mail->send();
            
            $paciente->resetIntentos(); // Reiniciar contador de intentos por seguridad

        } catch (Exception $e) {
            error_log("Error al enviar correo de restablecimiento: " . $e->getMessage());
            // No se reporta al usuario final el error del servidor de correo
        }
    }
}

http_response_code(200); 
echo json_encode($respuesta_segura);
?>