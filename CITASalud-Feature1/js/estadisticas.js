// /js/estadisticas.js (Completo y Corregido)

document.addEventListener('DOMContentLoaded', () => {
    
    // 1. Obtención y verificación del ID autenticado
    const idPaciente = sessionStorage.getItem('id_paciente');
    if (!idPaciente) {
        alert('Por favor, inicie sesión primero.');
        window.location.href = './../html/login.html';
        return;
    }


    // 2. Definición de la URL base con el ID del paciente autenticado
    // CORREGIDO: Uso de idPaciente en lugar de ID_PACIENTE
    const API_BASE_URL = `./../api/get_estadisticas_asistencia.php?id_paciente=${idPaciente}`; 

    // Nueva paleta de colores
    const COLORES = {
        ASISTIDA: '#007bff',      // Azul primario
        NO_ASISTIDA: '#6c757d', // Gris oscuro/medio
        TEXTO: '#343a40'          // Azul oscuro para texto
    };

    /**
     * Función principal que llama a la API, obtiene los datos y actualiza el DOM.
     * Lee el filtro de mes y ajusta la URL de la API.
     */
    async function obtenerDatosYDibujar() {
        // 1. Obtener el mes seleccionado del dropdown
        const filtroMesElement = document.getElementById('filtroMes');
        const mesSeleccionado = filtroMesElement ? filtroMesElement.value : '0'; // '0' = Todos los Meses

        // 2. Construir la URL con el filtro de mes
        let finalAPI_URL = API_BASE_URL;
        if (mesSeleccionado !== '0') {
            // Añade el parámetro 'mes' a la URL solo si no es "Todos los Meses"
            finalAPI_URL += `&mes=${mesSeleccionado}`;
        }
        
        // Mostrar mensaje de carga o similar antes de la llamada (opcional)

        try {
            // Usar la URL modificada
            const response = await fetch(finalAPI_URL);

            if (!response.ok) {
                throw new Error(`Error HTTP! Estado: ${response.status}`);
            }

            const data = await response.json();

            // 1. Actualizar el Resumen de Cumplimiento
            document.getElementById('totalAsistidas').innerText = data.resumen.total_asistidas;
            document.getElementById('totalNoAsistidas').innerText = data.resumen.total_no_asistidas;
            document.getElementById('porcentajeCumplimiento').innerText = data.resumen.porcentaje_cumplimiento + '%';

            // 2. Dibujar los Gráficos
            dibujarGraficoCircular(data.graficos.datos_totales);
            dibujarGraficoBarras(data.graficos.datos_totales);
            dibujarGraficoLineas(data.graficos.historial_mensual);

            // 3. Actualizar la fecha y hora de la última actualización
            const now = new Date();
            const dateStr = `${now.getDate().toString().padStart(2, '0')}/${(now.getMonth() + 1).toString().padStart(2, '0')}/${now.getFullYear()}`;
            const timeStr = now.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' });


        } catch (error) {
            console.error('Fallo al obtener datos de la API:', error);
            // Mostrar un error en la interfaz
            document.getElementById('totalAsistidas').innerText = 'Error';
            document.getElementById('totalNoAsistidas').innerText = 'Error';
            document.getElementById('porcentajeCumplimiento').innerText = 'N/A';

            // alert(`ERROR: No se pudo conectar a la API. URL: ${finalAPI_URL}. Revisa la consola (F12).`);
        }
    }


    function dibujarGraficoCircular(datos) {
        const ctx = document.getElementById('graficoCircular').getContext('2d');
        const asistidas = datos.find(d => d.etiqueta === 'Asistidas').valor;
        const noAsistidas = datos.find(d => d.etiqueta === 'No Asistidas').valor;

        const total = asistidas + noAsistidas;
        const porcentajeAsistidas = total > 0 ? ((asistidas / total) * 100).toFixed(0) : 0;
        const porcentajeNoAsistidas = total > 0 ? ((noAsistidas / total) * 100).toFixed(0) : 0;

        // Destruir la instancia anterior si existe (evita superposición)
        let chartStatus = Chart.getChart("graficoCircular");
        if (chartStatus !== undefined) {
            chartStatus.destroy();
        }

        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: [`Asistidas (${porcentajeAsistidas}%)`, `No Asistidas (${porcentajeNoAsistidas}%)`],
                datasets: [{
                    data: [asistidas, noAsistidas],
                    backgroundColor: [COLORES.ASISTIDA, COLORES.NO_ASISTIDA],
                    borderColor: '#fff',
                    borderWidth: 2,
                    hoverOffset: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: { color: COLORES.TEXTO }
                    },
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                let label = context.label || '';
                                if (label) { label += ': '; }
                                if (context.parsed !== null) { label += context.parsed + ' citas'; }
                                return label;
                            }
                        }
                    }
                }
            }
        });
    }

    function dibujarGraficoBarras(datos) {
        const ctx = document.getElementById('graficoBarras').getContext('2d');
        const asistidas = datos.find(d => d.etiqueta === 'Asistidas').valor;
        const noAsistidas = datos.find(d => d.etiqueta === 'No Asistidas').valor;

        let chartStatus = Chart.getChart("graficoBarras");
        if (chartStatus !== undefined) {
            chartStatus.destroy();
        }

        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['Asistidas', 'No Asistidas'],
                datasets: [{
                    label: 'Número de Citas',
                    data: [asistidas, noAsistidas],
                    backgroundColor: [COLORES.ASISTIDA, COLORES.NO_ASISTIDA],
                    borderColor: [COLORES.ASISTIDA, COLORES.NO_ASISTIDA],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: { beginAtZero: true, ticks: { color: COLORES.TEXTO } },
                    x: { ticks: { color: COLORES.TEXTO } }
                }
            }
        });
    }

    function dibujarGraficoLineas(historial) {
        const ctx = document.getElementById('graficoLineas').getContext('2d');
        const monthNames = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];

        // El filtro de mes solo afecta el lado PHP, el JavaScript dibuja el historial que le llega.
        const labels = historial.map(item => monthNames[parseInt(item.mes_anio.split('-')[1]) - 1] + '-' + item.mes_anio.split('-')[0].slice(-2));

        const asistidas = historial.map(item => parseInt(item.asistidas));
        const noAsistidas = historial.map(item => parseInt(item.no_asistidas));

        let chartStatus = Chart.getChart("graficoLineas");
        if (chartStatus !== undefined) {
            chartStatus.destroy();
        }

        new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Asistidas',
                        data: asistidas,
                        borderColor: COLORES.ASISTIDA,
                        backgroundColor: `rgba(0, 123, 255, 0.2)`,
                        pointBackgroundColor: COLORES.ASISTIDA,
                        fill: true,
                        tension: 0.4,
                        borderWidth: 3
                    },
                    {
                        label: 'No Asistidas',
                        data: noAsistidas,
                        borderColor: COLORES.NO_ASISTIDA,
                        backgroundColor: `rgba(108, 117, 125, 0.2)`,
                        pointBackgroundColor: COLORES.NO_ASISTIDA,
                        fill: true,
                        tension: 0.4,
                        borderWidth: 3
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    // 🚨 CORRECCIÓN: Desactivar el título ya que el filtro es global/externo
                    title: { display: false }, 
                    legend: { labels: { color: COLORES.TEXTO } }
                },
                scales: {
                    y: { beginAtZero: true, ticks: { color: COLORES.TEXTO } },
                    x: { ticks: { color: COLORES.TEXTO } }
                }
            }
        });
    }

    // Ejecutar la función principal al cargar la página
    obtenerDatosYDibujar();
    
    // El onchange del HTML ya llama a obtenerDatosYDibujar, pero añadimos el listener 
    // por si el onchange se elimina en el HTML.
    const filtroMesElement = document.getElementById('filtroMes');
    if (filtroMesElement) {
        filtroMesElement.addEventListener('change', obtenerDatosYDibujar);
    }
});