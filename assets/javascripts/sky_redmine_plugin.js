document.addEventListener('DOMContentLoaded', function () {
    var relationsDiv = document.getElementById('relations');
    if (relationsDiv) {
        // Esconde a seção de relações  
        relationsDiv.style.display = 'none';

        // Cria o link para expandir/colapsar  
        var toggleLink = document.createElement('a');
        toggleLink.href = '#';
        toggleLink.id = 'toggle-relations';
        toggleLink.innerText = 'Exibir tarefas relacionadas';
        toggleLink.style.display = 'block';
        toggleLink.style.marginBottom = '10px';

        // Insere o link antes da seção de relações  
        relationsDiv.parentNode.insertBefore(toggleLink, relationsDiv);

        // Adiciona o evento de clique ao link  
        toggleLink.addEventListener('click', function (event) {
            event.preventDefault();
            if (relationsDiv.style.display === 'none') {
                relationsDiv.style.display = 'block';
                toggleLink.innerText = 'Ocultar tarefas relacionadas';
            } else {
                relationsDiv.style.display = 'none';
                toggleLink.innerText = 'Exibir tarefas relacionadas';
            }
        });
    }
});