# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'test_helper'

class StylerTest < Minitest::Test
  def setup
    @styler = MyStyler.new
  end

  def test_styler
    expected = TestHelper.lstrip_pipe(<<-YAML)
    |---
    |Burgers:
    |  Classic:
    |    Sauce:
    |    - Ketchup
    |    - Mustard
    |    Cheese: American
    |    Bun: Sesame Seed
    |  BBQ: {Sauce: Honey BBQ, Cheese: Cheddar, Bun: Kaiser}
    |  Fancy: {Sauce: Spicy Wasabi, Cheese: Smoked Gouda, Bun: Hawaiian}
    |Toppings:
    |- 'Mushrooms'
    |- [Spinach, Onions, Pickles, Tomatoes]
    |- [[Ketchup, Mustard], [Salt, Pepper]]
    YAML

    assert_equal expected,TestHelper::BURGERS_DATA.to_yaml(stylers: @styler)
  end
end

class MyStyler
  include Psychgus::Styler

  def style(sniffer,node)
  end

  def style_alias(sniffer,node)
  end

  def style_mapping(sniffer,node)
    parent = sniffer.parent

    if !parent.nil?
      # BBQ.
      node.style = Psychgus::MAPPING_FLOW if parent.node_of?(:scalar) && parent.value.casecmp('BBQ') == 0

      # Fancy.
      node.style = Psychgus::MAPPING_FLOW if parent.level == 4 && parent.position == 3
    end
  end

  def style_scalar(_sniffer,node)
    node.style = Psychgus::SCALAR_SINGLE_QUOTED if node.value.casecmp('Mushrooms') == 0
    node.value = 'Spinach' if node.value.casecmp('Lettuce') == 0
  end

  def style_sequence(sniffer,node)
    node.style = Psychgus::SEQUENCE_FLOW if sniffer.level >= 3

    # Burgers => Classic => Sauce and Mushrooms.
    node.style = Psychgus::SEQUENCE_BLOCK if sniffer.position == 1
  end
end
