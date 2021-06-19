#!/usr/bin/env ruby
# encoding: UTF-8

#--
# This file is part of Psychgus.
# Copyright (c) 2019-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++


require 'psychgus/styler'
require 'psychgus/super_sniffer'

require 'stringio'

module Psychgus
  ###
  # A collection of commonly-used {Styler} mixins
  # that can be included in a class instead of {Styler}.
  #
  # @author Jonathan Bradley Whited
  # @since  1.2.0
  #
  # @see Stylers
  # @see Styler
  ###
  module Stylables
    ###
    # A helper mixin for Stylables that change a node's style.
    #
    # There is no max level, because a parent's style will override all of its children.
    ###
    module StyleStylable
      include Styler

      attr_accessor :min_level # @return [Integer] the minimum level (inclusive) to style
      attr_accessor :new_style # @return [Integer] the new style to set the nodes to

      # +max_level+ is not defined because a parent's style will override all of its children.
      #
      # @param min_level [Integer] the minimum level (inclusive) to style
      # @param new_style [Integer] the new style to set the nodes to
      # @param kargs [Hash] capture extra keyword args, so no error for undefined args
      def initialize(min_level=0,new_style: nil,**kargs)
        @min_level = min_level
        @new_style = new_style
      end

      # Change the style of +node+ to {new_style} if it is >= {min_level}.
      def change_style(sniffer,node)
        return unless node.respond_to?(:style=)

        node.style = @new_style if sniffer.level >= @min_level
      end
    end
  end

  module Stylables
    ###
    # (see Stylers::CapStyler)
    ###
    module CapStylable
      include Styler

      attr_reader :delim # @return [String,Regexp] the delimiter to split on
      attr_accessor :each_word # @return [true,false] whether to capitalize each word separated by {delim}
      attr_accessor :new_delim # @return [nil,String] the replacement for each {delim} if not nil

      # @param each_word [true,false] whether to capitalize each word separated by +delim+
      # @param new_delim [nil,String] the replacement for each +delim+ if not nil
      # @param delim [String,Regexp] the delimiter to split on
      # @param kargs [Hash] capture extra keyword args, so no error for undefined args
      def initialize(each_word: true,new_delim: nil,delim: /[\s_\-]/,**kargs)
        delim = Regexp.quote(delim.to_s()) unless delim.is_a?(Regexp)

        @delim = Regexp.new("(#{delim.to_s()})")
        @each_word = each_word
        @new_delim = new_delim
      end

      # Capitalize an individual word (not words).
      #
      # This method can safely be overridden with a new implementation.
      #
      # @param word [nil,String] the word to capitalize
      #
      # @return [String] the capitalized word
      def cap_word(word)
        return word if word.nil?() || word.empty?()

        # Already capitalized, good for all-capitalized words, like 'BBQ'
        return word if word[0] == word[0].upcase()

        return word.capitalize()
      end

      # Capitalize +node.value+.
      #
      # @see cap_word
      # @see Styler#style_scalar
      def style_scalar(sniffer,node)
        if !@each_word || node.value.nil?() || node.value.empty?()
          node.value = cap_word(node.value)
          return
        end

        is_delim = false

        node.value = node.value.split(@delim).map() do |v|
          if is_delim
            v = @new_delim unless @new_delim.nil?()
          else
            v = cap_word(v)
          end

          is_delim = !is_delim
          v
        end.join()
      end
    end

    ###
    # (see Stylers::HierarchyStyler)
    ###
    module HierarchyStylable
      include Styler

      attr_accessor :io # @return [IO] the IO to write to; defaults to StringIO
      attr_accessor :verbose # @return [true,false] whether to be more verbose (e.g., write child info)

      # @param io [IO] the IO to write to
      # @param verbose [true,false] whether to be more verbose (e.g., write child info)
      # @param kargs [Hash] capture extra keyword args, so no error for undefined args
      def initialize(io: StringIO.new(),verbose: false,**kargs)
        @io = io
        @verbose = verbose
      end

      # Write the hierarchy of +node+ to {io}.
      #
      # @see Styler#style
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

      # Convert {io} to a String if possible (e.g., StringIO).
      #
      # @return [String] the IO String result or just {io} as a String
      def to_s()
        return @io.respond_to?(:string) ? @io.string : @io.to_s()
      end
    end

    ###
    # (see Stylers::MapFlowStyler)
    ###
    module MapFlowStylable
      include StyleStylable

      # (see StyleStylable#initialize)
      # @!method initialize(min_level=0,new_style: nil,**kargs)
      #
      # If +new_style+ is nil (the default), then {MAPPING_FLOW} will be used.
      def initialize(*)
        super

        @new_style = MAPPING_FLOW if @new_style.nil?()
      end

      # Change the style of a Mapping to FLOW (or to the value of {new_style})
      # if it is >= {min_level}.
      #
      # @see change_style
      # @see Styler#style_mapping
      def style_mapping(sniffer,node)
        change_style(sniffer,node)
      end
    end

    ###
    # (see Stylers::NoSymStyler)
    ###
    module NoSymStylable
      include Styler

      attr_accessor :cap # @return [true,false] whether to capitalize the symbol

      alias_method :cap?,:cap

      # @param cap [true,false] whether to capitalize the symbol
      # @param kargs [Hash] capture extra keyword args, so no error for undefined args
      def initialize(cap: true,**kargs)
        @cap = cap
      end

      # If +node.value+ is a symbol, change it into a string and capitalize it.
      #
      # @see Styler#style_scalar
      def style_scalar(sniffer,node)
        return if node.value.nil?() || node.value.empty?()
        return if node.value[0] != ':'

        node.value = node.value[1..-1]
        node.value = node.value.capitalize() if @cap
      end
    end

    ###
    # (see Stylers::NoTagStyler)
    ###
    module NoTagStylable
      include Styler

      # If +node.tag+ is settable, set it to nil.
      #
      # @see Styler#style
      def style(sniffer,node)
        node.tag = nil if node.respond_to?(:tag=)
      end
    end

    ###
    # (see Stylers::SeqFlowStyler)
    ###
    module SeqFlowStylable
      include StyleStylable

      # (see StyleStylable#initialize)
      # @!method initialize(min_level=0,new_style: nil,**kargs)
      #
      # If +new_style+ is nil (the default), then {SEQUENCE_FLOW} will be used.
      def initialize(*)
        super

        @new_style = SEQUENCE_FLOW if @new_style.nil?()
      end

      # Change the style of a Sequence to FLOW (or to the value of {new_style})
      # if it is >= {min_level}.
      #
      # @see change_style
      # @see Styler#style_sequence
      def style_sequence(sniffer,node)
        change_style(sniffer,node)
      end
    end
  end
end
