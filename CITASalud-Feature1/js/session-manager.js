// js/session-manager.js - Versión Corregida

// Tiempos en milisegundos
const INACTIVITY_TIMEOUT = 30 * 60 * 1000;       // 30 minutos
const MAX_SESSION_DURATION = 60 * 60 * 1000;    // 1 hora
const EXPIRATION_WARNING_TIME = 2 * 60 * 1000;  // 2 minutos antes de expirar
const REMOTE_CHECK_INTERVAL = 30 * 1000;        // 30 segundos para la verificación remota

let inactivityTimer;
let durationCheckInterval;
let warningTimeout;
let remoteCheckInterval;
let isInternalNavigation = false; // 🔑 NUEVA VARIABLE

/** Redirige al login y limpia el lado del cliente y del servidor. */
async function expireSession(reason = "Su sesión ha expirado.") {
    clearInterval(durationCheckInterval);
    clearInterval(remoteCheckInterval);
    clearTimeout(inactivityTimer);
    clearTimeout(warningTimeout);
    
    // Quitar el listener beforeunload para evitar doble-logout
    window.removeEventListener('beforeunload', handleBeforeUnload);

    try {
        // Notificar al servidor para limpiar el session_id_activa de la DB
        await fetch('../api/logout.php', { method: 'POST' }); 
    } catch (error) {
        console.error("Error al notificar cierre de sesión al servidor:", error);
    }
    
    alert(reason + " Será redirigido/a al inicio de sesión.");
    
    // Limpieza total del lado del cliente
    sessionStorage.clear();
    localStorage.removeItem('sessionStartTime');
    window.location.href = './../html/login.html'; 
}

/** 🔑 FIX: Solo limpia la sesión si NO es navegación interna */
function handleBeforeUnload(event) {
    // Si es navegación interna, no hacer nada
    if (isInternalNavigation) {
        return;
    }
    
    // Solo si es cierre real de pestaña/navegador
    if (sessionStorage.getItem('isLoggedIn') === 'true') {
        const data = new FormData();
        navigator.sendBeacon('../api/logout.php', data);
    }
}

/** 🚨 Verifica si la sesión es aún la activa en la DB. */
async function checkRemoteSessionValidity() {
    try {
        const response = await fetch('../api/check_session.php');
        const result = await response.json();
        
        if (!result.is_valid) {
            // La sesión actual fue reemplazada por una nueva en otro dispositivo.
            expireSession("Su sesión ha sido cerrada porque se inició una nueva sesión en otro lugar.");
        }
    } catch (error) {
        console.error("Error al verificar la sesión remota:", error);
    }
}

/** Verifica si la duración máxima de 1 hora o el warning de 2 minutos se ha alcanzado. */
function checkSessionDuration() {
    const startTime = parseInt(localStorage.getItem('sessionStartTime'));
    if (!startTime) return;

    const elapsed = Date.now() - startTime;
    const remaining = MAX_SESSION_DURATION - elapsed;
    
    // Si quedan 2 minutos o menos, y no hemos mostrado la alerta
    if (remaining <= EXPIRATION_WARNING_TIME && remaining > 0 && !warningTimeout) {
        showExpirationWarning(remaining);
    } 
    
    // Si el tiempo máximo ha expirado
    if (remaining <= 0) {
        expireSession("Su sesión ha expirado tras 1 hora de uso continuo.");
    }
}

/** Muestra la alerta de expiración y establece el timer para el cierre forzado. */
function showExpirationWarning(remaining) {
    if (confirm("Su sesión está apunto de expirar. ¿Desea extender su sesión?")) {
        extendSession();
    } else {
        // Si no desea extender, se establece un timer para cerrar cuando el tiempo acabe
        warningTimeout = setTimeout(() => {
            expireSession("Su sesión ha expirado tras 1 hora de uso continuo.");
        }, remaining);
    }
}

/** Reinicia la duración máxima y la inactividad. */
function extendSession() {
    localStorage.setItem('sessionStartTime', Date.now());
    if (warningTimeout) clearTimeout(warningTimeout);
    warningTimeout = null;
    resetInactivityTimer();
}

/** Reinicia el temporizador de inactividad (30 min). */
function resetInactivityTimer() {
    clearTimeout(inactivityTimer);
    inactivityTimer = setTimeout(() => {
        expireSession("Su sesión ha expirado por inactividad (30 minutos).");
    }, INACTIVITY_TIMEOUT);
}

/** 🔑 NUEVO: Detecta clicks en enlaces internos */
function setupInternalNavigationDetection() {
    // Detectar clicks en enlaces del navbar y otros enlaces internos
    document.addEventListener('click', (e) => {
        const link = e.target.closest('a');
        if (link && link.href) {
            const currentDomain = window.location.origin;
            const linkDomain = new URL(link.href, window.location.href).origin;
            
            // Si el enlace es del mismo dominio, es navegación interna
            if (linkDomain === currentDomain) {
                isInternalNavigation = true;
                
                // Resetear después de un breve momento
                setTimeout(() => {
                    isInternalNavigation = false;
                }, 100);
            }
        }
    });
}

/** Inicializa la gestión de la sesión. */
function startSessionManager() {
    if (!localStorage.getItem('sessionStartTime')) {
        window.location.href = './../html/login.html'; 
        return; 
    }

    // Monitorear actividad
    document.addEventListener('mousemove', resetInactivityTimer);
    document.addEventListener('keypress', resetInactivityTimer);
    document.addEventListener('click', resetInactivityTimer);
    document.addEventListener('scroll', resetInactivityTimer);

    // Iniciar verificación de duración y la verificación remota
    durationCheckInterval = setInterval(checkSessionDuration, 5000); 
    remoteCheckInterval = setInterval(checkRemoteSessionValidity, REMOTE_CHECK_INTERVAL);

    // Iniciar el contador de inactividad
    resetInactivityTimer();
    
    // Ejecutar verificación inmediata al cargar la página
    checkRemoteSessionValidity();
    
    // 🔑 Configurar detección de navegación interna
    setupInternalNavigationDetection();
    
    // Añadir listener para cierre de pestaña
    window.addEventListener('beforeunload', handleBeforeUnload);
}

// 🔑 INICIO DE LA LÓGICA:
if (sessionStorage.getItem('isLoggedIn') === 'true') {
    startSessionManager();
} else if (window.location.pathname.indexOf('login.html') === -1) {
    // Si no está logueado y no está en la página de login, redirigir
    window.location.href = './../html/login.html'; 
}