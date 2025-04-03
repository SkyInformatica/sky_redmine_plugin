document.addEventListener('DOMContentLoaded', function () {
    // Inicializa todos os tooltips
    document.querySelectorAll('.tooltip-container i').forEach(function (el) {
        new bootstrap.Tooltip(el);
    });

    // Inicializa todos os gráficos
    document.querySelectorAll('[data-grafico]').forEach(function (el) {
        const config = JSON.parse(el.dataset.grafico);
        const ctx = el.getContext('2d');

        const chartConfig = {
            type: config.tipo,
            data: {
                labels: Object.keys(config.dados),
                datasets: [{
                    data: Object.values(config.dados),
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
                        position: 'bottom',
                        labels: {
                            padding: 20
                        }
                    }
                }
            }
        };

        new Chart(ctx, chartConfig);
    });
}); 