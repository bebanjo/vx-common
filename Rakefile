require 'rubygems'
require 'bundler'
Bundler.require
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => [:spec]
task :travis do
  exec "bundle exec rake SPEC_OPTS='--format documentation --order=rand'"
end
