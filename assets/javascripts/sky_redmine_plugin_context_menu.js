(function () {
    var oldBuildContextMenu = contextMenuRightClick.prototype.buildContextMenu;

    contextMenuRightClick.prototype.buildContextMenu = function (event) {
        var menu = oldBuildContextMenu.call(this, event);

        if (this.getSelection().length == 1) {
            var issue = this.getSelection()[0];
            var issueStatus = issue.querySelector('.status').textContent.trim();
            var projectName = issue.querySelector('.project').textContent.trim();
            var issueId = issue.getAttribute('data-issue-id');

            if (issueStatus == "Teste NOK" && ["Notarial - QS", "Registral - QS"].includes(projectName)) {
                menu.push({
                    title: 'Criar tarefa de retorno de testes para essa tarefa de testes',
                    callback: function () {
                        $.post(criar_retorno_testes_qs_path({ id: issueId }))
                            .done(function () { location.reload(); });
                    }
                });
            } else if (issueStatus == "Resolvida" && !["Notarial - QS", "Registral - QS"].includes(projectName)) {
                menu.push({
                    title: 'Criar tarefa de retorno de testes para essa tarefa de desenvolvimento',
                    callback: function () {
                        $.post(criar_retorno_testes_devel_path({ id: issueId }))
                            .done(function () { location.reload(); });
                    }
                });
            }
        }

        return menu;
    };
})();