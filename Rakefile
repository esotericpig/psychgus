# encoding: UTF-8
# frozen_string_literal: true

###
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
# along with Psychgus.  If not, see <http://www.gnu.org/licenses/>.
###

require 'bundler/gem_tasks'

require 'yard'

require 'psychgus/version'

require 'rake/clean'
require 'rake/testtask'

task default: [:test]

CLEAN.exclude('.git/','stock/')
CLOBBER.include('doc/')

# Exec "rake ghp_doc" for a dry run
# Exec "rake ghp_doc[true]" for actually deploying
desc %q(Rsync 'doc/' to my GitHub Page's repo; not useful for others)
task :ghp_doc,[:deploy] do |task,args|
  dry_run = args.deploy ? '' : '--dry-run'
  rsync_cmd = %Q(rsync -ahv --delete-after --progress #{dry_run} 'doc/' '../esotericpig.github.io/docs/yard/psychgus')
  
  sh rsync_cmd
end

Rake::TestTask.new() do |task|
  task.libs = ['lib','test']
  task.pattern = 'test/**/*_test.rb'
  task.verbose = true
  task.warning = true
end

# Exec "rake clobber yard" for pristine docs
YARD::Rake::YardocTask.new() do |task|
  task.files += ['lib/**/*.rb']
  
  task.options += ['--files','LICENSE']
  task.options += ['--readme','README.md']
  
  task.options += ['--protected'] # Show protected methods
  task.options += ['--template-path','yard/templates/']
  task.options += ['--title',"Psychgus v#{Psychgus::VERSION} Doc"]
end
