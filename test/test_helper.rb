# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'minitest/autorun'

require 'psychgus'

# NOTE: Changing the YAML/data will break tests.
module TestHelper
  BURGERS_YAML = <<~YAML
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
  YAML
  BURGERS_DATA = Psych.load(BURGERS_YAML).freeze

  COURSES_YAML = <<-YAML
    Courses:
      COSC: [470,'Computer Science']
      MUSC: [340,'Music']
      ARTS: [250,'The Arts']
    Schedule:
    - {Course: COSC,Time: '08:00'}
    - {Course: MUSC,Time: '10:30'}
    - {Course: ARTS,Time: '15:10'}
    - {Course: COSC,Time: '13:10'}
  YAML
  COURSES_DATA = Psych.load(COURSES_YAML).freeze

  DOLPHINS_YAML = <<~YAML
    Dolphins:
      Common:     &com {Length: ~2.5m, Weight:  ~235kg}
      Bottlenose: &bot {Length:   ~4m, Weight:  ~300kg}
      Dusky:      &dus {Length: ~1.7m, Weight:   ~78kg}
      Orca:       &orc {Length:   ~7m, Weight: ~3600kg}
    Popular:
      - *bot
      - *orc
  YAML
  # Psych v4+ uses safe_load() by default for load(),
  #   so use unsafe_load() to have aliases turned on.
  # Don't do 'aliases: true' because that doesn't exist
  #   in older versions of Psych.
  DOLPHINS_DATA = Psych.unsafe_load(DOLPHINS_YAML).freeze
end
