# frozen_string_literal: true

class RepositoryDateValue < RepositoryDateTimeValueBase
  def data_changed?(new_data)
    Time.use_zone('UTC') do
      new_time = Time.zone.parse(new_data)
      new_time.to_date != data.to_date
    end
  end

  def formatted
    Time.use_zone('UTC') do
      super(:full_date)
    end
  end

  def self.new_with_payload(payload, attributes)
    value = new(attributes)
    value.data = Time.zone.parse(payload)
    value
  end

  def self.import_from_text(text, attributes, options = {})
    date_format = (options.dig(:user, :settings, :date_format) || Constants::DEFAULT_DATE_FORMAT).gsub(/%-/, '%')
    Time.use_zone('UTC') do
      new(attributes.merge(data: Date.strptime(text, date_format).to_datetime))
    end
  rescue ArgumentError
    nil
  end

  alias export_formatted formatted
end
