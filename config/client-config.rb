# frozen_string_literal: true
require 'heroics'

Heroics.default_configuration do |config|
  config.base_url = 'https://api.heroku.com'
  config.module_name = 'PlatformAPI'
  config.schema_filepath = 'schema.json'

  config.headers = { 'Accept' => 'application/vnd.heroku+json; version=3' }
  config.ruby_name_replacement_patterns = {
    /add[^a-z]+on/i => 'addon',
    /[\s-]+/ => '_',
  }
  config.cache_path = '#{Dir.home}/.heroics/platform-api'
end
