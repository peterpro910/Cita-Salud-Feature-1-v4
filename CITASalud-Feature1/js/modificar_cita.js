// /js/modificar_cita.js

(function () {

    // --- Variables de DOM ---
    const modal = document.getElementById('modificationModal');
    const modificationForm = document.getElementById('modificationForm');
    const confirmationScreen = document.getElementById('confirmationScreen');
    const mensajeModificacion = document.getElementById('mensaje-modificacion');

    // Formulario (Paso 1)
    const especialidadDisplay = document.getElementById('especialidad_display');
    const especialidadIdInput = document.getElementById('especialidad_id');
    const sedeSelect = document.getElementById('sede');
    const profesionalSelect = document.getElementById('profesional');
    const fechaHorarioDisplay = document.getElementById('fecha_horario_display');
    const horarioIdInput = document.getElementById('horario_id');
    const nextToConfirmationBtn = document.getElementById('nextToConfirmation');
    const cancelModificationBtn = document.getElementById('cancelModification');

    // Confirmación (Paso 2)
    const originalDatetimeSpan = document.getElementById('original_datetime');
    const originalProfesionalSpan = document.getElementById('original_profesional');
    const originalSedeSpan = document.getElementById('original_sede');
    const modifiedDatetimeSpan = document.getElementById('modified_datetime');
    const modifiedProfesionalSpan = document.getElementById('modified_profesional');
    const modifiedSedeSpan = document.getElementById('modified_sede');
    const confirmModificationBtn = document.getElementById('confirmModification');

    // ***** INICIO DE CORRECCIÓN 1: ID del botón *****
    // El ID en citas.html es "backToFormBtn"
    const backToFormBtn = document.getElementById('backToFormBtn');
    // ***** FIN DE CORRECCIÓN 1 *****

    // Estado interno
    let originalCitaData = {};
    let fp = null; // Instancia de Flatpickr
    let isSettingDateProgrammatically = false;
    let allAvailableTimes = []; // Almacena todos los horarios
    let valorAuxiliarFechaHora = '';
    // --- Utilidades ---
    function mostrarMensajeInterno(texto, tipo = 'error') {
        if (mensajeModificacion) {
            mensajeModificacion.textContent = texto;
            mensajeModificacion.className = `mensaje ${tipo}`;
            mensajeModificacion.style.display = 'block';
        }
    }

    function ocultarMensajeInterno() {
        if (mensajeModificacion) {
            mensajeModificacion.style.display = 'none';
        }
    }

    function showStep(step) {
        if (modificationForm) modificationForm.style.display = step === 'form' ? 'block' : 'none';
        if (confirmationScreen) confirmationScreen.style.display = step === 'confirmation' ? 'block' : 'none';
        ocultarMensajeInterno();
    }

    // Formateador de hora local (si window.formatDateTime no está disponible)
    function formatHoraLocal(timeStr) {
        if (!timeStr) return '';
        if (typeof window.formatDateTime === 'function') {
            // Usa la función global de citas.js si existe
            return window.formatDateTime('2000-01-01', timeStr).hora;
        }
        // Fallback simple
        const [h, m] = timeStr.split(':');
        const hora = parseInt(h);
        const ampm = hora >= 12 ? 'PM' : 'AM';
        const hora12 = hora % 12 || 12;
        return `${hora12}:${m} ${ampm}`;
    }

    // --- Lógica de Carga de Datos (APIs) ---

    async function cargarSedes(especialidadId) {
        try {
            const response = await fetch(`../api/get_sedes.php?especialidad_id=${especialidadId}`);
            if (!response.ok) throw new Error("No se pudo obtener las sedes");

            const data = await response.json();

            // Validar que los datos tengan la propiedad 'nombre'
            const sedesValidas = data.filter(sede => sede.nombre);
            sedesValidas.sort((a, b) => a.nombre.localeCompare(b.nombre));

            const sedeSelect = document.getElementById("sede");
            sedeSelect.innerHTML = ""; // Limpiar opciones anteriores

            const defaultOption = document.createElement("option");
            defaultOption.value = "";
            defaultOption.textContent = "-- Selecciona una sede --";
            defaultOption.disabled = false;
            defaultOption.selected = true; // importante para que se muestre como seleccionada inicialmente
            sedeSelect.appendChild(defaultOption);


            // Agregar sedes al <select>
            sedesValidas.forEach(sede => {
                const option = document.createElement("option");
                option.value = sede.id;
                option.textContent = `${sede.nombre} (${sede.ciudad})`;
                option.dataset.direccion = sede.direccion; // útil si quieres mostrarla después
                sedeSelect.appendChild(option);
            });

        } catch (error) {
            console.error("Error al cargar sedes:", error);
            mostrarMensajeInterno("No se pudieron cargar las sedes disponibles.", "error");
        }
    }


    async function cargarProfesionales(sedeId, especialidadId, selectedProfesionalId) {
        const profesionalSelect = document.getElementById("profesional");
        if (!profesionalSelect) {
            console.warn("El campo #profesional no existe en el DOM.");
            return;
        }

        profesionalSelect.innerHTML = '<option value="" disabled selected hidden>Cargando profesionales...</option>';
        profesionalSelect.disabled = true;

        try {
            if (!especialidadId || !sedeId) {
                console.warn("Parámetros inválidos para cargar profesionales");
                mostrarMensajeInterno('Faltan datos para cargar profesionales.', 'warning');
                return;
            }

            const response = await fetch(`../api/get_profesionales.php?especialidad_id=${especialidadId}&sede_id=${sedeId}`);
            const data = await response.json();

            profesionalSelect.innerHTML = ""; // Limpiar opciones anteriores

            const defaultOption = document.createElement("option");
            defaultOption.value = "";
            defaultOption.textContent = "-- Selecciona un profesional --";
            defaultOption.disabled = false;
            defaultOption.selected = !selectedProfesionalId; // Solo seleccionada si no hay uno preseleccionado
            profesionalSelect.appendChild(defaultOption);


            if (response.ok && Array.isArray(data) && data.length > 0) {
                data.sort((a, b) => {
                    const nombreA = a.nombre_completo || `${a.nombre} ${a.apellido}`;
                    const nombreB = b.nombre_completo || `${b.nombre} ${b.apellido}`;
                    return nombreA.localeCompare(nombreB);
                });

                data.forEach(profesional => {
                    const option = document.createElement('option');
                    option.value = profesional.id || profesional.id_profesional;
                    option.textContent = profesional.nombre_completo || `${profesional.nombre} ${profesional.apellido}`;
                    option.selected = (option.value == selectedProfesionalId);
                    option.dataset.titulo = profesional.titulo_profesional || '';
                    option.dataset.experiencia = profesional.anos_experiencia || '';
                    option.dataset.horarios = profesional.horarios_disponibles || 0;
                    profesionalSelect.appendChild(option);
                });

                profesionalSelect.disabled = false;

                // Activar el calendario si hay un profesional preseleccionado
                if (selectedProfesionalId) {
                    profesionalSelect.dispatchEvent(new Event('change'));
                }

            } else {
                mostrarMensajeInterno('No se encontraron profesionales.', 'warning');
            }
        } catch (error) {
            console.error('Error al cargar profesionales:', error);
            mostrarMensajeInterno('Error de conexión al cargar profesionales.', 'error');
        }
    }



    async function configurarFlatpickr(profesionalId) {
        console.log(`%c[Depuración] configurarFlatpickr: Iniciando...`, 'color: #17a2b8; font-weight: bold;');
        const fechaHorarioDisplay = document.getElementById("fecha_horario_display");
        const horarioIdInput = document.getElementById("horario_id");
        const horarioOriginalInput = document.getElementById("horario_original_id");
        const idPaciente = window.idPaciente || null;
        const idHorarioOriginal = horarioOriginalInput?.value || null;
        fechaHorarioDisplay.placeholder = 'Cargando horarios...';
        fechaHorarioDisplay.disabled = true;
        if (fp) fp.destroy();

        if (!profesionalId || !idPaciente) {
            mostrarMensajeInterno("Faltan datos para cargar horarios disponibles.", "error");
            console.error("[Depuración] Faltan profesionalId o idPaciente.");
            return;
        }

        try {
            const url = `../api/get_horarios.php?profesional_id=${profesionalId}&id_paciente=${idPaciente}&id_horario_a_liberar=${idHorarioOriginal}`;
            console.log(`[Depuración] Fetching horarios desde: ${url}`);
            const response = await fetch(url);
            const data = await response.json();

            if (!response.ok || !Array.isArray(data)) {
                console.warn("[Depuración] API devolvió error o no hay horarios.", data.message);
                mostrarMensajeInterno(data.message || 'No hay horarios disponibles para este profesional.', 'warning');
                fechaHorarioDisplay.placeholder = 'No hay horarios disponibles';
                return;
            }
            console.log(`[Depuración] Horarios recibidos: ${data.length} registros.`);

            if (data.length > 0) {
                fechaHorarioDisplay.disabled = false;
                fechaHorarioDisplay.placeholder = 'Seleccionar fecha'; // <-- (Texto actualizado)
                allAvailableTimes = data;
                const availableDates = [...new Set(data.map(h => h.fecha))];
                console.log(`[Depuración] Días habilitados:`, availableDates);

                fp = flatpickr(fechaHorarioDisplay, {
                    // --- INICIO DE LA MODIFICACIÓN (SOLO FECHA) ---
                    // 1. Formato interno: Guarda SOLO fecha
                    dateFormat: "Y-m-d",
                    altInput: true,
                    // 2. Formato visible: Muestra SOLO fecha
                    altFormat: "d F, Y",
                    // --- FIN DE LA MODIFICACIÓN ---

                    minDate: "today",
                    maxDate: new Date().fp_incr(60),
                    enable: availableDates,
                    locale: 'es',
                    enableTime: false,

                    onChange: function (selectedDates, dateStr) {
                        ocultarMensajeInterno();
                        // (Este 'dateStr' ahora será "2025-11-05")
                        console.log(`[Depuración] Flatpickr onChange: Fecha seleccionada: ${dateStr}`);
                        if (selectedDates.length > 0) {
                            // const fechaSolo = flatpickr.formatDate(selectedDates[0], "Y-m-d"); (Ya no es necesaria)
                            console.log(`[Depuración] Flatpickr onChange: Llamando a showAvailableTimes con: ${dateStr}`);
                            showAvailableTimes(dateStr);
                        } else {
                            document.getElementById('horarios-list').style.display = 'none';
                        }
                    }
                });
                console.log("[Depuración] Flatpickr (SOLO FECHA) creado exitosamente.");

            } else {
                fechaHorarioDisplay.disabled = true;
                fechaHorarioDisplay.placeholder = 'No hay horarios disponibles';
                mostrarMensajeInterno('No hay horarios disponibles para este profesional.', 'warning');
            }

        } catch (error) {
            console.error('Error al cargar horarios:', error);
            mostrarMensajeInterno('Error de conexión al cargar horarios.', 'error');
        }
    }

    function validateForm() {
        const sede = document.getElementById("sede")?.value;
        const profesional = document.getElementById("profesional")?.value;
        const horarioId = document.getElementById("horario_id")?.value;
        const continuarBtn = document.getElementById("nextToConfirmation");

        const formularioCompleto = sede && profesional && horarioId;

        if (continuarBtn) {
            continuarBtn.disabled = !formularioCompleto;
        }
    }

    function showAvailableTimes(selectedDate) {
        console.log(`%c[Depuración] showAvailableTimes: Mostrando horas para la fecha: ${selectedDate}`, 'color: #007bff; font-weight: bold;');

        const timesContainer = document.getElementById('horarios-list');
        timesContainer.innerHTML = '';
        timesContainer.style.display = 'flex';
        timesContainer.style.gap = '10px';
        timesContainer.style.flexWrap = 'wrap';

        const dailyTimes = allAvailableTimes.filter(h => h.fecha === selectedDate);
        horarioIdInput.value = ''; // Limpiar el input oculto de horario antes de mostrar horas
        valorAuxiliarFechaHora = ''; // Limpiar el auxiliar

        if (dailyTimes.length > 0) {
            dailyTimes.forEach(horario => {
                const timeButton = document.createElement('button');
                timeButton.className = 'time-btn';
                timeButton.textContent = new Date(`2000-01-01T${horario.hora}`).toLocaleTimeString('es-CO', { hour: '2-digit', minute: '2-digit' });
                timeButton.setAttribute('data-id-horario', horario.id_horario);
                timeButton.setAttribute('data-fecha-hora', `${horario.fecha} ${horario.hora}`);

                timeButton.addEventListener('mousedown', (e) => {
                    e.preventDefault();
                });

                timeButton.addEventListener('click', (e) => {
                    e.preventDefault();
                    console.log(`%c[Depuración] Click en botón de hora: ${timeButton.textContent}`, 'color: #28a745; font-weight: bold;');

                    // 1. Marcar botón
                    document.querySelectorAll('.time-btn').forEach(btn => btn.classList.remove('selected'));
                    timeButton.classList.add('selected');

                    // 2. Guardar ID
                    const hiddenHorarioInput = document.getElementById('horario_id');
                    if (hiddenHorarioInput) {
                        hiddenHorarioInput.value = horario.id_horario;
                        console.log(`[Depuración] Paso: Guardar ID`, `Nombre: hiddenHorarioInput.value`, `Valor: ${hiddenHorarioInput.value}`);
                    }

                    // 3. Combinar y guardar en auxiliar
                    const horaBoton = horario.hora;
                    const horaFormateada = horaBoton.substring(0, 5);
                    const fechaHoraCompleta = `${selectedDate} ${horaFormateada}`;
                    valorAuxiliarFechaHora = fechaHoraCompleta;
                    console.log(`[Depuración] Paso: Guardar Auxiliar`, `Nombre: valorAuxiliarFechaHora`, `Valor: "${valorAuxiliarFechaHora}"`);

                    // 4. Mostrar en pantalla
                    const currentFechaHorarioDisplay = document.getElementById('current-fecha-horario');
                    if (currentFechaHorarioDisplay) {
                        currentFechaHorarioDisplay.textContent = fechaHoraCompleta;
                    }

                    // 5. Validar
                    validateForm();
                    console.log(`[Depuración] Paso: Validar`, `Nombre: validateForm()`, `Valor: (Llamada ejecutada)`);
                });

                timesContainer.appendChild(timeButton);
            });
        } else {
            timesContainer.innerHTML = '<p>No hay horarios disponibles para este día.</p>';
        }

        validateForm();
        console.log(`[Depuración] showAvailableTimes: Validación final ejecutada.`);
    }



    // -----------------------------------------------------------
    // FUNCIÓN DE INICIALIZACIÓN (EXPUESTA GLOBALMENTE)
    // -----------------------------------------------------------

    window.inicializarModificacion = async (
        idCita,
        idHorarioOriginal,
        especialidadId,
        especialidadNombre,
        fecha,
        hora,
        sedeId,
        sedeNombre,
        profesionalId,
        profesionalNombre
    ) => {
        // Mostrar la especialidad directamente
        const especialidadDisplay = document.getElementById("especialidad_display");
        if (especialidadDisplay) {
            especialidadDisplay.textContent = especialidadNombre;
        }

        // *** CORRECCIÓN CLAVE: ELIMINAR LA APERTURA DEL MODAL AQUÍ ***
        // Se ha eliminado: document.getElementById("modificationModal").style.display = "block";
        // Se ha eliminado: showStep("form");
        // *** FIN CORRECCIÓN CLAVE ***


        if (!idCita || !window.idPaciente) {
            window.mostrarModalMensaje('Error', 'ID de Cita o Paciente no definidos.', 'error');
            return;
        }

        try {
            const fechaHorarioDisplay = document.getElementById("fecha_horario_display");
            const horarioIdInput = document.getElementById("horario_id");
            const horariosList = document.getElementById("horarios-list");

            fechaHorarioDisplay.disabled = true;
            fechaHorarioDisplay.value = '';
            fechaHorarioDisplay.placeholder = 'Seleccione un profesional';
            horarioIdInput.value = '';
            horariosList.innerHTML = '';
            horariosList.style.display = 'none';

            // Validar reglas de modificación desde el backend
            const validacionResponse = await fetch(`../api/validar_modificacion.php?id_cita=${idCita}`);
            const validacionResult = await validacionResponse.json();

            if (!validacionResponse.ok || !validacionResult.success) {
                // Si la validación falla, muestra el error inmediatamente y retorna.
                // El modal principal nunca se abrió, logrando el comportamiento deseado.
                window.mostrarModalMensaje('Modificación no permitida', validacionResult.message || 'No se puede modificar esta cita.', 'error');
                return;
            }

            // *** CORRECCIÓN CLAVE: ABRIR EL MODAL SÓLO SI LA VALIDACIÓN ES EXITOSA ***
            // Mostrar modal y preparar formulario
            modal.style.display = 'flex';
            showStep('form');
            horarioIdInput.value = '';
            mostrarMensajeInterno('Preparando formulario...', 'info');
            // *** FIN CORRECCIÓN CLAVE ***

            // Construir originalCitaData directamente desde los datos del botón
            originalCitaData = {
                id_cita: idCita,
                id_horario_original: idHorarioOriginal,
                especialidad_id: especialidadId,
                especialidad_nombre: especialidadNombre,
                fecha,
                hora,
                sede_id: sedeId,
                sede_nombre: sedeNombre,
                profesional_id: profesionalId,
                profesional_nombre: profesionalNombre
            };

            // Validar que los campos clave no estén vacíos
            const camposClave = ['especialidad_id', 'sede_id', 'profesional_id'];
            const camposFaltantes = camposClave.filter(campo => !originalCitaData[campo]);

            if (camposFaltantes.length > 0) {
                console.warn("Faltan datos en originalCitaData:", camposFaltantes);
                mostrarMensajeInterno(`No se puede continuar: faltan datos de ${camposFaltantes.join(', ')}`, 'error');
                return;
            }

            // Llenar el formulario (Paso 1)
            if (especialidadDisplay) especialidadDisplay.value = originalCitaData.especialidad_nombre;
            if (especialidadIdInput) especialidadIdInput.value = originalCitaData.especialidad_id;

            // Cargar datos en cascada
            await cargarSedes(originalCitaData.especialidad_id);

            // Listener seguro para el campo "sede"
            const sedeSelectDOM = document.getElementById("sede");
            const nuevoSedeSelect = sedeSelectDOM.cloneNode(true);
            sedeSelectDOM.parentNode.replaceChild(nuevoSedeSelect, sedeSelectDOM);
            if (originalCitaData.sede_id) {
                nuevoSedeSelect.value = originalCitaData.sede_id;
            }


            nuevoSedeSelect.addEventListener("change", async (e) => {
                const sedeId = e.target.value;
                const especialidadId = document.getElementById("especialidad_id").value;

                const profesionalSelect = document.getElementById("profesional");
                profesionalSelect.innerHTML = '<option value="">Cargando profesionales...</option>';
                profesionalSelect.disabled = true;
                const horariosList = document.getElementById('horarios-list');
                // Reiniciar campo de fecha y hora
                if (fp) fp.destroy();
                fechaHorarioDisplay.value = '';
                fechaHorarioDisplay.placeholder = 'Seleccione un profesional';
                fechaHorarioDisplay.disabled = true;
                horarioIdInput.value = '';
                horariosList.innerHTML = '';
                horariosList.style.display = 'none';
                valorAuxiliarFechaHora = '';

                if (sedeId && especialidadId) {
                    await cargarProfesionales(sedeId, especialidadId, null); // Ya no preseleccionar el original
                } else {
                    profesionalSelect.innerHTML = '<option value="">Seleccione Sede primero</option>';
                    profesionalSelect.disabled = true;
                }
                validateForm();
            });

            // Cargar profesionales iniciales
            await cargarProfesionales(originalCitaData.sede_id, originalCitaData.especialidad_id, originalCitaData.profesional_id);

            // Listener seguro para el campo "profesional"
            const profesionalSelectDOM = document.getElementById("profesional");
            if (profesionalSelectDOM) {
                const nuevoProfesionalSelect = profesionalSelectDOM.cloneNode(true);
                profesionalSelectDOM.parentNode.replaceChild(nuevoProfesionalSelect, profesionalSelectDOM);

                nuevoProfesionalSelect.addEventListener("change", async (e) => {
                    const profesionalId = e.target.value;
                    ocultarMensajeInterno();
                    const fechaHorarioDisplay = document.getElementById("fecha_horario_display");
                    const horarioIdInput = document.getElementById("horario_id");
                    const horariosList = document.getElementById("horarios-list");

                    if (fp) fp.destroy();
                    fechaHorarioDisplay.value = '';
                    fechaHorarioDisplay.disabled = true;
                    fechaHorarioDisplay.placeholder = 'Seleccione una fecha';
                    horarioIdInput.value = '';
                    horariosList.innerHTML = '';
                    horariosList.style.display = 'none';
                    valorAuxiliarFechaHora = '';

                    if (profesionalId) {
                        await configurarFlatpickr(profesionalId);
                    }
                    if (!profesionalId || profesionalId === "") {
                        mostrarMensajeInterno("Selecciona un profesional para ver los horarios disponibles.", "info");
                        return;
                    }
                    validateForm();
                });
            }


            // Configurar Flatpickr si ya hay un profesional seleccionado al inicio
            if (originalCitaData.profesional_id) {
                await configurarFlatpickr(originalCitaData.profesional_id);
            }

            ocultarMensajeInterno();
            validateForm();

        } catch (error) {
            console.error('Error al inicializar modificación:', error);
            // Si el error ocurre en el try/catch general, asegura que el modal principal se cierre.
            window.mostrarModalMensaje('Error', error.message || 'No se pudo preparar la cita para modificar.', 'error', () => {
                modal.style.display = 'none';
            });
        }
    };




    // -----------------------------------------------------------
    // EVENT LISTENERS DEL MODAL (Asegurarse de que no sean nulos)
    // -----------------------------------------------------------

    if (nextToConfirmationBtn) {
        nextToConfirmationBtn.addEventListener('click', () => {
            console.log(`%c[Depuración] Click en 'Continuar'. Iniciando resumen...`, 'color: #dc3545; font-weight: bold;');

            validateForm();
            if (nextToConfirmationBtn.disabled) {
                mostrarMensajeInterno('Formulario incompleto.', 'error');
                console.warn("[Depuración] 'Continuar' bloqueado (Formulario incompleto).");
                return;
            }

            const currentSedeSelect = document.getElementById('sede');
            const currentProfesionalSelect = document.getElementById('profesional');

            const nuevaSedeNombre = currentSedeSelect.value
                ? currentSedeSelect.options[currentSedeSelect.selectedIndex]?.text.split('(')[0].trim()
                : 'No seleccionada';
            console.log(`[Depuración] Resumen:`, `nuevaSedeNombre = "${nuevaSedeNombre}"`);

            const nuevoProfesionalNombre = currentProfesionalSelect.value
                ? currentProfesionalSelect.options[currentProfesionalSelect.selectedIndex]?.text
                : 'No seleccionado';
            console.log(`[Depuración] Resumen:`, `nuevoProfesionalNombre = "${nuevoProfesionalNombre}"`);

            const nuevoHorarioTexto = valorAuxiliarFechaHora;
            console.log(`[Depuración] Resumen:`, `nuevoHorarioTexto (del valor auxiliar) = "${nuevoHorarioTexto}"`);

            const fOriginal = window.formatDateTime(originalCitaData.fecha, originalCitaData.hora);

            const [fNuevaFecha, fNuevaHoraCorta] = nuevoHorarioTexto.split(' ');
            console.log(`[Depuración] Resumen:`, `fNuevaFecha = "${fNuevaFecha}"`, `fNuevaHoraCorta = "${fNuevaHoraCorta}"`);

            // Aseguramos que la hora tenga segundos para formatDateTime (si es necesario)
            const fNuevaHoraCompleta = fNuevaHoraCorta ?
                (fNuevaHoraCorta.length === 5 ? `${fNuevaHoraCorta}:00` : fNuevaHoraCorta)
                : undefined;
            console.log(`[Depuración] Resumen:`, `fNuevaHoraCompleta (con segundos) = "${fNuevaHoraCompleta}"`);

            const fNueva = window.formatDateTime(fNuevaFecha, fNuevaHoraCompleta);
            console.log(`[Depuración] Resumen:`, `Objeto fNueva final =`, fNueva);


            const originalDatetimeSpan = document.getElementById("conf_original_datetime");
            const originalProfesionalSpan = document.getElementById("conf_original_profesional");
            const originalSedeSpan = document.getElementById("conf_original_sede");

            const modifiedDatetimeSpan = document.getElementById("conf_modified_datetime");
            const modifiedProfesionalSpan = document.getElementById("conf_modified_profesional");
            const modifiedSedeSpan = document.getElementById("conf_modified_sede");

            if (originalDatetimeSpan) originalDatetimeSpan.textContent = `${fOriginal.fecha} - ${fOriginal.hora}`;
            if (originalProfesionalSpan) originalProfesionalSpan.textContent = originalCitaData.profesional_nombre;
            if (originalSedeSpan) originalSedeSpan.textContent = originalCitaData.sede_nombre;

            if (modifiedDatetimeSpan) modifiedDatetimeSpan.textContent = `${fNueva.fecha} - ${fNueva.hora}`;
            if (modifiedProfesionalSpan) modifiedProfesionalSpan.textContent = nuevoProfesionalNombre;
            if (modifiedSedeSpan) modifiedSedeSpan.textContent = nuevaSedeNombre;

            showStep('confirmation');
        });
    }

    if (backToFormBtn) {
        backToFormBtn.addEventListener('click', () => {
            console.log("[Depuración] Click en 'Volver'. Limpiando horario_id.");
            const horarioIdInput = document.getElementById('horario_id');
            if (horarioIdInput) horarioIdInput.value = '';
            valorAuxiliarFechaHora = '';
            showStep('form');
            validateForm(); // Re-validar para deshabilitar "Continuar"
        });
    }

    if (cancelModificationBtn) {
        cancelModificationBtn.addEventListener('click', () => {
            modal.style.display = 'none';
            if (fp) fp.destroy();
            fp = null;
        });
    }

    if (confirmModificationBtn) {
        confirmModificationBtn.addEventListener('click', async () => {
            confirmModificationBtn.disabled = true;

            window.mostrarModalMensaje('Procesando...', 'Estamos modificando su cita, por favor espere.', 'info');

            // --- Referencias actualizadas ---
            const currentSedeSelect = document.getElementById('sede');
            const currentProfesionalSelect = document.getElementById('profesional');
            const currentHorarioIdInput = document.getElementById('horario_id');


            const dataToSend = {
                id_cita: originalCitaData.id_cita,
                id_paciente: window.idPaciente,
                id_horario_original: originalCitaData.id_horario_original,
                // Usamos la variable constante `horarioIdInput` (constante de DOM) que se actualiza al seleccionar hora
                id_nuevo_horario: currentHorarioIdInput?.value, 
                id_nueva_sede: currentSedeSelect?.value,
                id_nuevo_profesional: currentProfesionalSelect?.value,
                id_especialidad: originalCitaData.especialidad_id
            };


            console.log("ID del nuevo horario:", dataToSend.id_nuevo_horario);

            // Validación de campos
            if (!dataToSend.id_nuevo_horario || !dataToSend.id_nueva_sede || !dataToSend.id_nuevo_profesional) {
                console.error("Error: Faltan IDs en dataToSend", dataToSend);
                const modalMensaje = document.getElementById('modal-mensaje');
                if (modalMensaje) modalMensaje.style.display = 'none';

                window.mostrarModalMensaje('Error', 'El formulario está incompleto. Por favor, vuelva atrás y complete todos los pasos.', 'error');
                confirmModificationBtn.disabled = false;
                return;
            }

            try {
                const response = await fetch('../api/modificar_cita.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(dataToSend)
                });

                const contentType = response.headers.get('content-type');
                if (!contentType || !contentType.includes('application/json')) {
                    throw new Error('La respuesta del servidor no es JSON');
                }

                const result = await response.json();

                // 1. Cerrar el modal temporal "Procesando..."
                const tempModal = document.getElementById('modal-mensaje');
                if (tempModal) tempModal.style.display = 'none';

                if (response.ok) {

                    // *** LA CORRECCIÓN CLAVE: CERRAR EL MODAL PRINCIPAL AQUÍ ***
                    modal.style.display = 'none';
                    // *********************************************************

                    const nuevaFechaHora = window.formatDateTime(result.nueva_fecha, result.nueva_hora);
                    const exitoMsg = `Su cita ha sido modificada con éxito.<br>
                    <strong>Nueva Fecha y Hora:</strong> ${nuevaFechaHora.fecha} - ${nuevaFechaHora.hora}<br>
                    Se ha enviado un correo electrónico con los detalles.`;

                    // 2. Mostrar la notificación (se mostrará sobre la pantalla principal)
                    window.mostrarModalMensaje('Modificación Exitosa', exitoMsg, 'success', () => {
                        if (typeof window.cargarCitas === 'function') {
                            window.cargarCitas();
                        } else {
                            window.location.reload();
                        }
                    });
                } else {
                    // Si falla, el modal principal YA ESTÁ CERRADO (lo cerró el usuario o no se abrió).
                    window.mostrarModalMensaje('Error de Modificación', result.message || 'Error desconocido al modificar la cita.', 'error');
                }

            } catch (error) {
                console.error('Error de red al intentar modificar:', error);
                const tempModal = document.getElementById('modal-mensaje');
                if (tempModal) tempModal.style.display = 'none';

                window.mostrarModalMensaje('Error de Conexión', 'No se pudo contactar al servidor. Verifique la conexión.', 'error');
            } finally {
                confirmModificationBtn.disabled = false;
            }
        });
    }


})(); // Fin de la IIFE