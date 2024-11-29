document.addEventListener('DOMContentLoaded', function () {
    var instrucoesTestesDiv = document.querySelector('.text_cf.cf_43.attribute');
    if (instrucoesTestesDiv) {
        instrucoesTestesDiv.style.display = 'none';

        var hideText = 'Ocultar instruções para teste';
        var showText = 'Exibir instruções para teste';

        // Cria o link para expandir/colapsar  
        var toggleLink = document.createElement('a');
        toggleLink.href = '#';
        toggleLink.id = 'toggle-instrucoes-testes';
        toggleLink.innerText = showText;
        toggleLink.style.display = 'block';
        toggleLink.style.marginBottom = '10px';

        // Cria a linha divisória <hr>
        var hrElement = document.createElement('hr');
        hrElement.style.marginBottom = '10px'; // Adiciona um espaçamento opcional

        // Insere o <hr> antes do toggleLink
        instrucoesTestesDiv.parentNode.insertBefore(hrElement, instrucoesTestesDiv);

        // Insere o link antes do div
        instrucoesTestesDiv.parentNode.insertBefore(toggleLink, instrucoesTestesDiv);

        // Adiciona o evento de clique ao link  
        toggleLink.addEventListener('click', function (event) {
            event.preventDefault();
            if (instrucoesTestesDiv.style.display === 'none') {
                instrucoesTestesDiv.style.display = 'block';
                toggleLink.innerText = hideText;
            } else {
                instrucoesTestesDiv.style.display = 'none';
                toggleLink.innerText = showText;
            }
        });
    }
});
