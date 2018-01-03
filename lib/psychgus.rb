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

module Psychgus
  # TODO: OO way; sniff_classes(...)
  class Blueberry
    # TODO: ignore these attrs using encode_with() and/or init_with()
    # TODO: maybe change prefix to psychgus
    attr_accessor :psych_implicit
    attr_accessor :psych_plain
    attr_accessor :psych_quoted
    attr_accessor :psych_style
    attr_accessor :psych_tag
    
    def psychgus_sniffer()
      sniffer = Hash.new()
      
      # TODO: use instance_methods or instance_variables and test "psych_" prefix
      sniffer[:style] = psych_style
      
      return sniffer
    end
  end
  
  # TODO: maybe a singleton?
  class Unset
  end
  
  class Sniffer
    attr_accessor :smells
    
    # @param smells [Hash]
    #   - :end_column   [Integer]
    #   - :end_line     [Integer]
    #   - :implicit     [true, false]
    #   - :index        [Integer] ignored (see Psychgus::Psychgus)
    #   - :level        [Integer] ignored (see Psychgus::Psychgus)
    #   - :plain        [true, false]
    #   - :quoted       [true, false]
    #   - :start_column [Integer]
    #   - :start_line   [Integer]
    #   - :style        [Integer, Symbol[:any, :block, :double_quoted, :flow, :folded, :literal, :plain, :single_quoted]]
    #   - :tag
    #   - :type         [Class, Symbol[:alias, :document, :mapping, :node, :scalar, :sequence, :stream]]
    #   - :value
    def initialize(**smells)
      @smells = smells
    end
    
    def change(node)
      @smells.each do |key,value|
        key_setter = "#{key.to_s()}="
        next unless node.respond_to?(key_setter)
        value = to_value(node,key,value)
        node.send(key_setter,value) unless value.is_a?(Unset)
      end
    end
    
    def fragrant?(node)
      @smells.each() do |key,value|
        case key
        when :index,:level
          next # Handled outside of this class in Psychgus::Psychgus
        when :type
          value = Psych::Nodes.const_get(value.capitalize()) if value.is_a?(Symbol)
          return false unless node.is_a?(value)
          next
        end
        
        return false unless node.respond_to?(key)
        value = to_value(node,key,value)
        next if value.is_a?(Unset)
        node_value = node.send(key)
        
        # TODO: range
        if value.is_a?(Array)
          return false unless value.include?(node_value)
        else
          return false unless node_value == value
        end
      end
      
      return true
    end
    
    def to_value(node,key,value)
      case key
      when :style
        if value.is_a?(Symbol)
          value = value.upcase()
          return Unset.new() unless node.class.const_defined?(value)
          value = node.class.const_get(value)
        end
      end
      
      return value
    end
  end
  
  class Psychgus
    attr_reader :levels
    attr_reader :stream
    
    def initialize(yaml,type,classes: true,levels: true,**options)
      if !yaml.is_a?(String)
        yaml = yaml.to_yaml() 
        type = :string
      end
      
      case type
      when :file
        yaml = File.read(yaml)
      end
      
      @levels = []
      @stream = Psych.parse_stream(yaml)
      
      # TODO: maybe make init_levels also use "classes" bool so O(N) instead of O(2N)? init_classes_levels(...)?
      init_levels(@stream) if levels
    end
    
    def init_levels(node,level=0)
      return if node.nil?()
      
      while level >= @levels.length()
        @levels.push([])
      end
      @levels[level].push(node)
      
      return unless node_children?(node)
      
      node.children.each() do |child|
        init_levels(child,level + 1)
      end
    end
    
    def add_sniffer(sniffer,changer)
    end
    
    def dump()
      return to_s()
    end
    
    def dump_file(filepath)
      File.open(filepath,'w') do |f|
        f.write(to_s())
      end
    end
    
    def self.load(str,**options)
      return self.new(str,:string,**options)
   end
    
    def self.load_file(filepath,**options)
      return self.new(filepath,:file,**options)
    end
    
    def sniff(sniffer,changer)
      sniffer = Sniffer.new(sniffer) if sniffer.is_a?(Hash)
      changer = Sniffer.new(changer) if changer.is_a?(Hash)
      
      if sniffer.smells.key?(:level)
        index = sniffer.smells[:index] # TODO: range, array
        level = @levels[2 + sniffer.smells[:level]] # TODO: range, array
        
        level.each() do |node|
          if sniffer.fragrant?(node)
            changer.change(node)
          end
        end
      else
        # TODO: if no level, search all
      end
    end
    
    def sniff_classes(node=@stream)
      return if node.nil?()
      
      if node.respond_to?(:to_ruby)
        node_ruby = node.to_ruby()
        
        if node_ruby.is_a?(Blueberry)
          sniffer = node_ruby.psychgus_sniffer()
          sniffer = Sniffer.new(sniffer) if sniffer.is_a?(Hash)
          sniffer.change(node)
        end
      end
      
      return unless node_children?(node)
      
      node.children.each() do |child|
        sniff_classes(child)
      end
    end
    
    # TODO: sniff_children(), sniff_parents(), sniff_classes()
    
    def node_children?(node)
      return node.respond_to?(:children) && !node.children.nil?() && node.children.respond_to?(:empty?) &&
        !node.children.empty?()
    end
    
    def to_s()
      return @stream.to_yaml()
    end
  end
end

if $0 == __FILE__
  y = <<-EOS
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
  p = Psychgus::Psychgus.load(y)
  puts p
  puts
  
  #p.sniff(Psychgus::Sniffer.new(level: 2),Psychgus::Sniffer.new(style: :flow))
  p.sniff({:level=>2},{:style=>:flow})
  puts p
  puts
  
  class Muffin < Psychgus::Blueberry
    attr_accessor :types
    
    # TODO: better way to do this so can specify :types as flow, instead of whole class? maybe hash?
    def initialize()
      @psych_style = :flow
      @types = ['traditional','cakey','crumbly']
    end
  end
  
  m = Muffin.new()
  p = Psychgus::Psychgus.load(m)
  puts p
  puts
  
  p.sniff_classes()
  puts p
  puts
end
