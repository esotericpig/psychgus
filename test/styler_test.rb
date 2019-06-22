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

class MyStyler
  include Psychgus::Styler
  
  def style(sniffer,node)
  end
  
  def style_alias(sniffer,node)
  end
  
  def style_mapping(sniffer,node)
    parent = sniffer.parent
    
    if !parent.nil?()
      # BBQ
      node.style = Psychgus::MAPPING_FLOW if parent.node_of?(:scalar) && parent.value.casecmp('BBQ') == 0
      
      # Fancy
      node.style = Psychgus::MAPPING_FLOW if parent.level == 4 && parent.position == 3
    end
  end
  
  def style_scalar(sniffer,node)
    node.style = Psychgus::SCALAR_SINGLE_QUOTED if node.value.casecmp('Mushrooms') == 0
    node.value = 'Spinach' if node.value.casecmp('Lettuce') == 0
  end
  
  def style_sequence(sniffer,node)
    node.style = Psychgus::SEQUENCE_FLOW if sniffer.level >= 3
    
    # Burgers=>Classic=>Sauce and Mushrooms
    node.style = Psychgus::SEQUENCE_BLOCK if sniffer.position == 1
  end
end

class StylerTest < Minitest::Test
  def setup()
    @styler = MyStyler.new()
  end
  
  def test_styler()
    expected_out = <<-EOS
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
    EOS
    expected_out = PsychgusTester.lstrip_pipe(expected_out)
    
    assert_equal expected_out,PsychgusTester::BURGERS_DATA.to_yaml(stylers: @styler)
  end
end
