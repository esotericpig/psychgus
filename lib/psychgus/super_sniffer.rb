# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'psychgus/super_sniffer/parent'

module Psychgus
  class SuperSniffer
    ###
    # An empty {SuperSniffer} used for speed when you don't need sniffing in {StyledTreeBuilder}.
    ###
    class Empty < SuperSniffer
      def add_alias(*) end
      def add_scalar(*) end
      def end_document(*) end
      def end_mapping(*) end
      def end_sequence(*) end
      def end_stream(*) end
      def start_document(*) end
      def start_mapping(*) end
      def start_sequence(*) end
      def start_stream(*) end
    end
  end

  ###
  # This is used in {StyledTreeBuilder} to "sniff" information about the YAML.
  #
  # Then this information can be used in a {Styler} and/or a {Blueberry}.
  #
  # Most information is straightforward:
  # - {#aliases}   # Array of Psych::Nodes::Alias processed so far
  # - {#documents} # Array of Psych::Nodes::Document processed so far
  # - {#mappings}  # Array of Psych::Nodes::Mapping processed so far
  # - {#nodes}     # Array of Psych::Nodes::Node processed so far
  # - {#scalars}   # Array of Psych::Nodes::Scalar processed so far
  # - {#sequences} # Array of Psych::Nodes::Sequence processed so far
  # - {#streams}   # Array of Psych::Nodes::Stream processed so far
  #
  # {#parent} is the current {SuperSniffer::Parent} of the node being processed,
  # which is an empty Parent for the first node (not nil).
  #
  # {#parents} are all of the (grand){SuperSniffer::Parent}(s) for the current node,
  # which is an Array that just contains an empty Parent for the first node.
  #
  # A parent is a Mapping or Sequence, or a Key (Scalar) in a Mapping.
  #
  # {#level} and {#position} can be best understood by an example.
  #
  # If you have this YAML:
  #  Burgers:
  #     Classic:
  #       Sauce:  [Ketchup,Mustard]
  #       Cheese: American
  #       Bun:    Sesame Seed
  #     BBQ:
  #       Sauce:  Honey BBQ
  #       Cheese: Cheddar
  #       Bun:    Kaiser
  #     Fancy:
  #       Sauce:  Spicy Wasabi
  #       Cheese: Smoked Gouda
  #       Bun:    Hawaiian
  #   Toppings:
  #     - Mushrooms
  #     - [Lettuce, Onions, Pickles, Tomatoes]
  #     - [[Ketchup,Mustard], [Salt,Pepper]]
  #
  # Then the levels and positions will be as follows:
  #   # (level:position):current_node - <parent:(parent_level:parent_position)>
  #
  #   (1:1):Psych::Nodes::Stream - <root:(0:0)>
  #   (1:1):Psych::Nodes::Document - <stream:(1:1)>
  #   (1:1):Psych::Nodes::Mapping - <doc:(1:1)>
  #    (2:1):Burgers - <map:(1:1)>
  #     (3:1):Psych::Nodes::Mapping - <Burgers:(2:1)>
  #      (4:1):Classic - <map:(3:1)>
  #       (5:1):Psych::Nodes::Mapping - <Classic:(4:1)>
  #        (6:1):Sauce - <map:(5:1)>
  #         (7:1):Psych::Nodes::Sequence - <Sauce:(6:1)>
  #          (8:1):Ketchup - <seq:(7:1)>
  #          (8:2):Mustard - <seq:(7:1)>
  #        (6:2):Cheese - <map:(5:1)>
  #         (7:1):American - <Cheese:(6:2)>
  #        (6:3):Bun - <map:(5:1)>
  #         (7:1):Sesame Seed - <Bun:(6:3)>
  #      (4:2):BBQ - <map:(3:1)>
  #       (5:1):Psych::Nodes::Mapping - <BBQ:(4:2)>
  #        (6:1):Sauce - <map:(5:1)>
  #         (7:1):Honey BBQ - <Sauce:(6:1)>
  #        (6:2):Cheese - <map:(5:1)>
  #         (7:1):Cheddar - <Cheese:(6:2)>
  #        (6:3):Bun - <map:(5:1)>
  #         (7:1):Kaiser - <Bun:(6:3)>
  #      (4:3):Fancy - <map:(3:1)>
  #       (5:1):Psych::Nodes::Mapping - <Fancy:(4:3)>
  #        (6:1):Sauce - <map:(5:1)>
  #         (7:1):Spicy Wasabi - <Sauce:(6:1)>
  #        (6:2):Cheese - <map:(5:1)>
  #         (7:1):Smoked Gouda - <Cheese:(6:2)>
  #        (6:3):Bun - <map:(5:1)>
  #         (7:1):Hawaiian - <Bun:(6:3)>
  #    (2:2):Toppings - <map:(1:1)>
  #     (3:1):Psych::Nodes::Sequence - <Toppings:(2:2)>
  #      (4:1):Mushrooms - <seq:(3:1)>
  #      (4:2):Psych::Nodes::Sequence - <seq:(3:1)>
  #       (5:1):Lettuce - <seq:(4:2)>
  #       (5:2):Onions - <seq:(4:2)>
  #       (5:3):Pickles - <seq:(4:2)>
  #       (5:4):Tomatoes - <seq:(4:2)>
  #      (4:3):Psych::Nodes::Sequence - <seq:(3:1)>
  #       (5:1):Psych::Nodes::Sequence - <seq:(4:3)>
  #        (6:1):Ketchup - <seq:(5:1)>
  #        (6:2):Mustard - <seq:(5:1)>
  #       (5:2):Psych::Nodes::Sequence - <seq:(4:3)>
  #        (6:1):Salt - <seq:(5:2)>
  #        (6:2):Pepper - <seq:(5:2)>
  #
  # "The Super Sniffer" is the nickname for Gus's nose from the TV show Psych
  # because he has a very refined sense of smell.
  #
  # @note You should never call the methods that are not readers, like {#add_alias}, {#start_mapping}, etc.
  #       unless you are extending this class (creating a subclass).
  #
  # @see StyledTreeBuilder
  # @see Styler
  # @see Blueberry#psychgus_stylers
  ###
  class SuperSniffer
    EMPTY = Empty.new.freeze

    attr_reader :aliases # @return [Array<Psych::Nodes::Alias>] the aliases processed so far
    attr_reader :documents # @return [Array<Psych::Nodes::Document>] the documents processed so far
    attr_reader :level # @return [Integer] the current level
    attr_reader :mappings # @return [Array<Psych::Nodes::Mapping>] the mappings processed so far
    attr_reader :nodes # @return [Array<Psych::Nodes::Node>] the nodes processed so far
    attr_reader :parent # @return [Parent] the current parent
    attr_reader :parents # @return [Array<Parent>] the current (grand)parents
    attr_reader :position # @return [Integer] the current position
    attr_reader :scalars # @return [Array<Psych::Nodes::Scalar>] the scalars processed so far
    attr_reader :sequences # @return [Array<Psych::Nodes::Sequence>] the sequences processed so far
    attr_reader :streams # @return [Array<Psych::Nodes::Stream>] the streams processed so far

    # Initialize this class for sniffing.
    def initialize
      @aliases = []
      @documents = []
      @level = 0
      @mappings = []
      @nodes = []
      @parent = nil
      @parents = []
      @position = 0
      @scalars = []
      @sequences = []
      @streams = []

      # Do not pass in "top_level: true"
      start_parent(nil,debug_tag: :root)
    end

    # Add a Psych::Nodes::Alias to this class only (not to the YAML).
    #
    # A {Styler} should probably never call this.
    #
    # @param node [Psych::Nodes::Alias] the alias to add
    #
    # @see add_child
    def add_alias(node)
      add_child(node)
      @aliases.push(node)
    end

    # Add a Psych::Nodes::Scalar to this class only (not to the YAML).
    #
    # A {Styler} should probably never call this.
    #
    # @param node [Psych::Nodes::Scalar] the scalar to add
    #
    # @see add_child
    def add_scalar(node)
      add_child(node)
      @scalars.push(node)
    end

    # End a Psych::Nodes::Document started with {#start_document}.
    #
    # Pops off a parent from {#parents} and sets {#parent} to the last one.
    # {#level} and {#position} are reset according to the last parent.
    #
    # A {Styler} should probably never call this.
    def end_document
      end_parent(top_level: true)
    end

    # End a Psych::Nodes::Mapping started with {#start_mapping}.
    #
    # Pops off a parent from {#parents} and sets {#parent} to the last one.
    # {#level} and {#position} are reset according to the last parent.
    #
    # A {Styler} should probably never call this.
    #
    # @see end_parent
    def end_mapping
      end_parent(mapping_value: true)
    end

    # End a Psych::Nodes::Sequence started with {#start_sequence}.
    #
    # Pops off a parent from {#parents} and sets {#parent} to the last one.
    # {#level} and {#position} are reset according to the last parent.
    #
    # A {Styler} should probably never call this.
    #
    # @see end_parent
    def end_sequence
      end_parent(mapping_value: true)
    end

    # End a Psych::Nodes::Stream started with {#start_stream}.
    #
    # Pops off a parent from {#parents} and sets {#parent} to the last one.
    # {#level} and {#position} are reset according to the last parent.
    #
    # A {Styler} should probably never call this.
    def end_stream
      end_parent(top_level: true)
    end

    # Start a Psych::Nodes::Document.
    #
    # Creates a {SuperSniffer::Parent}, sets {#parent} to it, and adds it to {#parents}.
    # {#level} and {#position} are incremented/set accordingly.
    #
    # A {Styler} should probably never call this.
    #
    # @param node [Psych::Nodes::Document] the Document to start
    #
    # @see start_parent
    def start_document(node)
      start_parent(node,debug_tag: :doc,top_level: true)
      @documents.push(node)
    end

    # Start a Psych::Nodes::Mapping.
    #
    # Creates a {SuperSniffer::Parent}, sets {#parent} to it, and adds it to {#parents}.
    # {#level} and {#position} are incremented/set accordingly.
    #
    # A {Styler} should probably never call this.
    #
    # @param node [Psych::Nodes::Mapping] the Mapping to start
    #
    # @see start_parent
    def start_mapping(node)
      start_parent(node,debug_tag: :map,child_type: :key)
      @mappings.push(node)
    end

    # Start a Psych::Nodes::Sequence.
    #
    # Creates a {SuperSniffer::Parent}, sets {#parent} to it, and adds it to {#parents}.
    # {#level} and {#position} are incremented/set accordingly.
    #
    # A {Styler} should probably never call this.
    #
    # @param node [Psych::Nodes::Sequence] the Sequence to start
    #
    # @see start_parent
    def start_sequence(node)
      start_parent(node,debug_tag: :seq)
      @sequences.push(node)
    end

    # Start a Psych::Nodes::Stream.
    #
    # Creates a {SuperSniffer::Parent}, sets {#parent} to it, and adds it to {#parents}.
    # {#level} and {#position} are incremented/set accordingly.
    #
    # A {Styler} should probably never call this.
    #
    # @param node [Psych::Nodes::Stream] the Stream to start
    #
    # @see start_parent
    def start_stream(node)
      start_parent(node,debug_tag: :stream,top_level: true)
      @streams.push(node)
    end

    protected

    # Add a non-parent node.
    #
    # This will increment {#position} accordingly, and if the child is a Key to a Mapping,
    # create a fake "{SuperSniffer::Parent}".
    #
    # @param node [Psych::Nodes::Node] the non-parent Node to add
    #
    # @see end_mapping_value
    def add_child(node)
      if !@parent.nil?
        # Fake a "parent" if necessary
        case @parent.child_type
        when :key
          start_mapping_key(node)
          return
        when :value
          end_mapping_value
          return
        else
          @parent.child_position += 1
        end
      end

      @position += 1

      @nodes.push(node)
    end

    # End a fake "{SuperSniffer::Parent}" that is a Key/Value to a Mapping.
    #
    # @see add_child
    def end_mapping_value
      end_parent # Do not pass in "mapping_value: true" and/or "top_level: true"

      @parent.child_type = :key unless @parent.nil?
    end

    # End a {SuperSniffer::Parent}.
    #
    # Pops off a parent from {#parents} and sets {#parent} to the last one.
    # {#level} and {#position} are reset according to the last parent.
    #
    # @param mapping_value [true,false] true if parent can be the value of a Mapping's key
    # @param top_level [true,false] true if a top-level parent (i.e., encapsulating the main data)
    def end_parent(mapping_value: false,top_level: false)
      @parents.pop
      @parent = @parents.last

      @level = top_level ? 1 : (@level - 1)

      if !@parent.nil?
        @parent.child_position += 1
        @position = @parent.child_position

        # add_child() will not be called again, so end a fake "parent" manually with a fake "value"
        # - This is necessary for any parents that can be the value of a map's key (e.g., Sequence)
        end_mapping_value if mapping_value && !@parent.child_type.nil?
      end
    end

    # Start a fake "{SuperSniffer::Parent}" that is a Key/Value to a Mapping.
    #
    # Creates a {SuperSniffer::Parent}, sets {#parent} to it, and adds it to {#parents}.
    # {#level} and {#position} are incremented/set accordingly.
    #
    # @param node [Psych::Nodes::Node] the Node to start
    #
    # @see start_parent
    def start_mapping_key(node)
      debug_tag = nil

      # Value must be first because Scalar also has an anchor
      if node.respond_to?(:value)
        debug_tag = node.value
      elsif node.respond_to?(:anchor)
        debug_tag = node.anchor
      end

      debug_tag = :noface if debug_tag.nil?

      start_parent(node,debug_tag: debug_tag,child_type: :value)
    end

    # Start a {SuperSniffer::Parent}.
    #
    # Creates a {SuperSniffer::Parent}, sets {#parent} to it, and adds it to {#parents}.
    # {#level} and {#position} are incremented/set accordingly.
    #
    # @param node [Psych::Nodes::Node] the parent Node to start
    # @param top_level [true,false] true if a top-level parent (i.e., encapsulating the main data)
    # @param extra [Hash] the extra keyword args to pass to {SuperSniffer::Parent#initialize}
    #
    # @see SuperSniffer::Parent#initialize
    def start_parent(node,top_level: false,**extra)
      @parent = Parent.new(self,node,**extra)

      @parents.push(@parent)
      @nodes.push(node) unless node.nil?

      if top_level
        @level = 1
        @position = @parent.position
      else
        @level += 1
        @position = 1
      end
    end
  end
end
