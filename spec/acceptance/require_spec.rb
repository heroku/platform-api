describe 'The platform api client' do
  it "can be required from outside of this bundler context" do
    with_unbundled_env do
      out = `ruby -I#{File.join(__dir__, "../../lib")} -e "require 'platform-api'" 2>&1`
      raise "Expected command to succeed but it did not. Output:\n#{out}" unless $?.success?
    end
  end

  def with_unbundled_env
    if Bundler.respond_to?(:with_unbundled_env)
      Bundler.with_unbundled_env do
        yield
      end
    else
      Bundler.with_clean_env do
        yield
      end
    end
  end
end
