# encoding: utf-8
# frozen_string_literal: true

###
# This file is part of psychgus.
# Copyright (c) 2017 Jonathan Bradley Whited (@esotericpig)
# 
# psychgus is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# psychgus is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with psychgus.  If not, see <http://www.gnu.org/licenses/>.
###

lib = File.expand_path('../lib',__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'psychgus/version'

Gem::Specification.new do |spec|
  spec.name                   = 'psychgus'
  spec.version                = Psychgus::VERSION
  spec.authors                = ['Jonathan Bradley Whited (@esotericpig)']
  spec.email                  = ['']
  spec.license                = 'LGPL-3.0'
  
  spec.summary                = 'Easily style YAML files in Ruby'
  spec.description            = 'Easily style YAML files in Ruby.  Uses the psych parser as the back end.'
  spec.homepage               = 'https://github.com/esotericpig/psychgus'
  
  spec.files                  = Dir.glob("{bin,lib}/**/*") + %w(
                                    Gemfile
                                    Gemfile.lock
                                    LICENSE
                                    psychgus.gemspec
                                    README.md
                                  )
  spec.require_paths          = ['lib']
  
  spec.required_ruby_version  = '>= 2.2.0'
  
  spec.add_runtime_dependency 'psych','>= 2.2.2'
  
  spec.add_development_dependency 'bundler','>= 1.15.0'
end
