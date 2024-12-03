document.addEventListener('DOMContentLoaded', function () {

    var relationsDiv = document.getElementById('issue_tree');
    if (relationsDiv) {
        // Esconde a seção de relações  
        relationsDiv.style.display = 'none';

        var hideText = 'Ocultar subtarefas';
        var showText = 'Exibir subtarefas';

        // Cria o link para expandir/colapsar  
        var toggleLink = document.createElement('a');
        toggleLink.href = '#';
        toggleLink.id = 'toggle-relations';
        toggleLink.innerText = showText;
        toggleLink.style.display = 'block';
        toggleLink.style.marginBottom = '10px';

        // Insere o link antes da seção de relações  
        relationsDiv.parentNode.insertBefore(toggleLink, relationsDiv);

        // Adiciona o evento de clique ao link  
        toggleLink.addEventListener('click', function (event) {
            event.preventDefault();
            if (relationsDiv.style.display === 'none') {
                relationsDiv.style.display = 'block';
                toggleLink.innerText = hideText;
            } else {
                relationsDiv.style.display = 'none';
                toggleLink.innerText = showText;
            }
        });

        /*
        var previousElement = relationsDiv.previousElementSibling;
        while (previousElement && previousElement.tagName === 'BR') {
            var elementToRemove = previousElement;
            previousElement = previousElement.previousElementSibling;
            elementToRemove.remove();
        }
        if (previousElement && previousElement.tagName === 'HR') {
            previousElement.remove();
        }
            */

    }
});
