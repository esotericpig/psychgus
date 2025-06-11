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

describe Psychgus do
  before do
    @expected_burgers = <<~YAML
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

    @flow_styler = FlowStyler.new.freeze
  end

  it 'should deref aliases' do
    _(TestHelper::DOLPHINS_DATA.to_yaml(deref_aliases: true,stylers: @flow_styler)).must_equal(<<~YAML)
      ---
      Dolphins:
        Common: {Length: "~2.5m", Weight: "~235kg"}
        Bottlenose: {Length: "~4m", Weight: "~300kg"}
        Dusky: {Length: "~1.7m", Weight: "~78kg"}
        Orca: {Length: "~7m", Weight: "~3600kg"}
      Popular:
      - {Length: "~4m", Weight: "~300kg"}
      - {Length: "~7m", Weight: "~3600kg"}
    YAML
  end

  it 'should dump the YAML' do
    _(Psychgus.dump(TestHelper::BURGERS_DATA,stylers: @flow_styler)).must_equal(@expected_burgers)
    _(Psychgus.dump_stream(TestHelper::BURGERS_DATA,stylers: @flow_styler)).must_equal(@expected_burgers)
    _(TestHelper::BURGERS_DATA.to_yaml(stylers: @flow_styler)).must_equal(@expected_burgers)
  end

  it 'should dump the YAML to a file' do
    Tempfile.create(['Psychgus','.yaml'],encoding: 'UTF-8:UTF-8') do |file|
      # puts "Testing #{self.class.name} w/ temp file: #{file.path}"

      Psychgus.dump_file(
        file.path,TestHelper::BURGERS_DATA,
        mode: File::CREAT | File::RDWR,
        opt: {textmode: true},
        # perm: 644, # Unix only
        stylers: @flow_styler,
      )

      file.rewind
      lines = file.readlines.join

      _(lines).must_equal(@expected_burgers)

      file.rewind
      file.close
      data = Psych.load_file(file)

      _(data).wont_equal(false)
      _(data).wont_be_nil

      data = Psychgus.parse_file(file)

      _(data).wont_equal(false)
      _(data).wont_be_nil
    end
  end

  it 'should honor the indent' do
    # Indent of 3 spaces, like a crazy person.
    expected = <<~YAML
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

    # rubocop:disable Style/HashSyntax
    _(TestHelper::BURGERS_DATA.to_yaml(indent: 3,stylers: @flow_styler)).must_equal(expected)
    _(TestHelper::BURGERS_DATA.to_yaml(**{:indent => 3,:stylers => @flow_styler})).must_equal(expected)
    _(TestHelper::BURGERS_DATA.to_yaml(indentation: 3,stylers: @flow_styler)).must_equal(expected)
    _(TestHelper::BURGERS_DATA.to_yaml(**{:indentation => 3,:stylers => @flow_styler})).must_equal(expected)
    # rubocop:enable all
  end

  it 'should have the Psych::Nodes consts' do
    _(Psychgus::MAPPING_ANY).must_equal(Psych::Nodes::Mapping::ANY)
    _(Psychgus::MAPPING_BLOCK).must_equal(Psych::Nodes::Mapping::BLOCK)
    _(Psychgus::MAPPING_FLOW).must_equal(Psych::Nodes::Mapping::FLOW)

    _(Psychgus::SCALAR_ANY).must_equal(Psych::Nodes::Scalar::ANY)
    _(Psychgus::SCALAR_PLAIN).must_equal(Psych::Nodes::Scalar::PLAIN)
    _(Psychgus::SCALAR_SINGLE_QUOTED).must_equal(Psych::Nodes::Scalar::SINGLE_QUOTED)
    _(Psychgus::SCALAR_DOUBLE_QUOTED).must_equal(Psych::Nodes::Scalar::DOUBLE_QUOTED)
    _(Psychgus::SCALAR_LITERAL).must_equal(Psych::Nodes::Scalar::LITERAL)
    _(Psychgus::SCALAR_FOLDED).must_equal(Psych::Nodes::Scalar::FOLDED)

    _(Psychgus::SEQUENCE_ANY).must_equal(Psych::Nodes::Sequence::ANY)
    _(Psychgus::SEQUENCE_BLOCK).must_equal(Psych::Nodes::Sequence::BLOCK)
    _(Psychgus::SEQUENCE_FLOW).must_equal(Psych::Nodes::Sequence::FLOW)

    _(Psychgus::STREAM_ANY).must_equal(Psych::Nodes::Stream::ANY)
    _(Psychgus::STREAM_UTF8).must_equal(Psych::Nodes::Stream::UTF8)
    _(Psychgus::STREAM_UTF16LE).must_equal(Psych::Nodes::Stream::UTF16LE)
    _(Psychgus::STREAM_UTF16BE).must_equal(Psych::Nodes::Stream::UTF16BE)
  end

  it 'should parse the YAML' do
    parser = Psychgus.parser(stylers: @flow_styler)
    parser.parse(TestHelper::BURGERS_YAML)
    yaml = "---\n#{parser.handler.root.to_yaml}"

    _(yaml).must_equal(@expected_burgers)

    node = Psychgus.parse(TestHelper::BURGERS_YAML,stylers: @flow_styler)

    _(node).wont_equal(false)

    yaml = Psychgus.parse_stream(TestHelper::BURGERS_YAML,stylers: @flow_styler).to_yaml
    yaml = "---\n#{yaml}"

    _(yaml).must_equal(@expected_burgers)
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
