document.addEventListener('DOMContentLoaded', function () {
    // Verifica se o elemento das abas existe  
    var tabsElement = document.getElementById('history');
    if (tabsElement) {
        // Cria o novo link  
        var scrollToTabsLink = document.createElement('a');
        scrollToTabsLink.href = '#history';
        scrollToTabsLink.innerText = 'Ir para as abas';
        scrollToTabsLink.title = 'Ir para as abas';

        // Tenta selecionar a div com os links "Anterior" e "Próximo"  
        var nextPrevLinks = document.querySelector('.next-prev-links.contextual');

        if (nextPrevLinks) {
            // Adiciona um separador "|"  
            var separator = document.createTextNode(' | ');

            // Insere o separador e o novo link após os links existentes  
            nextPrevLinks.appendChild(separator);
            nextPrevLinks.appendChild(scrollToTabsLink);

        } else {
            // Caso a div nextPrevLinks não exista, adiciona o link na div .subject  
            var subjectDiv = document.querySelector('.subject');

            if (subjectDiv) {
                // Selecionar o elemento h3 (título)  
                var tituloElement = subjectDiv.querySelector('h3');

                if (tituloElement) {
                    // Criar o elemento <span> com a classe 'contextual' e inserir o link dentro dele  
                    var contextualSpan = document.createElement('span');
                    contextualSpan.className = 'contextual';
                    contextualSpan.appendChild(scrollToTabsLink);

                    // Criar um contêiner flex para alinhar o título e o link  
                    var tituloContainer = document.createElement('div');
                    tituloContainer.style.display = 'flex';
                    tituloContainer.style.justifyContent = 'space-between';
                    tituloContainer.style.alignItems = 'center';

                    // Mover o título e o link para o contêiner  
                    tituloContainer.appendChild(tituloElement);
                    tituloContainer.appendChild(contextualSpan);

                    // Inserir o contêiner na div .subject  
                    subjectDiv.appendChild(tituloContainer);
                }
            }
        }
    }
});