document.addEventListener('DOMContentLoaded', function () {
    var relationsDiv = document.getElementById('issue_tree');
    var tabContentDiv = document.querySelector('#tab-content-subtarefas');

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