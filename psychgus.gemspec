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
# along with Psychgus.  If not, see <http://www.gnu.org/licenses/>.
#++


lib = File.expand_path('../lib',__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'psychgus/version'

Gem::Specification.new do |spec|
  spec.name    = 'psychgus'
  spec.version = Psychgus::VERSION
  spec.authors = ['Jonathan Bradley Whited (@esotericpig)']
  spec.email   = ['']
  spec.license = 'LGPL-3.0-or-later'
  
  spec.homepage    = 'https://github.com/esotericpig/psychgus'
  spec.summary     = %q(Easily style YAML files using Psych, like Sequence/Mapping Flow style.)
  spec.description = <<-EOS
Easily style YAML files using Psych, like Sequence/Mapping Flow style.

Simple example:
  class CoffeeStyler
    include Psychgus::Styler
    
    def style_sequence(sniffer,node)
      node.style = Psychgus::SEQUENCE_FLOW
    end
  end
  
  coffee = {
    'Roast'=>['Light','Medium','Dark','Extra Dark'],
    'Style'=>['Cappuccino','Espresso','Latte','Mocha']}
  
  puts coffee.to_yaml(stylers: CoffeeStyler.new)
  
  # Output:
  # ---
  # Roast: [Light, Medium, Dark, Extra Dark]
  # Style: [Cappuccino, Espresso, Latte, Mocha]

Class example:
  class Coffee
    include Psychgus::Blueberry
    
    def initialize
      @roast = ['Light','Medium','Dark','Extra Dark']
      @style = ['Cappuccino','Espresso','Latte','Mocha']
    end
    
    def psychgus_stylers(sniffer)
      CoffeeStyler.new
    end
  end
  
  puts Coffee.new.to_yaml
  
  # Output:
  # --- !ruby/object:Coffee
  # roast: [Light, Medium, Dark, Extra Dark]
  # style: [Cappuccino, Espresso, Latte, Mocha]

The produced YAML without Psychgus styling (i.e., without CoffeeStyler):
  # ---
  # Roast:
  # - Light
  # - Medium
  # - Dark
  # - Extra Dark
  # Style:
  # - Cappuccino
  # - Espresso
  # - Latte
  # - Mocha
  EOS
  
  spec.files         = Dir.glob("{lib,test,yard}/**/*") + %w(
                         Gemfile
                         LICENSE.txt
                         psychgus.gemspec
                         Rakefile
                         README.md
                       )
  spec.require_paths = ['lib']
  
  spec.required_ruby_version = '>= 2.1.10'
  
  spec.add_runtime_dependency 'psych','>= 2.0.5'
  
  spec.add_development_dependency 'bundler'  ,'~> 1.16'
  spec.add_development_dependency 'minitest' ,'~> 5.11' # For testing
  spec.add_development_dependency 'rake'     ,'~> 12.3'
  spec.add_development_dependency 'rdoc'     ,'~> 6.1'  # For RDoc for YARD (*.rb)
  spec.add_development_dependency 'redcarpet','~> 3.4'  # For Markdown for YARD (*.md)
  spec.add_development_dependency 'yard'     ,'~> 0.9'  # For documentation
end
