<?php
class Profesional {
    private $conn;
    private $table_name = "profesionales";

    public function __construct($db) {
        $this->conn = $db;
    }

    public function getProfesionalesPorEspecialidadYSede($especialidad_id, $sede_id) {
        $query = "
            SELECT 
                p.id_profesional, 
                p.nombre, 
                p.apellido, 
                p.titulo_profesional, 
                p.anos_experiencia,
                COUNT(hp.id_horario) as horarios_disponibles
            FROM 
                " . $this->table_name . " p
            INNER JOIN 
                profesionales_especialidades pe ON p.id_profesional = pe.id_profesional
            INNER JOIN 
                profesionales_sedes ps ON p.id_profesional = ps.id_profesional
            LEFT JOIN
                horarios_profesionales hp ON p.id_profesional = hp.id_profesional
                AND hp.disponible = 1
                AND hp.fecha BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 60 DAY)
            WHERE
                p.id_estado = 1
                AND pe.id_especialidad = :especialidad_id
                AND ps.id_sede = :sede_id
                AND NOT EXISTS (
                    SELECT 1
                    FROM ausencias_profesionales ap
                    WHERE ap.id_profesional = p.id_profesional
                    AND CURDATE() BETWEEN ap.fecha_inicio AND ap.fecha_fin
                )
            GROUP BY 
                p.id_profesional
            ORDER BY 
                p.nombre ASC, p.apellido ASC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":especialidad_id", $especialidad_id);
        $stmt->bindParam(":sede_id", $sede_id);
        $stmt->execute();

        return $stmt;
    }
}
?>