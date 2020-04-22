require 'platform-api'

describe 'Platform API config' do
  describe 'rate limiting' do
    before(:each) do
      WebMock.enable!

      rate_throttle = PlatformAPI.rate_throttle
      @original_rate_throttle = rate_throttle.dup

      # No junk in test dots
      rate_throttle.log = ->(*_) {} if rate_throttle.respond_to?("log=")

      # Don't sleep in tests
      def rate_throttle.sleep(value); end
    end

    after(:each) do
      WebMock.disable!

      PlatformAPI.rate_throttle = @original_rate_throttle
    end

    it "works even if first request is rate limited" do
      skip("Default behavior changes in v3+") unless Gem::Version.new(PlatformAPI::VERSION) >= Gem::Version.new("3.0.0.beta")

      stub_request(:get, "https://api.heroku.com/apps")
        .to_return([
          {status: 429},
          {status: 200}
        ])

      client.app.list

      expect(WebMock).to have_requested(:get, "https://api.heroku.com/apps").twice
    end

    it "allows the rate throttling class to be modified" do
      stub_request(:get, "https://api.heroku.com/apps")
        .to_return([
          {status: 429},
          {status: 429},
          {status: 200}
        ])

      @retry_count = 0
      PlatformAPI.rate_throttle = RateThrottleClient::ExponentialIncreaseProportionalRemainingDecrease.new
      PlatformAPI.rate_throttle.log = ->(*_) { @retry_count += 1 }
      client.app.list

      expect(WebMock).to have_requested(:get, "https://api.heroku.com/apps").times(3)
      expect(@retry_count).to eq(2)
    end

    it "allows rate throttling logic to be changed" do
      stub_request(:get, "https://api.heroku.com/apps")
        .to_return([
          {status: 429}
        ])

      @times_called = 0
      PlatformAPI.rate_throttle = ->(&block) { @times_called += 1; block.call }

      client.app.list

      expect(WebMock).to have_requested(:get, "https://api.heroku.com/apps").once
      expect(@times_called).to eq(1)
    end
  end
end
