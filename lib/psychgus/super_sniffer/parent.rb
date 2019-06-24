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
    ###
    # A container for the parent of a Psych::Nodes::Node.
    # 
    # A parent is a Mapping, Sequence, or a Key (Scalar) of a Mapping.
    # 
    # You can use the getters in this class in {Styler} to filter what to change.
    # 
    # If a Node method has not been exposed, you can use {#node}:
    #   if parent.node_of?(:scalar)
    #     parent.value = 'FUBAR'
    #     parent.node.value = 'FUBAR' # Same as above
    #     
    #     parent.fubar = true      # NoMethodError
    #     parent.node.fubar = true # Use some new Psych::Nodes::Node method not in this version
    #                              #   of Psychgus or that is not exposed by Parent
    #   end
    # 
    # @author Jonathan Bradley Whited (@esotericpig)
    # @since  1.0.0
    # 
    # @see SuperSniffer
    # @see SuperSniffer#start_parent SuperSniffer#start_parent
    # @see SuperSniffer#end_parent SuperSniffer#end_parent
    # @see Styler
    ###
    class Parent
      # Calling the getter is fine; calling the setter is *not* and could cause weird results.
      # 
      # @return [Integer] the next child's position
      attr_accessor :child_position
      
      # Calling the getter is fine; calling the setter is *not* and could cause weird results.
      # 
      # @return [nil,:key,:value] the next child's Mapping type, if {#node} is a Mapping
      attr_accessor :child_type
      
      # @return [:noface,Symbol,String] a tag (class name, value) for debugging; also used in {#to_s}
      attr_reader :debug_tag
      
      attr_reader :level # @return [Integer] the level of this Node in the YAML
      attr_reader :node # @return [Psych::Nodes::Node] the Node of this parent
      attr_reader :position # @return [Integer] the position of this Node in the YAML
      
      # Initialize this class with parent data.
      # 
      # @param sniffer [SuperSniffer] the sniffer that contains this parent (not stored; used for data)
      # @param node [Psych::Nodes::Node] the node of this parent
      # @param debug_tag [:noface,Symbol,String] the tag (class name, value) used for debugging and in {#to_s}
      # @param child_type [nil,:key,:value] the next child's Mapping type, if +node+ is a Mapping
      def initialize(sniffer,node,debug_tag: nil,child_type: nil)
        @child_position = 1
        @child_type = child_type
        @debug_tag = debug_tag
        @level = sniffer.level
        @node = node
        @position = sniffer.position
      end
      
      # @see Psych::Nodes::Alias#anchor=
      # @see Psych::Nodes::Mapping#anchor=
      # @see Psych::Nodes::Scalar#anchor=
      # @see Psych::Nodes::Sequence#anchor=
      def anchor=(anchor)
        node.anchor = anchor
      end
      
      # @see Psych::Nodes::Scalar#plain=
      def plain=(plain)
        node.plain = plain
      end
      
      # @see Psych::Nodes::Scalar#quoted=
      def quoted=(quoted)
        node.quoted = quoted
      end
      
      # @see Psych::Nodes::Mapping#style=
      # @see Psych::Nodes::Scalar#style=
      # @see Psych::Nodes::Sequence#style=
      def style=(style)
        node.style = style
      end
      
      # @see Psych::Nodes::Node#tag=
      def tag=(tag)
        node.tag = tag
      end
      
      # @see Psych::Nodes::Scalar#value=
      def value=(value)
        node.value = value
      end
      
      # @see Psych::Nodes::Alias#anchor
      # @see Psych::Nodes::Mapping#anchor
      # @see Psych::Nodes::Scalar#anchor
      # @see Psych::Nodes::Sequence#anchor
      def anchor()
        return node.anchor
      end
      
      # @see Psych::Nodes::Stream#encoding
      def encoding()
        return node.encoding
      end
      
      # @see Psych::Nodes::Node#end_column
      def end_column()
        return node.end_column
      end
      
      # @see Psych::Nodes::Node#end_line
      def end_line()
        return node.end_line
      end
      
      # @see Psych::Nodes::Document#implicit
      # @see Psych::Nodes::Mapping#implicit
      # @see Psych::Nodes::Sequence#implicit
      def implicit?()
        return node.implicit
      end
      
      # @see Psych::Nodes::Document#implicit_end
      def implicit_end?()
        return node.implicit_end
      end
      
      # (see Ext::NodeExt#node_of?)
      def node_of?(name)
        return node.node_of?(name)
      end
      
      # @see Psych::Nodes::Scalar#plain
      def plain?()
        return node.plain
      end
      
      # @see Psych::Nodes::Scalar#quoted
      def quoted?()
        return node.quoted
      end
      
      # @see Psych::Nodes::Node#start_column
      def start_column()
        return node.start_column
      end
      
      # @see Psych::Nodes::Node#start_line
      def start_line()
        return node.start_line
      end
      
      # @see Psych::Nodes::Mapping#style
      # @see Psych::Nodes::Scalar#style
      # @see Psych::Nodes::Sequence#style
      def style()
        return node.style
      end
      
      # @see Psych::Nodes::Node#tag
      def tag()
        return node.tag
      end
      
      # @see Psych::Nodes::Document#tag_directives
      def tag_directives()
        return node.tag_directives
      end
      
      # @see Psych::Nodes::Scalar#value
      def value()
        return node.value
      end
      
      # @see Psych::Nodes::Document#version
      def version()
        return node.version
      end
      
      # @note If this method is modified, then tests will fail
      # 
      # @return [String] a String representation of this class for debugging and testing
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
