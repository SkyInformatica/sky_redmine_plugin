document.addEventListener("DOMContentLoaded", function () {
    // Selecionar o contêiner de abas  
    const tabsContainer = document.querySelector(".tabs ul");
    if (tabsContainer) {
        // Adicionar a aba "Fluxo de Tarefas" à lista de abas  
        const newTab = document.createElement("li");
        newTab.innerHTML = `  
        <a id="tab-fluxo-tarefas" href="#tab-content-fluxo-tarefas" onclick="showIssueHistory('fluxo-tarefas', this.href); return false;">  
          Fluxo de Tarefas  
        </a>  
      `;
        tabsContainer.appendChild(newTab);

        // Adicionar o conteúdo correspondente à aba  
        const tabContent = document.createElement("div");
        tabContent.id = "tab-content-fluxo-tarefas";
        tabContent.className = "tab-content";
        tabContent.style.display = "none"; // Inicialmente oculto  
        tabContent.innerHTML = `  
        <div class="fluxo-tarefas">  
          <h3>Fluxo de Tarefas</h3>  
          <p>Carregando fluxo de tarefas...</p>  
        </div>  
      `;

        // Adicionar o conteúdo ao contêiner principal das abas  
        const historyContainer = document.getElementById("history");
        if (historyContainer) {
            historyContainer.parentNode.appendChild(tabContent);
        }

        // Configurar a alternância de abas  
        tabsContainer.querySelectorAll("a").forEach((tabLink) => {
            tabLink.addEventListener("click", function (e) {
                e.preventDefault();

                // Esconder todos os conteúdos de abas  
                document.querySelectorAll(".tab-content").forEach((tabContent) => {
                    tabContent.style.display = "none";
                });

                // Remover a classe 'selected' de todas as abas  
                tabsContainer.querySelectorAll("a").forEach((link) => {
                    link.classList.remove("selected");
                });

                // Exibir o conteúdo da aba clicada  
                const targetId = this.getAttribute("href").substring(1); // Obter o ID do conteúdo da aba  
                const targetContent = document.getElementById(targetId);
                if (targetContent) {
                    targetContent.style.display = "block";
                }

                // Marcar a aba clicada como 'selected'  
                this.classList.add("selected");
            });
        });
    }
});