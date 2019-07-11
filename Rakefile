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
# along with Psychgus.  If not, see <http://www.gnu.org/licenses/>.
#++


require 'bundler/gem_tasks'

require 'yard'

require 'psychgus/version'

require 'rake/clean'
require 'rake/testtask'

task default: [:test]

CLEAN.exclude('.git/','stock/')
CLOBBER.include('doc/')

module PsychgusRake
  # Remove if exists
  def self.rm_exist(filename,output=true)
    if File.exist?(filename)
      puts "Delete [#{filename}]" if output
      File.delete(filename)
    end
  end
end

# Execute "rake ghp_doc" for a dry run
# Execute "rake ghp_doc[true]" for actually deploying
desc %q(Rsync "doc/" to my GitHub Page's repo; not useful for others)
task :ghp_doc,[:deploy] do |task,args|
  dry_run = args.deploy ? '' : '--dry-run'
  rsync_cmd = "rsync -ahv --delete-after --progress #{dry_run} 'doc/' '../esotericpig.github.io/docs/psychgus/yardoc/'"
  
  sh rsync_cmd
  
  if !args.deploy
    puts
    puts 'Execute "rake ghp_doc[true]" for actually deploying (non-dry-run)'
  end
end

Rake::TestTask.new() do |task|
  task.libs = ['lib','test']
  task.pattern = 'test/**/*_test.rb'
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
  task.files = ['lib/**/*.rb']
  
  task.options += ['--files','CHANGELOG.md,LICENSE.txt']
  task.options += ['--readme','README.md']
  
  task.options << '--protected' # Show protected methods
  task.options += ['--template-path','yard/templates/']
  task.options += ['--title',"Psychgus v#{Psychgus::VERSION} Doc"]
end

desc 'Fix (find & replace) text in the YARD files for GitHub differences'
task :yard_fix,[:dev] do |task,args|
  # Delete this file as it's never used (index.html is an exact copy)
  PsychgusRake.rm_exist('doc/file.README.html')
  
  ['doc/index.html'].each do |filename|
    puts "File [#{filename}]:"
    
    lines = []
    write = false
    
    File.open(filename,'r') do |file|
      file.each_line do |line|
        out = false
        
        # CSS
        if line =~ /^\s*\<\/head\>\s*$/i
          line = '<link href="'
          line << (args.dev ? '../../esotericpig.github.io/' : '../../../')
          line << 'css/prism.css" rel="stylesheet" /> </head>'
          
          out = true
        end
        
        # JS
        if line =~ /^\s*\<\/body\>\s*$/i
          line = '<script src="'
          line << (args.dev ? '../../esotericpig.github.io/' : '../../../')
          line << 'js/prism.js"></script> </body>'
          
          out = true
        end
        
        # Anchor links
        tag = 'href="#'
        quoted_tag = Regexp.quote(tag)
        
        if !(i = line.index(Regexp.new(quoted_tag + '[a-z]'))).nil?()
          line = line.gsub(Regexp.new(quoted_tag + '[a-z][^"]*"')) do |href|
            link = href[tag.length..-2]
            link = link.split('-').map(&:capitalize).join('_')
            
            %Q(#{tag}#{link}")
          end
          
          out = true
        end
        
        out = !line.gsub!('href="CHANGELOG.md"','href="file.CHANGELOG.html"').nil?() || out
        out = !line.gsub!('href="LICENSE.txt"','href="file.LICENSE.html"').nil?() || out
        out = !line.gsub!('code class="Ruby"','code class="language-ruby"').nil?() || out
        out = !line.gsub!('code class="YAML"','code class="language-yaml"').nil?() || out
        
        if out
          puts "  #{line}"
          write = true
        end
        
        lines << line
      end
    end
    
    if write
      File.open(filename,'w') do |file|
        file.puts lines
      end
    end
  end
end

desc 'Generate pristine YARDoc'
task :yard_fresh => [:clobber,:yard,:yard_fix] do |task|
end
