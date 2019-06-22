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
      def initialize(*) end
      def add_alias(*) end
      def add_scalar(*) end
      def end_mapping(*) end
      def end_sequence(*) end
      def start_mapping(*) end
      def start_sequence(*) end
    end
  end
  
  ###
  # This is used in {StyledTreeBuilder} to "sniff" information about the YAML.
  # 
  # Then this information can be used in a {Styler} and/or a {Blueberry}.
  # 
  # Most information is straightforward:
  # - {#aliases}   # Array of Psych::Nodes::Alias processed so far
  # - {#mappings}  # Array of Psych::Nodes::Mapping processed so far
  # - {#nodes}     # Array of all Psych::Nodes::Node processed so far
  # - {#scalars}   # Array of Psych::Nodes::Scalar processed so far
  # - {#sequences} # Array of Psych::Nodes::Sequence processed so far
  # 
  # {#parent} is the current {SuperSniffer::Parent} of the node being processed,
  # which is nil for the first node.
  # 
  # {#parents} are all of the {SuperSniffer::Parent}(s) processed so far,
  # which is empty for the first node.
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
  #   (1:1):Psych::Nodes::Mapping - <nil>
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
  # The "Super Sniffer" is the nickname for Gus's nose from the TV show Psych
  # because he has a very refined sense of smell.
  # 
  # @note You should never call the methods that are not readers, like {#add_alias}, {#start_mapping}, etc.
  #       unless you are extending this class (creating a subclass).
  # 
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  1.0.0
  # 
  # @see StyledTreeBuilder
  # @see Styler
  # @see Blueberry#psychgus_stylers
  ###
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
    
    # Initialize this class for sniffing.
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
    
    # Add a Psych::Nodes::Alias to this class only (not to the YAML).
    # 
    # A {Styler} should probably never call this.
    # 
    # @param node [Psych::Nodes::Alias] the alias to add
    def add_alias(node)
      add_child(node)
      @aliases.push(node)
    end
    
    # Add a Psych::Nodes::Scalar to this class only (not to the YAML).
    # 
    # A {Styler} should probably never call this.
    # 
    # @param node [Psych::Nodes::Scalar] the scalar to add
    def add_scalar(node)
      add_child(node)
      @scalars.push(node)
    end
    
    # End a Psych::Nodes::Mapping started with {#start_mapping}.
    # 
    # Pops off a parent from {#parents} and sets {#parent} to the last one.
    # {level} and {position} are reset according to the last parent.
    # 
    # A {Styler} should probably never call this.
    def end_mapping()
      end_parent()
      
      if !@parent.nil?() && !@parent.child_type.nil?()
        # add_child() will not be called again, so end the fake "parent" manually with a fake "value"
        end_mapping_value()
      end
    end
    
    # End a Psych::Nodes::Sequence started with {#start_sequence}.
    # 
    # Pops off a parent from {#parents} and sets {#parent} to the last one.
    # {level} and {position} are reset according to the last parent.
    # 
    # A {Styler} should probably never call this.
    def end_sequence()
      end_parent()
      
      if !@parent.nil?() && !@parent.child_type.nil?()
        # If a sequence is the value of a map's key, then this is necessary
        end_mapping_value()
      end
    end
    
    def start_mapping(node)
      start_parent(node,debug_tag: :map,child_type: :key)
      @mappings.push(node)
    end
    
    def start_sequence(node)
      start_parent(node,debug_tag: :seq)
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
      
      @parent.child_type = :key unless @parent.nil?()
    end
    
    def end_parent()
      @parents.pop()
      @parent = @parents.last
      
      @level -= 1
      
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
      
      start_parent(node,debug_tag: debug_tag,child_type: :value)
    end
    
    def start_parent(node,**extra)
      @parent = Parent.new(self,node,**extra)
      
      @parents.push(@parent)
      @nodes.push(node)
      
      @level += 1
      @position = 1
    end
  end
end
