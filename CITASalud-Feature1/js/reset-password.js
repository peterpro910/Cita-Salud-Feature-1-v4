// js/reset-password.js

const resetPasswordForm = document.getElementById('reset-password-form');
const newPasswordInput = document.getElementById('new-password');
const confirmPasswordInput = document.getElementById('confirm-password');
const resetMessageContainer = document.getElementById('reset-message-container');

// Obtener token y documento de la URL
const urlParams = new URLSearchParams(window.location.search);
const token = urlParams.get('token');
const documento = urlParams.get('doc');

if (!token || !documento) {
    resetMessageContainer.innerHTML = "Enlace de restablecimiento incompleto. Por favor, solicite uno nuevo.";
    resetMessageContainer.classList.add('error');
    resetMessageContainer.classList.remove('hidden');
}

function validatePassword(password) {
    const criteria = [];
    if (password.length < 7 || password.length > 16) criteria.push("Entre 7 y 16 caracteres.");
    if (!/[A-Z]/.test(password)) criteria.push("Al menos una letra mayúscula.");
    if (!/[a-z]/.test(password)) criteria.push("Al menos una letra minúscula.");
    if (!/[0-9]/.test(password)) criteria.push("Al menos un número.");
    // Caracteres especiales
    if (!/[!@#$%^&*()_+={}\[\]|\\:;"'<>,.?\/~`]/.test(password)) criteria.push("Al menos un carácter especial.");
    
    return criteria;
}

resetPasswordForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    resetMessageContainer.classList.add('hidden');

    const newPassword = newPasswordInput.value;
    const confirmPassword = confirmPasswordInput.value;

    if (newPassword !== confirmPassword) {
        resetMessageContainer.innerHTML = "Las contraseñas no coinciden.";
        resetMessageContainer.className = 'message-container error';
        resetMessageContainer.classList.remove('hidden');
        return;
    }

    const validationErrors = validatePassword(newPassword);
    if (validationErrors.length > 0) {
        resetMessageContainer.innerHTML = `**La contraseña no cumple los requisitos:**<br><ul>${validationErrors.map(err => `<li>${err}</li>`).join('')}</ul>`;
        resetMessageContainer.className = 'message-container error';
        resetMessageContainer.classList.remove('hidden');
        return;
    }

    try {
        const response = await fetch('../api/reset_password.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ documento, token, new_password: newPassword, confirm_password: confirmPassword })
        });
        const result = await response.json();

        if (result.success) {
            resetMessageContainer.innerHTML = `${result.message} Será redirigido al login en 5 segundos.`;
            resetMessageContainer.className = 'message-container success';
            resetMessageContainer.classList.remove('hidden');
            
            // Redirigir al login
            setTimeout(() => {
                window.location.href = './../html/login.html'; 
            }, 5000); 

        } else {
            resetMessageContainer.innerHTML = result.message;
            resetMessageContainer.className = 'message-container error';
            resetMessageContainer.classList.remove('hidden');
        }

    } catch (error) {
        resetMessageContainer.innerHTML = 'Error de red o servidor.';
        resetMessageContainer.className = 'message-container error';
        resetMessageContainer.classList.remove('hidden');
    }
});