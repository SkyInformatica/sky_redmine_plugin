function exibirProgresso(tipo, titulo) {
    // Cria o diálogo se não existir
    if (!document.getElementById("progresso-dialogo")) {
        const dialogo = document.createElement("div");
        dialogo.id = "progresso-dialogo";
        dialogo.innerHTML = `
      <div class="progresso-overlay">
        <div class="progresso-caixa">
          <h3 id="progresso-titulo"></h3>
          <div class="progresso-barra-container">
            <div id="progresso-barra" class="progresso-barra"></div>
          </div>
          <p id="progresso-texto">0%</p>
        </div>
      </div>
    `;
        document.body.appendChild(dialogo);
    }

    // Configura o título
    document.getElementById("progresso-titulo").innerText = titulo;

    // Exibe o diálogo
    document.getElementById("progresso-dialogo").style.display = "block";

    // Atualiza o progresso periodicamente
    const intervalo = setInterval(() => {
        fetch(`/progresso?tipo=${tipo}`)
            .then((response) => response.json())
            .then((data) => {
                const progresso = data.progresso;
                document.getElementById("progresso-barra").style.width = `${progresso}%`;
                document.getElementById("progresso-texto").innerText = `${progresso}%`;

                // Fecha o diálogo quando o progresso atinge 100%
                if (progresso >= 100) {
                    clearInterval(intervalo);
                    setTimeout(() => {
                        document.getElementById("progresso-dialogo").style.display = "none";
                    }, 1000);
                }
            });
    }, 1000);
}
