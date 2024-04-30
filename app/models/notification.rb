# frozen_string_literal: true

class Notification < ApplicationRecord
  include Noticed::Model

  belongs_to :recipient, polymorphic: true

  before_save :set_subtype

  scope :in_app, lambda {
    where.not("notifications.params ? 'hide_in_app' AND notifications.params->'hide_in_app' = 'true'")
  }

  def self.subgroup_subtypes(subgroup)
    NotificationExtends::NOTIFICATIONS_GROUPS
      .values
      .reduce(&:merge)
      .select { |k, _| k == subgroup.to_sym }
      .values
      .flatten
  end

  private

  def can_send_to_user?(_user)
    true # overridable send permission method
  end

  def set_subtype
    self.subtype = to_notification.subtype
  end
end
