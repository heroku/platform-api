require 'heroics'
require 'moneta'

# Ruby HTTP client for the Heroku API.
module PlatformAPI
  def self.rate_throttle=(rate_throttle)
    @rate_throttle = rate_throttle
  end

  # Get access to the rate throttling class object for configuration.
  #
  # @return [PlatformAPI::HerokuClientThrottle]
  def self.rate_throttle
    @rate_throttle
  end
end

require_relative '../config/client-config'

require 'platform-api/client'
require 'platform-api/version'
require 'platform-api/heroku_client_throttle'
