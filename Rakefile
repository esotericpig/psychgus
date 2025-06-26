# encoding: UTF-8
# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'yard'
require 'yard_ghurt'

require 'psychgus/version'
require 'rake/clean'
require 'rake/testtask'

task default: %i[test]

CLEAN.exclude('{.git,.github,.idea,stock}/**/*')
CLOBBER.include('.yardoc/','doc/')

# Execute "rake clobber doc" for pristine docs.
desc 'Generate doc'
task doc: %i[yard yard_gfm_fix]

# To test using different Gem versions:
#   GST=1 bundle update && bundle exec rake test
# For verbose output:
#   bundle exec rake test TESTOPT=-v
Rake::TestTask.new do |task|
  task.libs = ['lib','test']
  task.pattern = 'test/**/*_test.rb'
  task.warning = true
  task.verbose = false
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

  task.before = proc do |b,args|
    # Delete this file as it's never used (`index.html` is an exact copy).
    YardGhurt.rm_exist(File.join(b.doc_dir,'file.README.html'))

    # Root dir of my GitHub Page for CSS/JS.
    ghp_root_dir = YardGhurt.to_bool(args.dev) ? '../../esotericpig.github.io' : ''

    b.css_styles << %(<link rel="stylesheet" type="text/css" href="#{ghp_root_dir}/css/prism.css" />)
    b.js_scripts << %(<script src="#{ghp_root_dir}/js/prism.js"></script>)
  end
end
