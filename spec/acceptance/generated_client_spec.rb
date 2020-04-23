describe 'The generated platform api client' do
  include PlatformAPI::SpecHelperMethods

  before(:all) do
    @app_name = ENV["TEST_APP_NAME"] || hatchet_app.name
  end

  def app_name
    @app_name
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
end
