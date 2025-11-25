// Script: js/cancelacion.js

document.addEventListener('DOMContentLoaded', () => {

    // --- Variables de DOM y Configuración ---

    // **MODIFICACIÓN CLAVE:** Obtener idPaciente del almacenamiento de sesión.
    // Esto asegura que la variable esté disponible para las llamadas a la API.
    const idPaciente = sessionStorage.getItem('id_paciente');

    const modalMensaje = document.getElementById('modal-mensaje');
    const modalTitulo = document.getElementById('modal-titulo'); // Necesario para mostrar mensajes
    const modalTexto = document.getElementById('modal-texto');   // Necesario para mostrar mensajes
    const btnCerrarMensaje = document.getElementById('modal-cerrar-btn');

    const motivoSelect = document.getElementById('motivo-select');
    const btnContinuarCancelacion = document.getElementById('btn-continuar-cancelacion');
    const modalCancelacion = document.getElementById('modal-cancelacion');

    const modalResumen = document.getElementById('modal-resumen-cancelacion');
    const resumenEspecialidad = document.getElementById('resumen-especialidad');
    const resumenFecha = document.getElementById('resumen-fecha');
    const resumenHora = document.getElementById('resumen-hora');
    const resumenProfesional = document.getElementById('resumen-profesional');
    const resumenSede = document.getElementById('resumen-sede');
    const resumenMotivo = document.getElementById('resumen-motivo-seleccionado');
    const resumenCancelacionesMes = document.getElementById('resumen-cancelaciones-mes');
    const btnConfirmarCancelacion = document.getElementById('btn-confirmar-cancelacion');
    const btnModificarMotivo = document.getElementById('btn-modificar-motivo');
    const btnCerrarCancelacion = document.getElementById('btn-cerrar-cancelacion');
    const formMotivo = document.getElementById('form-motivo-cancelacion');
    const btnCerrarResumen = document.getElementById('btn-cerrar-resumen-cancelacion');


    let citaDataTemporal = {};

    // Función de utilidad para mostrar modales de mensaje (globalizada para que el script principal la pueda usar si la necesita)
    // El script principal ya tiene una versión de esta, pero se mantiene aquí para la funcionalidad de este modal.
    const mostrarModalMensaje = (titulo, texto, type = 'info') => {
        if (!modalMensaje || !modalTitulo || !modalTexto) return;
        modalTitulo.innerHTML = titulo;
        modalTexto.innerHTML = texto;
        modalMensaje.style.display = 'flex';
    };

    // Función de recarga (asume que el script principal la ha expuesto globalmente)
    const cargarCitas = window.cargarCitas || function () {
        console.warn("Función 'cargarCitas' no definida. La vista de citas no se recargará.");
    };


    // -------------------------------------------------------------------------
    // HU-06: Lógica de Carga y Inicio de Cancelación
    // -------------------------------------------------------------------------

    // Inicia el proceso al hacer clic en el botón "Cancelar" de la card.
    // Es global (`window.`) para ser llamada desde el script de renderizado de citas.
    window.iniciarProcesoCancelacion = function (e) {
        const target = e.target;

        // CRÍTICO: Asegurarse de que el ID del paciente esté disponible.
        if (!idPaciente) {
            mostrarModalMensaje('Error de Sesión', 'No se pudo identificar al paciente. Por favor, recargue la página.', 'error');
            return;
        }

        const idCita = target.getAttribute('data-cita-id');

        console.log("[DEBUG CANCELACION] ID Leído del botón:", idCita);

        if (!idCita) {
            mostrarModalMensaje('Error Interno', 'Faltan datos de la cita para iniciar la cancelación.', 'error');
            return;
        }

        // Almacenar datos de la cita desde los data-attributes del botón
        citaDataTemporal = {
            id: idCita,
            especialidad: target.getAttribute('data-especialidad'),
            fecha: target.getAttribute('data-fecha'),
            hora: target.getAttribute('data-hora'),
            profesional: target.getAttribute('data-profesional'),
            sede: target.getAttribute('data-sede'),
            motivo_id: null,
            motivo_nombre: null
        };

        // **VALIDACIÓN DE 24 HORAS (Frontend)**
        const fechaCita = new Date(`${citaDataTemporal.fecha}T${citaDataTemporal.hora}`);
        const ahora = new Date();
        const diffHoras = (fechaCita.getTime() - ahora.getTime()) / (1000 * 60 * 60);

        if (diffHoras < 24) {
            mostrarModalMensaje('Cancelación Rechazada', 'No es posible cancelar la cita con menos de 24 horas de anticipación.', 'error');
            return;
        }

        // Mostrar el modal de selección de motivo
        motivoSelect.value = "";
        btnContinuarCancelacion.disabled = true;
        modalCancelacion.style.display = 'flex';
    }


    // Cargar los motivos de cancelación (HU-06)
    async function cargarMotivos() {
        try {
            const response = await fetch(`../api/get_motivos_cancelacion.php`);
            const data = await response.json();

            motivoSelect.innerHTML = '<option value="" disabled selected hidden>Seleccione un motivo</option>';

            if (response.ok && Array.isArray(data) && data.length > 0) {
                data.forEach(motivo => {
                    const option = document.createElement('option');
                    option.value = motivo.id;
                    option.textContent = motivo.nombre;
                    motivoSelect.appendChild(option);
                });
            } else {
                motivoSelect.innerHTML = '<option value="" disabled>Error al cargar motivos</option>';
                motivoSelect.disabled = true;
            }
        } catch (error) {
            console.error('Error al cargar motivos:', error);
            mostrarModalMensaje('Error de Conexión', 'Fallo al cargar la lista de motivos de cancelación.', 'error');
        }
    }

    // Manejar cambio en la selección del motivo (HU-06)
    if (motivoSelect) {
        motivoSelect.addEventListener('change', (e) => {
            btnContinuarCancelacion.disabled = !e.target.value;
        });
    }

    // -------------------------------------------------------------------------
    // HU-07: Lógica de Resumen y Confirmación
    // -------------------------------------------------------------------------

    if (formMotivo) {
        formMotivo.addEventListener('submit', async (e) => {
            e.preventDefault();

            // 1. Almacenar el motivo seleccionado
            citaDataTemporal.motivo_id = motivoSelect.value;
            citaDataTemporal.motivo_nombre = motivoSelect.options[motivoSelect.selectedIndex].text;

            // 2. Ocultar el modal de motivo y preparar resumen
            modalCancelacion.style.display = 'none';
            resumenCancelacionesMes.innerHTML = `<span style="color: #004a99;">Cargando límites...</span>`;

            // 3. **ACTUALIZAR RESUMEN CON DATOS**
            if (resumenEspecialidad) resumenEspecialidad.textContent = citaDataTemporal.especialidad || 'N/A';
            if (resumenFecha) resumenFecha.textContent = citaDataTemporal.fecha || 'N/A';
            if (resumenHora) resumenHora.textContent = citaDataTemporal.hora || 'N/A';
            if (resumenProfesional) resumenProfesional.textContent = citaDataTemporal.profesional || 'N/A';
            if (resumenSede) resumenSede.textContent = citaDataTemporal.sede || 'N/A';
            if (resumenMotivo) resumenMotivo.textContent = citaDataTemporal.motivo_nombre || 'N/A';

            modalResumen.style.display = 'flex'; // Mostrar el modal de resumen

            // 4. LLAMADA ASÍNCRONA A LA API para obtener los límites
            try {
                // Validación para evitar llamadas a la API si falta el ID
                if (!idPaciente) throw new Error("ID de paciente no encontrado.");

                const response = await fetch(`../api/count_cancelaciones.php?id_paciente=${idPaciente}`);
                const data = await response.json();
                const LIMITE_MENSUAL = 3;

                if (response.ok) {
                    let mensajeLimite = '';
                    let limite = data.limite || LIMITE_MENSUAL;
                    let restantes = data.restantes !== undefined ? data.restantes : (limite - (data.totales || 0));

                    btnConfirmarCancelacion.disabled = false;

                    if (restantes > 0) {
                        mensajeLimite = `Te quedan ${restantes} cancelaciones disponibles este mes (Límite: ${limite}).`;
                    } else {
                        mensajeLimite = `<span style="color: red; font-weight: bold;">¡ADVERTENCIA!</span> Ha alcanzado el límite de ${limite} cancelaciones mensuales. NO PUEDE CANCELAR MÁS.`;
                        btnConfirmarCancelacion.disabled = true;
                    }
                    resumenCancelacionesMes.innerHTML = mensajeLimite;
                } else {
                    resumenCancelacionesMes.innerHTML = `Error del servidor al verificar límites.`;
                }
            } catch (error) {
                console.error('Error al obtener el límite de cancelaciones:', error);
                resumenCancelacionesMes.innerHTML = `Error de conexión con la API de límites.`;
                btnConfirmarCancelacion.disabled = true;
            }
        });
    }

    // Modificar Motivo (HU-07)
    if (btnModificarMotivo) {
        btnModificarMotivo.addEventListener('click', () => {
            modalResumen.style.display = 'none';
            modalCancelacion.style.display = 'flex';
        });
    }

    // Cerrar Modal de Motivo
    if (btnCerrarCancelacion) {
        btnCerrarCancelacion.addEventListener('click', () => {
            modalCancelacion.style.display = 'none';
        });
    }


    // --- HU-07: Acción final de Confirmar Cancelación ---
    if (btnConfirmarCancelacion) {
        btnConfirmarCancelacion.addEventListener('click', async () => {
            btnConfirmarCancelacion.disabled = true;

            const data = {
                id_cita: citaDataTemporal.id,
                id_paciente: idPaciente,
                id_motivo_cancelacion: citaDataTemporal.motivo_id
            };

            let response = null;
            let result = null;

            try {
                response = await fetch('../api/cancelar_cita.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });

                try { result = await response.json(); } catch (e) { }

                if (response.ok) {
                    modalResumen.style.display = 'none';
                    let mensajeExito = result.message || 'Cita cancelada correctamente. Se ha enviado la confirmación por email.';
                    if (result && result.cancelaciones_restantes !== undefined) {
                        mensajeExito += `<br><br>Le quedan <strong>${result.cancelaciones_restantes} cancelaciones</strong> disponibles este mes.`;
                    }
                    mostrarModalMensaje('Cancelación Exitosa', mensajeExito, 'success');
                    cargarCitas(); // Recargar las citas después del éxito

                } else {
                    modalResumen.style.display = 'none';
                    const tituloError = 'Error de Cancelación  (Cód. ' + response.status + ')';
                    const textoError = (result && result.message) || 'Error del servidor al intentar cancelar.';
                    mostrarModalMensaje(tituloError, textoError, 'error');
                }

            } catch (error) {
                console.error('Error de red:', error);
                modalResumen.style.display = 'none';
                mostrarModalMensaje('Error de Conexión 📡', 'No se pudo contactar al servidor para cancelar.', 'error');
            } finally {
                btnConfirmarCancelacion.disabled = false;
            }
        });
    }

    if (btnCerrarResumen) {
        btnCerrarResumen.addEventListener('click', () => {
            if (modalResumen) {
                modalResumen.style.display = 'none';
            }
        });
    }


    // Cerrar el modal de mensaje general
    if (btnCerrarMensaje) {
        btnCerrarMensaje.addEventListener('click', () => {
            if (modalMensaje) {
                modalMensaje.style.display = 'none';
            }
        });
    }

    // Inicializar la carga de motivos al cargar la página
    cargarMotivos();
});