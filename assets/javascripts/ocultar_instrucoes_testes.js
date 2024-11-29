document.addEventListener('DOMContentLoaded', function () {

    var campos = [
        {
            selector: '.text_cf.cf_43.attribute'
        },
        {
            selector: '.text_cf.cf_59.attribute'
        }
        {
            selector: '.text_cf.cf_60.attribute'
        }
    ];

    campos.forEach(function (campo) {
        var campoDiv = document.querySelector(campo.selector);
        if (campoDiv) {
            campoDiv.style.display = 'block';

            var hideText = 'Ocultar';
            var showText = 'Exibir';

            // Criar o link para expandir/colapsar  
            var toggleLink = document.createElement('a');
            toggleLink.href = '#';
            toggleLink.innerText = hideText;

            // Criar o elemento <span> com a classe 'contextual' e inserir o toggleLink dentro dele  
            var contextualSpan = document.createElement('span');
            contextualSpan.className = 'contextual';
            contextualSpan.appendChild(toggleLink);

            // Selecionar o título  
            var tituloElement = campoDiv.querySelector('p strong span');
            var tituloContainer = document.createElement('div');
            tituloContainer.style.display = 'flex';
            tituloContainer.style.justifyContent = 'space-between';
            tituloContainer.style.alignItems = 'center';

            // Mover o título para o contêiner  
            tituloContainer.appendChild(tituloElement.parentNode.parentNode); // Captura o <p> que contém o título  
            tituloContainer.appendChild(contextualSpan);

            // Inserir o contêiner antes do conteúdo  
            var conteudoDiv = campoDiv.querySelector('.value');
            campoDiv.insertBefore(tituloContainer, conteudoDiv);

            // Adicionar o evento de clique ao link  
            toggleLink.addEventListener('click', function (event) {
                event.preventDefault();
                if (conteudoDiv.style.display === 'none') {
                    conteudoDiv.style.display = 'block';
                    toggleLink.innerText = hideText;
                } else {
                    conteudoDiv.style.display = 'none';
                    toggleLink.innerText = showText;
                }
            });
        }
    });
});