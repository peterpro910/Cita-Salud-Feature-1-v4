<?php
class Horario {
    private $conn;
    private $table_name = "horarios_profesionales";

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Obtiene los horarios disponibles para un profesional, excluyendo los horarios
     * en los que el paciente ya tiene una cita agendada.
     * @param int $profesional_id ID del profesional.
     * @param int $paciente_id ID del paciente.
     * @return PDOStatement
     */
    public function getHorariosDisponiblesPorProfesional($profesional_id, $paciente_id) {
        $query = "
            SELECT
                hp.id_horario,
                hp.fecha,
                hp.hora
            FROM
                " . $this->table_name . " hp
            WHERE
                hp.id_profesional = :profesional_id
                AND hp.disponible = 1
                AND CONCAT(hp.fecha, ' ', hp.hora) >= NOW()
                AND hp.fecha BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 60 DAY)
                 AND NOT EXISTS (
                    -- Verifica si ya existe una cita agendada para el paciente en la misma fecha
                    SELECT 1
                    FROM citas c
                    JOIN horarios_profesionales hp_existente ON c.id_horario = hp_existente.id_horario
                    WHERE c.id_paciente = :paciente_id
                    AND hp_existente.fecha = hp.fecha
                )
            ORDER BY
                hp.fecha ASC, hp.hora ASC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":profesional_id", $profesional_id);
        $stmt->bindParam(":paciente_id", $paciente_id);
        $stmt->execute();

        return $stmt;
    }
}
?>