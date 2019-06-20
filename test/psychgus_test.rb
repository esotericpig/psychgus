#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

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

require 'minitest/autorun'

require 'psychgus'

module PsychgusTest
  # Changing this will break tests
  BASE_YAML_STR = <<-EOS.freeze()
Burgers:
  Classic:
    Sauce:  [Ketchup,Mustard]
    Cheese: American
    Bun:    Sesame Seed
  BBQ:
    Sauce:  Honey BBQ
    Cheese: Cheddar
    Bun:    Kaiser
  Fancy:
    Sauce:  Spicy Wasabi
    Cheese: Smoked Gouda
    Bun:    Hawaiian
Toppings:
  - Mushrooms
  - [Lettuce, Onions, Pickles, Tomatoes]
  - [[Ketchup,Mustard], [Salt,Pepper]]
  EOS
  
  BASE_YAML = Psych.load(BASE_YAML_STR).freeze()
  
  # This is for "<<-" heredoc
  # - Purposely not using "<<~" (tilde) for older Ruby versions
  def self.lstrip_pipe(str)
    return str.gsub(/^\s*\|/,'')
  end
end
