#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

#--
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
#++


require 'minitest/autorun'

require 'psychgus'

# Changing the YAML/data will break tests
class PsychgusTester < Minitest::Test
  # If true, will...
  # - Run tests that create temp file(s).
  #   - I don't like creating temp file(s) every time I run tests (which is a lot).
  # 
  # To do this, execute:
  #   rake test_all
  TEST_ALL = (ENV['PSYCHGUS_TEST'].to_s().strip().casecmp('all') == 0)
  TEST_ALL_SKIP_MSG = %q(Execute "rake test_all" for this test)
  
  BURGERS_YAML = <<-EOY.freeze()
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
  EOY
  BURGERS_DATA = Psych.load(BURGERS_YAML).freeze()
  
  COURSES_YAML = <<-EOY.freeze()
Courses:
  COSC: [470,'Computer Science']
  MUSC: [340,'Music']
  ARTS: [250,'The Arts']
Schedule:
- {Course: COSC,Time: '08:00'}
- {Course: MUSC,Time: '10:30'}
- {Course: ARTS,Time: '15:10'}
- {Course: COSC,Time: '13:10'}
  EOY
  COURSES_DATA = Psych.load(COURSES_YAML).freeze()
  
  DOLPHINS_YAML = <<-EOY.freeze()
Dolphins:
  Common:     &com {Length: ~2.5m, Weight:  ~235kg}
  Bottlenose: &bot {Length:   ~4m, Weight:  ~300kg}
  Dusky:      &dus {Length: ~1.7m, Weight:   ~78kg}
  Orca:       &orc {Length:   ~7m, Weight: ~3600kg}
Popular:
  - *bot
  - *orc
  EOY
  DOLPHINS_DATA = Psych.load(DOLPHINS_YAML).freeze()
  
  # This is for "<<-" heredoc
  # - Purposely not using "<<~" (tilde) for older Ruby versions
  def self.lstrip_pipe(str)
    return str.gsub(/^\s*\|/,'')
  end
end
