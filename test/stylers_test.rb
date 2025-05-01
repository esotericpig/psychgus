# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'test_helper'

class StylersTest < Minitest::Test
  def setup
    @egg_carton = EggCarton.new
  end

  def test_capstyler
    actual = @egg_carton.to_yaml(stylers: Psychgus::CapStyler.new(each_word: false))
    expected = TestHelper.lstrip_pipe(<<-YAML)
    |--- !ruby/object:EggCarton
    |Eggs:
    |  :styles: [Omelette, BBQ eggs, Hard-boiled eggs, Soft_boiled eggs, Fried@eggs]
    |  :colors: [Brown, White, [Blue, Green]]
    YAML

    assert_equal expected,actual

    actual = @egg_carton.to_yaml(stylers: Psychgus::CapStyler.new(new_delim: '+',delim: /[\s_\-@]/))
    expected = TestHelper.lstrip_pipe(<<-YAML)
    |--- !ruby/object:EggCarton
    |Eggs:
    |  :styles: [Omelette, BBQ+Eggs, Hard+Boiled+Eggs, Soft+Boiled+Eggs, Fried+Eggs]
    |  :colors: [Brown, White, [Blue, Green]]
    YAML

    assert_equal expected,actual
  end

  def test_nosymstyler
    actual = @egg_carton.to_yaml(stylers: Psychgus::NoSymStyler.new)
    expected = TestHelper.lstrip_pipe(<<-YAML)
    |--- !ruby/object:EggCarton
    |eggs:
    |  Styles: [omelette, BBQ eggs, hard-boiled eggs, soft_boiled eggs, fried@eggs]
    |  Colors: [brown, white, [blue, green]]
    YAML

    assert_equal expected,actual
  end

  def test_notagstyler
    actual = @egg_carton.to_yaml(stylers: Psychgus::NoTagStyler.new)
    expected = TestHelper.lstrip_pipe(<<-YAML)
    |---
    |eggs:
    |  :styles: [omelette, BBQ eggs, hard-boiled eggs, soft_boiled eggs, fried@eggs]
    |  :colors: [brown, white, [blue, green]]
    YAML

    assert_equal expected,actual
  end
end

class EggCarton
  include Psychgus::Blueberry

  def initialize
    @eggs = {
      styles: ['omelette','BBQ eggs','hard-boiled eggs','soft_boiled eggs','fried@eggs'],
      colors: ['brown','white',['blue','green']],
    }
  end

  def psychgus_stylers(_sniffer)
    return Psychgus::FlowStyler.new(4)
  end
end
