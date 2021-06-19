#!/usr/bin/env ruby
# encoding: UTF-8

#--
# This file is part of Psychgus.
# Copyright (c) 2019-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++


require 'psychgus/stylables'

module Psychgus
  ###
  # A collection of commonly-used {Styler} classes.
  #
  # @example
  #   require 'psychgus'
  #
  #   class EggCarton
  #     def initialize
  #       @eggs = {
  #         :styles => ['fried', 'scrambled', ['BBQ', 'ketchup & mustard']],
  #         :colors => ['brown', 'white', ['blue', 'green']]
  #       }
  #     end
  #   end
  #
  #   hierarchy = Psychgus::HierarchyStyler.new(io: $stdout)
  #
  #   puts EggCarton.new.to_yaml(stylers: [
  #     Psychgus::NoSymStyler.new,
  #     Psychgus::NoTagStyler.new,
  #     Psychgus::CapStyler.new,
  #     Psychgus::FlowStyler.new(4),
  #     hierarchy
  #   ])
  #
  #   # Output:
  #   # ---
  #   # Eggs:
  #   #   Styles: [Fried, Scrambled, [BBQ, Ketchup & Mustard]]
  #   #   Colors: [Brown, White, [Blue, Green]]
  #
  #   # (1:1):Psych::Nodes::Stream - <root:(0:0)>
  #   # (1:1):Psych::Nodes::Document - <stream:(1:1)>
  #   # (1:1):Psych::Nodes::Mapping - <doc:(1:1)>
  #   #  (2:1):Eggs - <map:(1:1)>
  #   #   (3:1):Psych::Nodes::Mapping - <Eggs:(2:1)>
  #   #    (4:1):Styles - <map:(3:1)>
  #   #     (5:1):Psych::Nodes::Sequence - <Styles:(4:1)>
  #   #      (6:1):Fried - <seq:(5:1)>
  #   #      (6:2):Scrambled - <seq:(5:1)>
  #   #      (6:3):Psych::Nodes::Sequence - <seq:(5:1)>
  #   #       (7:1):BBQ - <seq:(6:3)>
  #   #       (7:2):Ketchup & Mustard - <seq:(6:3)>
  #   #    (4:2):Colors - <map:(3:1)>
  #   #     (5:1):Psych::Nodes::Sequence - <Colors:(4:2)>
  #   #      (6:1):Brown - <seq:(5:1)>
  #   #      (6:2):White - <seq:(5:1)>
  #   #      (6:3):Psych::Nodes::Sequence - <seq:(5:1)>
  #   #       (7:1):Blue - <seq:(6:3)>
  #   #       (7:2):Green - <seq:(6:3)>
  #
  # @author Jonathan Bradley Whited
  # @since  1.2.0
  #
  # @see Stylables
  # @see Styler
  ###
  module Stylers
    ###
    # A Capitalizer for Scalars.
    #
    # @example
    #   require 'psychgus'
    #
    #   data = {
    #     'eggs' => [
    #       'omelette',
    #       'BBQ eggs',
    #       'hard-boiled eggs',
    #       'soft_boiled eggs',
    #       'fried@eggs'
    #   ]}
    #
    #   seq_flow = Psychgus::SeqFlowStyler.new
    #
    #   puts data.to_yaml(stylers: [Psychgus::CapStyler.new,seq_flow])
    #
    #   # Output:
    #   # ---
    #   # Eggs: [Omelette, BBQ Eggs, Hard-Boiled Eggs, Soft_Boiled Eggs, Fried@eggs]
    #
    #   puts data.to_yaml(stylers: [Psychgus::CapStyler.new(each_word: false),seq_flow])
    #
    #   # Output:
    #   # ---
    #   # Eggs: [Omelette, BBQ eggs, Hard-boiled eggs, Soft_boiled eggs, Fried@eggs]
    #
    #   puts data.to_yaml(stylers: [Psychgus::CapStyler.new(new_delim: '(o)'),seq_flow])
    #
    #   # Output:
    #   # ---
    #   # Eggs: [Omelette, BBQ(o)Eggs, Hard(o)Boiled(o)Eggs, Soft(o)Boiled(o)Eggs, Fried@eggs]
    #
    #   class Cappie
    #     include Psychgus::CapStylable
    #
    #     def cap_word(word)
    #       return 'bbq' if word.casecmp('BBQ') == 0
    #
    #       super(word)
    #     end
    #   end
    #
    #   puts data.to_yaml(stylers: [Cappie.new(new_delim: '*',delim: /[\s@]/),seq_flow])
    #
    #   # Output:
    #   # ---
    #   # Eggs: [Omelette, bbq*Eggs, Hard-boiled*Eggs, Soft_boiled*Eggs, Fried*Eggs]
    #
    # @see Stylables::CapStylable
    ###
    class CapStyler
      include Stylables::CapStylable
    end

    ###
    # A FLOW style changer for Mappings & Sequences.
    #
    # @example
    #   require 'psychgus'
    #
    #   data = {
    #     'Eggs' => {
    #       'Styles' => ['Fried', 'Scrambled', ['BBQ', 'Ketchup']],
    #       'Colors' => ['Brown', 'White', ['Blue', 'Green']]
    #   }}
    #
    #   puts data.to_yaml(stylers: Psychgus::FlowStyler.new)
    #
    #   # Output:
    #   # --- {Eggs: {Styles: [Fried, Scrambled, [BBQ, Ketchup]], Colors: [Brown, White, [Blue, Green]]}}
    #
    #   # >= level 4 (see Psychgus.hierarchy)
    #   puts data.to_yaml(stylers: Psychgus::FlowStyler.new(4))
    #
    #   # Output:
    #   # ---
    #   # Eggs:
    #   #   Styles: [Fried, Scrambled, [BBQ, Ketchup]]
    #   #   Colors: [Brown, White, [Blue, Green]]
    #
    #   # >= level 6 (see Psychgus.hierarchy)
    #   puts data.to_yaml(stylers: Psychgus::FlowStyler.new(6))
    #
    #   # Output:
    #   # ---
    #   # Eggs:
    #   #   Styles:
    #   #   - Fried
    #   #   - Scrambled
    #   #   - [BBQ, Ketchup]
    #   #   Colors:
    #   #   - Brown
    #   #   - White
    #   #   - [Blue, Green]
    #
    # @see Stylables::MapFlowStylable
    # @see Stylables::SeqFlowStylable
    ###
    class FlowStyler
      include Stylables::MapFlowStylable
      include Stylables::SeqFlowStylable
    end

    ###
    # A visual hierarchy writer of the levels.
    #
    # This is useful for determining the correct level/position when writing a {Styler}.
    #
    # The default IO is StringIO, but can specify a different one.
    #
    # See {Psychgus.hierarchy} for more details.
    #
    # @see Psychgus.hierarchy
    # @see Stylables::HierarchyStylable
    ###
    class HierarchyStyler
      include Stylables::HierarchyStylable
    end

    ###
    # A FLOW style changer for Mappings only.
    #
    # @see FlowStyler
    # @see Stylables::MapFlowStylable
    ###
    class MapFlowStyler
      include Stylables::MapFlowStylable
    end

    ###
    # A Symbol remover for Scalars.
    #
    # @example
    #   require 'psychgus'
    #
    #   data = {
    #     :eggs => {
    #       :styles => ['Fried', 'Scrambled', ['BBQ', 'Ketchup']],
    #       :colors => ['Brown', 'White', ['Blue', 'Green']]
    #   }}
    #
    #   flow = Psychgus::FlowStyler.new(4)
    #
    #   puts data.to_yaml(stylers: [Psychgus::NoSymStyler.new,flow])
    #
    #   # Output:
    #   # ---
    #   # Eggs:
    #   #   Styles: [Fried, Scrambled, [BBQ, Ketchup]]
    #   #   Colors: [Brown, White, [Blue, Green]]
    #
    #   puts data.to_yaml(stylers: [Psychgus::NoSymStyler.new(cap: false),flow])
    #
    #   # ---
    #   # eggs:
    #   #   styles: [Fried, Scrambled, [BBQ, Ketchup]]
    #   #   colors: [Brown, White, [Blue, Green]]
    #
    # @see Stylables::NoSymStylable
    ###
    class NoSymStyler
      include Stylables::NoSymStylable
    end

    ###
    # A Tag remover for classes.
    #
    # @example
    #   require 'psychgus'
    #
    #   class Eggs
    #     def initialize
    #       @styles = ['Fried', 'Scrambled', ['BBQ', 'Ketchup']]
    #       @colors = ['Brown', 'White', ['Blue', 'Green']]
    #     end
    #   end
    #
    #   class EggCarton
    #     include Psychgus::Blueberry
    #
    #     def initialize
    #       @eggs = Eggs.new
    #     end
    #
    #     def psychgus_stylers(sniffer)
    #       Psychgus::FlowStyler.new(4)
    #     end
    #   end
    #
    #   puts EggCarton.new.to_yaml
    #
    #   # Output:
    #   # --- !ruby/object:EggCarton
    #   # eggs: !ruby/object:Eggs
    #   #   styles: [Fried, Scrambled, [BBQ, Ketchup]]
    #   #   colors: [Brown, White, [Blue, Green]]
    #
    #   puts EggCarton.new.to_yaml(stylers: Psychgus::NoTagStyler.new)
    #
    #   # Output:
    #   # ---
    #   # eggs:
    #   #   styles: [Fried, Scrambled, [BBQ, Ketchup]]
    #   #   colors: [Brown, White, [Blue, Green]]
    #
    # @see Stylables::NoTagStylable
    ###
    class NoTagStyler
      include Stylables::NoTagStylable
    end

    ###
    # A FLOW style changer for Sequences only.
    #
    # @see FlowStyler
    # @see Stylables::SeqFlowStylable
    ###
    class SeqFlowStyler
      include Stylables::SeqFlowStylable
    end
  end
end
