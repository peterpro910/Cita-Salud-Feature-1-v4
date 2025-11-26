<?php
// config/db.php

class Database {
    private $host = "localhost";
    private $db_name = "feature1_db";
    private $username = "root"; // Reemplaza con tu usuario de MySQL
    private $password = "";     // Reemplaza con tu contraseña de MySQL
    public $conn;

    /**
     * Obtiene la conexión a la base de datos
     * @return PDO|null Objeto de conexión PDO o null si falla
     */
    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new PDO("mysql:host=" . $this->host . ";dbname=" . $this->db_name, $this->username, $this->password);
            $this->conn->exec("set names utf8");
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch(PDOException $exception) {
            // Muestra un error detallado solo en desarrollo. En producción, loguea el error y muestra un mensaje genérico.
            error_log("Connection error: " . $exception->getMessage());
            //die("Error de conexión a la base de datos.");
            return null; // Devuelve null si la conexión falla
        }
        return $this->conn;
    }
}
?>