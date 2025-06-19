# frozen_string_literal: true

json.html controller.render_to_string(
  partial: 'access_permissions/modals/edit_modal',
  formats: [:html],
  locals: {
    assignable: @repository,
    top_level_assignable: @repository,
    manually_assigned_users: @repository.manually_assigned_users,
    update_path: access_permissions_form_path(@repository),
    new_assignment_path: new_access_permissions_form_path(id: @repository)
  },
  layout: false
)

json.flash @message
