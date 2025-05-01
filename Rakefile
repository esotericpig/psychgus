# encoding: UTF-8
# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'yard'
require 'yard_ghurt'

require 'psychgus/version'
require 'rake/clean'
require 'rake/testtask'

task default: %i[test]

CLEAN.exclude('.git/','stock/')
CLOBBER.include('.yardoc/','doc/')

# Execute "rake clobber doc" for pristine docs.
desc 'Generate documentation (YARDoc)'
task doc: %i[yard yard_gfm_fix]

# To test using different Gem versions:
#   GST=1 bundle update && bundle exec rake test
Rake::TestTask.new do |task|
  task.libs = ['lib','test']
  task.pattern = 'test/**/*_test.rb'
  # task.options = '--verbose' # Execute "rake test TESTOPT=-v" instead.
  task.verbose = true
  task.warning = true
end

YARD::Rake::YardocTask.new do |task|
  task.files = ['lib/**/*.rb']
  task.options += ['--title',"Psychgus v#{Psychgus::VERSION}"]
end

YardGhurt::GFMFixTask.new do |task|
  task.arg_names = [:dev]
  task.dry_run = false
  task.fix_code_langs = true
  task.md_files = ['index.html']

  task.before = proc do |t2,_args|
    # Delete this file as it's never used (index.html is an exact copy).
    YardGhurt.rm_exist(File.join(t2.doc_dir,'file.README.html'))

    t2.css_styles << '<link rel="stylesheet" type="text/css" href="/css/prism.css" />'
    t2.js_scripts << '<script src="/js/prism.js"></script>'
  end
end
