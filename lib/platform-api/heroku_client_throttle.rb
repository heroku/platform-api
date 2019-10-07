require 'thread'

module PlatformAPI
  # This class is responsible for making sure requests
  # to the Heroku API do not fail, and do not do not
  # cause excess burden to the API server by delaying
  # requests and spreading them over time.
  #
  # If a request is rate limited, this class will
  # automatically retry the request.
  #
  # High level logic:
  #   - When a rate limit event occurs, double the amount
  #     of time the client sleeps for
  #   - When a request is successful reduce the amount of
  #     of time the client sleeps for by a small amount
  #
  # This logic loosely mimics "congestion avoidance" in TCP.
  #
  # Example Usage:
  #
  #   client = HerokuClientThrottle.new
  #   request = client.call { Excon.get("https://api.heroku.com/<path>")}
  #   request.status #=> 200
  #
  class HerokuClientThrottle
    MAX_LIMIT = 4500.to_f
    MIN_SLEEP = 1/(MAX_LIMIT / 3600)
    MIN_SLEEP_OVERTIME_PERCENT = 1.0 - 0.9 # Allow min sleep to go lower than actually calculated value, must be less than 1

    attr_reader :rate_limit_multiply_at, :sleep_for, :rate_limit_count, :log, :mutex

    def initialize(log = ->(req, throttle) {})
      @mutex = Mutex.new
      @sleep_for = 2 * MIN_SLEEP
      @rate_limit_count = 0
      @times_retried = 0
      @retry_thread = nil
      @min_sleep_bound = MIN_SLEEP * MIN_SLEEP_OVERTIME_PERCENT
      @rate_multiplier = 1
      @rate_limit_multiply_at = Time.now - 1800
      @log = log
    end

    def jitter
      sleep_for * rand(0.0..0.1)
    end

    def call(&block)
      sleep(sleep_for + jitter) unless @rate_limit_count.zero?

      req = yield

      log.call(req, self)

      if retry_request?(req)
        req = retry_request_logic(req, &block)
        return req
      else
        decrement_logic(req)
        return req
      end
    end

    def decrement_amount(req, time_now = Time.now)
      ratelimit_remaining = req.headers["RateLimit-Remaining"].to_i

      # The goal of this logic is to balance out rate limiting events,
      # to prevent one single "flappy" client.
      #
      # When a client was recently rate limitied the time factor will be high.
      # This is used to slow down the decrement logic so that other clients that
      # have not hit a rate limit in a long time can come down.
      # Equation is based on exponential decay
      seconds_since_last_multiply = (time_now - self.rate_limit_multiply_at) + 1 # avoid case where current time is also recorded multiply time
      time_factor = 1.0/(1.0 - Math::E ** -(seconds_since_last_multiply/4500.0))

      return (ratelimit_remaining*self.sleep_for)/(time_factor*MAX_LIMIT)
    end

    def decrement_logic(req)
      @mutex.synchronize do
        @sleep_for -= decrement_amount(req)
        @sleep_for = @min_sleep_bound if @sleep_for < @min_sleep_bound
      end
    end

    def retry_request_logic(req, &block)
      @mutex.synchronize do
        if @retry_thread.nil? || @retry_thread == Thread.current
          @rate_multiplier = req.headers.fetch("RateLimit-Multiplier") { @rate_multiplier }.to_f
          @min_sleep_bound = (1/(@rate_multiplier * MAX_LIMIT / 4500))
          @min_sleep_bound *= MIN_SLEEP_OVERTIME_PERCENT
          @rate_limit_count += 1

          # First retry request, only increase sleep value if retry doesn't work.
          # Should guard against run-away high sleep values
          if @times_retried != 0
            @sleep_for *= 2
            @rate_limit_multiply_at = Time.now
          end

          @times_retried += 1
          @retry_thread = Thread.current
        end
      end

      # Retry the request with the new sleep value
      req = call(&block)
      if @retry_thread == Thread.current
        @mutex.synchronize do
          @times_retried = 0
          @retry_thread = nil
        end
      end
      return req
    end

    def retry_request?(req)
      req.status == 429
    end
  end

end
