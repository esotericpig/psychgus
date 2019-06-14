#!/usr/bin/env ruby
# encoding: UTF-8

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

module Psychgus
  class SuperSniffer
    class Empty < SuperSniffer
      def initialize(); end
      def add_alias(node); end
      def add_scalar(node); end
      def end_mapping(); end
      def end_sequence(); end
      def next_position(node); end
      def start_mapping(node); end
      def start_sequence(node); end
    end
    
    class Parent
      attr_accessor :child_position # For next child's position
      attr_accessor :child_type # For next child's mapping: nil, :key, or :value
      attr_reader :level
      attr_reader :node
      attr_reader :position
      attr_reader :tag # For debugging
      
      def initialize(sniffer,node,child_type: nil,tag: nil)
        @child_position = 1
        @child_type = child_type
        @level = sniffer.level
        @node = node
        @position = sniffer.position
        @tag = tag
      end
    end
  end
  
  class SuperSniffer
    EMPTY = Empty.new().freeze()
    
    attr_reader :aliases
    attr_reader :level
    attr_reader :mappings
    attr_reader :nodes
    attr_reader :parent
    attr_reader :parents
    attr_reader :position
    attr_reader :scalars
    attr_reader :sequences
    
    def initialize()
      @aliases = []
      @level = 1
      @mappings = []
      @nodes = []
      @parent = nil
      @parents = []
      @position = 1
      @scalars = []
      @sequences = []
    end
    
    def add_alias(node)
      next_position(node)
      @aliases.push(node)
    end
    
    def add_scalar(node)
      next_position(node)
      @scalars.push(node)
    end
    
    def end_mapping()
      end_parent()
      
      if !@parent.nil?() && @parent.child_type == :key
        end_parent()
        
        @level -= 1
        @parent.child_type = :key if !@parent.nil?()
      end
    end
    
    def end_sequence()
      end_parent()
      
      @level -= 1
    end
    
    def next_position(node)
      if !@parent.nil?() && !@parent.child_type.nil?()
        case @parent.child_type
        when :key
          tag = :unknown
          
          if node.respond_to?(:value,true)
            tag = node.value
          elsif node.respond_to?(:anchor,true)
            tag = node.anchor
          end
          
          start_parent(node,child_type: :value,tag: tag)
          
          @parent.child_position = @position
          
          @level += 1
          @position = 1
        when :value
          end_parent()
          
          @level -= 1
          @parent.child_type = :key if !@parent.nil?()
        end
      else
        @position += 1
        
        @nodes.push(node)
      end
    end
    
    def start_mapping(node)
      start_parent(node,child_type: :key,tag: :map)
      
      # Do not increment @level; the first child (key) will
      @position = @parent.child_position
      
      @mappings.push(node)
    end
    
    def start_sequence(node)
      start_parent(node,tag: :seq)
      
      @level += 1
      @position = @parent.child_position
      
      @sequences.push(node)
    end
    
    protected
    
    def end_parent()
      @parent = @parents.pop()
      
      if !@parent.nil?()
        @parent.child_position += 1
        @position = @parent.child_position
      end
    end
    
    def start_parent(node,**extra)
      @parent = Parent.new(self,node,extra)
      
      @parents.push(@parent)
      @nodes.push(node)
    end
  end
end
