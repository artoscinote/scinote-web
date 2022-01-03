# frozen_string_literal: true

require 'capybara/rspec'
require 'simplecov'
require 'faker'
require 'active_record'
require 'bullet'
require 'json_matchers/rspec'
require 'webmock/rspec'

# Require all custom matchers
Dir[
  File.expand_path(File.join(File.dirname(__FILE__), 'support', '**', '*.rb'))
].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups

  if Bullet.enable?
    config.before(:each) do
      Bullet.start_request
    end

    config.after(:each) do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end

  config.before(:suite) do
    class Activity
      mattr_accessor :logged_activity_webhook_payloads

      before_save :save_activity_payload

      @@logged_activity_webhook_payloads = []

      def save_activity_payload
        payload = Activities::ActivityWebhookService.new(Webhook.new, self).activity_payload
        payload[:created_at] = Time.now
        @@logged_activity_webhook_payloads.push payload
      end
    end
  end

  config.after(:suite) do
    Activity.logged_activity_webhook_payloads.uniq { |ap| ap[:type] }.each do |activity_payload|
      open('activity_payloads.md', 'a') do |f|
        f.puts "### #{activity_payload[:type].humanize}"
        f.puts "```"
        f.puts JSON.pretty_generate(activity_payload)
        f.puts "```"
        f.puts
      end
    end
  end
end
