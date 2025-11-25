<?php
// models/Sede.php

class Sede {
    private $conn;
    private $table_name = "sedes";

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Obtiene las sedes que tienen profesionales con una especialidad específica.
     * @param int $especialidad_id ID de la especialidad.
     * @return PDOStatement
     */
    public function getSedesPorEspecialidad($especialidad_id) {
        // Consulta corregida para obtener las sedes.
        // La tabla 'profesionales' no tiene una columna 'id_sede'.
        // Se debe usar la tabla intermedia 'profesionales_sedes' para unir sedes y profesionales.
        $query = "SELECT DISTINCT s.id_sede, s.nombre_sede, s.direccion, c.nombre_ciudad
                  FROM " . $this->table_name . " s
                  INNER JOIN profesionales_sedes ps ON s.id_sede = ps.id_sede
                  INNER JOIN profesionales p ON ps.id_profesional = p.id_profesional
                  INNER JOIN profesionales_especialidades pe ON p.id_profesional = pe.id_profesional
                  INNER JOIN ciudades c ON s.id_ciudad = c.id_ciudad
                  WHERE pe.id_especialidad = :especialidad_id
                  ORDER BY s.nombre_sede ASC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':especialidad_id', $especialidad_id);
        $stmt->execute();

        return $stmt;
    }
}
?>