# frozen_string_literal: true
require 'heroics'
require 'rate_throttle_client'

require_relative '../lib/platform-api.rb'

Heroics.default_configuration do |config|
  config.base_url = 'https://api.heroku.com'
  config.module_name = 'PlatformAPI'
  config.schema_filepath = File.join(File.expand_path('../..', __FILE__), 'schema.json')

  PlatformAPI.rate_throttle = RateThrottleClient::ExponentialIncreaseProportionalRemainingDecrease.new
  config.rate_throttle = PlatformAPI.rate_throttle
  config.acceptable_status_codes = [429]

  config.headers = {
    'Accept'      => 'application/vnd.heroku+json; version=3',
    'User-Agent'  => "platform-api/#{PlatformAPI::VERSION}"
  }
  config.ruby_name_replacement_patterns = {
    /add[^a-z]+on/i => 'addon',
    /[\s-]+/ => '_',
  }
  # This needs to be in single quotes to avoid interpolation during the client
  # build
  config.cache_path = '#{Dir.home}/.heroics/platform-api'
end
