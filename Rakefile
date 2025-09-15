require 'bundler/gem_tasks'
require 'yard'

desc 'Generate API documentation'
YARD::Rake::YardocTask.new

desc 'Download the latest schema and build a new client'
task :build do
  sh 'curl -o schema.json -H "Accept: application/vnd.heroku+json; version=3" https://api.heroku.com/schema'
  sh 'bundle exec heroics-generate ./config/client-config.rb > lib/platform-api/client.rb'
end

desc 'Publish API documentation'
task :publish_docs => [:build] do
  sh 'rake yard'
  sh 'cp -R doc /tmp/platform-api-doc'
  sh 'git checkout gh-pages'
  sh 'rm -rf *'
  sh 'cp -R /tmp/platform-api-doc/* .'
  sh 'rm -rf /tmp/platform-api-doc'
  sh 'git add -A .'
  sh 'git commit -am "Rebuild documentation"'
  sh 'git push origin gh-pages'
  sh 'git checkout main'
end

# After releasing publish the docs
Rake::Task["release"].enhance do
  Rake::Task[:publish_docs].invoke
end

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  task default: [:spec]
rescue LoadError
end
