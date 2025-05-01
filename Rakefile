# encoding: UTF-8
# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'yard'

require 'psychgus/version'
require 'rake/clean'
require 'rake/testtask'

task default: %i[test]

CLEAN.exclude('.git/','stock/')
CLOBBER.include('doc/')

# Execute "rake clobber doc" for pristine docs.
desc 'Generate documentation (YARDoc)'
task doc: %i[yard]

# To test using different Gem versions:
#   GST=1 bundle update && bundle exec rake test
Rake::TestTask.new do |task|
  task.libs = ['lib','test']
  task.pattern = File.join('test','**','*_test.rb')
  # task.options = '--verbose' # Execute "rake test TESTOPT=-v" instead.
  task.verbose = true
  task.warning = true
end

YARD::Rake::YardocTask.new do |task|
  task.files = [File.join('lib','**','*.rb')]
end
