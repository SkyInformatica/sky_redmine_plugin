document.addEventListener("DOMContentLoaded", function () {
    // Certifique-se de que há abas para modificar  
    const tabs = document.querySelector("#tab-container");
    if (tabs) {
        // Adicionar a aba 'Fluxo de Tarefas' na lista de abas  
        const fluxoTarefasTab = document.createElement("li");
        fluxoTarefasTab.id = "tab-fluxo-tarefas";
        fluxoTarefasTab.className = "tab";
        fluxoTarefasTab.innerHTML = '<a href="#fluxo-tarefas">Fluxo de Tarefas</a>';
        tabs.querySelector("ul").appendChild(fluxoTarefasTab);

        // Garantir que o conteúdo da aba está carregado corretamente  
        const fluxoTarefasContent = document.querySelector("#fluxo-tarefas");
        if (fluxoTarefasContent) {
            fluxoTarefasTab.addEventListener("click", function () {
                // Mostra apenas o conteúdo desta aba  
                document
                    .querySelectorAll(".tab-content")
                    .forEach((tab) => (tab.style.display = "none"));
                fluxoTarefasContent.style.display = "block";

                // Atualizar as classes das abas ativas  
                document
                    .querySelectorAll("#tab-container .tab")
                    .forEach((tab) => tab.classList.remove("selected"));
                this.classList.add("selected");
            });
        }
    }
});