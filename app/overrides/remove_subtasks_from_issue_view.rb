# plugins/sky_redmine_plugin/app/overrides/remove_subtasks_from_issue_view.rb

Deface::Override.new(
  virtual_path: "issues/show",
  name: "remove-subtasks-from-issue-view",
  remove: "erb[loud]:contains('render :partial => \"subtasks\"')",
)
