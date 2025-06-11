# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'psych'

require 'psychgus/styler'
require 'psychgus/super_sniffer'

module Psychgus
  ###
  # Use this wherever Psych::TreeBuilder would have been used, to enable styling.
  #
  # @see Psychgus.parser Psychgus.parser
  # @see Psychgus.dump_stream Psychgus.dump_stream
  # @see Psych::TreeBuilder
  ###
  class StyledTreeBuilder < Psych::TreeBuilder
    # @return [true,false] whether to dereference aliases; output the actual value instead of the alias
    attr_accessor :deref_aliases
    alias_method :deref_aliases?,:deref_aliases

    # @return [SuperSniffer] the {SuperSniffer} being used to sniff the YAML nodes, level, etc.
    attr_reader :sniffer

    # @return [Array<Stylers>] the {Styler}(s) being used to style the YAML nodes
    attr_reader :stylers

    # Initialize this class with {Styler}(s).
    #
    # @param stylers [Styler] {Styler}(s) to use for styling this TreeBuilder
    # @param deref_aliases [true,false] whether to dereference aliases; output the actual value
    #                                   instead of the alias
    def initialize(*stylers,deref_aliases: false,**_options)
      super()

      @deref_aliases = deref_aliases
      @sniffer = SuperSniffer.new
      @stylers = []

      add_styler(*stylers)
    end

    # Add {Styler}(s) onto the end of the data structure.
    #
    # @param stylers [Styler] {Styler}(s) to add
    #
    # @return [self] this class
    def add_styler(*stylers)
      @stylers.push(*stylers)

      return self
    end

    # Calls super, styler(s), and sniffer.
    #
    # @see Psych::TreeBuilder#alias
    # @see Styler#style
    # @see Styler#style_alias
    # @see SuperSniffer#add_alias
    #
    # @return [Psych::Nodes::Alias] the alias node created
    def alias(*)
      node = super

      @stylers.each do |styler|
        styler.style(sniffer,node)
        styler.style_alias(sniffer,node)
      end

      @sniffer.add_alias(node)

      return node
    end

    # Calls super and sniffer.
    #
    # @see Psych::TreeBuilder#end_document
    # @see SuperSniffer#end_document
    def end_document(*)
      result = super

      @sniffer.end_document

      return result
    end

    # Calls super and sniffer.
    #
    # @see Psych::TreeBuilder#end_mapping
    # @see SuperSniffer#end_mapping
    def end_mapping(*)
      result = super

      @sniffer.end_mapping

      return result
    end

    # Calls super and sniffer.
    #
    # @see Psych::TreeBuilder#end_sequence
    # @see SuperSniffer#end_sequence
    def end_sequence(*)
      result = super

      @sniffer.end_sequence

      return result
    end

    # Calls super and sniffer.
    #
    # @see Psych::TreeBuilder#end_stream
    # @see SuperSniffer#end_stream
    def end_stream(*)
      result = super

      @sniffer.end_stream

      return result
    end

    # Insert {Styler}(s) at +index+ into the data structure.
    #
    # @param stylers [Styler] {Styler}(s) to insert
    #
    # @return [self] this class
    def insert_styler(index,*stylers)
      @stylers.insert(index,*stylers)

      return self
    end

    # Remove the last {Styler}(s) from the data structure.
    #
    # @param count [Integer] the optional amount of tail elements to pop
    #
    # @return [Styler,Array<Styler>,nil] the last {Styler}(s), or if empty or count==0, nil
    def pop_styler(count = 1)
      return nil if count == 0
      return @stylers.pop if count == 1

      return @stylers.pop(count)
    end

    # Remove the {Styler} that matches +styler+ from the data structure.
    #
    # An optional +block+ can return a default value if not found.
    #
    # @param styler [Styler] the {Styler} to find and remove
    # @param block [Proc] an optional block to call when +styler+ is not found
    #
    # @return [Styler,nil] the last {Styler}, or if not found, nil or the result of +block+
    def remove_styler(styler,&)
      return @stylers.delete(styler,&)
    end

    # Remove the {Styler} at +index+ from the data structure.
    #
    # @param index [Integer] the index of the {Styler} to remove
    #
    # @return [Styler,nil] the {Styler} removed or nil if empty
    def remove_styler_at(index)
      return @stylers.delete_at(index)
    end

    # Calls super, styler(s), and sniffer.
    #
    # @see Psych::TreeBuilder#scalar
    # @see Styler#style
    # @see Styler#style_scalar
    # @see SuperSniffer#add_scalar
    #
    # @return [Psych::Nodes::Scalar] the scalar node created
    def scalar(*)
      node = super

      @stylers.each do |styler|
        styler.style(sniffer,node)
        styler.style_scalar(sniffer,node)
      end

      @sniffer.add_scalar(node)

      return node
    end

    # Calls super, styler(s), and sniffer.
    #
    # @see Psych::TreeBuilder#start_document
    # @see Styler#style
    # @see Styler#style_document
    # @see SuperSniffer#start_document
    #
    # @return [Psych::Nodes::Document] the document node created
    def start_document(*)
      node = super

      @stylers.each do |styler|
        styler.style(sniffer,node)
        styler.style_document(sniffer,node)
      end

      @sniffer.start_document(node)

      return node
    end

    # Calls super, styler(s), and sniffer.
    #
    # @see Psych::TreeBuilder#start_mapping
    # @see Styler#style
    # @see Styler#style_mapping
    # @see SuperSniffer#start_mapping
    #
    # @return [Psych::Nodes::Mapping] the mapping node created
    def start_mapping(*)
      node = super

      @stylers.each do |styler|
        styler.style(sniffer,node)
        styler.style_mapping(sniffer,node)
      end

      @sniffer.start_mapping(node)

      return node
    end

    # Calls super, styler(s), and sniffer.
    #
    # @see Psych::TreeBuilder#start_sequence
    # @see Styler#style
    # @see Styler#style_sequence
    # @see SuperSniffer#start_sequence
    #
    # @return [Psych::Nodes::Sequence] the sequence node created
    def start_sequence(*)
      node = super

      @stylers.each do |styler|
        styler.style(sniffer,node)
        styler.style_sequence(sniffer,node)
      end

      @sniffer.start_sequence(node)

      return node
    end

    # Calls super, styler(s), and sniffer.
    #
    # @see Psych::TreeBuilder#start_stream
    # @see Styler#style
    # @see Styler#style_stream
    # @see SuperSniffer#start_stream
    #
    # @return [Psych::Nodes::Stream] the stream node created
    def start_stream(*)
      node = super

      @stylers.each do |styler|
        styler.style(sniffer,node)
        styler.style_stream(sniffer,node)
      end

      @sniffer.start_stream(node)

      return node
    end
  end
end
