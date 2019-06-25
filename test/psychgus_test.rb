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

require 'tempfile'

class FlowStyler
  include Psychgus::Styler
  
  def style_mapping(sniffer,node)
    node.style = Psychgus::MAPPING_FLOW if sniffer.level >= 4
  end
  
  def style_sequence(sniffer,node)
    node.style = Psychgus::SEQUENCE_FLOW if sniffer.level >= 4
  end
end

class PsychgusTest < Minitest::Test
  def setup()
    @flow_styler = FlowStyler.new()
    @expected_out = <<-EOS
    |---
    |Burgers:
    |  Classic: {Sauce: [Ketchup, Mustard], Cheese: American, Bun: Sesame Seed}
    |  BBQ: {Sauce: Honey BBQ, Cheese: Cheddar, Bun: Kaiser}
    |  Fancy: {Sauce: Spicy Wasabi, Cheese: Smoked Gouda, Bun: Hawaiian}
    |Toppings:
    |- Mushrooms
    |- [Lettuce, Onions, Pickles, Tomatoes]
    |- [[Ketchup, Mustard], [Salt, Pepper]]
    EOS
    @expected_out = PsychgusTester.lstrip_pipe(@expected_out)
  end
  
  def test_dump()
    assert_equal @expected_out,Psychgus.dump(PsychgusTester::BURGERS_DATA,stylers: @flow_styler)
    assert_equal @expected_out,Psychgus.dump_stream(PsychgusTester::BURGERS_DATA,stylers: @flow_styler)
    assert_equal @expected_out,PsychgusTester::BURGERS_DATA.to_yaml(stylers: @flow_styler)
  end
  
  # Execute "rake test_all" if you update Psychgus.dump_file()/load_file()
  def test_file()
    if !PsychgusTester::TEST_ALL
      skip(PsychgusTester::TEST_ALL_SKIP_MSG)
      return # Justin Case
    end
    
    Tempfile.create(['Psychgus','.yaml']) do |file|
      puts "Testing #{self.class.name} w/ temp file: #{file.path}"
      
      Psychgus.dump_file(file,PsychgusTester::BURGERS_DATA,stylers: @flow_styler)
      
      file.rewind()
      lines = file.readlines().join()
      assert_equal @expected_out,lines
      
      file.rewind()
      data = Psych.load_file(file)
      refute_equal false,data
    end
  end
  
  def test_node_consts()
    assert_equal Psych::Nodes::Mapping::FLOW,Psychgus::MAPPING_FLOW
    assert_equal Psych::Nodes::Scalar::FOLDED,Psychgus::SCALAR_FOLDED
    assert_equal Psych::Nodes::Sequence::FLOW,Psychgus::SEQUENCE_FLOW
    assert_equal Psych::Nodes::Stream::UTF8,Psychgus::STREAM_UTF8
  end
  
  def test_parse()
    parser = Psychgus.parser(stylers: @flow_styler)
    parser.parse(PsychgusTester::BURGERS_YAML)
    yaml = "---\n" + parser.handler.root.to_yaml()
    assert_equal @expected_out,yaml
    
    node = Psychgus.parse(PsychgusTester::BURGERS_YAML,stylers: @flow_styler)
    refute_equal false,node
    
    yaml = Psychgus.parse_stream(PsychgusTester::BURGERS_YAML,stylers: @flow_styler).to_yaml()
    yaml = "---\n#{yaml}"
    assert_equal @expected_out,yaml
  end
end
