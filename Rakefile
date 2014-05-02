require 'bundler/gem_tasks'
require 'yard'

desc 'Generate API documentation'
YARD::Rake::YardocTask.new

desc 'Publish API documentation'
task :publish do
  sh 'rake yard'
  sh 'cp -R doc /tmp/platform-api-doc'
  sh 'git checkout gh-pages'
  sh 'cp -R /tmp/platform-api-doc/* .'
  sh 'rm -rf /tmp/platform-api-doc'
  sh './fix-links.sh'
  sh 'git add .'
  sh 'git commit -am "Rebuilt documentation"'
  sh 'git checkout master'
end
