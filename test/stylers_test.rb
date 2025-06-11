# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'test_helper'

describe Psychgus::Stylers do
  before do
    @egg_carton = EggCarton.new
  end

  it '::CapStyler should capitalize the words' do
    _(
      @egg_carton.to_yaml(stylers: Psychgus::CapStyler.new(each_word: false))
    ).must_equal(<<~YAML)
      --- !ruby/object:EggCarton
      Eggs:
        :styles: [Omelette, BBQ eggs, Hard-boiled eggs, Soft_boiled eggs, Fried@eggs]
        :colors: [Brown, White, [Blue, Green]]
    YAML

    _(
      @egg_carton.to_yaml(stylers: Psychgus::CapStyler.new(new_delim: '+',delim: /[\s_\-@]/))
    ).must_equal(<<~YAML)
      --- !ruby/object:EggCarton
      Eggs:
        :styles: [Omelette, BBQ+Eggs, Hard+Boiled+Eggs, Soft+Boiled+Eggs, Fried+Eggs]
        :colors: [Brown, White, [Blue, Green]]
    YAML
  end

  it '::NoSymStyler should convert the symbols to strings' do
    _(@egg_carton.to_yaml(stylers: Psychgus::NoSymStyler.new)).must_equal(<<~YAML)
      --- !ruby/object:EggCarton
      eggs:
        Styles: [omelette, BBQ eggs, hard-boiled eggs, soft_boiled eggs, fried@eggs]
        Colors: [brown, white, [blue, green]]
    YAML
  end

  it '::NoTagStyler should remove the tags' do
    _(@egg_carton.to_yaml(stylers: Psychgus::NoTagStyler.new)).must_equal(<<~YAML)
      ---
      eggs:
        :styles: [omelette, BBQ eggs, hard-boiled eggs, soft_boiled eggs, fried@eggs]
        :colors: [brown, white, [blue, green]]
    YAML
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
