# frozen_string_literal: true

json.modal controller.render_to_string(
  partial: 'access_permissions/modals/show_modal',
  formats: [:html],
  locals: {
    assignable: @repository,
    top_level_assignable: @repository,
    manually_assigned_users: @repository.manually_assigned_users
  },
  layout: false
)
