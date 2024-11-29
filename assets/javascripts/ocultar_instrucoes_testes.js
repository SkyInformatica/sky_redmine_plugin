document.addEventListener('DOMContentLoaded', function () {
    var relationsDiv = document.getElementById('text_cf cf_43 attribute');
    if (relationsDiv) {
        relationsDiv.style.display = 'none';

        var hideText = 'Ocultar instrucoes para teste';
        var showText = 'Exibir instrucoes para teste';

        // Cria o link para expandir/colapsar  
        var toggleLink = document.createElement('a');
        toggleLink.href = '#';
        toggleLink.id = 'toggle-instrucoes-testes';
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
    }
});