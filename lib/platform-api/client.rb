module PlatformAPI
  # Get a client configured with the specified username and token.
  def self.connect(username, token)
    url = "https://#{username}:#{token}@api.heroku.com"
    default_headers {'Accept' => 'application/vnd.heroku+json; version=3'}
    options = {options: {default_headers: default_headers}}
    schema_json = File.read("#{File.dirname(__FILE__)}/schema.json")
    schema = Heroics::Schema.new(MultiJson.decode(schema_json))
    Heroics.client_from_schema(schema, url, options)
  end
end
