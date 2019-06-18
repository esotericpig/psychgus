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
    class Parent
      attr_accessor :child_position # For next child's position
      attr_accessor :child_type # For next child's mapping: nil, :key, or :value
      attr_reader :debug_tag
      attr_reader :level
      attr_reader :node
      attr_reader :position
      
      def initialize(sniffer,node,child_type: nil,debug_tag: nil)
        @child_position = 1
        @child_type = child_type
        @debug_tag = debug_tag
        @level = sniffer.level
        @node = node
        @position = sniffer.position
      end
      
      def style=(style)
        node.style = style
      end
      
      def value=(value)
        node.value = value
      end
      
      def anchor()
        return node.anchor
      end
      
      def encoding()
        return node.encoding
      end
      
      def end_column()
        return node.end_column
      end
      
      def end_line()
        return node.end_line
      end
      
      def implicit?()
        return node.implicit
      end
      
      def implicit_end?()
        return node.implicit_end
      end
      
      def node_of?(name)
        return node.node_of?(name)
      end
      
      def plain?()
        return node.plain
      end
      
      def quoted?()
        return node.quoted
      end
      
      def start_column()
        return node.start_column
      end
      
      def start_line()
        return node.start_line
      end
      
      def style()
        return node.style
      end
      
      def tag()
        return node.tag
      end
      
      def tag_directives()
        return node.tag_directives
      end
      
      def value()
        return node.value
      end
      
      def version()
        return node.version
      end
      
      def to_s()
        return "<#{@debug_tag}:(#{@level}:#{@position}):#{@child_type}:(:#{@child_position})>"
      end
      
      alias_method :implicit,:implicit?
      alias_method :implicit_end,:implicit_end?
      alias_method :plain,:plain?
      alias_method :quoted,:quoted?
    end
  end
end
