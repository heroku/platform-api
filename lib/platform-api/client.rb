module PlatformAPI
  # Get a client configured with the specified OAuth token.
  def self.connect_oauth(oauth_token, options={})
    url = "https://api.heroku.com"
    default_headers = {'Accept' => 'application/vnd.heroku+json; version=3'}
    cache = Moneta.new(:File, dir: "#{Dir.home}/.heroku/platform-api")
    options = {default_headers: default_headers, cache: cache}.merge(options)
    schema_json = File.read("#{File.dirname(__FILE__)}/schema.json")
    schema = Heroics::Schema.new(MultiJson.decode(schema_json))
    Heroics.oauth_client_from_schema(oauth_token, schema, url, options)
  end

  # Get a client configured with the specified API token.
  #
  # Always prefer `connect_oauth` unless there's a very good reason you must
  # use a non-OAuth API token.
  def self.connect(token, options={})
    options = default_options.merge(options)
    url = "https://:#{token}@#{options[:host]}"
    default_headers = {'Accept' => 'application/vnd.heroku+json; version=3'}
    cache = Moneta.new(:File, dir: "#{Dir.home}/.heroku/platform-api")
    schema_json = File.read("#{File.dirname(__FILE__)}/schema.json")
    schema = Heroics::Schema.new(MultiJson.decode(schema_json))
    Heroics.client_from_schema(schema, url, options)
  end

  def self.default_options
    {
      default_headers: default_headers,
      cache: cache,
      host: "api.heroku.com"
    }
  end
  private_class_method :default_options
end
