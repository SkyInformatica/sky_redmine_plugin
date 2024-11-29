document.addEventListener('DOMContentLoaded', function () {
    var relationsDiv = document.getElementById('issue_tree');
    if (relationsDiv) {
        // Remover a div 'relations'  
        relationsDiv.remove();

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
    }
});