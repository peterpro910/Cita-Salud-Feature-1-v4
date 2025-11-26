// /js/limpiar_agendamiento.js (Nuevo archivo)

document.addEventListener('DOMContentLoaded', () => {
    
    // --- Lógica de Prevención de Cache de Datos ---
    
    const isLogoutClearNeeded = ('sessionStorage' in window && sessionStorage.getItem('logout_clear_form') === 'true');

    if (isLogoutClearNeeded) {
        
        console.log('Detectado cierre de sesión previo. Limpiando campos del formulario.');
        
        // 1. Selecciona todos los campos de entrada relevantes en el formulario de agendamiento
        // Ajusta el selector si los campos están dentro de un <form id="agendarForm"> específico
        const formInputs = document.querySelectorAll('input:not([type="hidden"]), select, textarea');
        
        // 2. Limpia los valores de todos los campos
        formInputs.forEach(input => {
            // Limpia texto, número, email, etc.
            if (input.type !== 'checkbox' && input.type !== 'radio' && input.type !== 'submit' && input.type !== 'button') {
                input.value = '';
            } 
            // Limpia checkboxes/radio
            else if (input.type === 'checkbox' || input.type === 'radio') {
                input.checked = false;
            }
        });
    }
});