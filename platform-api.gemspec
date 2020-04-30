# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'platform-api/version'

Gem::Specification.new do |spec|
  spec.name          = 'platform-api'
  spec.version       = PlatformAPI::VERSION
  spec.authors       = ['jkakar']
  spec.email         = ['jkakar@kakar.ca']
  spec.description   = 'Ruby HTTP client for the Heroku API.'
  spec.summary       = 'Ruby HTTP client for the Heroku API.'
  spec.homepage      = 'https://github.com/heroku/platform-api'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'netrc'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'heroku_hatchet'
  spec.add_development_dependency 'webmock'

  spec.add_dependency 'heroics', '~> 0.1.1'
  spec.add_dependency 'moneta', '~> 1.0.0'
  spec.add_dependency 'rate_throttle_client', '~> 0.1.0'
end
