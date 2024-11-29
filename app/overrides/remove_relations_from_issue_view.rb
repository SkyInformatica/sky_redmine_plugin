# plugins/sky_redmine_plugin/app/overrides/remove_relations_from_issue_view.rb

module RemoveRelationsFromIssueView
  Deface::Override.new(
    virtual_path: "issues/show",
    name: "remove-relations-from-issue-view",
    remove: "erb[loud]:contains('render :partial => \"relations\"')",
  )
end
