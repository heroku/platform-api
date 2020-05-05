require 'heroics'
require 'moneta'
require 'platform-api/version'

# Ruby HTTP client for the Heroku API.
module PlatformAPI
  def self.rate_throttle=(rate_throttle)
    @rate_throttle = rate_throttle
    Heroics.default_configuration do |config|
      config.rate_throttle = @rate_throttle
    end
  end

  # Get access to the rate throttling class object for configuration.
  def self.rate_throttle
    @rate_throttle
  end
end

require_relative '../config/client-config'
require 'platform-api/client'
