// /js/citas.js
document.addEventListener('DOMContentLoaded', () => {

    // -----------------------------------------------------------
    // 1. CONFIGURACIÓN Y GLOBALIZACIÓN
    // -----------------------------------------------------------

    const idPaciente = sessionStorage.getItem('id_paciente');
    if (!idPaciente) {
        alert('Por favor, inicie sesión primero.');
        window.location.href = './../html/login.html';
        return;
    }
    
    // **GLOBALIZACIÓN:** Exponer el ID del paciente.
    window.idPaciente = idPaciente; 

    const citasContainer = document.getElementById('citas-container');
    const mensajeDiv = document.getElementById('mensaje');
    const modal = document.getElementById('modal-detalle-cita');
    const modalContent = document.getElementById('modal-info-body');
    const btnCerrarModal = document.querySelector('#modal-detalle-cita .close-modal-btn');
    
    // Elementos del Modal de Mensaje
    const modalMensaje = document.getElementById('modal-mensaje');
    const modalTitulo = document.getElementById('modal-titulo');
    const modalTexto = document.getElementById('modal-texto');
    const btnCerrarMensaje = document.getElementById('modal-cerrar-btn'); 

    // Función auxiliar para mostrar mensajes en el DIV superior
    function mostrarMensaje(texto, tipo) {
        mensajeDiv.textContent = texto;
        mensajeDiv.className = `mensaje ${tipo}`;
        mensajeDiv.setAttribute('aria-live', 'polite');
    }
    
    // **GLOBALIZACIÓN:** Función para mostrar el modal de mensajes.
    window.mostrarModalMensaje = function(titulo, texto, type = 'info', callback = null) {
        if (modalMensaje && modalTitulo && modalTexto && btnCerrarMensaje) {
            modalTitulo.innerHTML = titulo;
            modalTexto.innerHTML = texto;
            modalMensaje.className = `modal modal-${type}`; 
            modalMensaje.style.display = 'flex';

            const closeHandler = () => {
                modalMensaje.style.display = 'none';
                btnCerrarMensaje.removeEventListener('click', closeHandler);
                if (callback) {
                    callback();
                }
            };
            
            btnCerrarMensaje.removeEventListener('click', closeHandler);
            btnCerrarMensaje.addEventListener('click', closeHandler);

            } else {
                alert(titulo + "\n" + texto);
                if (callback) callback();
            }
            };
    
    // **GLOBALIZACIÓN:** Función de Recarga
    window.cargarCitas = cargarCitas; 
    
    // --- Funciones de utilidad ---
    function getEstadoClass(id_estado) {
        switch (parseInt(id_estado)) { 
            case 1: return 'estado-agendada'; 
            case 2: return 'estado-modificada'; 
            case 3: return 'estado-cancelada'; 
            case 4: return 'estado-asistida'; 
            case 5: return 'estado-sin-asistencia'; 
            default: return 'estado-pasada';
        }
    }

    function getTiempoRestante(fechaHora) {
        const ahora = new Date();
        const cita = new Date(fechaHora);
        const diff = cita.getTime() - ahora.getTime();

        if (diff < 0) return null;

        const dias = Math.floor(diff / (1000 * 60 * 60 * 24));
        const horas = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutos = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));

        return `${dias}d ${horas}h ${minutos}m`;
    }

    // **GLOBALIZACIÓN:** Hacemos global formatDateTime
    window.formatDateTime = function(dateStr, timeStr, locale = 'es-CO') {
        if (!dateStr || !timeStr) return { fecha: '', hora: '', fechaHora: '' };
        const dateObj = new Date(`${dateStr}T${timeStr}`);
        const fechaTexto = dateObj.toLocaleDateString(locale, { year: 'numeric', month: '2-digit', day: '2-digit' });
        const horaTexto = dateObj.toLocaleTimeString(locale, { hour: '2-digit', minute: '2-digit', hour12: true });
        return { fecha: fechaTexto, hora: horaTexto, fechaHora: `${dateStr} ${timeStr}` };
    }

    // =======================================
    //          INICIO: LÓGICA HU-20 (Especialidad)
    // =======================================
    
    const selectEspecialidad = document.getElementById('filtro-especialidad');
    const btnLimpiarEspecialidad = document.getElementById('btn-limpiar-filtro-especialidad'); 
    const KEY_FILTRO_ESP = 'filtroEspecialidadGuardado';
    
    /** @type {Object} Mapa de especialidades y sus nombres */
    let mapaEspecialidades = {}; 

    /**
     * Obtiene especialidades con conteo desde la API (HU-20)
     */
    async function cargarEspecialidades() {
        if (!selectEspecialidad) return;

        try {
            // NOTA: Debes implementar este endpoint en PHP
            const response = await fetch(`./../api/get_especialidades_paciente.php?id_paciente=${idPaciente}`); 
            const data = await response.json();

            if (!response.ok) throw new Error(data.message || 'Error al obtener especialidades.');

            selectEspecialidad.innerHTML = '<option value="todas">Todas las especialidades</option>';
            mapaEspecialidades = {};

            if (data.especialidades && data.especialidades.length > 0) {
                // Ordenar alfabéticamente el array de especialidades antes de poblar
                 data.especialidades.sort((a, b) => a.nombre_especialidad.localeCompare(b.nombre_especialidad));
                
                data.especialidades.forEach(esp => {
                    const nombreConConteo = `${esp.nombre_especialidad} (${esp.total_citas})`;
                    const option = new Option(nombreConConteo, esp.id_especialidad); 
                    selectEspecialidad.appendChild(option);

                    mapaEspecialidades[esp.id_especialidad] = esp.nombre_especialidad;
                });
            }

            // Aplicar Persistencia de Filtro de Especialidad
            const filtroGuardado = localStorage.getItem(KEY_FILTRO_ESP) || 'todas';
            selectEspecialidad.value = filtroGuardado;
            
        } catch (error) {
            console.error('Error al cargar especialidades:', error);
            // Mostrar una opción de error si la carga falla
            selectEspecialidad.innerHTML = '<option value="todas">Error al cargar</option>';
        }
    }
    
    // =======================================
    //          FIN: LÓGICA HU-20
    // =======================================


    // =======================================
    //          INICIO: LÓGICA HU-17 (Estado)
    // =======================================

    const filtroSelect = document.getElementById('filtro-estado'); 
    const btnLimpiarFiltro = document.getElementById('btn-limpiar-filtro'); 
    const mensajeListaVacia = document.getElementById('mensaje-lista-vacia');
    
    /** @type {Array<Object>} Caché global de citas */
    let todasLasCitas = [];
    const KEY_FILTRO_ESTADO = 'filtroEstadoGuardado'; 

    const MAPA_ESTADOS = {
        1: 'Agendada', 4: 'Asistida', 3: 'Cancelada', 2: 'Modificada', 5: 'Sin Asistencia'
    };
    const ESTADOS_ORDENADOS_IDS = [1, 4, 3, 2, 5]; 

    /**
     * Calcula contadores desde el caché global
     */
    function calcularContadores(citas) {
        const counts = {};
        ESTADOS_ORDENADOS_IDS.forEach(id => counts[id] = 0);
        
        for (const cita of citas) {
            const id = parseInt(cita.id_estado);
            if (counts.hasOwnProperty(id)) {
                counts[id]++;
            }
        }
        return counts;
    }

    /**
     * Puebla el dropdown de ESTADO con contadores
     */
    function popularDropdownFiltro(counts) {
        if (!filtroSelect) return; 
        filtroSelect.innerHTML = '';
        
        const opcionTodas = new Option(`Todas las citas (${todasLasCitas.length})`, 'todas'); 
        filtroSelect.appendChild(opcionTodas);
        
        for (const id of ESTADOS_ORDENADOS_IDS) {
            const nombre = MAPA_ESTADOS[id] || 'Desconocido';
            const count = counts[id] || 0;
            const opcion = new Option(`${nombre} (${count})`, id); 
            filtroSelect.appendChild(opcion);
        }
    }
    
    /**
     * Muestra el mensaje de lista vacía
     */
    function mostrarMensajeVacio(filtroEstado, filtroEspecialidad) { 
        if (!mensajeListaVacia) return;
        
        let texto = 'No tiene citas registradas.';
        if (filtroEstado !== 'todas' || filtroEspecialidad !== 'todas') {
             const nombreEstado = MAPA_ESTADOS[filtroEstado] || '';
             const nombreEspecialidad = mapaEspecialidades[filtroEspecialidad] || '';

             if (filtroEstado !== 'todas' && filtroEspecialidad !== 'todas') {
                texto = `No tiene citas ${nombreEstado} en ${nombreEspecialidad}.`;
             } else if (filtroEstado !== 'todas') {
                texto = `No tiene citas ${nombreEstado}`;
             } else if (filtroEspecialidad !== 'todas') {
                texto = `No tiene citas registradas en ${nombreEspecialidad}`;
             }
        }
        
        mensajeListaVacia.textContent = texto;
        mensajeListaVacia.style.display = 'block';
    }

    /**
     * Renderiza las citas según AMBOS filtros (Estado y Especialidad)
     */
    function renderizarCitas() {
        if (!citasContainer) return; 
        citasContainer.innerHTML = ''; 
        
        // 1. Obtener filtros activos
        const filtroEstado = filtroSelect ? filtroSelect.value : 'todas';
        const filtroEspecialidad = selectEspecialidad ? selectEspecialidad.value : 'todas';

        // 2. Aplicar AMBOS filtros
        const citasFiltradas = todasLasCitas.filter(cita => {
            const pasaEstado = filtroEstado === 'todas' || cita.id_estado == filtroEstado;
            const pasaEspecialidad = filtroEspecialidad === 'todas' || cita.id_especialidad == filtroEspecialidad;
            
            return pasaEstado && pasaEspecialidad;
        });

        // 3. Mostrar mensaje si no hay citas
        if (citasFiltradas.length === 0) {
            mostrarMensajeVacio(filtroEstado, filtroEspecialidad);
            return;
        }
        if (mensajeListaVacia) mensajeListaVacia.style.display = 'none';

        
        // 4. Renderizar las tarjetas
        citasFiltradas.forEach(cita => {
            const { id_cita, fecha, hora, nombre_estado, nombre_especialidad, id_estado, nombre_profesional, apellido_profesional, nombre_sede, id_horario_original, id_horario, id_especialidad, id_sede, id_profesional } = cita;
            
            const { fecha: fechaTexto, hora: horaTexto, fechaHora } = window.formatDateTime(fecha, hora); 
            const estadoClass = getEstadoClass(id_estado);
            
            const card = document.createElement('div');
            card.className = `cita-card ${estadoClass}`;
            card.setAttribute('tabindex', '0'); 

            const tiempoRestante = (id_estado == 1 || id_estado == 2) ? getTiempoRestante(fechaHora) : null;
            let contadorHTML = tiempoRestante ? `<p class="contador" aria-live="polite">Restante: <strong>${tiempoRestante}</strong></p>` : '';

            const esAgendada = parseInt(id_estado) === 1;
            const esModificada = parseInt(id_estado) === 2;
            const cancelarDisabled = !esAgendada && !esModificada;
            const modificarDisabled = !esAgendada; 

            card.innerHTML = `
                <h3>${nombre_especialidad || 'Especialidad no definida'}</h3>
                <p>Fecha: <strong>${fechaTexto}</strong></p>
                <p>Hora: <strong>${horaTexto}</strong></p>
                <p>Estado: <span class="estado-label ${estadoClass}">${nombre_estado || 'Estado no definido'}</span></p>
                ${contadorHTML}
                <div class="card-actions">
                    <button class="btn-accion btn-ver-mas" aria-label="Ver más detalles de la cita">Ver más</button>
                    
                    <button class="btn-accion btn-modificar" 
                        data-id-cita="${id_cita}"
                        data-id-horario-original="${id_horario || id_horario_original}" 
                        data-id-especialidad="${id_especialidad}"
                        data-especialidad-nombre="${nombre_especialidad}"
                        data-fecha="${fecha}"
                        data-hora="${hora}"
                        data-id-sede="${id_sede}"
                        data-sede-nombre="${nombre_sede}"
                        data-id-profesional="${id_profesional}"
                        data-profesional-nombre="${nombre_profesional} ${apellido_profesional}"
                        ${modificarDisabled ? 'disabled' : ''} 
                        aria-label="${modificarDisabled ? 'Modificar cita (deshabilitado)' : 'Modificar cita'}">Modificar</button>
                    
                    <button class="btn-accion btn-cancelar" 
                        data-cita-id="${id_cita}" 
                        data-especialidad="${nombre_especialidad}" 
                        data-fecha="${fecha}" 
                        data-hora="${hora}"
                        data-profesional="${nombre_profesional} ${apellido_profesional}"
                        data-sede="${nombre_sede}"
                        ${cancelarDisabled ? 'disabled' : ''} 
                        aria-label="${cancelarDisabled ? 'Cancelar cita (deshabilitado)' : 'Cancelar cita'}">Cancelar</button>
                </div>
            `;

            // Lógica de listeners
            card.querySelector('.btn-ver-mas').addEventListener('click', () => mostrarDetallesCita(cita));

            const btnModificar = card.querySelector('.btn-modificar');
            if (!modificarDisabled && btnModificar) {
                btnModificar.addEventListener('click', (e) => {
                    const dataset = e.currentTarget.dataset;
                    if (typeof window.inicializarModificacion === 'function') {
                        window.inicializarModificacion(
                            dataset.idCita, dataset.idHorarioOriginal, dataset.idEspecialidad, dataset.especialidadNombre,
                            dataset.fecha, dataset.hora, dataset.idSede, dataset.sedeNombre, dataset.idProfesional, dataset.profesionalNombre
                        );
                    } else {
                        window.mostrarModalMensaje('Error', 'La función de modificación no está disponible.');
                    }
                });
            }

            const btnCancelar = card.querySelector('.btn-cancelar');
            if (!cancelarDisabled) {
                btnCancelar.addEventListener('click', (e) => {
                    if (typeof window.iniciarProcesoCancelacion === 'function') {
                        window.iniciarProcesoCancelacion(e);
                    } else {
                        window.mostrarModalMensaje('Error', 'La función de cancelación no está disponible.');
                    }
                });
            }

            citasContainer.appendChild(card);
        });
    }

    // =======================================
    //          FIN: LÓGICA HU-17
    // =======================================
    
    // -----------------------------------------------------------
    // 2. LÓGICA DE CARGA DE CITAS (Función principal)
    // -----------------------------------------------------------
    async function cargarCitas() {
        // Ejecutar primero la carga de especialidades (HU-20)
        await cargarEspecialidades(); 

        mostrarMensaje('Cargando tus citas...', 'info');

        try {
            const response = await fetch(`./../api/get_citas_paciente.php?id_paciente=${idPaciente}`);
            const data = await response.json();

            if (!response.ok || (data.message && !Array.isArray(data))) {
                if (data.message) throw new Error(data.message);
                throw new Error(`Error ${response.status}: ${response.statusText}`);
            }
            
            if (Array.isArray(data) && data.length === 0) {
                 todasLasCitas = []; 
                 mostrarMensaje('', '', '');
                 const countsVacio = calcularContadores(todasLasCitas);
                 popularDropdownFiltro(countsVacio);
                 renderizarCitas(); 
                 return;
            }
            
            // Ordenar por fecha ASC (más antigua a más reciente)
            data.sort((a, b) => new Date(a.fecha + 'T' + a.hora) - new Date(b.fecha + 'T' + b.hora));

            // Guardar en caché global
            todasLasCitas = data;

            // Calcular contadores de ESTADO
            const counts = calcularContadores(todasLasCitas);

            // Poblar el dropdown de ESTADO
            popularDropdownFiltro(counts);

            // Aplicar filtro ESTADO guardado
            const filtroGuardadoEstado = localStorage.getItem(KEY_FILTRO_ESTADO) || 'todas';
            if (filtroSelect) { 
                filtroSelect.value = filtroGuardadoEstado;
            }

            // Llamar a la función de renderizado que usa AMBOS filtros
            renderizarCitas();
            
            mostrarMensaje('', '', ''); // Limpiar mensaje de carga

            // Lógica de recarga
            if (window.citaIntervalFiltro) {
                clearInterval(window.citaIntervalFiltro);
            }
            window.citaIntervalFiltro = setInterval(cargarCitas, 60000); 

        } catch (error) {
            console.error('Error al cargar las citas:', error);
            mostrarMensaje(`Error al obtener las citas: ${error.message}. Intente de nuevo más tarde.`, 'error');
            if (citasContainer) citasContainer.innerHTML = '';
            if (mensajeListaVacia) {
                mensajeListaVacia.textContent = 'Error al cargar las citas.';
                mensajeListaVacia.style.display = 'block';
            }
        }
    }

    // -----------------------------------------------------------
    // 3. LÓGICA DE MODAL "Ver Más" (Mantenida)
    // -----------------------------------------------------------

    function mostrarDetallesCita(cita) {
        const { fecha, hora, nombre_especialidad, nombre_profesional, apellido_profesional, nombre_sede, direccion_sede, nombre_ciudad, nombre_estado, id_estado } = cita;
        
        const { fecha: fechaTexto, hora: horaTexto } = window.formatDateTime(fecha, hora);
        
        const profesionalCompleto = (nombre_profesional && apellido_profesional) ? `${nombre_profesional} ${apellido_profesional}` : 'No asignado';
        const sedeTexto = nombre_sede || 'No asignada';
        const direccionTexto = (direccion_sede && nombre_ciudad) ? `${direccion_sede}, ${nombre_ciudad}` : 'Dirección no disponible';
        const especialidadTexto = nombre_especialidad || 'Especialidad no definida';

        const estadoClass = getEstadoClass(id_estado);

        let detallesAdicionales = '';

        // Detalle de Cancelación
        if (parseInt(id_estado) === 3 && cita.fecha_cancelacion) {
            const { fecha: fechaCancelacion, hora: horaCancelacion } = window.formatDateTime(cita.fecha_cancelacion, cita.hora_cancelacion);
            detallesAdicionales += `
                <hr>
                <h4 class="detalle-titulo">Detalles de Cancelación</h4>
                <p><strong>Motivo:</strong> ${cita.motivo_cancelacion || 'No especificado'}</p>
                <p><strong>Fecha y Hora de Cancelación:</strong> ${fechaCancelacion} - ${horaCancelacion}</p>
            `;
        }

        // Detalle de Modificación
        if (parseInt(id_estado) === 2 && cita.fecha_original && cita.hora_original) {
            const { fecha: fechaOriginalTexto, hora: horaOriginalTexto } = window.formatDateTime(cita.fecha_original, cita.hora_original);
            detallesAdicionales += `
                <hr>
                <h4 class="detalle-titulo">Detalles de Modificación</h4>
                <p><strong>Fecha/Hora Original:</strong> ${fechaOriginalTexto} - ${horaOriginalTexto}</p>
            `;
        }

        modalContent.innerHTML = `
            <h2 id="modal-title">Detalles de Cita</h2>
            <p><strong>Especialidad:</strong> ${especialidadTexto}</p>
            <p><strong>Estado Actual:</strong> <span class="estado-label ${estadoClass}">${nombre_estado}</span></p>
            <hr>
            <p><strong>Fecha:</strong> ${fechaTexto}</p>
            <p><strong>Hora:</strong> ${horaTexto}</p>
            <p><strong>Profesional:</strong> ${profesionalCompleto}</p>
            <p><strong>Sede:</strong> ${sedeTexto}</p>
            <p><strong>Dirección:</strong> ${direccionTexto}</p>
            ${detallesAdicionales}
        `;

        modal.style.display = 'flex';
        modal.focus();
    }


    const closeModal = () => {
        modal.style.display = 'none';
    };

    btnCerrarModal.addEventListener('click', closeModal);

    window.addEventListener('click', (event) => {
        if (event.target == modal) {
            closeModal();
        }
    });

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape' && modal.style.display === 'flex') {
            closeModal();
        }
    });

    // =======================================
    //     INICIO: Listeners HU-17 Y HU-20
    // =======================================
    
    // --- Listeners HU-17 (Filtro por ESTADO) ---
    if (filtroSelect) {
        filtroSelect.addEventListener('change', (e) => {
            const estadoSeleccionado = e.target.value;
            localStorage.setItem(KEY_FILTRO_ESTADO, estadoSeleccionado);
            renderizarCitas(); 
        });
    }
    
    if (btnLimpiarFiltro) {
        btnLimpiarFiltro.addEventListener('click', () => {
            if (filtroSelect) filtroSelect.value = 'todas';
            localStorage.removeItem(KEY_FILTRO_ESTADO); 
            renderizarCitas(); 
        });
    }

    // --- Listeners HU-20 (Filtro por ESPECIALIDAD) ---
    if (selectEspecialidad) {
        selectEspecialidad.addEventListener('change', (e) => {
            const especialidadSeleccionada = e.target.value;
            localStorage.setItem(KEY_FILTRO_ESP, especialidadSeleccionada); 
            renderizarCitas(); 
        });
    }

    if (btnLimpiarEspecialidad) { 
        btnLimpiarEspecialidad.addEventListener('click', () => {
            if (selectEspecialidad) selectEspecialidad.value = 'todas';
            localStorage.removeItem(KEY_FILTRO_ESP); 
            renderizarCitas(); 
        });
    }

    // =======================================
    //          FIN: Listeners HU-17 Y HU-20
    // =======================================
    
    // Iniciar la carga de citas al cargar la página
    cargarCitas();
});