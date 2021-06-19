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


# Execute "rake clobber doc" for pristine docs
desc 'Generate documentation (YARDoc)'
task doc: %i[yard yard_gfm_fix]

Rake::TestTask.new() do |task|
  task.libs = ['lib','test']
  task.pattern = File.join('test','**','*_test.rb')
  task.description += " ('#{task.pattern}')"
  #task.options = '--verbose' # Execute "rake test TESTOPT=-v" instead
  task.verbose = true
  task.warning = true
end

desc 'Run all tests (including writing to temp files, etc.)'
task :test_all do |task|
  ENV['PSYCHGUS_TEST'] = 'all'

  test_task = Rake::Task[:test]

  test_task.reenable()
  test_task.invoke()
end

YARD::Rake::YardocTask.new() do |task|
  task.files = [File.join('lib','**','*.rb')]

  task.options += ['--files','CHANGELOG.md,LICENSE.txt']
  task.options += ['--readme','README.md']

  task.options << '--protected' # Show protected methods
  task.options += ['--template-path',File.join('yard','templates')]
  task.options += ['--title',"Psychgus v#{Psychgus::VERSION} Doc"]
end

YardGhurt::GFMFixTask.new() do |task|
  task.description = 'Fix (find & replace) text in the YARD files for GitHub differences'

  task.arg_names = [:dev]
  task.dry_run = false
  task.fix_code_langs = true
  task.md_files = ['index.html']

  task.before = Proc.new() do |task,args|
    # Delete this file as it's never used (index.html is an exact copy)
    YardGhurt.rm_exist(File.join(task.doc_dir,'file.README.html'))

    # Root dir of my GitHub Page for CSS/JS
    GHP_ROOT = YardGhurt.to_bool(args.dev) ? '../../esotericpig.github.io' : '../../..'

    task.css_styles << %Q(<link rel="stylesheet" type="text/css" href="#{GHP_ROOT}/css/prism.css" />)
    task.js_scripts << %Q(<script src="#{GHP_ROOT}/js/prism.js"></script>)
  end
end
