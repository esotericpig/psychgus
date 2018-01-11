#!/usr/bin/env ruby

###
# This file is part of psychgus.
# Copyright (c) 2017-2018 Jonathan Bradley Whited (@esotericpig)
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

require 'psychgus/unset'

module Psychgus
  class Sniffer
    attr_accessor :odors
    
    # @param odors [Hash]
    #   - :end_column   [Integer]
    #   - :end_line     [Integer]
    #   - :implicit     [true,false]
    #   - :index        [Integer] ignored (see Psychgus)
    #   - :level        [Integer] ignored (see Psychgus)
    #   - :plain        [true,false]
    #   - :quoted       [true,false]
    #   - :start_column [Integer]
    #   - :start_line   [Integer]
    #   - :style        [Integer,Symbol[:any, :block, :double_quoted, :flow, :folded, :literal, :plain, :single_quoted]]
    #   - :tag          [Object,String]
    #   - :type         [Class,Symbol[:alias, :document, :mapping, :node, :scalar, :sequence, :stream]]
    #   - :value        [Object,String]
    def initialize(**odors)
      @odors = odors
    end
    
    def [](key)
      return @odors[key]
    end
    
    def []=(key,value)
      return @odors[key] = value
    end
    
    def sniff(node)
      @odors.each() do |key,value|
        case key
        when :index,:level
          next # Handled outside of this class in Psychgus
        when :type
          value = Psych::Nodes.const_get(value.capitalize()) if value.is_a?(Symbol)
          return false unless node.is_a?(value)
          next
        end
        
        next unless node.respond_to?(key)
        value = self.class.to_value(node,key,value)
        next if value == Unset
        node_value = node.send(key)
        
        # No reason for Range here, I think
        if value.is_a?(Array)
          return false unless value.include?(node_value)
        else
          return false unless node_value == value
        end
      end
      
      return true
    end
    
    def key?(key)
      return @odors.key?(key)
    end
    
    def odors?()
      return @odors && !@odors.empty?()
    end
    
    def self.to_value(node,key,value)
      case key
      when :style
        if value.is_a?(Symbol)
          value = value.upcase()
          return Unset unless node.class.const_defined?(value)
          value = node.class.const_get(value)
        end
      end
      
      return value
    end
  end
end
