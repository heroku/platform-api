require 'pry'
require 'webmock/rspec'
require 'platform-api'
require 'netrc'
require 'hatchet'

include WebMock::API
WebMock.allow_net_connect!

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.warnings = true
  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end
  config.order = :random
  Kernel.srand config.seed
end

def hatchet_app
  @hatchet_app ||= begin
    app = Hatchet::Runner.new("default_ruby", buildpacks: ["heroku/ruby"])
    app.in_directory do
      app.setup!
      app.push_with_retry!
    end
    app.api_rate_limit.call.app_webhook.create(app.name, include: ["dyno"] , level: "notify", url: "https://example.com")
    app.api_rate_limit.call.addon.create(app.name, plan: 'heroku-postgresql' )
    app
  end
end

def client
  @client ||= begin
    entry = Netrc.read['api.heroku.com']
    if entry
      oauth_token = entry.password
      @email = entry.login
    else
      oauth_token = ENV['OAUTH_TOKEN']
      @email = ENV['ACCOUNT_EMAIL']
    end
    raise "Must set env vars or write a netrc" unless @email

    PlatformAPI.connect_oauth(oauth_token)
  end
end
