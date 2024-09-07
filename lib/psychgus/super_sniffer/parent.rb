# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'delegate'

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
    # @see SuperSniffer
    # @see SuperSniffer#start_parent SuperSniffer#start_parent
    # @see SuperSniffer#end_parent SuperSniffer#end_parent
    # @see Styler
    ###
    class Parent < SimpleDelegator
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
        super(node)

        @child_position = 1
        @child_type = child_type
        @debug_tag = debug_tag
        @level = sniffer.level
        @node = node
        @position = sniffer.position
      end

      # @api private
      def __getobj__
        return @node
      end

      # Check if the children of this parent are keys to a Mapping.
      #
      # @return [true,false] whether the children are keys to a Mapping
      def child_key?
        return @child_type == :key
      end

      # Check if the children of this parent are values to a Mapping (i.e., values to a key).
      #
      # @return [true,false] whether the children are values to a Mapping (i.e., values to a key)
      def child_value?
        return @child_type == :value
      end

      # @see Psych::Nodes::Document#implicit
      # @see Psych::Nodes::Mapping#implicit
      # @see Psych::Nodes::Sequence#implicit
      def implicit?
        return @node.implicit
      end

      # @see Psych::Nodes::Document#implicit_end
      def implicit_end?
        return @node.implicit_end
      end

      # (see Ext::NodeExt#node_of?)
      def node_of?(*names)
        return @node.node_of?(*names)
      end

      # @see Psych::Nodes::Scalar#plain
      def plain?
        return @node.plain
      end

      # @see Psych::Nodes::Scalar#quoted
      def quoted?
        return @node.quoted
      end

      # @note If this method is modified, then tests will fail
      #
      # @return [String] a String representation of this class for debugging and testing
      def to_s
        return "<#{@debug_tag}:(#{@level}:#{@position}):#{@child_type}:(:#{@child_position})>"
      end
    end
  end
end
