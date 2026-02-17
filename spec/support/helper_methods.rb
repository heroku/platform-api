module PlatformAPI::SpecHelperMethods
  def hatchet_app
    config = { "FOO" => "bar" }
    @hatchet_app ||= begin
      app = Hatchet::Runner.new("default_ruby", buildpacks: ["heroku/ruby"], config: config)
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
end
