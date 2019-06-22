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

require 'psychgus_tester'

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

class Burgers
  attr_accessor :burgers
  attr_accessor :toppings
  
  def initialize()
    @burgers = {
      'Classic' => Burger.new(['Ketchup','Mustard'],'American','Sesame Seed'),
      'BBQ'     => Burger.new('Honey BBQ','Cheddar','Kaiser'),
      'Fancy'   => Burger.new('Spicy Wasabi','Smoked Gouda','Hawaiian')
    }
    
    @toppings = [
      'Mushrooms',
      %w(Lettuce Onions Pickles Tomatoes),
      [%w(Ketchup Mustard),%w(Salt Pepper)]
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
  
  def style(sniffer,node)
    # Remove ugly and unsafe "!ruby/object:Burger"
    node.tag = nil if node.respond_to?(:tag)
  end
  
  def style_mapping(sniffer,node)
    parent = sniffer.parent
    
    if !parent.nil?()
      # BBQ
      node.style = Psychgus::MAPPING_FLOW if parent.respond_to?(:value) && parent.value.casecmp('BBQ') == 0
    end
  end
  
  def style_scalar(sniffer,node)
    # Only for Burgers
    node.style = Psychgus::SCALAR_SINGLE_QUOTED
  end
  
  def style_sequence(sniffer,node)
    relative_level = (sniffer.level - @level) + 1
    
    # [Ketchup, Mustard]
    node.style = Psychgus::SEQUENCE_FLOW if relative_level == 3
  end
end

class BlueberryTest < Minitest::Test
  def setup()
    @burgers = Burgers.new()
  end
  
  def test_blueberry()
    expected_out = <<-EOS
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
    EOS
    expected_out = PsychgusTester.lstrip_pipe(expected_out)
    
    assert_equal expected_out,@burgers.to_yaml()
  end
end
