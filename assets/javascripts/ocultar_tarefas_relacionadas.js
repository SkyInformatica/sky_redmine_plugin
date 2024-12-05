document.addEventListener('DOMContentLoaded', function () {
    var relationsDiv = document.getElementById('relations');
    var tabContentDiv = document.querySelector('#tab-content-tarefas_relacionadas');

    if (relationsDiv && tabContentDiv) {


        // Remover o <hr> imediatamente antes da div 'relations'  
        var previousElement = relationsDiv.previousElementSibling;
        while (previousElement && previousElement.tagName === 'BR') {
            var elementToRemove = previousElement;
            previousElement = previousElement.previousElementSibling;
            elementToRemove.remove();
        }
        if (previousElement && previousElement.tagName === 'HR') {
            previousElement.remove();
        }

        // Move a div 'relations' para dentro do conteúdo da aba  
        tabContentDiv.appendChild(relationsDiv);
    }
});