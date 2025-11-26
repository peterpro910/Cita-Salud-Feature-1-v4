// Tu script de Logout Modificado (e.g., /js/auth.js o similar)

document.addEventListener('DOMContentLoaded', () => {
    
    const LOGIN_URL = './../html/login.html'; 
    const logoutLink = document.getElementById('logout-link');
    
    if (logoutLink) {
        logoutLink.addEventListener('click', async (e) => {
            e.preventDefault();
            
            try {
                // 1. Llama a la API de PHP para destruir la sesión del servidor
                // NOTA: Asumimos que './../api/logout.php' funciona correctamente.
                const response = await fetch('./../api/logout.php', { method: 'POST' });

                // Verificación de éxito del servidor (opcional pero robusto)
                if (!response.ok) {
                    console.error('Logout API falló, pero se limpiará el cliente.', await response.text());
                }
                
            } catch (error) {
                console.error('Logout: Error de conexión al API o de servidor.', error);
            }

            // 2. Limpieza de datos sensibles en el lado del cliente (sessionStorage)
            sessionStorage.removeItem('id_paciente');
            sessionStorage.removeItem('nombre_paciente');
            localStorage.removeItem('accepted_appointment_notifications_persistent');

            sessionStorage.removeItem('last_especialidad_id');
            sessionStorage.removeItem('last_sede_id');
            sessionStorage.removeItem('last_profesional_id');

            // 3. CLAVE DE LIMPIEZA: Establecer una bandera en sessionStorage
            // Esta bandera será leída por la página de agendamiento para limpiar los campos.
            if ('sessionStorage' in window) {
               sessionStorage.setItem('logout_clear_form', 'true');
            }

            // 4. ¡REDIRECCIÓN Y LIMPIEZA DE HISTORIAL!
            // Usamos replace() para prevenir que la página actual se mantenga en el historial
            // y que el navegador restaure el estado del formulario.
            window.location.replace(LOGIN_URL);
        });
    }
});