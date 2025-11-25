// js/notifications.js

document.addEventListener('DOMContentLoaded', () => {

    // 1. INYECCIÓN DE ESTILOS CSS EN EL <head>
    const style = document.createElement('style');
    style.innerHTML = `
#notification-toast-container {
    /* Posicionamiento y tamaño (sin cambios) */
    display: block;
    position: fixed;
    right: 1.5rem;
    bottom: 1.5rem;
    left: auto;
    width: 380px;
    max-width: 90%;
    z-index: 9990;

    /* Transición inicial y animaciones (sin cambios) */
    opacity: 0;
    visibility: hidden;
    transform: translateX(100%);
    transition: opacity 0.4s ease-out, transform 0.4s ease-out, visibility 0.4s;
}

/* Clase para mostrar el Toast con la transición (sin cambios) */
#notification-toast-container.show {
    opacity: 1;
    visibility: visible;
    transform: translateX(0);
}

.toast-content {
    /* **CAMBIO DE FONDO AQUÍ** */
    /* Fondo ligeramente gris (Similar a #f1f5f9 o #f8fafc) para contraste */
    background: #f8fafc; 
    
    border-radius: 12px;
    /* Borde izquierdo distintivo en azul (similar a mensajes .info) */
    border-left: 4px solid #3b82f6; 
    
    /* Sombra profesional (sin cambios) */
    box-shadow: 0 8px 25px rgba(59, 130, 246, 0.2); 
    
    padding: 1.25rem;
    font-family: 'Inter', sans-serif;
    color: #0f172a;
}

.toast-header {
    /* Estilos del encabezado (sin cambios) */
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.75rem;
    /* Separador suave */
    border-bottom: 1px solid #e0f2fe; 
    padding-bottom: 0.5rem;
}

.toast-header h4 {
    /* Título con gradiente azul para destacar (sin cambios) */
    margin: 0;
    background: linear-gradient(135deg, #0ea5e9 0%, #3b82f6 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    font-size: 1.1rem;
    font-weight: 700;
}

.toast-close-btn {
    /* Botón de cierre (fondo ajustado al nuevo fondo del Toast para que no contraste) */
    background: #ffffff; /* Usamos blanco para que destaque ligeramente del #f8fafc */
    border: 1px solid #e0f2fe;
    border-radius: 8px;
    color: #64748b; 
    font-size: 1.2rem;
    cursor: pointer;
    line-height: 1;
    padding: 0.4rem 0.6rem;
    transition: all 0.2s ease;
}

.toast-close-btn:hover {
    background: #fee2e2;
    border-color: #ef4444;
    color: #dc2626;
    transform: rotate(5deg);
}

.toast-list {
    /* Estilos de la lista (sin cambios) */
    list-style: none;
    padding: 0;
    margin: 0 0 1rem 0;
    font-size: 0.95rem;
    color: #475569;
}

.toast-list li {
    margin-bottom: 0.4rem;
    line-height: 1.4;
    font-weight: 500;
}

/* Botón de Aceptar/Acción dentro del Toast (sin cambios) */
#notification-accept-btn {
    display: block;
    width: 100%;
    padding: 0.75rem 1rem;
    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
    color: white;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9rem;
    transition: all 0.3s ease;
    box-shadow: 0 4px 10px rgba(16, 185, 129, 0.3);
}

#notification-accept-btn:hover {
    background-color: #057a4e;
    transform: translateY(-1px);
    box-shadow: 0 6px 15px rgba(16, 185, 129, 0.4);
}
    `;
    document.head.appendChild(style);

    // 2. Elementos DOM y Configuración
    const toastContainer = document.getElementById('notification-toast-container');
    
    if (!toastContainer) return;

    const idPaciente = sessionStorage.getItem('id_paciente');
    const nombrePaciente = sessionStorage.getItem('nombre_paciente') || 'Estimado Paciente'; 
    
    if (!idPaciente) return; 

    const NOTIFICATION_API_URL = `./../api/get_notifications.php?id_paciente=${idPaciente}`;
    const ACCEPTED_KEY = 'accepted_appointment_notifications_persistent'; 
    
    // Función de ayuda para formato de fecha
    const formatDateTime = (dateStr, timeStr) => {
        const date = new Date(`${dateStr}T${timeStr}`);
        const formattedDate = date.toLocaleDateString('es-ES', { 
            weekday: 'short', day: 'numeric', month: 'short'
        });
        // 🔑 CLAVE: Se fuerza el formato de 12 horas con AM/PM (hour12: true)
        const formattedTime = date.toLocaleTimeString('es-ES', { 
            hour: '2-digit', 
            minute: '2-digit',
            hour12: true 
        }); 
        return { formattedDate, formattedTime };
    };
    
    // Funciones de control de estado y visibilidad (Omitidas por brevedad)
    function isNotificationAccepted(idCita) {
        const acceptedCitas = JSON.parse(localStorage.getItem(ACCEPTED_KEY)) || {};
        return acceptedCitas[idCita] === true;
    }

    function markNotificationsAccepted(pendingCitas) {
        let acceptedCitas = JSON.parse(localStorage.getItem(ACCEPTED_KEY)) || {};
        
        pendingCitas.forEach(cita => {
            acceptedCitas[cita.id_cita] = true;
        });
        
        localStorage.setItem(ACCEPTED_KEY, JSON.stringify(acceptedCitas));
        
        toastContainer.classList.remove('show');
    }
    
    function showToast() {
        setTimeout(() => {
            toastContainer.classList.add('show');
        }, 10);
    }

    function hideToast() {
        toastContainer.classList.remove('show');
    }


    // 3. Obtención de datos y Renderizado
    async function fetchAndDisplayPopup() {
        try {
            const response = await fetch(NOTIFICATION_API_URL);
            if (!response.ok) throw new Error(`Error HTTP! Estado: ${response.status}`);
            const result = await response.json();

            if (result.success && result.count > 0) {
                
                const pendingCitas = result.data.filter(cita => !isNotificationAccepted(cita.id_cita));
                
                if (pendingCitas.length === 0) {
                    return;
                }

                // Generar el contenido HTML completo del Toast
                let listHtml = pendingCitas.map(cita => {
                    const { formattedDate, formattedTime } = formatDateTime(cita.fecha, cita.hora);
                    
                    // Asegurar que los nuevos campos existen (siempre devuelve al menos '')
                    const profesional = cita.nombre_profesional || 'Profesional no asignado';
                    const sede = cita.nombre_sede || 'Sede principal';
                    const direccion = cita.direccion_sede || 'Dirección no disponible';

                    return `
                        <li>
                            <br>
                            <i class="fas fa-calendar-check"></i> 
                            <strong>Especialidad:</strong> ${cita.nombre_especialidad}
                            <br>
                            <i class="fas fa-user-md"></i>
                            <strong>Profesional:</strong> ${profesional}
                            <br>
                            <i class="fas fa-clock"></i>
                            <strong>Fecha y Hora:</strong> ${formattedDate} a las ${formattedTime}
                            <br>
                            <i class="fas fa-hospital-alt"></i>
                            <strong>Sede:</strong> ${sede} (${direccion})
                        </li>
                    `;
                }).join('');
                
                toastContainer.innerHTML = `
                    <div class="toast-content">
                        <div class="toast-header">
                            <h4><i class="fas fa-bullhorn"></i> Recordatorio de Cita</h4>
                            <button class="toast-close-btn" id="toast-close-btn">&times;</button>
                        </div>
                        <p style="font-size: 0.95rem;">
                            Hola ${nombrePaciente}, tienes ${pendingCitas.length} cita(s) en las próximas 24 horas:
                        </p>
                        <ul class="toast-list">
                            ${listHtml}
                        </ul>
                        <button id="notification-accept-btn">
                            Aceptar 
                        </button>
                    </div>
                `;
                
                // 4. Asignar Eventos 
                const currentAcceptBtn = document.getElementById('notification-accept-btn');
                const closeBtn = document.getElementById('toast-close-btn');

                currentAcceptBtn.onclick = () => {
                    markNotificationsAccepted(pendingCitas);
                };

                closeBtn.onclick = () => {
                    hideToast();
                };

                showToast();

            } 

        } catch (error) {
            console.error('Fallo al obtener notificaciones de citas:', error);
        }
    }
    
    fetchAndDisplayPopup();
});