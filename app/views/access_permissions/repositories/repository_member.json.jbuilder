# frozen_string_literal: true

json.form controller.render_to_string(
  partial: 'access_permissions/partials/member_field',
  formats: [:html],
  locals: {
    user: @user_assignment.user,
    assignable: @repository,
    update_path: access_permissions_form_path(@repository),
    delete_path: access_permissions_form_path(@repository, user_id: @user_assignment.user_id)
  },
  layout: false
)
