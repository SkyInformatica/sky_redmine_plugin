document.addEventListener('DOMContentLoaded', function () {
    if (typeof Chart === 'undefined') {
        console.error('Chart.js não foi carregado corretamente.');
        return;
    }

    // Inicializa todos os tooltips
    document.querySelectorAll('.tooltip-container i').forEach(function (el) {
        new bootstrap.Tooltip(el);
    });

    // Inicializa todos os gráficos
    document.querySelectorAll('canvas[data-grafico]').forEach(function (canvas) {
        var config = JSON.parse(canvas.dataset.grafico);
        var dados = config.dados;
        var labels = Object.keys(dados);
        var values = Object.values(dados);

        var chartConfig = {
            type: config.tipo,
            data: {
                labels: labels,
                datasets: [{
                    label: ' ',  // Espaço em branco para não mostrar 'undefined'
                    data: values,
                    backgroundColor: [
                        'rgba(54, 162, 235, 0.8)',
                        'rgba(255, 99, 132, 0.8)',
                        'rgba(75, 192, 192, 0.8)',
                        'rgba(255, 206, 86, 0.8)',
                        'rgba(153, 102, 255, 0.8)',
                        'rgba(255, 159, 64, 0.8)'
                    ],
                    borderColor: [
                        'rgba(54, 162, 235, 1)',
                        'rgba(255, 99, 132, 1)',
                        'rgba(75, 192, 192, 1)',
                        'rgba(255, 206, 86, 1)',
                        'rgba(153, 102, 255, 1)',
                        'rgba(255, 159, 64, 1)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: config.tipo !== 'bar' // Remove legenda apenas para gráficos de barra
                    }
                }
            }
        };

        // Configurações específicas para gráficos
        if (config.tipo === 'bar') {
            // Configura o eixo Y para usar apenas números inteiros
            chartConfig.options.scales = {
                y: {
                    beginAtZero: true,
                    ticks: {
                        stepSize: 1,
                        precision: 0
                    }
                }
            };
        }

        new Chart(canvas, chartConfig);
    });
});