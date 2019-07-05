#!/usr/bin/env ruby
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


require 'psychgus/styler'
require 'psychgus/super_sniffer'

require 'stringio'

# TODO: add documentation

module Psychgus
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  1.2.0
  # 
  # @see Styler
  ###
  module Stylers
    module CapStylable
      include Styler
      
      attr_reader :delim
      attr_accessor :each_word
      attr_accessor :new_delim
      
      def initialize(each_word: true,new_delim: nil,delim: /[\s_\-]/,**kargs)
        delim = Regexp.quote(delim.to_s()) unless delim.is_a?(Regexp)
        
        @delim = Regexp.new("(#{delim.to_s()})")
        @each_word = each_word
        @new_delim = new_delim
      end
      
      def style_scalar(sniffer,node)
        return if node.value.nil?()
        
        if @each_word
          is_delim = false
          
          node.value = node.value.split(@delim).map() do |v|
            if is_delim
              v = @new_delim unless @new_delim.nil?()
            else
              v = v.capitalize()
            end
            
            is_delim = !is_delim
            v
          end.join()
        else
          node.value = node.value.capitalize()
        end
      end
    end
    
    module HierarchyStylable
      include Styler
      
      attr_accessor :io
      attr_accessor :verbose
      
      def initialize(io: StringIO.new(),verbose: false,**kargs)
        @io = io
        @verbose = verbose
      end
      
      def style(sniffer,node)
        @io.print (' ' * (sniffer.level - 1))
        
        name = node.respond_to?(:value) ? node.value : node.class.name
        parent = sniffer.parent
        
        @io.print "(#{sniffer.level}:#{sniffer.position}):#{name} - "
        
        if @verbose
          @io.print parent
        else
          @io.print "<#{parent.debug_tag}:(#{parent.level}:#{parent.position})>"
        end
        
        @io.puts
      end
      
      def to_s()
        return @io.respond_to?(:string) ? @io.string : @io
      end
    end
    
    module MinMaxLevelStylable
      include Styler
      
      attr_accessor :max_level
      attr_accessor :min_level
      
      def initialize(min_level=0,max_level=-1)
        @max_level = max_level
        @min_level = min_level
      end
    end
    
    module MapFlowStylable
      include MinMaxLevelStylable
      
      def style_mapping(sniffer,node)
        if sniffer.level >= @min_level && (@max_level < 0 || sniffer.level < @max_level)
          node.style = MAPPING_FLOW
        end
      end
    end
    
    module NoSymStylable
      include Styler
      
      attr_accessor :cap
      
      alias_method :cap?,:cap
      
      def initialize(cap: true,**kargs)
        @cap = cap
      end
      
      def style_scalar(sniffer,node)
        return if node.value.nil?()
        
        node.value = node.value.sub(/\A\:/,'')
        node.value = node.value.capitalize() if @cap
      end
    end
    
    module NoTagStylable
      include Styler
      
      def style(sniffer,node)
        node.tag = nil if node.respond_to?(:tag=)
      end
    end
    
    module SeqFlowStylable
      include MinMaxLevelStylable
      
      def style_sequence(sniffer,node)
        if sniffer.level >= @min_level && (@max_level < 0 || sniffer.level < @max_level)
          node.style = SEQUENCE_FLOW
        end
      end
    end
  end
  
  module Stylers
    class CapStyler
      include CapStylable
    end
    
    class FlowStyler
      include MapFlowStylable
      include SeqFlowStylable
    end
    
    class HierarchyStyler
      include HierarchyStylable
    end
    
    class MapFlowStyler
      include MapFlowStylable
    end
    
    class NoSymStyler
      include NoSymStylable
    end
    
    class NoTagStyler
      include NoTagStylable
    end
    
    class SeqFlowStyler
      include SeqFlowStylable
    end
  end
end
