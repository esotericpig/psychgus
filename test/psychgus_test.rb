# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'test_helper'

require 'tempfile'

class PsychgusTest < Minitest::Test
  EXPECTED_BURGERS = <<-YAML
---
Burgers:
  Classic: {Sauce: [Ketchup, Mustard], Cheese: American, Bun: Sesame Seed}
  BBQ: {Sauce: Honey BBQ, Cheese: Cheddar, Bun: Kaiser}
  Fancy: {Sauce: Spicy Wasabi, Cheese: Smoked Gouda, Bun: Hawaiian}
Toppings:
- Mushrooms
- [Lettuce, Onions, Pickles, Tomatoes]
- [[Ketchup, Mustard], [Salt, Pepper]]
  YAML

  def setup
    @flow_styler = FlowStyler.new
  end

  def test_alias
    expected = TestHelper.lstrip_pipe(<<-YAML)
    |---
    |Dolphins:
    |  Common: {Length: "~2.5m", Weight: "~235kg"}
    |  Bottlenose: {Length: "~4m", Weight: "~300kg"}
    |  Dusky: {Length: "~1.7m", Weight: "~78kg"}
    |  Orca: {Length: "~7m", Weight: "~3600kg"}
    |Popular:
    |- {Length: "~4m", Weight: "~300kg"}
    |- {Length: "~7m", Weight: "~3600kg"}
    YAML

    assert_equal expected,TestHelper::DOLPHINS_DATA.to_yaml(deref_aliases: true,stylers: @flow_styler)
  end

  def test_dump
    assert_equal EXPECTED_BURGERS,Psychgus.dump(TestHelper::BURGERS_DATA,stylers: @flow_styler)
    assert_equal EXPECTED_BURGERS,Psychgus.dump_stream(TestHelper::BURGERS_DATA,stylers: @flow_styler)
    assert_equal EXPECTED_BURGERS,TestHelper::BURGERS_DATA.to_yaml(stylers: @flow_styler)
  end

  def test_file
    Tempfile.create(['Psychgus','.yaml']) do |file|
      # puts "Testing #{self.class.name} w/ temp file: #{file.path}"

      Psychgus.dump_file(
        file,TestHelper::BURGERS_DATA,
        mode: File::CREAT | File::RDWR,
        opt: {textmode: true},
        # perm: 644, # Unix only
        stylers: @flow_styler,
      )

      file.rewind

      lines = file.readlines.join
      assert_equal EXPECTED_BURGERS,lines

      file.rewind
      file.close

      data = Psych.load_file(file)
      refute_equal false,data
      refute_nil data

      data = Psychgus.parse_file(file)
      refute_equal false,data
      refute_nil data
    end
  end

  def test_indent
    # Indent of 3 spaces, like a crazy person.
    expected = TestHelper.lstrip_pipe(<<-YAML)
    |---
    |Burgers:
    |   Classic: {Sauce: [Ketchup, Mustard], Cheese: American, Bun: Sesame Seed}
    |   BBQ: {Sauce: Honey BBQ, Cheese: Cheddar, Bun: Kaiser}
    |   Fancy: {Sauce: Spicy Wasabi, Cheese: Smoked Gouda, Bun: Hawaiian}
    |Toppings:
    |- Mushrooms
    |- [Lettuce, Onions, Pickles, Tomatoes]
    |- [[Ketchup, Mustard], [Salt, Pepper]]
    YAML

    # rubocop:disable Style/HashSyntax
    assert_equal expected,TestHelper::BURGERS_DATA.to_yaml(indent: 3,stylers: @flow_styler)
    assert_equal expected,TestHelper::BURGERS_DATA.to_yaml(**{:indent => 3,:stylers => @flow_styler})
    assert_equal expected,TestHelper::BURGERS_DATA.to_yaml(indentation: 3,stylers: @flow_styler)
    assert_equal expected,TestHelper::BURGERS_DATA.to_yaml(**{:indentation => 3,:stylers => @flow_styler})
    # rubocop:enable all
  end

  def test_node_consts
    assert_equal Psych::Nodes::Mapping::ANY,Psychgus::MAPPING_ANY
    assert_equal Psych::Nodes::Mapping::BLOCK,Psychgus::MAPPING_BLOCK
    assert_equal Psych::Nodes::Mapping::FLOW,Psychgus::MAPPING_FLOW

    assert_equal Psych::Nodes::Scalar::ANY,Psychgus::SCALAR_ANY
    assert_equal Psych::Nodes::Scalar::PLAIN,Psychgus::SCALAR_PLAIN
    assert_equal Psych::Nodes::Scalar::SINGLE_QUOTED,Psychgus::SCALAR_SINGLE_QUOTED
    assert_equal Psych::Nodes::Scalar::DOUBLE_QUOTED,Psychgus::SCALAR_DOUBLE_QUOTED
    assert_equal Psych::Nodes::Scalar::LITERAL,Psychgus::SCALAR_LITERAL
    assert_equal Psych::Nodes::Scalar::FOLDED,Psychgus::SCALAR_FOLDED

    assert_equal Psych::Nodes::Sequence::ANY,Psychgus::SEQUENCE_ANY
    assert_equal Psych::Nodes::Sequence::BLOCK,Psychgus::SEQUENCE_BLOCK
    assert_equal Psych::Nodes::Sequence::FLOW,Psychgus::SEQUENCE_FLOW

    assert_equal Psych::Nodes::Stream::ANY,Psychgus::STREAM_ANY
    assert_equal Psych::Nodes::Stream::UTF8,Psychgus::STREAM_UTF8
    assert_equal Psych::Nodes::Stream::UTF16LE,Psychgus::STREAM_UTF16LE
    assert_equal Psych::Nodes::Stream::UTF16BE,Psychgus::STREAM_UTF16BE
  end

  def test_parse
    parser = Psychgus.parser(stylers: @flow_styler)
    parser.parse(TestHelper::BURGERS_YAML)
    yaml = "---\n#{parser.handler.root.to_yaml}"
    assert_equal EXPECTED_BURGERS,yaml

    node = Psychgus.parse(TestHelper::BURGERS_YAML,stylers: @flow_styler)
    refute_equal false,node

    yaml = Psychgus.parse_stream(TestHelper::BURGERS_YAML,stylers: @flow_styler).to_yaml
    yaml = "---\n#{yaml}"
    assert_equal EXPECTED_BURGERS,yaml
  end
end

class FlowStyler
  include Psychgus::Styler

  def style_mapping(sniffer,node)
    node.style = Psychgus::MAPPING_FLOW if sniffer.level >= 4
  end

  def style_sequence(sniffer,node)
    node.style = Psychgus::SEQUENCE_FLOW if sniffer.level >= 4
  end
end
