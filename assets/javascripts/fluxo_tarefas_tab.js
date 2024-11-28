document.addEventListener("DOMContentLoaded", function () {
    // Selecionar o contêiner de abas  
    const tabsContainer = document.querySelector(".tabs ul");
    if (tabsContainer) {
        // Adicionar a aba "Fluxo de Tarefas"  
        const fluxoTarefasTab = document.createElement("li");
        fluxoTarefasTab.innerHTML = `  
        <a id="tab-fluxo-tarefas" href="#fluxo-tarefas" onclick="showIssueHistory('fluxo-tarefas', this.href); return false;" class="">  
          Fluxo de Tarefas  
        </a>  
      `;
        tabsContainer.appendChild(fluxoTarefasTab);

        // Adicionar o conteúdo correspondente à aba  
        const fluxoTarefasContent = document.createElement("div");
        fluxoTarefasContent.id = "fluxo-tarefas";
        fluxoTarefasContent.style.display = "none"; // Inicialmente oculto  
        fluxoTarefasContent.classList.add("tab-content");
        fluxoTarefasContent.innerHTML = `  
        <div class="fluxo-tarefas">  
          <p>Carregando fluxo de tarefas...</p>  
        </div>  
      `;
        const historyContainer = document.getElementById("history");
        if (historyContainer) {
            historyContainer.parentNode.appendChild(fluxoTarefasContent);
        }

        // Configurar alternância de abas  
        document.querySelectorAll(".tabs ul li a").forEach((tabLink) => {
            tabLink.addEventListener("click", function (event) {
                // Ocultar todos os conteúdos de abas  
                document.querySelectorAll(".tab-content").forEach((tabContent) => {
                    tabContent.style.display = "none";
                });

                // Remover a classe "selected" de todas as abas  
                document.querySelectorAll(".tabs ul li a").forEach((link) => {
                    link.classList.remove("selected");
                });

                // Exibir o conteúdo da aba clicada  
                const targetId = this.getAttribute("href").substring(1); // Obter o ID do conteúdo da aba  
                const targetContent = document.getElementById(targetId);
                if (targetContent) {
                    targetContent.style.display = "block";
                }

                // Marcar a aba clicada como "selected"  
                this.classList.add("selected");

                event.preventDefault();
            });
        });
    }
});