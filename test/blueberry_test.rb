# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'test_helper'

class BlueberryTest < Minitest::Test
  def setup
    @burgers = Burgers.new
  end

  def test_blueberry
    expected = TestHelper.lstrip_pipe(<<-YAML)
    |--- !ruby/object:Burgers
    |Burgers:
    |  Classic:
    |    'Bun': 'Sesame Seed'
    |    'Cheese': 'American'
    |    'Sauce': ['Ketchup', 'Mustard']
    |  BBQ: {'Bun': 'Kaiser', 'Cheese': 'Cheddar', 'Sauce': 'Honey BBQ'}
    |  Fancy:
    |    'Bun': 'Hawaiian'
    |    'Cheese': 'Smoked Gouda'
    |    'Sauce': 'Spicy Wasabi'
    |Toppings:
    |- Mushrooms
    |- - Lettuce
    |  - Onions
    |  - Pickles
    |  - Tomatoes
    |- - - Ketchup
    |    - Mustard
    |  - - Salt
    |    - Pepper
    YAML

    assert_equal expected,@burgers.to_yaml
  end
end

class Burgers
  attr_accessor :burgers
  attr_accessor :toppings

  def initialize
    @burgers = {
      'Classic' => Burger.new(['Ketchup','Mustard'],'American','Sesame Seed'),
      'BBQ'     => Burger.new('Honey BBQ','Cheddar','Kaiser'),
      'Fancy'   => Burger.new('Spicy Wasabi','Smoked Gouda','Hawaiian'),
    }

    @toppings = [
      'Mushrooms',
      %w[Lettuce Onions Pickles Tomatoes],
      [%w[Ketchup Mustard],%w[Salt Pepper]],
    ]
  end

  def encode_with(coder)
    coder['Burgers'] = @burgers
    coder['Toppings'] = @toppings
  end
end

class BurgerStyler
  include Psychgus::Styler

  def initialize(sniffer)
    @level = sniffer.level
    @position = sniffer.position
  end

  def style(_sniffer,node)
    # Remove ugly and unsafe `!ruby/object:Burger`.
    node.tag = nil if node.respond_to?(:tag)
  end

  def style_mapping(sniffer,node)
    parent = sniffer.parent

    if !parent.nil? && parent.respond_to?(:value) && parent.value.casecmp('BBQ') == 0
      # BBQ.
      node.style = Psychgus::MAPPING_FLOW
    end
  end

  def style_scalar(_sniffer,node)
    # Only for Burgers.
    node.style = Psychgus::SCALAR_SINGLE_QUOTED
  end

  def style_sequence(sniffer,node)
    relative_level = (sniffer.level - @level) + 1

    # [Ketchup, Mustard].
    node.style = Psychgus::SEQUENCE_FLOW if relative_level == 3
  end
end

class Burger
  include Psychgus::Blueberry

  attr_accessor :bun
  attr_accessor :cheese
  attr_accessor :sauce

  def initialize(sauce,cheese,bun)
    @bun = bun
    @cheese = cheese
    @sauce = sauce
  end

  def encode_with(coder)
    coder['Bun'] = @bun
    coder['Cheese'] = @cheese
    coder['Sauce'] = @sauce
  end

  def psychgus_stylers(sniffer)
    return BurgerStyler.new(sniffer)
  end
end
