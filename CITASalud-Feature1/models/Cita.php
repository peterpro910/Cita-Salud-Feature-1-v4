<?php
// models/Cita.php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

class Cita {
    private $conn;
    private $table_name = "citas";

    public $id_cita;
    public $id_paciente;
    public $id_horario;
    public $motivo_cancelacion;
    public $id_horario_original;
    public $id_nuevo_horario;
    public $id_nueva_sede;
    public $id_nuevo_profesional;
    public $id_especialidad;

    const ESTADO_ASISTIDA = 4;
    const ESTADO_NO_ASISTIDA = 5;

    public function __construct($db) {
        $this->conn = $db;
    }


    /**
     * Cuenta las cancelaciones del paciente en el mes actual (HU-07)
     */
    public function countCancellationsThisMonth($id_paciente) {
        $query = "
            SELECT COUNT(*) AS total_cancelaciones
            FROM historial_cancelaciones
            WHERE id_paciente = :id_paciente 
            AND YEAR(fecha_cancelacion) = YEAR(NOW())
            AND MONTH(fecha_cancelacion) = MONTH(NOW())";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id_paciente', $id_paciente, PDO::PARAM_INT);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return (int)$row['total_cancelaciones'] ?? 0;
    }

    /**
     * Obtiene los detalles de la cita para la validación de 24h.
     * Nota: Se incluye el id_paciente para seguridad en la búsqueda.
     */
    public function getCitaDetailsForCancellation($id_cita, $id_paciente) {
        $query = "
            SELECT
                c.id_cita, c.id_profesional, c.id_especialidad, c.id_sede, h.fecha, h.hora, h.id_horario, e.nombre_especialidad, s.nombre_sede, s.direccion
            FROM
                " . $this->table_name . " c
            INNER JOIN
                horarios_profesionales h ON c.id_horario = h.id_horario
            INNER JOIN
                especialidades e ON c.id_especialidad = e.id_especialidad
            INNER JOIN
                sedes s ON c.id_sede = s.id_sede
            WHERE
                c.id_cita = :id_cita 
                AND c.id_paciente = :id_paciente 
                AND c.id_estado IN (1, 2)
            LIMIT 0,1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id_cita', $id_cita, PDO::PARAM_INT);
        $stmt->bindParam(':id_paciente', $id_paciente, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    /**
     * Cancela una cita: actualiza estado, inserta historial_cancelaciones, 
     * ACTUALIZA historiales_cita, y libera horario (HU-07)
     * * Esta función es atómica (usa Transacciones PDO).
     */
    public function cancelarCita($id_horario) {
        try {
            $this->conn->beginTransaction();
            $ID_ESTADO_CANCELADA = 3; 
            $OBSERVACION_CANCELACION = 'Cita cancelada por el paciente';

            // 1. Actualizar el estado de la cita a 3 (Cancelada) en la tabla 'citas'
            $queryCita = "
                UPDATE " . $this->table_name . "
                SET 
                    id_estado = :estado 
                WHERE 
                    id_cita = :cita_id AND id_paciente = :paciente_id 
                    AND id_estado IN (1, 2)";

            $stmtCita = $this->conn->prepare($queryCita);
            $stmtCita->bindParam(':estado', $ID_ESTADO_CANCELADA, PDO::PARAM_INT);
            $stmtCita->bindParam(':cita_id', $this->id_cita, PDO::PARAM_INT);
            $stmtCita->bindParam(':paciente_id', $this->id_paciente, PDO::PARAM_INT);
            $stmtCita->execute();

            // 2. Insertar registro en historial_cancelaciones (Para el límite mensual)
            $queryHistorialCancelacion = "
                INSERT INTO historial_cancelaciones 
                (id_cita, id_paciente, id_motivo, fecha_cancelacion, hora_cancelacion)
                VALUES 
                (:cita_id, :paciente_id, :motivo_id, CURDATE(), TIME(NOW()))";

            $stmtHistorialCancelacion = $this->conn->prepare($queryHistorialCancelacion);
            $stmtHistorialCancelacion->bindParam(':cita_id', $this->id_cita, PDO::PARAM_INT);
            $stmtHistorialCancelacion->bindParam(':paciente_id', $this->id_paciente, PDO::PARAM_INT);
            $stmtHistorialCancelacion->bindParam(':motivo_id', $this->motivo_cancelacion, PDO::PARAM_INT);
            $stmtHistorialCancelacion->execute();
            
            // 3. ¡CRÍTICO! ACTUALIZAR registro en historiales_cita
            $queryHistorialCita = "
                UPDATE historiales_cita 
                SET 
                    id_estado = :id_estado, 
                    fecha_cambio = NOW(),
                    observacion = :observacion
                WHERE 
                    id_cita = :id_cita";

            $stmtHistorialCita = $this->conn->prepare($queryHistorialCita);
            $stmtHistorialCita->bindParam(':id_cita', $this->id_cita, PDO::PARAM_INT);
            $stmtHistorialCita->bindParam(':id_estado', $ID_ESTADO_CANCELADA, PDO::PARAM_INT);
            $stmtHistorialCita->bindParam(':observacion', $OBSERVACION_CANCELACION, PDO::PARAM_STR);
            $stmtHistorialCita->execute();


            // 4. Liberar el horario, cambiando el campo 'disponible' en horarios_profesionales a 1
            $queryHorario = "
                UPDATE horarios_profesionales
                SET 
                    disponible = 1
                WHERE 
                    id_horario = :id_horario AND disponible = 0";

            $stmtHorario = $this->conn->prepare($queryHorario);
            $stmtHorario->bindParam(':id_horario', $id_horario, PDO::PARAM_INT);
            $stmtHorario->execute();

            // 5. Verificación y Commit
            if ($stmtCita->rowCount() > 0) { 
                $this->conn->commit();
                return true;
            } else {
                // No se afectó la cita (ya estaba cancelada o no existía)
                $this->conn->rollBack();
                return false;
            }

        } catch (Exception $e) {
            // En caso de cualquier fallo, se revierte toda la transacción.
            if ($this->conn->inTransaction()) {
                 $this->conn->rollBack();
            }
            error_log("Error al cancelar cita (Transacción): " . $e->getMessage());
            return false;
        }
    }

        /**
 * Obtiene los detalles de la cita para la pantalla de modificación (HU-08).
 * Incluye seguridad para verificar que la cita pertenece al paciente.
 *
 * @param int $id_cita ID de la cita.
 * @param int $id_paciente ID del paciente (para seguridad).
 * @return array|false Detalles de la cita o false.
 */
public function getCitaDetailsForModification($id_cita, $id_paciente) {
    $query = "
        SELECT 
            c.id_cita,
            c.id_paciente,
            c.id_especialidad,
            c.id_profesional AS id_profesional_nuevo,
            c.id_sede AS id_sede_nueva,
            hp.fecha AS fecha_nueva,
            hp.hora AS hora_nueva,
            e.nombre_especialidad,
            pr.nombre AS nombre_profesional_nuevo,
            pr.apellido AS apellido_profesional_nuevo,
            s.nombre_sede AS nombre_sede_nueva,
            hm.fecha_anterior,
            hm.hora_anterior,
            hm.id_profesional_anterior,
            hm.id_sede_anterior,
            hm.fecha_modificacion,
            hm.hora_modificacion
        FROM citas c
        JOIN horarios_profesionales hp ON c.id_horario = hp.id_horario
        JOIN profesionales pr ON c.id_profesional = pr.id_profesional
        JOIN sedes s ON c.id_sede = s.id_sede
        JOIN especialidades e ON c.id_especialidad = e.id_especialidad
        LEFT JOIN (
            SELECT * FROM historial_modificaciones 
            WHERE id_cita = :id_cita_historial 
            ORDER BY fecha_modificacion DESC 
            LIMIT 1
        ) hm ON hm.id_cita = c.id_cita
        WHERE c.id_cita = :id_cita 
          AND c.id_paciente = :id_paciente
          AND c.id_estado = 1
        LIMIT 1";

    $stmt = $this->conn->prepare($query);
    if (!$stmt) {
        error_log("Error al preparar la consulta: " . implode(" | ", $this->conn->errorInfo()));
        return false;
    }

    $stmt->bindParam(':id_cita', $id_cita, PDO::PARAM_INT);
    $stmt->bindParam(':id_cita_historial', $id_cita, PDO::PARAM_INT);
    $stmt->bindParam(':id_paciente', $id_paciente, PDO::PARAM_INT);

    if (!$stmt->execute()) {
        error_log("Error al ejecutar la consulta: " . implode(" | ", $stmt->errorInfo()));
        return false;
    }

    $detalles = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$detalles) {
        return false;
    }

    // Si no hay historial, usar los datos actuales como originales
    foreach (['fecha_anterior', 'hora_anterior', 'id_profesional_anterior', 'id_sede_anterior'] as $campo) {
        if (empty($detalles[$campo])) {
            $detalles[$campo] = $detalles[str_replace('_anterior', '_nueva', $campo)];
        }
    }

    return $detalles;
}

/**
 * Realiza la modificación de una cita en una transacción segura.
 *
 * @param int $id_cita ID de la cita.
 * @param int $id_paciente ID del paciente.
 * @param int $id_horario_original ID del horario actual.
 * @param int $id_nuevo_horario ID del nuevo horario.
 * @return true|array Devuelve true si fue exitosa o un array con 'error' si falla.
 */
public function modificarCita($id_cita, $id_paciente, $id_horario_original, $id_nuevo_horario) {
    $ID_ESTADO_MODIFICADA = 2;
    $ID_ESTADO_AGENDADA = 1;
    $OBSERVACION_MODIFICACION = "Cita modificada por el paciente.";

    $this->conn->beginTransaction();

    try {
        // Obtener datos originales y nuevos
        $original = $this->getHorarioDetails($id_horario_original);
        $nuevo = $this->getHorarioDetails($id_nuevo_horario);

        if (!$original || !$nuevo) {
            $this->conn->rollBack();
            return ["error" => "No se pudieron obtener los datos de los horarios."];
        }

        // Ocupar nuevo horario
        $stmtOcupar = $this->conn->prepare("
            UPDATE horarios_profesionales SET disponible = 0 
            WHERE id_horario = :id AND disponible = 1");
        $stmtOcupar->bindParam(':id', $id_nuevo_horario, PDO::PARAM_INT);
        $stmtOcupar->execute();
        if ($stmtOcupar->rowCount() === 0) {
            $this->conn->rollBack();
            return ["error" => "El nuevo horario ya no está disponible."];
        }

        // Actualizar cita con datos ya obtenidos (sin subconsultas)
        $stmtCita = $this->conn->prepare("
            UPDATE {$this->table_name}
            SET 
                id_horario = :id_nuevo,
                id_estado = :estado,
                id_especialidad = :id_especialidad,
                id_profesional = :id_profesional,
                id_sede = :id_sede,
                veces_modificada = veces_modificada + 1
            WHERE id_cita = :id_cita AND id_paciente = :id_paciente AND id_estado IN (:estado1, :estado2)");
        $stmtCita->execute([
            ':id_nuevo' => $id_nuevo_horario,
            ':estado' => $ID_ESTADO_MODIFICADA,
            ':id_especialidad' => $this->id_especialidad,
            ':id_profesional' => $nuevo['id_profesional'],
            ':id_sede' => $nuevo['id_sede'],
            ':id_cita' => $id_cita,
            ':id_paciente' => $id_paciente,
            ':estado1' => $ID_ESTADO_MODIFICADA,
            ':estado2' => $ID_ESTADO_AGENDADA
        ]);
        if ($stmtCita->rowCount() === 0) {
            $this->conn->rollBack();
            return ["error" => "No se pudo actualizar la cita."];
        }

        // Liberar horario original
        $stmtLiberar = $this->conn->prepare("
            UPDATE horarios_profesionales SET disponible = 1 
            WHERE id_horario = :id AND disponible = 0");
        $stmtLiberar->bindParam(':id', $id_horario_original, PDO::PARAM_INT);
        $stmtLiberar->execute();

        // Insertar en historial_modificaciones
        $stmtHistorialMod = $this->conn->prepare("
            INSERT INTO historial_modificaciones (
                id_cita, fecha_anterior, hora_anterior, id_profesional_anterior, id_sede_anterior,
                fecha_nueva, hora_nueva, id_profesional_nuevo, id_sede_nueva,
                fecha_modificacion, hora_modificacion
            ) VALUES (
                :id_cita, :f_ant, :h_ant, :p_ant, :s_ant,
                :f_nue, :h_nue, :p_nue, :s_nue,
                NOW(), TIME(NOW())
            )");
        $stmtHistorialMod->execute([
            ':id_cita' => $id_cita,
            ':f_ant' => $original['fecha'],
            ':h_ant' => $original['hora'],
            ':p_ant' => $original['id_profesional'],
            ':s_ant' => $original['id_sede'],
            ':f_nue' => $nuevo['fecha'],
            ':h_nue' => $nuevo['hora'],
            ':p_nue' => $nuevo['id_profesional'],
            ':s_nue' => $nuevo['id_sede']
        ]);

        // Registrar en historiales_cita
        $stmtHistorial = $this->conn->prepare("
            INSERT INTO historiales_cita (id_cita, id_estado, fecha_cambio, observacion)
            VALUES (:id, :estado, NOW(), :obs)");
        $stmtHistorial->execute([
            ':id' => $id_cita,
            ':estado' => $ID_ESTADO_MODIFICADA,
            ':obs' => $OBSERVACION_MODIFICACION
        ]);

        $this->conn->commit();
        return true;

    } catch (Exception $e) {
        if ($this->conn->inTransaction()) {
            $this->conn->rollBack();
        }
        error_log("Error en modificarCita: " . $e->getMessage());
        return ["error" => "Excepción en base de datos al modificar: " . $e->getMessage()];
    }
}



/**
 * Método auxiliar para obtener detalles de un horario.
 *
 * @param int $id_horario ID del horario a consultar.
 * @return array|false Arreglo con fecha, hora, id_profesional e id_sede, o false si falla.
 */
private function getHorarioDetails($id_horario) {
    $query = "
        SELECT 
            hp.fecha,
            hp.hora,
            hp.id_profesional,
            (
                SELECT ps.id_sede
                FROM profesionales_sedes ps
                WHERE ps.id_profesional = hp.id_profesional
                LIMIT 1
            ) AS id_sede
        FROM horarios_profesionales hp
        WHERE hp.id_horario = :id_horario
        LIMIT 1";

    $stmt = $this->conn->prepare($query);
    if (!$stmt) {
        error_log("Error al preparar getHorarioDetails: " . implode(" | ", $this->conn->errorInfo()));
        return false;
    }

    $stmt->bindParam(':id_horario', $id_horario, PDO::PARAM_INT);

    if (!$stmt->execute()) {
        error_log("Error al ejecutar getHorarioDetails: " . implode(" | ", $stmt->errorInfo()));
        return false;
    }

    $horario = $stmt->fetch(PDO::FETCH_ASSOC);
    return $horario ?: false;
}


    /**
     * Valida si la cita puede ser modificada según el límite de horas antes de la atención.
     *
     * @param int $id_cita
     * @param int $id_paciente
     * @param int $limite_horas Número mínimo de horas antes de la cita para permitir modificación.
     * @return array ['success' => bool, 'message' => string]
     */
    public function validateModificationTime($id_cita, $id_paciente, $limite_horas) {
        $query = "
            SELECT hp.fecha, hp.hora
            FROM citas c
            JOIN horarios_profesionales hp ON c.id_horario = hp.id_horario
            WHERE c.id_cita = :id_cita AND c.id_paciente = :id_paciente AND c.id_estado = 1
            LIMIT 1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id_cita', $id_cita, PDO::PARAM_INT);
        $stmt->bindParam(':id_paciente', $id_paciente, PDO::PARAM_INT);

        if (!$stmt->execute()) {
            return ['success' => false, 'message' => 'Error al validar la cita.'];
        }

        $cita = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$cita) {
            return ['success' => false, 'message' => 'La cita no existe o no está activa.'];
        }

        $fechaHoraCita = strtotime($cita['fecha'] . ' ' . $cita['hora']);
        $fechaHoraActual = time();
        $diferenciaHoras = ($fechaHoraCita - $fechaHoraActual) / 3600;

        if ($diferenciaHoras < $limite_horas) {
            return ['success' => false, 'message' => "La cita no puede modificarse porque faltan menos de $limite_horas horas."];
        }

        return ['success' => true, 'message' => 'La cita puede ser modificada.'];
    }

        public function getDetailsForModificationEmail() {
        $query = "
            SELECT 
                p.nombre AS nombre_paciente,
                p.apellido AS apellido_paciente,
                p.correo AS correo_paciente,
                e.nombre_especialidad AS nombre_especialidad,

                hpo.fecha AS fecha_original,
                hpo.hora AS hora_original,
                po.nombre AS nombre_profesional_original,
                po.apellido AS apellido_profesional_original,
                so.nombre_sede AS nombre_sede_original,
                so.direccion AS direccion_sede_original,

                hpn.fecha AS fecha_nueva,
                hpn.hora AS hora_nueva,
                pn.nombre AS nombre_profesional,
                pn.apellido AS apellido_profesional,
                sn.nombre_sede AS nombre_sede,
                sn.direccion AS direccion_sede

            FROM citas c
            JOIN pacientes p ON c.id_paciente = p.id_paciente
            JOIN especialidades e ON c.id_especialidad = e.id_especialidad

            JOIN horarios_profesionales hpo ON hpo.id_horario = :id_horario_original
            JOIN profesionales po ON hpo.id_profesional = po.id_profesional
            JOIN profesionales_sedes pso ON po.id_profesional = pso.id_profesional
            JOIN sedes so ON pso.id_sede = so.id_sede

            JOIN horarios_profesionales hpn ON hpn.id_horario = :id_nuevo_horario
            JOIN profesionales pn ON hpn.id_profesional = pn.id_profesional
            JOIN profesionales_sedes psn ON pn.id_profesional = psn.id_profesional
            JOIN sedes sn ON psn.id_sede = sn.id_sede

            WHERE c.id_cita = :id_cita AND c.id_paciente = :id_paciente
            LIMIT 1
        ";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([
            ':id_cita' => $this->id_cita,
            ':id_paciente' => $this->id_paciente,
            ':id_horario_original' => $this->id_horario_original,
            ':id_nuevo_horario' => $this->id_nuevo_horario
        ]);

        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row) {
            return false;
        }

        return [
            'nombre_paciente' => $row['nombre_paciente'],
            'apellido_paciente' => $row['apellido_paciente'],
            'correo_paciente' => $row['correo_paciente'],
            'nombre_especialidad' => $row['nombre_especialidad'],
            'fecha_original' => $row['fecha_original'],
            'hora_original' => $row['hora_original'],
            'fecha_nueva' => $row['fecha_nueva'],
            'hora_nueva' => $row['hora_nueva'],
            'original' => [
                'nombre_profesional_original' => $row['nombre_profesional_original'],
                'apellido_profesional_original' => $row['apellido_profesional_original'],
                'nombre_sede_original' => $row['nombre_sede_original'],
                'direccion_sede_original' => $row['direccion_sede_original']
            ],
            'nuevo' => [
                'nombre_profesional' => $row['nombre_profesional'],
                'apellido_profesional' => $row['apellido_profesional'],
                'nombre_sede' => $row['nombre_sede'],
                'direccion_sede' => $row['direccion_sede']
            ]
        ];
    }

/**
     * Obtiene el total de citas asistidas y no asistidas del paciente, con filtro opcional de mes.
     * Requerido para el cálculo de totales, porcentaje de cumplimiento, y Gráficos Circular/Barras.
     * @param int $id_paciente ID del paciente.
     * @param int|null $mes_filtro Mes a filtrar (1-12) o null/0 para todos.
     * @return array [total_asistidas, total_no_asistidas, total_validas]
     */
    public function getTotalesAsistencia($id_paciente, $mes_filtro = null) { // 🚨 MODIFICADO: Añadido $mes_filtro
        $query = "
            SELECT 
                SUM(CASE WHEN c.id_estado = :estado_asistida THEN 1 ELSE 0 END) AS total_asistidas,
                SUM(CASE WHEN c.id_estado = :estado_no_asistida THEN 1 ELSE 0 END) AS total_no_asistidas,
                COUNT(c.id_cita) AS total_validas
            FROM 
                " . $this->table_name . " c
            INNER JOIN 
                horarios_profesionales hp ON c.id_horario = hp.id_horario -- Para acceder a la fecha
            WHERE 
                c.id_paciente = :id_paciente
                AND c.id_estado IN (:estado_asistida, :estado_no_asistida)
                AND hp.fecha <= CURDATE() -- Solo citas que ya ocurrieron y tienen estado final
        "; 
        
        // 🔑 CLAVE: Aplicar la condición de filtrado por mes
        if ($mes_filtro !== null && is_numeric($mes_filtro) && $mes_filtro >= 1 && $mes_filtro <= 12) {
            $query .= " AND MONTH(hp.fecha) = :mes_filtro ";
        }

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id_paciente', $id_paciente, PDO::PARAM_INT);
        $stmt->bindValue(':estado_asistida', self::ESTADO_ASISTIDA, PDO::PARAM_INT);
        $stmt->bindValue(':estado_no_asistida', self::ESTADO_NO_ASISTIDA, PDO::PARAM_INT);

        // 🔑 CLAVE: Asignar el parámetro de filtro condicional
        if ($mes_filtro !== null && is_numeric($mes_filtro) && $mes_filtro >= 1 && $mes_filtro <= 12) {
            $stmt->bindParam(':mes_filtro', $mes_filtro, PDO::PARAM_INT);
        }

        $stmt->execute();
        
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    /**
     * Obtiene el historial de asistencias y no asistencias mes a mes.
     * Requerido para el Gráfico de Línea (Evolución mes a mes).
     * @param int $id_paciente ID del paciente.
     * @return PDOStatement
     */
    public function getHistorialMensual($id_paciente, $mes_filtro = null) {
    // 1. Iniciar la consulta SQL
    $query = "
        SELECT 
            DATE_FORMAT(hp.fecha, '%Y-%m') as mes_anio,
            MONTH(hp.fecha) as mes,
            YEAR(hp.fecha) as anio,
            SUM(CASE WHEN c.id_estado = :estado_asistida THEN 1 ELSE 0 END) AS asistidas,
            SUM(CASE WHEN c.id_estado = :estado_no_asistida THEN 1 ELSE 0 END) AS no_asistidas
        FROM 
            " . $this->table_name . " c
        INNER JOIN
            horarios_profesionales hp ON c.id_horario = hp.id_horario
        WHERE 
            c.id_paciente = :id_paciente
            AND c.id_estado IN (:estado_asistida, :estado_no_asistida)
            AND hp.fecha <= CURDATE() -- Solo citas que ya ocurrieron y tienen estado final
    ";

    // 2. Lógica de Filtrado Condicional
    // Si se proporciona un mes válido, añade la condición WHERE
    if ($mes_filtro !== null && is_numeric($mes_filtro) && $mes_filtro >= 1 && $mes_filtro <= 12) {
        $query .= " AND MONTH(hp.fecha) = :mes_filtro ";
    }

    // 3. Finalizar la consulta (GROUP BY y ORDER BY)
    $query .= "
        GROUP BY 
            mes_anio
        ORDER BY
            mes_anio DESC
        LIMIT 6; -- Mostrar solo los últimos 6 meses (o meses filtrados)
    ";

    // 4. Preparar la consulta
    $stmt = $this->conn->prepare($query);

    // 5. Asignar parámetros fijos
    $stmt->bindParam(':id_paciente', $id_paciente, PDO::PARAM_INT);
    $stmt->bindValue(':estado_asistida', self::ESTADO_ASISTIDA, PDO::PARAM_INT);
    $stmt->bindValue(':estado_no_asistida', self::ESTADO_NO_ASISTIDA, PDO::PARAM_INT);

    // 6. Asignar el parámetro de filtro condicional
    if ($mes_filtro !== null && is_numeric($mes_filtro) && $mes_filtro >= 1 && $mes_filtro <= 12) {
        $stmt->bindParam(':mes_filtro', $mes_filtro, PDO::PARAM_INT);
    }

    // 7. Ejecutar y retornar
    $stmt->execute();
    
    return $stmt;
}

/**
     * Obtiene las citas activas del paciente que están próximas (dentro de las próximas 24 horas).
     * Incluye el nombre completo del profesional y la dirección de la sede.
     * @param int $id_paciente ID del paciente.
     * @return PDOStatement
     */
    public function getUpcomingAppointmentNotifications($id_paciente) {
        $query = "
            SELECT 
                c.id_cita,
                e.nombre_especialidad,
                CONCAT(p.nombre, ' ', p.apellido) AS nombre_profesional, -- 🔑 CLAVE: Combina nombre y apellido
                hp.fecha,
                hp.hora,
                s.nombre_sede,
                s.direccion AS direccion_sede -- Incluye la dirección completa
            FROM 
                " . $this->table_name . " c
            INNER JOIN
                horarios_profesionales hp ON c.id_horario = hp.id_horario
            INNER JOIN
                especialidades e ON c.id_especialidad = e.id_especialidad
            INNER JOIN
                profesionales p ON c.id_profesional = p.id_profesional
            INNER JOIN 
                profesionales_sedes ps ON p.id_profesional = ps.id_profesional
            INNER JOIN
                sedes s ON ps.id_sede = s.id_sede
            WHERE 
                c.id_paciente = :id_paciente
                AND c.id_estado IN (1, 2)
                AND CONCAT(hp.fecha, ' ', hp.hora) > NOW()
                AND CONCAT(hp.fecha, ' ', hp.hora) <= DATE_ADD(NOW(), INTERVAL 24 HOUR)
            GROUP BY 
                c.id_cita, e.nombre_especialidad, nombre_profesional, hp.fecha, hp.hora, s.nombre_sede, s.direccion
            ORDER BY
                hp.fecha ASC, hp.hora ASC
        ";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id_paciente', $id_paciente, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt;
    }
   
}
?>