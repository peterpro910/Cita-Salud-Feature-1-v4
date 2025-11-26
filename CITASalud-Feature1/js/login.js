// js/login.js

const loginForm = document.getElementById('login-form');
const documentoInput = document.getElementById('documento');
const passwordInput = document.getElementById('password');
const togglePassword = document.getElementById('toggle-password');
const messageContainer = document.getElementById('message-container');
const loginButton = document.getElementById('login-button');

// Modales y formularios de Olvidó Contraseña
const forgotPasswordModal = document.getElementById('forgot-password-modal');
const forgotPasswordForm = document.getElementById('forgot-password-form');
const sessionActiveModal = document.getElementById('session-active-modal');
const forceLoginButton = document.getElementById('force-login-button');
const cancelLoginButton = document.getElementById('cancel-login-button');

const permissionModal = document.getElementById('permission-modal');
const modalBackButton = document.getElementById('modal-back-button');
const closePermissionModal = permissionModal.querySelector('.close-button');
const ROL_PACIENTE = 2; // Definir el ID del rol de paciente

// Función de utilidad para mostrar mensajes de forma temporal
function displayMessage(message, type = 'error') {
    messageContainer.innerHTML = message;
    messageContainer.className = `message-container ${type}`;
    messageContainer.classList.remove('hidden');

    // Si es éxito, ocultar después de 3 segundos
    if (type === 'success') {
        setTimeout(() => {
            messageContainer.classList.add('hidden');
        }, 3000); // 3 segundos
    }
}

// ----------------------------------------------------
// A. LÓGICA DE INICIO DE SESIÓN
// ----------------------------------------------------
loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const startTime = Date.now();
    loginButton.disabled = true;
    displayMessage('Iniciando sesión...', 'info');

    const credentials = {
        documento: documentoInput.value,
        password: passwordInput.value
    };

    try {
        const response = await fetch('../api/login.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(credentials)
        });
        const result = await response.json();

        const endTime = Date.now();
        const processTime = endTime - startTime;

        // Criterio de Aceptación: Tiempo de procesamiento < 5 segundos
        console.log(`Tiempo de procesamiento: ${processTime} ms`);

        if (result.success) {
            // Éxito: Mostrar mensaje de bienvenida por 3s y redirigir
            displayMessage(result.message, 'success');

            if (result.user_id_rol == ROL_PACIENTE) {
                // ⚠️ La sesión se inicializa aquí
                sessionStorage.setItem('isLoggedIn', 'true');
                localStorage.setItem('sessionStartTime', Date.now());

                // 🔑 GUARDAR ID y NOMBRE EN sessionStorage (Para uso global en otras páginas)
                sessionStorage.setItem('id_paciente', result.id_paciente);
                sessionStorage.setItem('nombre_paciente', result.nombre_paciente);

                setTimeout(() => {
                    window.location.href = './../html/citas.html';
                }, 3000); // Redirigir después del mensaje de 3 segundos
            } else {
                // Rol 1 (Profesional) o cualquier otro: Acceso Bloqueado
                displayMessage(result.message, 'success'); // Muestra mensaje de bienvenida

                // 🔑 Mostrar modal
                permissionModal.classList.remove('hidden');

                // Limpiar la sesión en el servidor (para que el profesional pueda cerrar la sesión única)
                await fetch('../api/logout.php', { method: 'POST' });
            }
        } else if (result.session_active) {
            // Caso de Sesión Activa Única
            document.getElementById('session-active-msg').textContent = result.message;
            sessionActiveModal.classList.remove('hidden');

            // Pasar credenciales al botón de forzar login
            forceLoginButton.dataset.documento = credentials.documento;
            forceLoginButton.dataset.password = credentials.password;

            // El proceso de login no ha finalizado, así que re-habilitamos el botón
            loginButton.disabled = false;

        } else {
            // Credenciales inválidas o bloqueo (401/403)
            displayMessage(result.message, 'error');
            loginButton.disabled = false;
        }

    } catch (error) {
        displayMessage('Error de red o servidor. Intente de nuevo.', 'error');
        loginButton.disabled = false;
    }
});

// ----------------------------------------------------
// B. LÓGICA DE SESIÓN ACTIVA ÚNICA
// ----------------------------------------------------
forceLoginButton.addEventListener('click', async () => {
    sessionActiveModal.classList.add('hidden');
    loginButton.disabled = true;
    displayMessage('Forzando inicio de sesión...', 'info');

    const credentials = {
        documento: forceLoginButton.dataset.documento,
        password: forceLoginButton.dataset.password
    };

    try {
        const response = await fetch('../api/force_login.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(credentials)
        });
        const result = await response.json();

        if (result.success) {
            if (result.user_id_rol == ROL_PACIENTE) {
                displayMessage(result.message, 'success');
                sessionStorage.setItem('isLoggedIn', 'true');
                localStorage.setItem('sessionStartTime', Date.now());

                // 🔑 GUARDAR ID y NOMBRE EN sessionStorage (Para uso global en otras páginas)
                sessionStorage.setItem('id_paciente', result.id_paciente);
                sessionStorage.setItem('nombre_paciente', result.nombre_paciente);

                setTimeout(() => {
                    window.location.href = './../html/citas.html';
                }, 3000);
            } else {
                // Rol 1 (Profesional) o cualquier otro: Acceso Bloqueado
                displayMessage(result.message, 'success'); // Muestra mensaje de bienvenida

                // 🔑 Mostrar modal
                permissionModal.classList.remove('hidden');

                // Limpiar la sesión en el servidor (para que el profesional pueda cerrar la sesión única)
                await fetch('../api/logout.php', { method: 'POST' });
            }
        } else {
            displayMessage(result.message, 'error');
            loginButton.disabled = false;
        }
    } catch (error) {
        displayMessage('Error al forzar el inicio de sesión.', 'error');
        loginButton.disabled = false;
    }
});

cancelLoginButton.addEventListener('click', () => {
    sessionActiveModal.classList.add('hidden');
    loginButton.disabled = false;
});

// ----------------------------------------------------
// C. LÓGICA DE RECUPERACIÓN DE CONTRASEÑA
// ----------------------------------------------------
document.getElementById('forgot-password-link').addEventListener('click', (e) => {
    e.preventDefault();
    forgotPasswordModal.classList.remove('hidden');
    document.getElementById('forgot-documento').value = documentoInput.value; // Pre-llenar
    document.getElementById('forgot-message').classList.add('hidden');
});

forgotPasswordForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const doc = document.getElementById('forgot-documento').value;
    const forgotMessage = document.getElementById('forgot-message');
    forgotMessage.classList.add('hidden');

    try {
        const response = await fetch('../api/forgot_password.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ documento: doc })
        });
        const result = await response.json();

        forgotMessage.innerHTML = result.message;
        forgotMessage.className = `message-container success`;
        forgotMessage.classList.remove('hidden');

    } catch (error) {
        forgotMessage.innerHTML = 'Error de red. Intente de nuevo.';
        forgotMessage.className = `message-container error`;
        forgotMessage.classList.remove('hidden');
    }
});

document.getElementById('close-forgot-modal').addEventListener('click', () => {
    forgotPasswordModal.classList.add('hidden');
});

// ----------------------------------------------------
// D. ACCESIBILIDAD Y UI (Password Toggle, Tab/Enter)
// ----------------------------------------------------
togglePassword.addEventListener('click', () => {
    const type = passwordInput.type === 'password' ? 'text' : 'password';
    passwordInput.type = type;
    togglePassword.textContent = type === 'password' ? '🔒' : '🔓';
    togglePassword.setAttribute('aria-label', type === 'password' ? 'Mostrar contraseña' : 'Ocultar contraseña');
});

// La navegación con Tab y Enter es manejada de forma nativa por el navegador.


// ----------------------------------------------------
// E. LÓGICA DEL MODAL DE PERMISOS
// ----------------------------------------------------

// Manejador del botón "Volver al Inicio de Sesión"
modalBackButton.addEventListener('click', () => {
    permissionModal.classList.add('hidden');
    loginForm.reset(); // Limpia el formulario
    documentoInput.focus(); 
    loginButton.disabled = false;
});

// Manejador del botón de cierre 'x'
closePermissionModal.addEventListener('click', () => {
    permissionModal.classList.add('hidden');
    loginForm.reset();
    documentoInput.focus();
    loginButton.disabled = false;
});