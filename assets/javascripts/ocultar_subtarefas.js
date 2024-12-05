document.addEventListener('DOMContentLoaded', function () {
    var relationsDiv = document.getElementById('issue_tree');
    var tabContentDiv = document.querySelector('#tab-content-subtarefas');

    if (relationsDiv && tabContentDiv) {
        // Move a div 'relations' para dentro do conteúdo da aba  
        tabContentDiv.appendChild(relationsDiv);

        // Remove o título e o <hr> que ficavam antes da div 'relations'  
        var previousElements = [];
        var element = relationsDiv.previousElementSibling;
        while (element && (element.tagName === 'P' || element.tagName === 'HR' || element.tagName === 'BR')) {
            previousElements.push(element);
            element = element.previousElementSibling;
        }
        previousElements.forEach(function (el) {
            el.parentNode.removeChild(el);
        });
    }
});