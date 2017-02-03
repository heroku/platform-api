# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'heroku/platform_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'platform-api'
  spec.version       = Heroku::PlatformAPI::VERSION
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

  spec.add_dependency 'heroics', '~> 0.0.17'
end
