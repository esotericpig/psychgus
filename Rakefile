# encoding: UTF-8

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Jonathan Bradley Whited (@esotericpig)
# 
# Psychgus is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Psychgus is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with Psychgus.  If not, see <https://www.gnu.org/licenses/>.
#++


require 'bundler/gem_tasks'

require 'yard'
require 'yard_ghurt'

require 'psychgus/version'

require 'rake/clean'
require 'rake/testtask'

task default: [:test]

CLEAN.exclude('.git/','stock/')
CLOBBER.include('doc/')

# Execute "rake ghp_doc" for a dry run
# Execute "rake ghp_doc[true]" for actually deploying
YardGhurt::GHPSyncerTask.new(:ghp_doc) do |task|
  task.description = %q(Rsync "doc/" to my GitHub Page's repo; not useful for others)
  
  task.ghp_dir = '../esotericpig.github.io/docs/psychgus/yardoc'
  task.sync_args << '--delete-after'
end

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

# Execute "rake clobber yard" for pristine docs
YARD::Rake::YardocTask.new() do |task|
  task.files = [File.join('lib','**','*.rb')]
  
  task.options += ['--files','CHANGELOG.md,LICENSE.txt']
  task.options += ['--readme','README.md']
  
  task.options << '--protected' # Show protected methods
  task.options += ['--template-path',File.join('yard','templates')]
  task.options += ['--title',"Psychgus v#{Psychgus::VERSION} Doc"]
end

YardGhurt::GFMFixerTask.new(:yard_fix) do |task|
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

desc 'Generate pristine YARDoc'
task :yard_fresh => [:clobber,:yard,:yard_fix] do |task|
end
