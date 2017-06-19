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

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep('^(test|spec|features)/')
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'netrc'
  spec.add_development_dependency 'rspec'

  spec.add_dependency 'heroics', '~> 0.0.23'
  spec.add_dependency 'moneta', '~> 0.8.1'
end
