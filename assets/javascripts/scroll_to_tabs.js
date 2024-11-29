document.addEventListener('DOMContentLoaded', function () {
    // Seleciona a div com os links "Anterior" e "Próximo"  
    var nextPrevLinks = document.querySelector('.next-prev-links.contextual');

    if (nextPrevLinks) {
        // Verifica se o elemento das abas existe  
        var tabsElement = document.getElementById('history');
        if (tabsElement) {
            // Cria o novo link  
            var scrollToTabsLink = document.createElement('a');
            scrollToTabsLink.href = '#history';
            scrollToTabsLink.innerText = 'Ir para as abas';
            scrollToTabsLink.title = 'Ir para as abas';

            // Adiciona um separador "|"  
            var separator = document.createTextNode(' | ');

            // Insere o separador e o novo link após os links existentes  
            nextPrevLinks.appendChild(separator);
            nextPrevLinks.appendChild(scrollToTabsLink);
        }
    }
});