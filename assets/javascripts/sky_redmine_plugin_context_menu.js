(function () {
    // Certifique-se que a função de criação de menus de contexto já está definida
    console.log('inicio sky_redmine_plugin_context_menu')

    /*
    const originalBuildContextMenu = contextMenuRightClick.prototype.buildContextMenu;

    contextMenuRightClick.prototype.buildContextMenu = function (event) {
        const menu = originalBuildContextMenu.call(this, event); // Chama o original

        // Verifique se uma tarefa única está selecionada
        if (this.getSelection().length === 1) {
            const issue = this.getSelection()[0];

            const issueStatus = issue.querySelector('.status').textContent.trim();
            const projectName = issue.querySelector('.project').textContent.trim();
            const issueId = issue.getAttribute('data-issue-id');
            console.log("issueId: ", issueId)

            
            // Verifique as condições para adicionar o menu
            if (issueStatus === "Teste NOK" && ["Notarial - QS", "Registral - QS"].includes(projectName)) {
                menu.push({
                    title: 'Criar tarefa de retorno de testes para essa tarefa de testes',
                    callback: function() {
                        $.post(criar_retorno_testes_qs_path({ id: issueId }))
                            .done(function() { location.reload(); });
                    }
                });
            } else if (issueStatus === "Resolvida" && !["Notarial - QS", "Registral - QS"].includes(projectName)) {
                menu.push({
                    title: 'Criar tarefa de retorno de testes para essa tarefa de desenvolvimento',
                    callback: function() {
                        $.post(criar_retorno_testes_devel_path({ id: issueId }))
                            .done(function() { location.reload(); });
                    }
                });
            }
            
        }

        return menu; // Retorna o menu atualizado
    };
    */

})();

