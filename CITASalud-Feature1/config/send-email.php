<?php

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;
use PHPMailer\PHPMailer\SMTP;

// Ruta base a la carpeta PHPMailer
$ruta_base = __DIR__ . '/../PHPMailer/';

require $ruta_base . 'Exception.php';
require $ruta_base . 'PHPMailer.php';
require $ruta_base . 'SMTP.php';

// ======================================================
//  CONFIGURACIÓN BASE DEL SERVIDOR SMTP
// ======================================================
function get_mailer_instance() {
    $mail = new PHPMailer(true);

    try {
        $mail->isSMTP();
        $mail->SMTPDebug = 0; // Cambia a 2 si necesitas ver los logs detallados
        $mail->Debugoutput = 'error_log'; // manda los errores al log, no al HTML
        $mail->Host       = 'smtp.gmail.com';
        $mail->SMTPAuth   = true;
        $mail->Username   = 'notificaciones.citasalud@gmail.com'; 
        $mail->Password   = 'zefzgxgqtjmnoupk'; 
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port       = 587;

        // Opciones SSL para evitar errores de certificados en entornos locales
        $mail->SMTPOptions = array(
            'ssl' => array(
                'verify_peer' => false,
                'verify_peer_name' => false,
                'allow_self_signed' => true
            )
        );

        $mail->CharSet = 'UTF-8';
        $mail->setFrom('notificaciones.citasalud@gmail.com', 'Sistema Citas Médicas');
    } catch (Exception $e) {
        error_log("Fallo al inicializar PHPMailer: " . $e->getMessage());
        throw new Exception("Error al configurar el servicio de correo.");
    }

    return $mail;
}

// ======================================================
//   ENVÍO DE CORREO DE CONFIRMACIÓN DE CITA
// ======================================================
function send_appointment_email($paciente_correo, $paciente_nombre, $detalles_cita, $tipo_correo) {
    try {
        $mail = get_mailer_instance();
        $mail->addAddress($paciente_correo, $paciente_nombre);
        
        if ($tipo_correo === 'recordatorio') {
            $asunto = 'Recordatorio de Cita Médica para Mañana: ' . $detalles_cita['fecha'];
            $encabezado = '<h1>RECORDATORIO: Tu Cita es Mañana</h1>';
            $mensaje_adicional = '<p>Recuerda que tienes una cita programada para el día de mañana. Por favor, verifica los detalles a continuación:</p>';
            $alt_body_text = "Tu recordatorio de cita ha sido enviado: {$detalles_cita['profesional']} el {$detalles_cita['fecha']} a las {$detalles_cita['hora']}.";
        } else { // Confirmación (Usado al agendar cita)
            $asunto = 'Cita Confirmada: ' . $detalles_cita['fecha'];
            $encabezado = '<h1>¡Cita Agendada Exitosamente!</h1>';
            $mensaje_adicional = '<p>Hemos confirmado tu nueva cita. Aquí están todos los detalles importantes:</p>';
            $alt_body_text = "Tu cita ha sido confirmada con el profesional {$detalles_cita['profesional']} el {$detalles_cita['fecha']} a las {$detalles_cita['hora']}.";
        }
        // Contenido del mensaje
        $mail->isHTML(true);
        $mail->Subject = $asunto;
        $mail->Body = "
            {$encabezado}
            <p>Hola <strong>{$paciente_nombre}</strong>,</p>
            {$mensaje_adicional}
            <p>Detalles:</p>
            <ul>
                <li><strong>Profesional:</strong> {$detalles_cita['profesional']}</li>
                <li><strong>Especialidad:</strong> {$detalles_cita['especialidad']}</li>
                <li><strong>Fecha:</strong> {$detalles_cita['fecha']}</li>
                <li><strong>Hora:</strong> {$detalles_cita['hora']}</li>
                <li><strong>Sede:</strong> {$detalles_cita['sede']}</li>
            </ul>
            <p>Gracias por confiar en nosotros.</p>";
            $mail->AltBody = $alt_body_text;

        // Intentar enviar
        $mail->send();
        return true;

    } catch (Exception $e) {
        // No imprimir HTML: registrar en log y retornar falso
        error_log("Error al enviar correo: " . $e->getMessage());
        return false;
    }
}

// ======================================================
// ENVÍO DE CORREO DE CANCELACIÓN
// ======================================================
function send_cancellation_email($paciente_correo, $paciente_nombre, $detalles_cancelacion) {
    try {
        $mail = get_mailer_instance();
        $mail->addAddress($paciente_correo, $paciente_nombre);

        // Contenido del Correo (Adaptado para la cancelación)
        $mail->isHTML(true);
        $mail->Subject = 'Cita CANCELADA: ' . $detalles_cancelacion['fecha'];
        $mail->Body    = "
            <h1>¡Cita Cancelada Exitosamente!</h1>
            <p>Hola <strong>{$paciente_nombre}</strong>,</p>
            <p>Confirmamos la cancelación de tu cita con los siguientes detalles:</p>
            <hr>
            <ul>
                <li><strong>Especialidad:</strong> {$detalles_cancelacion['especialidad']}</li>
                <li><strong>Profesional:</strong> {$detalles_cancelacion['profesional']}</li>
                <li><strong>Fecha Original:</strong> {$detalles_cancelacion['fecha']}</li>
                <li><strong>Hora Original:</strong> {$detalles_cancelacion['hora']}</li>
                <li><strong>Motivo:</strong> {$detalles_cancelacion['motivo']}</li>
            </ul>
            <hr>
            <p style='color: #004a99;'><strong>NOTIFICACIÓN DE LÍMITE:</strong></p>
            <p>Te quedan <strong>{$detalles_cancelacion['cancelaciones_restantes']} cancelaciones</strong> disponibles este mes (Límite: {$detalles_cancelacion['limite_mensual']}).</p>
            
            <p>Si deseas reagendar, por favor utiliza nuestra plataforma. ¡Gracias!</p>";
        $mail->AltBody = "Tu cita ha sido cancelada...";

        $mail->send();
        return true;

    } catch (Exception $e) {
        error_log("Error al enviar correo de cancelación: " . $e->getMessage());
        return false;
    }
}

// ======================================================
//  ENVÍO DE CORREO DE MODIFICAÍON
// ======================================================
function render_template($template, $data) {
    foreach ($data as $key => $value) {
        $template = str_replace('{{' . $key . '}}', htmlspecialchars($value), $template);
    }
    return $template;
}

/**
 * Envía un correo de confirmación de modificación de cita.
 * * @param string $toEmail
 * @param string $toName
 * @param array $datos_cita Array con detalles de la cita original y nueva.
 * @return bool True si el correo se envió, False si falló.
 */
function send_modification_email($toEmail, $toName, $datos_cita) {
    $mail = get_mailer_instance();

    try {
        $mail->addAddress($toEmail, $toName);
        $mail->Subject = 'Confirmación de Modificación de Cita Médica';

        // Construir el cuerpo HTML del correo
        $htmlBody = '
        <html>
        <head>
        <style>
            body { font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px; }
            .container { background-color: #fff; border-radius: 8px; padding: 20px; max-width: 600px; margin: auto; box-shadow: 0 0 10px rgba(0,0,0,0.05); }
            h2 { color: #0077B6; }
            h3 { margin-top: 30px; color: #023E8A; }
            .section { margin-bottom: 20px; }
            .label { font-weight: bold; color: #555; }
            .footer { margin-top: 40px; font-size: 0.9em; color: #666; text-align: center; }
        </style>
        </head>
        <body>
        <div class="container">
            <h2>¡Modificación de Cita Confirmada!</h2>
            <p>Fecha y hora de modificación: <strong>{{fecha_modificacion}}</strong></p>

            <div class="section">
            <p><span class="label">Paciente:</span> {{nombre_paciente}}</p>
            <p><span class="label">Especialidad:</span> {{especialidad}}</p>
            </div>

            <h3>Datos anteriores</h3>
            <div class="section">
            <p><span class="label">Fecha:</span> {{fecha_original}}</p>
            <p><span class="label">Hora:</span> {{hora_original}}</p>
            <p><span class="label">Profesional:</span> {{profesional_original}}</p>
            <p><span class="label">Sede:</span> {{sede_original}}</p>
            <p><span class="label">Dirección:</span> {{direccion_sede_original}}</p>
            </div>

            <h3>Datos nuevos</h3>
            <div class="section">
            <p><span class="label">Fecha:</span> {{fecha_nueva}}</p>
            <p><span class="label">Hora:</span> {{hora_nueva}}</p>
            <p><span class="label">Profesional:</span> {{profesional_nuevo}}</p>
            <p><span class="label">Sede:</span> {{sede_nueva}}</p>
            <p><span class="label">Dirección:</span> {{direccion_sede_nueva}}</p>
            </div>

            <div class="footer">
            <p>Gracias por confiar en nosotros, <strong>CITASalud</strong>.</p>
            <p>Este correo confirma la modificación de su cita médica. Si tiene alguna duda, puede contactarnos respondiendo a este mensaje.</p>
            </div>
        </div>
        </body>
        </html>
        ';
        
        $mail->isHTML(true);
        $htmlBody = render_template($htmlBody, array_merge($datos_cita, [
            'nombre_paciente' => $toName
        ]));

        $mail->isHTML(true);
        $mail->Body = $htmlBody;
        $mail->AltBody = "Su cita ha sido modificada. Nueva fecha: {$datos_cita['fecha_nueva']} a las {$datos_cita['hora_nueva']} con {$datos_cita['profesional_nuevo']} en {$datos_cita['sede_nueva']}.";

        $mail->send();
        return true;

    } catch (Exception $e) {
        error_log("Error al enviar correo de modificación: {$mail->ErrorInfo}");
        return false;
    }
}
?>