#!/usr/bin/env ruby
# encoding: UTF-8

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


require 'psychgus_tester'

class EggCarton
  include Psychgus::Blueberry
  
  def initialize()
    @eggs = {
      :styles => ['omelette','BBQ eggs','hard-boiled eggs','soft_boiled eggs','fried@eggs'],
      :colors => ['brown','white',['blue','green']]
    }
  end
  
  def psychgus_stylers(sniffer)
    return Psychgus::FlowStyler.new(4)
  end
end

###
# @since 1.2.0
###
class StylersTest < PsychgusTester
  def setup()
    @egg_carton = EggCarton.new()
  end
  
  def test_capstyler()
    actual = @egg_carton.to_yaml(stylers: Psychgus::CapStyler.new(each_word: false))
    expected = <<-EOY
    |--- !ruby/object:EggCarton
    |Eggs:
    |  :styles: [Omelette, BBQ eggs, Hard-boiled eggs, Soft_boiled eggs, Fried@eggs]
    |  :colors: [Brown, White, [Blue, Green]]
    EOY
    
    assert_equal self.class.lstrip_pipe(expected),actual
    
    actual = @egg_carton.to_yaml(stylers: Psychgus::CapStyler.new(new_delim: '+',delim: /[\s_\-@]/))
    expected = <<-EOY
    |--- !ruby/object:EggCarton
    |Eggs:
    |  :styles: [Omelette, BBQ+Eggs, Hard+Boiled+Eggs, Soft+Boiled+Eggs, Fried+Eggs]
    |  :colors: [Brown, White, [Blue, Green]]
    EOY
    
    assert_equal self.class.lstrip_pipe(expected),actual
  end
  
  def test_nosymstyler()
    actual = @egg_carton.to_yaml(stylers: Psychgus::NoSymStyler.new())
    expected = <<-EOY
    |--- !ruby/object:EggCarton
    |eggs:
    |  Styles: [omelette, BBQ eggs, hard-boiled eggs, soft_boiled eggs, fried@eggs]
    |  Colors: [brown, white, [blue, green]]
    EOY
    
    assert_equal self.class.lstrip_pipe(expected),actual
  end
  
  def test_notagstyler()
    actual = @egg_carton.to_yaml(stylers: Psychgus::NoTagStyler.new())
    expected = <<-EOY
    |---
    |eggs:
    |  :styles: [omelette, BBQ eggs, hard-boiled eggs, soft_boiled eggs, fried@eggs]
    |  :colors: [brown, white, [blue, green]]
    EOY
    
    assert_equal self.class.lstrip_pipe(expected),actual
  end
end
