document.addEventListener('DOMContentLoaded', () => {
    const idPaciente = sessionStorage.getItem('id_paciente');
    if (!idPaciente) {
        alert('Por favor, inicie sesión primero.');
        window.location.href = './../html/login.html';
        return;
    }

    const especialidadSelect = document.getElementById('especialidad');
    const sedeSelect = document.getElementById('sede');
    const profesionalSelect = document.getElementById('profesional');
    const horarioSelect = document.getElementById('horario');
    const agendarBtn = document.getElementById('agendar-btn');
    const confirmarBtn = document.getElementById('confirmar-btn');
    const regresarBtn = document.getElementById('regresar-btn');
    const citaForm = document.getElementById('cita-form');
    const mensajeDiv = document.getElementById('mensaje');
    const resumenDiv = document.getElementById('resumen-cita');
    const modal = document.getElementById('modal-confirmacion');
    const btnAceptar = document.getElementById('btn-aceptar');

    let flatpickrInstance;
    let allAvailableTimes = [];

    function mostrarMensaje(texto, tipo) {
        mensajeDiv.textContent = texto;
        mensajeDiv.className = `mensaje ${tipo}`;
    }

    async function cargarEspecialidades(selectedId = null) {
        mostrarMensaje('Cargando especialidades...', 'info');
        especialidadSelect.disabled = true;

        try {
            const response = await fetch('./../api/get_especialidades.php');
            const data = await response.json();

            especialidadSelect.innerHTML = '<option value="">Selecciona una especialidad</option>';

            if (response.status === 200 && data.length > 0) {
                data.forEach(especialidad => {
                    const option = document.createElement('option');
                    option.value = especialidad.id_especialidad;
                    option.textContent = especialidad.nombre_especialidad;
                    if (especialidad.horarios_disponibles === 0) {
                        option.textContent += ' (Sin disponibilidad)';
                        option.disabled = true;
                    }
                    especialidadSelect.appendChild(option);
                });
                especialidadSelect.disabled = false;
                if (selectedId) especialidadSelect.value = selectedId;
                mostrarMensaje('');
                return true;
            } else {
                especialidadSelect.innerHTML = '<option value="">No hay especialidades disponibles</option>';
                especialidadSelect.disabled = true;
                mostrarMensaje(data.message || 'No hay especialidades disponibles.', 'error');
                return false;
            }
        } catch (error) {
            console.error('Error al cargar especialidades:', error);
            mostrarMensaje('Error de conexión con el servidor. Intente de nuevo más tarde.', 'error');
            return false;
        }
    }

    async function cargarSedes(especialidadId, selectedId = null) {
        mostrarMensaje('Cargando sedes...', 'info');
        sedeSelect.disabled = true;
        profesionalSelect.disabled = true;
        horarioSelect.disabled = true;
        agendarBtn.style.display = 'none';
        sedeSelect.innerHTML = '<option value="">Selecciona una sede</option>';
        profesionalSelect.innerHTML = '<option value="">Selecciona primero una especialidad y sede</option>';
        horarioSelect.value = '';
        if (flatpickrInstance) flatpickrInstance.destroy();

        try {
            const response = await fetch(`./../api/get_sedes.php?especialidad_id=${especialidadId}`);
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.message);
            }
            const data = await response.json();
            
            if (data.length > 0) {
                data.forEach(sede => {
                    const option = document.createElement('option');
                    option.value = sede.id;
                    option.textContent = `${sede.nombre} - ${sede.direccion}, ${sede.ciudad}`;
                    sedeSelect.appendChild(option);
                });
                sedeSelect.disabled = false;
                if (selectedId) sedeSelect.value = selectedId;
                mostrarMensaje('');
                return true;
            } else {
                sedeSelect.innerHTML = '<option value="">No hay sedes para esta especialidad</option>';
                sedeSelect.disabled = true;
                mostrarMensaje('No hay sedes para esta especialidad.', 'warning');
                return false;
            }
        } catch (error) {
            console.error('Error al cargar sedes:', error);
            mostrarMensaje(error.message || 'Error al cargar las sedes. Intente de nuevo.', 'error');
            return false;
        }
    }

    async function cargarProfesionales(especialidadId, sedeId, selectedId = null) {
        mostrarMensaje('Cargando profesionales...', 'info');
        profesionalSelect.disabled = true;
        horarioSelect.disabled = true;
        agendarBtn.style.display = 'none';
        profesionalSelect.innerHTML = '<option value="">Selecciona un profesional</option>';
        horarioSelect.value = '';
        if (flatpickrInstance) flatpickrInstance.destroy();

        try {
            const response = await fetch(`./../api/get_profesionales.php?especialidad_id=${especialidadId}&sede_id=${sedeId}`);
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.message || 'Error en la respuesta del servidor.');
            }

            const data = await response.json();
            
            if (data.length > 0) {
                data.forEach(profesional => {
                    const option = document.createElement('option');
                    option.value = profesional.id;
                    option.textContent = `${profesional.nombre_completo} - ${profesional.titulo_profesional} (${profesional.anos_experiencia} años de exp.)`;
                    if (profesional.horarios_disponibles === 0) {
                        option.textContent += ' (Sin disponibilidad)';
                        option.disabled = true;
                    }
                    profesionalSelect.appendChild(option);
                });
                profesionalSelect.disabled = false;
                if (selectedId) profesionalSelect.value = selectedId;
                mostrarMensaje('');
                return true;
            } else {
                profesionalSelect.innerHTML = '<option value="">No hay profesionales disponibles</option>';
                profesionalSelect.disabled = true;
                mostrarMensaje('No hay profesionales disponibles.', 'warning');
                return false;
            }
        } catch (error) {
            console.error('Error al cargar profesionales:', error);
            mostrarMensaje(error.message || 'Error al cargar los profesionales. Intente de nuevo.', 'error');
            return false;
        }
    }

    async function cargarHorarios(profesionalId) {
        mostrarMensaje('Cargando horarios...', 'info');
        agendarBtn.style.display = 'none';
        horarioSelect.disabled = true;
        document.getElementById('horarios-list').style.display = 'none';
        document.getElementById('horarios-list').innerHTML = '';
        
        if (flatpickrInstance) flatpickrInstance.destroy();
        horarioSelect.value = '';

        try {
            const idPaciente = sessionStorage.getItem('id_paciente');
            const response = await fetch(`./../api/get_horarios.php?profesional_id=${profesionalId}&id_paciente=${idPaciente}`);
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.message || 'Error en la respuesta del servidor.');
            }

            const data = await response.json();

            if (data.length > 0) {
                allAvailableTimes = data;
                const availableDates = [...new Set(data.map(h => h.fecha))];
                
                horarioSelect.disabled = false;
                
                flatpickrInstance = flatpickr(horarioSelect, {
                    dateFormat: "Y-m-d",
                    altInput: true,
                    altFormat: "d F, Y",
                    minDate: "today",
                    maxDate: new Date().fp_incr(60),
                    enable: availableDates,
                    locale: 'es',
                    onOpen: function () {
                        this.set('dateFormat', 'Y-m-d');
                        this.set('altFormat', 'd F, Y');
                        this.set('enableTime', false);
                        this.set('noCalendar', false);
                    },
                    onChange: function (selectedDates, dateStr) {
                        if (selectedDates.length > 0) {
                            showAvailableTimes(dateStr);
                        } else {
                            document.getElementById('horarios-list').style.display = 'none';
                            agendarBtn.style.display = 'none';
                        }
                    }
                });
                mostrarMensaje('');
                return true;
            } else {
                horarioSelect.disabled = true;
                mostrarMensaje('No hay horarios disponibles para este profesional.', 'warning');
                return false;
            }
        } catch (error) {
            console.error('Error al cargar horarios:', error);
            mostrarMensaje(error.message || 'Error al cargar los horarios. Intente de nuevo.', 'error');
            return false;
        }
    }

    function showAvailableTimes(selectedDate) {
        const timesContainer = document.getElementById('horarios-list');
        timesContainer.innerHTML = '';
        timesContainer.style.display = 'flex';
        timesContainer.style.gap = '10px';
        timesContainer.style.flexWrap = 'wrap';

        const dailyTimes = allAvailableTimes.filter(h => h.fecha === selectedDate);
        
        if (dailyTimes.length > 0) {
            dailyTimes.forEach(horario => {
                const timeButton = document.createElement('button');
                timeButton.className = 'time-btn';
                timeButton.textContent = new Date(`2000-01-01T${horario.hora}`).toLocaleTimeString('es-CO', { hour: '2-digit', minute: '2-digit' });
                timeButton.setAttribute('data-id-horario', horario.id_horario);
                timeButton.setAttribute('data-fecha-hora', `${horario.fecha} ${horario.hora}`);

                timeButton.addEventListener('click', (e) => {
                    e.preventDefault();
                    document.querySelectorAll('.time-btn').forEach(btn => btn.classList.remove('selected'));
                    timeButton.classList.add('selected');
                    const hiddenHorarioInput = document.getElementById('horario_seleccionado');
                    hiddenHorarioInput.value = horario.id_horario;
                    agendarBtn.style.display = 'block';
                    agendarBtn.disabled = false;
                });
                timesContainer.appendChild(timeButton);
            });
        } else {
            timesContainer.innerHTML = '<p>No hay horarios disponibles para este día.</p>';
        }
    }

    function mostrarResumen() {
        const especialidadNombre = especialidadSelect.options[especialidadSelect.selectedIndex].text;
        const profesionalNombre = profesionalSelect.options[profesionalSelect.selectedIndex].text;
        const sedeNombre = sedeSelect.options[sedeSelect.selectedIndex].text;
        
        const horarioCompleto = document.querySelector('.time-btn.selected').getAttribute('data-fecha-hora');
        const [fecha, hora] = horarioCompleto.split(' ');
        
        const fechaObj = new Date(fecha + 'T' + hora);
        const fechaTexto = fechaObj.toLocaleDateString('es-CO', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
        const horaTexto = fechaObj.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true });
        
        document.getElementById('resumen-paciente').textContent = sessionStorage.getItem('nombre_paciente');
        document.getElementById('resumen-especialidad').textContent = especialidadNombre;
        document.getElementById('resumen-profesional').textContent = profesionalNombre;
        document.getElementById('resumen-sede').textContent = sedeNombre;
        document.getElementById('resumen-fecha-hora').textContent = `${fechaTexto} - ${horaTexto}`;

        citaForm.style.display = 'none';
        resumenDiv.style.display = 'block';
    }

    async function agendarCita(e) {
        e.preventDefault();
        confirmarBtn.disabled = true;
        mostrarMensaje('Confirmando cita...', 'info');

        const data = {
            id_paciente: idPaciente,
            id_profesional: profesionalSelect.value,
            id_sede: sedeSelect.value,
            id_especialidad: especialidadSelect.value,
            id_horario: document.getElementById('horario_seleccionado').value
        };

        try {
            const response = await fetch('./../api/agendar_cita.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });

            const result = await response.json();

            if (response.ok) {
                modal.style.display = 'flex';
            } else {
                mostrarMensaje(result.message || 'Error al agendar la cita.', 'error');
                resumenDiv.style.display = 'none';
                citaForm.style.display = 'block';
            }
        } catch (error) {
            console.error('Error al agendar la cita:', error);
            mostrarMensaje('Error de conexión. No se pudo agendar la cita.', 'error');
        } finally {
            confirmarBtn.disabled = false;
        }
    }

    especialidadSelect.addEventListener('change', async (event) => {
        const especialidadId = event.target.value;
        if (especialidadId) {
            sessionStorage.setItem('last_especialidad_id', especialidadId);
            sessionStorage.removeItem('last_sede_id');
            sessionStorage.removeItem('last_profesional_id');
            await cargarSedes(especialidadId);
        } else {
            sessionStorage.removeItem('last_especialidad_id');
            sessionStorage.removeItem('last_sede_id');
            sessionStorage.removeItem('last_profesional_id');
            sedeSelect.innerHTML = '<option value="">Selecciona una especialidad primero</option>';
            sedeSelect.disabled = true;
            profesionalSelect.innerHTML = '<option value="">Selecciona una sede primero</option>';
            profesionalSelect.disabled = true;
            horarioSelect.value = '';
            horarioSelect.disabled = true;
            if (flatpickrInstance) flatpickrInstance.destroy();
            document.getElementById('horarios-list').style.display = 'none';
            agendarBtn.style.display = 'none';
        }
    });

    sedeSelect.addEventListener('change', async (event) => {
        const sedeId = event.target.value;
        const especialidadId = especialidadSelect.value;
        if (sedeId && especialidadId) {
            sessionStorage.setItem('last_sede_id', sedeId);
            sessionStorage.removeItem('last_profesional_id');
            await cargarProfesionales(especialidadId, sedeId);
        } else {
            sessionStorage.removeItem('last_sede_id');
            sessionStorage.removeItem('last_profesional_id');
            profesionalSelect.innerHTML = '<option value="">Selecciona una sede primero</option>';
            profesionalSelect.disabled = true;
            horarioSelect.value = '';
            horarioSelect.disabled = true;
            if (flatpickrInstance) flatpickrInstance.destroy();
            document.getElementById('horarios-list').style.display = 'none';
            agendarBtn.style.display = 'none';
        }
    });

    profesionalSelect.addEventListener('change', async (event) => {
        const profesionalId = event.target.value;
        if (profesionalId) {
            sessionStorage.setItem('last_profesional_id', profesionalId);
            await cargarHorarios(profesionalId);
        } else {
            sessionStorage.removeItem('last_profesional_id');
            horarioSelect.value = '';
            horarioSelect.disabled = true;
            if (flatpickrInstance) flatpickrInstance.destroy();
            document.getElementById('horarios-list').style.display = 'none';
            agendarBtn.style.display = 'none';
        }
    });
    
    agendarBtn.addEventListener('click', (e) => {
        e.preventDefault();
        mostrarResumen();
    });

    confirmarBtn.addEventListener('click', agendarCita);

    regresarBtn.addEventListener('click', () => {
        resumenDiv.style.display = 'none';
        citaForm.style.display = 'block';
    });

    btnAceptar.addEventListener('click', () => {
        modal.style.display = 'none';
        resumenDiv.style.display = 'none';
        citaForm.style.display = 'block';
        citaForm.reset();
        document.getElementById('horarios-list').style.display = 'none';
        document.getElementById('horarios-list').innerHTML = '';
        agendarBtn.style.display = 'none';
        sessionStorage.removeItem('last_especialidad_id');
        sessionStorage.removeItem('last_sede_id');
        sessionStorage.removeItem('last_profesional_id');
        iniciarFormulario();
    });

    async function iniciarFormulario() {
        const lastEspecialidadId = sessionStorage.getItem('last_especialidad_id');
        const lastSedeId = sessionStorage.getItem('last_sede_id');
        const lastProfesionalId = sessionStorage.getItem('last_profesional_id');
        
        await cargarEspecialidades();

        if (lastEspecialidadId) {
            especialidadSelect.value = lastEspecialidadId;
            const changeEvent = new Event('change');
            especialidadSelect.dispatchEvent(changeEvent);

            await new Promise(resolve => setTimeout(resolve, 500));

            if (lastSedeId) {
                sedeSelect.value = lastSedeId;
                sedeSelect.dispatchEvent(changeEvent);

                await new Promise(resolve => setTimeout(resolve, 500));

                if (lastProfesionalId) {
                    profesionalSelect.value = lastProfesionalId;
                    profesionalSelect.dispatchEvent(changeEvent);
                }
            }
        }
    }

    iniciarFormulario();
});
