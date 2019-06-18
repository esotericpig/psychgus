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

require 'psychgus/super_sniffer/parent'

module Psychgus
  class SuperSniffer
    class Empty < SuperSniffer
      def initialize(*); end
      def add_alias(*); end
      def add_scalar(*); end
      def end_mapping(*); end
      def end_sequence(*); end
      def start_mapping(*); end
      def start_sequence(*); end
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
      add_child(node)
      @aliases.push(node)
    end
    
    def add_scalar(node)
      add_child(node)
      @scalars.push(node)
    end
    
    def end_mapping()
      if !@parent.nil?() && !@parent.child_type.nil?()
        # add_child() will not be called again, so end the fake "parent" manually with a fake "value"
        end_mapping_value()
      end
      
      end_parent()
    end
    
    def end_sequence()
      end_parent()
      
      @level -= 1
      
      if !@parent.nil?() && !@parent.child_type.nil?()
        # If a sequence is the value of a map's key, then this is necessary
        end_mapping_value()
      end
    end
    
    def start_mapping(node)
      start_parent(node,child_type: :key,debug_tag: :map)
      
      # Do not increment @level; the first child (key) will
      # - See add_child() and start_mapping_key()
      @position = 1
      
      @mappings.push(node)
    end
    
    def start_sequence(node)
      start_parent(node,debug_tag: :seq)
      
      @level += 1
      @position = 1
      
      @sequences.push(node)
    end
    
    protected
    
    def add_child(node)
      if !@parent.nil?()
        # Fake a "parent"
        case @parent.child_type
        when :key
          start_mapping_key(node)
          return
        when :value
          end_mapping_value()
          return
        else
          @parent.child_position += 1
        end
      end
      
      @position += 1
      
      @nodes.push(node)
    end
    
    def end_mapping_value()
      end_parent()
      
      @level -= 1
      @parent.child_type = :key unless @parent.nil?()
    end
    
    def end_parent()
      @parents.pop()
      @parent = @parents.last
      
      if !@parent.nil?()
        @parent.child_position += 1
        @position = @parent.child_position
      end
    end
    
    def start_mapping_key(node)
      debug_tag = nil
      
      # Value must be first because Scalar also has an anchor
      if node.respond_to?(:value)
        debug_tag = node.value
      elsif node.respond_to?(:anchor)
        debug_tag = node.anchor
      end
      
      debug_tag = :noface if debug_tag.nil?()
      
      start_parent(node,child_type: :value,debug_tag: debug_tag)
      
      @level += 1
      @position = 1
    end
    
    def start_parent(node,**extra)
      @parent = Parent.new(self,node,extra)
      
      @parents.push(@parent)
      @nodes.push(node)
    end
  end
end
