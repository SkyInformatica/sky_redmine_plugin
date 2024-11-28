document.addEventListener("DOMContentLoaded", function () {
    const tabsContainer = document.querySelector(".tabs");
    if (tabsContainer) {
        // Adicionar a aba "Fluxo de Tarefas" à lista de abas  
        const tabsList = tabsContainer.querySelector("ul");
        if (tabsList) {
            // Criar elemento para a nova aba  
            const newTab = document.createElement("li");
            newTab.innerHTML = `  
          <a id="tab-fluxo-tarefas" href="#fluxo-tarefas">  
            Fluxo de Tarefas  
          </a>  
        `;
            tabsList.appendChild(newTab);

            // Exibir o conteúdo da aba ao clicar  
            newTab.addEventListener("click", function (e) {
                e.preventDefault();
                // Esconder todos os conteúdos de abas  
                document.querySelectorAll(".tab-content").forEach((tabContent) => {
                    tabContent.style.display = "none";
                });

                // Remover a classe 'selected' de abas existentes  
                tabsList.querySelectorAll("a").forEach((tabLink) => {
                    tabLink.classList.remove("selected");
                });

                // Exibir a nova aba  
                document.getElementById("fluxo-tarefas").style.display = "block";
                this.querySelector("a").classList.add("selected");
            });
        }
    }
});