# frozen_string_literal: true

class UserNotificationsController < ApplicationController
  prepend_before_action -> { request.env['devise.skip_trackable'] = true }, only: :unseen_counter

  def index
    page = (params.dig(:page, :number) || 1).to_i
    notifications = load_notifications.page(page).per(Constants::INFINITE_SCROLL_LIMIT)

    render json: notifications, each_serializer: NotificationSerializer

    notifications.mark_as_read!
  end

  def unseen_counter
    render json: {
      unseen: load_notifications.where(read_at: nil).size
    }
  end

  def filter_groups
    render json:
      {
        data:
          NotificationExtends::NOTIFICATIONS_GROUPS.values.map(&:keys)
                                                   .flatten
                                                   .map { |g| [g, I18n.t("notifications.sub_groups.#{g}")] }
      }
  end

  private

  def load_notifications
    notifications =
      current_user.notifications
                  .in_app
                  .order(created_at: :desc)

    subgroups = params[:subgroups]&.split(',')

    if subgroups&.any?
      notifications =
        notifications.where(subtype: subgroups.map { |sg| Notification.subgroup_subtypes(sg) }.flatten)
    end

    notifications
  end
end
