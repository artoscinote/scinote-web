# frozen_string_literal: true

class Webhook < ApplicationRecord
  enum method: { get: 0, post: 1, patch: 2 }

  belongs_to :activity_filter
  validates :method, presence: true
  validates :url, presence: true
  validate :valid_url

  def name
    "#{method.upcase} #{url}"
  end

  private

  def valid_url
    unless /\A#{URI::DEFAULT_PARSER.make_regexp(%w(http https))}\z/.match?(url)
      errors.add(:url, I18n.t('activerecord.errors.models.webhook.attributes.url.not_valid'))
    end
  end
end
