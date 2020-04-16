require 'netrc'
require 'platform-api'
require 'hatchet'

describe 'The generated platform api client' do
  before(:all) do
    @app_name = ENV["TEST_APP_NAME"] || hatchet_app.name
  end

  it "can get account info" do
    expect(client.account.info).not_to be_empty
  end

  it "can get addon info for an app" do
    expect(client.addon.list_by_app(app_name)).not_to be_empty
  end

  it "can list apps" do
    expect(client.app.list.to_a).not_to be_empty
  end

  it "can get app info" do
    app_info = client.app.info(app_name)
    expect(app_info['name']).to eq app_name
  end

  it "can get build info" do
    expect(client.build.list(app_name)).not_to be_empty
  end

  it "can get config vars" do
    expect(client.config_var.info_for_app(app_name)).not_to be_empty
  end

  it "can get domain list and info" do
    domains = client.domain.list(app_name)
    expect(domains).not_to be_empty

    expect(client.domain.info(app_name, domains.first['hostname'])).not_to be_empty
  end

  it "can get dyno sizes" do
    expect(client.dyno_size.list).not_to be_empty
  end

  it "can get add-on plan info" do
    expect(client.plan.list_by_addon('heroku-postgresql')).not_to be_empty
  end

  it "can get release info" do
    expect(client.release.list(app_name)).not_to be_empty
  end

  it "can get app webhooks" do
    expect(client.app_webhook.list(app_name)).not_to be_empty
  end

  def app_name
    @app_name
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

  def email
    @email
  end

  def client
    @client ||=
      begin
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
