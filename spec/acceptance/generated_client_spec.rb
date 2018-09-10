require 'netrc'
require 'platform-api'

describe 'The generated platform api client' do
  it "can get account info" do
    expect(client.account.info).not_to be_empty
  end

  it "can get addon info for an app" do
    expect(client.addon.list_by_app(an_app['name'])).not_to be_empty
  end

  it "can list apps" do
    expect(client.app.list).not_to be_empty
  end

  it "can get app info" do
    expect(client.app.info(an_app['name'])).to eq an_app
  end

  it "can get build info" do
    expect(client.build.list(an_app['name'])).not_to be_empty
  end

  it "can get config vars" do
    expect(client.config_var.info_for_app(an_app['name'])).not_to be_empty
  end

  it "can get domain list and info" do
    domains = client.domain.list(an_app['name'])
    expect(domains).not_to be_empty

    expect(client.domain.info(an_app['name'], domains.first['hostname'])).not_to be_empty
  end

  it "can get dyno sizes" do
    expect(client.dyno_size.list).not_to be_empty
  end

  it "can get add-on plan info" do
    expect(client.plan.list_by_addon('heroku-postgresql')).not_to be_empty
  end

  it "can get release info" do
    expect(client.release.list(an_app['name'])).not_to be_empty
  end

  it "can get app webhooks" do
    expect(client.app_webhook.list(an_app['name'])).not_to be_empty
  end

  %i[addon_webhook_delivery addon_webhook_event addon_webhook app_webhook_delivery app_webhook_event app_webhook
     peering_info peering vpn_connection].each do |api_endpoint|
    it "supports #{api_endpoint}" do
      expect(client).to respond_to(api_endpoint)
    end
  end

  def an_app
    @app ||= client.app.list.first
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
        PlatformAPI.connect_oauth(oauth_token)
      end
  end
end
