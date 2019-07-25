# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2017-2019 Jonathan Bradley Whited (@esotericpig)
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


lib = File.expand_path('../lib',__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'psychgus/version'

Gem::Specification.new() do |spec|
  spec.name        = 'psychgus'
  spec.version     = Psychgus::VERSION
  spec.authors     = ['Jonathan Bradley Whited (@esotericpig)']
  spec.email       = ['bradley@esotericpig.com']
  spec.licenses    = ['LGPL-3.0-or-later']
  spec.homepage    = 'https://github.com/esotericpig/psychgus'
  spec.summary     = %q(Easily style YAML files using Psych.)
  spec.description = %q(Easily style YAML files using Psych, like Sequence/Mapping Flow style.)
  
  spec.metadata = {
    'bug_tracker_uri'   => 'https://github.com/esotericpig/psychgus/issues',
    'changelog_uri'     => 'https://github.com/esotericpig/psychgus/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://esotericpig.github.io/docs/psychgus/yardoc/index.html',
    'homepage_uri'      => 'https://github.com/esotericpig/psychgus',
    'source_code_uri'   => 'https://github.com/esotericpig/psychgus'
  }
  
  spec.require_paths = ['lib']
  
  spec.files = Dir.glob(File.join("{#{spec.require_paths.join(',')}}",'**','*.{erb,rb}')) +
               Dir.glob(File.join('{test,yard}','**','*.{erb,rb}')) +
               %W( Gemfile #{spec.name}.gemspec Rakefile ) +
               %w( CHANGELOG.md LICENSE.txt README.md )
  
  spec.required_ruby_version = '>= 2.1.10'
  
  spec.add_runtime_dependency 'psych','>= 2.0.5'
  
  spec.add_development_dependency 'bundler'   ,'~> 1.16'
  spec.add_development_dependency 'minitest'  ,'~> 5.11' # For testing
  spec.add_development_dependency 'rake'      ,'~> 12.3'
  spec.add_development_dependency 'rdoc'      ,'~> 6.1'  # For RDoc for YARD (*.rb)
  spec.add_development_dependency 'redcarpet' ,'~> 3.4'  # For Markdown for YARD (*.md)
  spec.add_development_dependency 'yard'      ,'~> 0.9'  # For documentation
  spec.add_development_dependency 'yard_ghurt','~> 1.0'  # For YARD GitHub rake tasks
end
