#!/usr/bin/env ruby

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

require 'psych'
require 'yaml'

module Psychgus
  # TODO: OO way; sniff_classes(...)
  class Blueberry
    attr_accessor :psych_implicit
    attr_accessor :psych_plain
    attr_accessor :psych_quoted
    attr_accessor :psych_style
    attr_accessor :psych_tag
  end
  
  class Sniffer
    attr_accessor :smells
    
    def initialize(**smells)
      @smells = smells
    end
    
    def change(node)
      @smells.each do |key,value|
        key_setter = key.to_s() + '='
        next unless node.respond_to?(key_setter)
        value = convert_value(node,key,value)
        node.send(key_setter,value) if value
      end
    end
    
    def convert_value(node,key,value)
      case key
      when :style
        if value.is_a?(Symbol)
          value = value.upcase()
          # TODO: raise ex instead
          return false unless node.class.const_defined?(value)
          value = node.class.const_get(value)
        end
      end
      
      return value
    end
    
    def sniff(node)
      @smells.each do |key,value|
        case key
        when :index,:level
          next # Handled outside of this class
        when :type
          value = Psych::Nodes.const_get(value.capitalize()) if value.is_a?(Symbol)
          return false unless node.is_a?(value)
          next
        end
        
        return false unless node.respond_to?(key)
        
        value = convert_value(node,key,value)
        
        # TODO: range
        if value.is_a?(Array)
          return false unless value.include?(node.send(key))
        else
          return false unless node.send(key) == value
        end
      end
      
      return true
    end
  end
  
  class Psychgus
    attr_reader :levels
    attr_reader :parser
    attr_reader :tree
    
    # yaml can be a str or a class
    # TODO: pass in type, load_file(), load()
    def initialize(yaml)
      yaml = yaml.to_yaml() if !yaml.is_a?(String)
      
      @levels = []
      @parser = Psych.parser()
      @parser.parse(yaml)
      @tree = @parser.handler.root
      
      init_levels(@tree)
    end
    
    def init_levels(node,level=0)
      return if node.nil?()
      
      while level >= @levels.length()
        @levels.push([])
      end
      @levels[level].push(node)
      
      return if !node.respond_to?(:children) || node.children.nil?() || node.children.empty?()
      
      node.children.each() do |child|
        init_levels(child,level + 1)
      end
    end
    
    def add_sniffer(sniffer,changer)
    end
    
    def sniff(sniffer,changer)
      # TODO: change to Sniffer if Hash
      
      if sniffer.smells.key?(:level)
        level = @levels[sniffer.smells[:level]]
        
        level.each do |node|
          if sniffer.sniff(node)
            changer.change(node)
          end
        end
      end
    end
    
    # TODO: sniff_children(), sniff_parents(), sniff_classes()
    
    def to_s()
      return @tree.yaml()
    end
  end
end

if $0 == __FILE__
  p = Psychgus::Psychgus.new(<<-EOS
Class:
  Blue:
    Type:  EU
    Level: 2
  Green:
    Type:  BB
    Level: 1
Sched:
  - Class: Blue
    UL:    U1-L1
  - Class: Green
    UL:    U2-L2
EOS
        )
  
  puts p
  puts
  
  p.sniff(Psychgus::Sniffer.new(level: 4),Psychgus::Sniffer.new(style: :flow))
  
  puts p
end
