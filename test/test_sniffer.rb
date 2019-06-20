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

require 'psychgus_test'
require 'stringio'

class IOStyler
  include Psychgus::Styler
  
  attr_reader :io
  
  def initialize(io=StringIO.new())
    @io = io
  end
  
  def style(sniffer,node)
    return if sniffer.parent.nil?()
    
    (1...sniffer.level).each do
      @io.print ' '
    end
    
    name = node.node_of?(:scalar) ? node.value : node.class.name
    
    @io.print "(#{sniffer.level}:#{sniffer.position}):#{name}"
    @io.puts " - #{sniffer.parent}"
  end
end

class SnifferTest < Minitest::Test
  def setup()
    @io_styler = IOStyler.new()
  end
  
  def test_sniffer()
    expected_out = <<-EOS
    |(1:1):Burgers - <map:(1:1):key:(:1)>
    | (2:1):Psych::Nodes::Mapping - <Burgers:(1:1):value:(:1)>
    | (2:1):Classic - <map:(2:1):key:(:1)>
    |  (3:1):Psych::Nodes::Mapping - <Classic:(2:1):value:(:1)>
    |  (3:1):Sauce - <map:(3:1):key:(:1)>
    |   (4:1):Psych::Nodes::Sequence - <Sauce:(3:1):value:(:1)>
    |    (5:1):Ketchup - <seq:(4:1)::(:1)>
    |    (5:2):Mustard - <seq:(4:1)::(:2)>
    |  (3:2):Cheese - <map:(3:1):key:(:2)>
    |   (4:1):American - <Cheese:(3:2):value:(:1)>
    |  (3:3):Bun - <map:(3:1):key:(:3)>
    |   (4:1):Sesame Seed - <Bun:(3:3):value:(:1)>
    | (2:2):BBQ - <map:(2:1):key:(:2)>
    |  (3:1):Psych::Nodes::Mapping - <BBQ:(2:2):value:(:1)>
    |  (3:1):Sauce - <map:(3:1):key:(:1)>
    |   (4:1):Honey BBQ - <Sauce:(3:1):value:(:1)>
    |  (3:2):Cheese - <map:(3:1):key:(:2)>
    |   (4:1):Cheddar - <Cheese:(3:2):value:(:1)>
    |  (3:3):Bun - <map:(3:1):key:(:3)>
    |   (4:1):Kaiser - <Bun:(3:3):value:(:1)>
    | (2:3):Fancy - <map:(2:1):key:(:3)>
    |  (3:1):Psych::Nodes::Mapping - <Fancy:(2:3):value:(:1)>
    |  (3:1):Sauce - <map:(3:1):key:(:1)>
    |   (4:1):Spicy Wasabi - <Sauce:(3:1):value:(:1)>
    |  (3:2):Cheese - <map:(3:1):key:(:2)>
    |   (4:1):Smoked Gouda - <Cheese:(3:2):value:(:1)>
    |  (3:3):Bun - <map:(3:1):key:(:3)>
    |   (4:1):Hawaiian - <Bun:(3:3):value:(:1)>
    |(1:2):Toppings - <map:(1:1):key:(:2)>
    | (2:1):Psych::Nodes::Sequence - <Toppings:(1:2):value:(:1)>
    |  (3:1):Mushrooms - <seq:(2:1)::(:1)>
    |  (3:2):Psych::Nodes::Sequence - <seq:(2:1)::(:2)>
    |   (4:1):Lettuce - <seq:(3:2)::(:1)>
    |   (4:2):Onions - <seq:(3:2)::(:2)>
    |   (4:3):Pickles - <seq:(3:2)::(:3)>
    |   (4:4):Tomatoes - <seq:(3:2)::(:4)>
    |  (3:3):Psych::Nodes::Sequence - <seq:(2:1)::(:3)>
    |   (4:1):Psych::Nodes::Sequence - <seq:(3:3)::(:1)>
    |    (5:1):Ketchup - <seq:(4:1)::(:1)>
    |    (5:2):Mustard - <seq:(4:1)::(:2)>
    |   (4:2):Psych::Nodes::Sequence - <seq:(3:3)::(:2)>
    |    (5:1):Salt - <seq:(4:2)::(:1)>
    |    (5:2):Pepper - <seq:(4:2)::(:2)>
    EOS
    expected_out = PsychgusTest.lstrip_pipe(expected_out)
    
    PsychgusTest::BASE_DATA.to_yaml(stylers: @io_styler)
    assert_equal expected_out,@io_styler.io.string
  end
end
