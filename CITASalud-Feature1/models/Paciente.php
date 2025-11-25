<?php
// models/Paciente.php

class Paciente {
    private $conn;
    private $table_pacientes = "pacientes";
    private $table_usuarios = "usuarios";
    private $table_profesionales = "profesionales";

    // Propiedades del paciente y su usuario asociado
    public $id_usuario;
    public $id_paciente;
    public $documento;
    public $nombre;
    public $apellido;
    public $correo;
    public $contrasena_hash;
    public $intentos_fallidos;
    public $bloqueo_hasta;
    public $session_id_activa;
    public $reset_token;
    public $token_expira;
    public $id_rol;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Busca un paciente por número de documento y trae sus datos de usuario.
     */
    public function findByDocumento($documento) {
        $query = "SELECT 
                    p.id_paciente, u.correo,
                    u.id_usuario, u.contrasena AS contrasena_hash, u.intentos_fallidos, u.bloqueo_hasta, u.session_id_activa, u.reset_token, u.token_expira,
                    u.id_rol,
                    
                    COALESCE(p.numero_documento, pr.numero_documento) AS documento_encontrado,
                    COALESCE(p.nombre, pr.nombre) AS nombre_completo,
                    COALESCE(p.apellido, pr.apellido) AS apellido_completo
                  FROM " . $this->table_usuarios . " u 
            
                  LEFT JOIN " . $this->table_pacientes . " p ON p.id_usuario = u.id_usuario
                  LEFT JOIN " . $this->table_profesionales ." pr ON pr.id_usuario = u.id_usuario
                  WHERE p.numero_documento = :documento OR pr.numero_documento = :documento
                  LIMIT 1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':documento', $documento);
        $stmt->execute();

		if ($stmt->rowCount() > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            
            foreach ($row as $key => $value) {
                if (property_exists($this, $key) && $key !== 'nombre_completo' && $key !== 'apellido_completo' && $key !== 'documento_encontrado') {
                    $this->$key = $value;
                }
            }
            
            // Asignar propiedades específicas (usando los alias COALESCE)
            $this->documento = $row['documento_encontrado'];
            $this->correo = $row['correo']; 
            $this->nombre = $row['nombre_completo'];
            $this->apellido = $row['apellido_completo'];
            
            return $this;
        }

        return false;
    }

    /**
     * Intenta iniciar sesión, verifica bloqueo y maneja intentos fallidos.
     * @param string $password_plano Contraseña en texto plano.
     * @return bool True si el login es exitoso.
     */
    public function login($password_plano) {
        // Verificar bloqueo temporal
        if ($this->bloqueo_hasta && strtotime($this->bloqueo_hasta) > time()) {
            return false;
        }

        if ($this->bloqueo_hasta && strtotime($this->bloqueo_hasta) <= time() && $this->intentos_fallidos > 0) {
            // El tiempo de bloqueo ha expirado. Resetear intentos en la DB y en el objeto.
            $this->resetIntentos();
            $this->intentos_fallidos = 0; 
            $this->bloqueo_hasta = null;
        }

        // Usar SHA-256 para compatibilidad con la DB actual
        $password_ingresada_hash = hash('sha256', $password_plano);
        
        if ($password_ingresada_hash === $this->contrasena_hash) {
            // Éxito: Reiniciar contador
            $this->resetIntentos();
            return true;
        } else {
            // Fracaso: Incrementar intentos
            $this->incrementIntentos();
            return false;
        }
    }

    /**
     * Incrementa el contador de intentos fallidos y aplica bloqueo si excede el límite (5 intentos / 30 min).
     */
    public function incrementIntentos() {
        $max_intentos = 5;
        $tiempo_bloqueo = 30 * 60; // 30 minutos

        $this->intentos_fallidos = (int)$this->intentos_fallidos + 1;
        $query = "UPDATE " . $this->table_usuarios . " SET intentos_fallidos = :intentos";
        $params = [':intentos' => $this->intentos_fallidos];

        if ($this->intentos_fallidos >= $max_intentos) {
            $tiempo_desbloqueo = date('Y-m-d H:i:s', time() + $tiempo_bloqueo);
            $query .= ", bloqueo_hasta = :bloqueo_hasta";
            $params[':bloqueo_hasta'] = $tiempo_desbloqueo;
            $this->bloqueo_hasta = $tiempo_desbloqueo; 
        }
        $query .= " WHERE id_usuario = :id_usuario";
        $params[':id_usuario'] = $this->id_usuario;

        $stmt = $this->conn->prepare($query);
        $stmt->execute($params);
    }

    /**
     * Reinicia el contador de intentos fallidos y el bloqueo.
     */
    public function resetIntentos() {
        $query = "UPDATE " . $this->table_usuarios . " SET intentos_fallidos = 0, bloqueo_hasta = NULL WHERE id_usuario = :id_usuario";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id_usuario', $this->id_usuario);
        $stmt->execute();
        $this->intentos_fallidos = 0;
        $this->bloqueo_hasta = null;
    }

    // --- Sesión Única ---

    public function hasActiveSession($current_session_id) {
        // Si hay un session_id_activa guardado y es diferente al actual, significa que hay otra sesión.
        return !empty($this->session_id_activa) && $this->session_id_activa !== $current_session_id;
    }
    
    public function setActiveSession($session_id) {
        $query = "UPDATE " . $this->table_usuarios . " SET session_id_activa = :session_id WHERE id_usuario = :id_usuario";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':session_id', $session_id);
        $stmt->bindParam(':id_usuario', $this->id_usuario);
        $stmt->execute();
    }
    
    // --- Restablecimiento de Contraseña ---

    public function saveResetToken($token) {
        $expiracion = date('Y-m-d H:i:s', time() + (10 * 60)); // Expira en 10 minutos
        $query = "UPDATE " . $this->table_usuarios . " SET reset_token = :token, token_expira = :expiracion WHERE id_usuario = :id_usuario";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':token', $token);
        $stmt->bindParam(':expiracion', $expiracion);
        $stmt->bindParam(':id_usuario', $this->id_usuario);

        return $stmt->execute();
    }

    public function updatePassword($new_password) {
        // Usar SHA-256 para compatibilidad con la DB actual
        $new_hash = hash('sha256', $new_password);

        $query = "UPDATE " . $this->table_usuarios . " SET contrasena = :hash, reset_token = NULL, token_expira = NULL, intentos_fallidos = 0 WHERE id_usuario = :id_usuario";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':hash', $new_hash);
        $stmt->bindParam(':id_usuario', $this->id_usuario);

        return $stmt->execute();
    }

/**
 * Limpia el session_id_activa del paciente en la base de datos, 
 * cerrando así la sesión única.
 * @return bool True en caso de éxito, False si falla.
 */
    public function clearActiveSession() {
        // 🔑 CORRECCIÓN 1: Usar la tabla de usuarios ($this->table_usuarios)
        // 🔑 CORRECCIÓN 2: Usar id_usuario como condición, que está cargado.
        $query = "UPDATE " . $this->table_usuarios . "
                SET session_id_activa = NULL
                WHERE id_usuario = :id_usuario"; // Usar el ID de usuario para la actualización

        $stmt = $this->conn->prepare($query);

        // No es necesario limpiar el documento aquí, solo necesitamos el ID de usuario.
    
        // Vincular el parámetro
        $stmt->bindParam(':id_usuario', $this->id_usuario);

        // Ejecutar la consulta
        if ($stmt->execute()) {
            // Opcional: Actualizar la propiedad local del objeto
            $this->session_id_activa = null; 
            return true;
        }
    
        // Puedes descomentar para ver el error si falla:
        // error_log("Error al limpiar session_id_activa: " . implode(":", $stmt->errorInfo()));
        return false;
    }
}
?>