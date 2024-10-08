# encoding: UTF-8
# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'yard'
require 'yard_ghurt'

require 'psychgus/version'

require 'rake/clean'
require 'rake/testtask'

task default: [:test]

CLEAN.exclude('.git/','stock/')
CLOBBER.include('doc/')

# Execute "rake clobber doc" for pristine docs.
desc 'Generate documentation (YARDoc)'
task doc: %i[yard yard_gfm_fix]

# To test using different Gem versions:
#   GST=1 bundle update && bundle exec rake test
Rake::TestTask.new do |task|
  task.libs = ['lib','test']
  task.pattern = File.join('test','**','*_test.rb')
  task.description += " ('#{task.pattern}')"
  #task.options = '--verbose' # Execute "rake test TESTOPT=-v" instead.
  task.verbose = true
  task.warning = true
end

YARD::Rake::YardocTask.new do |task|
  task.files = [File.join('lib','**','*.rb')]
end

YardGhurt::GFMFixTask.new do |task|
  task.description = 'Fix (find & replace) text in the YARD files for GitHub differences'

  task.arg_names = [:dev]
  task.dry_run = false
  task.fix_code_langs = true
  task.md_files = ['index.html']

  task.before = proc do |t2,args|
    # Delete this file as it's never used (index.html is an exact copy)
    YardGhurt.rm_exist(File.join(t2.doc_dir,'file.README.html'))

    ghp_root = '../../..'
    t2.css_styles << %Q(<link rel="stylesheet" type="text/css" href="#{ghp_root}/css/prism.css" />)
    t2.js_scripts << %Q(<script src="#{ghp_root}/js/prism.js"></script>)
  end
end
