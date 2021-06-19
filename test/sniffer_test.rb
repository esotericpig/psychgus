#!/usr/bin/env ruby
# encoding: UTF-8

#--
# This file is part of Psychgus.
# Copyright (c) 2019-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++


require 'psychgus_tester'

require 'stringio'

class SnifferTest < PsychgusTester
  def setup()
  end

  def assert_hierarchy(*data,expected)
    expected = self.class.lstrip_pipe(expected)
    hierarchy = Psychgus.hierarchy(*data,verbose: true)

    assert_equal expected,hierarchy
  end

  def test_multi_doc()
    assert_hierarchy(BURGERS_DATA,COURSES_DATA,DOLPHINS_DATA,<<-EOH
    |(1:1):Psych::Nodes::Stream - <root:(0:0)::(:1)>
    |(1:1):Psych::Nodes::Document - <stream:(1:1)::(:1)>
    |(1:1):Psych::Nodes::Mapping - <doc:(1:1)::(:1)>
    | (2:1):Burgers - <map:(1:1):key:(:1)>
    |  (3:1):Psych::Nodes::Mapping - <Burgers:(2:1):value:(:1)>
    |   (4:1):Classic - <map:(3:1):key:(:1)>
    |    (5:1):Psych::Nodes::Mapping - <Classic:(4:1):value:(:1)>
    |     (6:1):Sauce - <map:(5:1):key:(:1)>
    |      (7:1):Psych::Nodes::Sequence - <Sauce:(6:1):value:(:1)>
    |       (8:1):Ketchup - <seq:(7:1)::(:1)>
    |       (8:2):Mustard - <seq:(7:1)::(:2)>
    |     (6:2):Cheese - <map:(5:1):key:(:2)>
    |      (7:1):American - <Cheese:(6:2):value:(:1)>
    |     (6:3):Bun - <map:(5:1):key:(:3)>
    |      (7:1):Sesame Seed - <Bun:(6:3):value:(:1)>
    |   (4:2):BBQ - <map:(3:1):key:(:2)>
    |    (5:1):Psych::Nodes::Mapping - <BBQ:(4:2):value:(:1)>
    |     (6:1):Sauce - <map:(5:1):key:(:1)>
    |      (7:1):Honey BBQ - <Sauce:(6:1):value:(:1)>
    |     (6:2):Cheese - <map:(5:1):key:(:2)>
    |      (7:1):Cheddar - <Cheese:(6:2):value:(:1)>
    |     (6:3):Bun - <map:(5:1):key:(:3)>
    |      (7:1):Kaiser - <Bun:(6:3):value:(:1)>
    |   (4:3):Fancy - <map:(3:1):key:(:3)>
    |    (5:1):Psych::Nodes::Mapping - <Fancy:(4:3):value:(:1)>
    |     (6:1):Sauce - <map:(5:1):key:(:1)>
    |      (7:1):Spicy Wasabi - <Sauce:(6:1):value:(:1)>
    |     (6:2):Cheese - <map:(5:1):key:(:2)>
    |      (7:1):Smoked Gouda - <Cheese:(6:2):value:(:1)>
    |     (6:3):Bun - <map:(5:1):key:(:3)>
    |      (7:1):Hawaiian - <Bun:(6:3):value:(:1)>
    | (2:2):Toppings - <map:(1:1):key:(:2)>
    |  (3:1):Psych::Nodes::Sequence - <Toppings:(2:2):value:(:1)>
    |   (4:1):Mushrooms - <seq:(3:1)::(:1)>
    |   (4:2):Psych::Nodes::Sequence - <seq:(3:1)::(:2)>
    |    (5:1):Lettuce - <seq:(4:2)::(:1)>
    |    (5:2):Onions - <seq:(4:2)::(:2)>
    |    (5:3):Pickles - <seq:(4:2)::(:3)>
    |    (5:4):Tomatoes - <seq:(4:2)::(:4)>
    |   (4:3):Psych::Nodes::Sequence - <seq:(3:1)::(:3)>
    |    (5:1):Psych::Nodes::Sequence - <seq:(4:3)::(:1)>
    |     (6:1):Ketchup - <seq:(5:1)::(:1)>
    |     (6:2):Mustard - <seq:(5:1)::(:2)>
    |    (5:2):Psych::Nodes::Sequence - <seq:(4:3)::(:2)>
    |     (6:1):Salt - <seq:(5:2)::(:1)>
    |     (6:2):Pepper - <seq:(5:2)::(:2)>
    |(1:2):Psych::Nodes::Document - <stream:(1:1)::(:2)>
    |(1:2):Psych::Nodes::Mapping - <doc:(1:2)::(:1)>
    | (2:1):Courses - <map:(1:2):key:(:1)>
    |  (3:1):Psych::Nodes::Mapping - <Courses:(2:1):value:(:1)>
    |   (4:1):COSC - <map:(3:1):key:(:1)>
    |    (5:1):Psych::Nodes::Sequence - <COSC:(4:1):value:(:1)>
    |     (6:1):470 - <seq:(5:1)::(:1)>
    |     (6:2):Computer Science - <seq:(5:1)::(:2)>
    |   (4:2):MUSC - <map:(3:1):key:(:2)>
    |    (5:1):Psych::Nodes::Sequence - <MUSC:(4:2):value:(:1)>
    |     (6:1):340 - <seq:(5:1)::(:1)>
    |     (6:2):Music - <seq:(5:1)::(:2)>
    |   (4:3):ARTS - <map:(3:1):key:(:3)>
    |    (5:1):Psych::Nodes::Sequence - <ARTS:(4:3):value:(:1)>
    |     (6:1):250 - <seq:(5:1)::(:1)>
    |     (6:2):The Arts - <seq:(5:1)::(:2)>
    | (2:2):Schedule - <map:(1:2):key:(:2)>
    |  (3:1):Psych::Nodes::Sequence - <Schedule:(2:2):value:(:1)>
    |   (4:1):Psych::Nodes::Mapping - <seq:(3:1)::(:1)>
    |    (5:1):Course - <map:(4:1):key:(:1)>
    |     (6:1):COSC - <Course:(5:1):value:(:1)>
    |    (5:2):Time - <map:(4:1):key:(:2)>
    |     (6:1):08:00 - <Time:(5:2):value:(:1)>
    |   (4:2):Psych::Nodes::Mapping - <seq:(3:1)::(:2)>
    |    (5:1):Course - <map:(4:2):key:(:1)>
    |     (6:1):MUSC - <Course:(5:1):value:(:1)>
    |    (5:2):Time - <map:(4:2):key:(:2)>
    |     (6:1):10:30 - <Time:(5:2):value:(:1)>
    |   (4:3):Psych::Nodes::Mapping - <seq:(3:1)::(:3)>
    |    (5:1):Course - <map:(4:3):key:(:1)>
    |     (6:1):ARTS - <Course:(5:1):value:(:1)>
    |    (5:2):Time - <map:(4:3):key:(:2)>
    |     (6:1):15:10 - <Time:(5:2):value:(:1)>
    |   (4:4):Psych::Nodes::Mapping - <seq:(3:1)::(:4)>
    |    (5:1):Course - <map:(4:4):key:(:1)>
    |     (6:1):COSC - <Course:(5:1):value:(:1)>
    |    (5:2):Time - <map:(4:4):key:(:2)>
    |     (6:1):13:10 - <Time:(5:2):value:(:1)>
    |(1:3):Psych::Nodes::Document - <stream:(1:1)::(:3)>
    |(1:3):Psych::Nodes::Mapping - <doc:(1:3)::(:1)>
    | (2:1):Dolphins - <map:(1:3):key:(:1)>
    |  (3:1):Psych::Nodes::Mapping - <Dolphins:(2:1):value:(:1)>
    |   (4:1):Common - <map:(3:1):key:(:1)>
    |    (5:1):Psych::Nodes::Mapping - <Common:(4:1):value:(:1)>
    |     (6:1):Length - <map:(5:1):key:(:1)>
    |      (7:1):~2.5m - <Length:(6:1):value:(:1)>
    |     (6:2):Weight - <map:(5:1):key:(:2)>
    |      (7:1):~235kg - <Weight:(6:2):value:(:1)>
    |   (4:2):Bottlenose - <map:(3:1):key:(:2)>
    |    (5:1):Psych::Nodes::Mapping - <Bottlenose:(4:2):value:(:1)>
    |     (6:1):Length - <map:(5:1):key:(:1)>
    |      (7:1):~4m - <Length:(6:1):value:(:1)>
    |     (6:2):Weight - <map:(5:1):key:(:2)>
    |      (7:1):~300kg - <Weight:(6:2):value:(:1)>
    |   (4:3):Dusky - <map:(3:1):key:(:3)>
    |    (5:1):Psych::Nodes::Mapping - <Dusky:(4:3):value:(:1)>
    |     (6:1):Length - <map:(5:1):key:(:1)>
    |      (7:1):~1.7m - <Length:(6:1):value:(:1)>
    |     (6:2):Weight - <map:(5:1):key:(:2)>
    |      (7:1):~78kg - <Weight:(6:2):value:(:1)>
    |   (4:4):Orca - <map:(3:1):key:(:4)>
    |    (5:1):Psych::Nodes::Mapping - <Orca:(4:4):value:(:1)>
    |     (6:1):Length - <map:(5:1):key:(:1)>
    |      (7:1):~7m - <Length:(6:1):value:(:1)>
    |     (6:2):Weight - <map:(5:1):key:(:2)>
    |      (7:1):~3600kg - <Weight:(6:2):value:(:1)>
    | (2:2):Popular - <map:(1:3):key:(:2)>
    |  (3:1):Psych::Nodes::Sequence - <Popular:(2:2):value:(:1)>
    |   (4:1):Psych::Nodes::Alias - <seq:(3:1)::(:1)>
    |   (4:2):Psych::Nodes::Alias - <seq:(3:1)::(:2)>
    EOH
    )
  end

  def test_single_docs()
    assert_hierarchy(BURGERS_DATA,<<-EOH
    |(1:1):Psych::Nodes::Stream - <root:(0:0)::(:1)>
    |(1:1):Psych::Nodes::Document - <stream:(1:1)::(:1)>
    |(1:1):Psych::Nodes::Mapping - <doc:(1:1)::(:1)>
    | (2:1):Burgers - <map:(1:1):key:(:1)>
    |  (3:1):Psych::Nodes::Mapping - <Burgers:(2:1):value:(:1)>
    |   (4:1):Classic - <map:(3:1):key:(:1)>
    |    (5:1):Psych::Nodes::Mapping - <Classic:(4:1):value:(:1)>
    |     (6:1):Sauce - <map:(5:1):key:(:1)>
    |      (7:1):Psych::Nodes::Sequence - <Sauce:(6:1):value:(:1)>
    |       (8:1):Ketchup - <seq:(7:1)::(:1)>
    |       (8:2):Mustard - <seq:(7:1)::(:2)>
    |     (6:2):Cheese - <map:(5:1):key:(:2)>
    |      (7:1):American - <Cheese:(6:2):value:(:1)>
    |     (6:3):Bun - <map:(5:1):key:(:3)>
    |      (7:1):Sesame Seed - <Bun:(6:3):value:(:1)>
    |   (4:2):BBQ - <map:(3:1):key:(:2)>
    |    (5:1):Psych::Nodes::Mapping - <BBQ:(4:2):value:(:1)>
    |     (6:1):Sauce - <map:(5:1):key:(:1)>
    |      (7:1):Honey BBQ - <Sauce:(6:1):value:(:1)>
    |     (6:2):Cheese - <map:(5:1):key:(:2)>
    |      (7:1):Cheddar - <Cheese:(6:2):value:(:1)>
    |     (6:3):Bun - <map:(5:1):key:(:3)>
    |      (7:1):Kaiser - <Bun:(6:3):value:(:1)>
    |   (4:3):Fancy - <map:(3:1):key:(:3)>
    |    (5:1):Psych::Nodes::Mapping - <Fancy:(4:3):value:(:1)>
    |     (6:1):Sauce - <map:(5:1):key:(:1)>
    |      (7:1):Spicy Wasabi - <Sauce:(6:1):value:(:1)>
    |     (6:2):Cheese - <map:(5:1):key:(:2)>
    |      (7:1):Smoked Gouda - <Cheese:(6:2):value:(:1)>
    |     (6:3):Bun - <map:(5:1):key:(:3)>
    |      (7:1):Hawaiian - <Bun:(6:3):value:(:1)>
    | (2:2):Toppings - <map:(1:1):key:(:2)>
    |  (3:1):Psych::Nodes::Sequence - <Toppings:(2:2):value:(:1)>
    |   (4:1):Mushrooms - <seq:(3:1)::(:1)>
    |   (4:2):Psych::Nodes::Sequence - <seq:(3:1)::(:2)>
    |    (5:1):Lettuce - <seq:(4:2)::(:1)>
    |    (5:2):Onions - <seq:(4:2)::(:2)>
    |    (5:3):Pickles - <seq:(4:2)::(:3)>
    |    (5:4):Tomatoes - <seq:(4:2)::(:4)>
    |   (4:3):Psych::Nodes::Sequence - <seq:(3:1)::(:3)>
    |    (5:1):Psych::Nodes::Sequence - <seq:(4:3)::(:1)>
    |     (6:1):Ketchup - <seq:(5:1)::(:1)>
    |     (6:2):Mustard - <seq:(5:1)::(:2)>
    |    (5:2):Psych::Nodes::Sequence - <seq:(4:3)::(:2)>
    |     (6:1):Salt - <seq:(5:2)::(:1)>
    |     (6:2):Pepper - <seq:(5:2)::(:2)>
    EOH
    )

    assert_hierarchy(COURSES_DATA,<<-EOH
    |(1:1):Psych::Nodes::Stream - <root:(0:0)::(:1)>
    |(1:1):Psych::Nodes::Document - <stream:(1:1)::(:1)>
    |(1:1):Psych::Nodes::Mapping - <doc:(1:1)::(:1)>
    | (2:1):Courses - <map:(1:1):key:(:1)>
    |  (3:1):Psych::Nodes::Mapping - <Courses:(2:1):value:(:1)>
    |   (4:1):COSC - <map:(3:1):key:(:1)>
    |    (5:1):Psych::Nodes::Sequence - <COSC:(4:1):value:(:1)>
    |     (6:1):470 - <seq:(5:1)::(:1)>
    |     (6:2):Computer Science - <seq:(5:1)::(:2)>
    |   (4:2):MUSC - <map:(3:1):key:(:2)>
    |    (5:1):Psych::Nodes::Sequence - <MUSC:(4:2):value:(:1)>
    |     (6:1):340 - <seq:(5:1)::(:1)>
    |     (6:2):Music - <seq:(5:1)::(:2)>
    |   (4:3):ARTS - <map:(3:1):key:(:3)>
    |    (5:1):Psych::Nodes::Sequence - <ARTS:(4:3):value:(:1)>
    |     (6:1):250 - <seq:(5:1)::(:1)>
    |     (6:2):The Arts - <seq:(5:1)::(:2)>
    | (2:2):Schedule - <map:(1:1):key:(:2)>
    |  (3:1):Psych::Nodes::Sequence - <Schedule:(2:2):value:(:1)>
    |   (4:1):Psych::Nodes::Mapping - <seq:(3:1)::(:1)>
    |    (5:1):Course - <map:(4:1):key:(:1)>
    |     (6:1):COSC - <Course:(5:1):value:(:1)>
    |    (5:2):Time - <map:(4:1):key:(:2)>
    |     (6:1):08:00 - <Time:(5:2):value:(:1)>
    |   (4:2):Psych::Nodes::Mapping - <seq:(3:1)::(:2)>
    |    (5:1):Course - <map:(4:2):key:(:1)>
    |     (6:1):MUSC - <Course:(5:1):value:(:1)>
    |    (5:2):Time - <map:(4:2):key:(:2)>
    |     (6:1):10:30 - <Time:(5:2):value:(:1)>
    |   (4:3):Psych::Nodes::Mapping - <seq:(3:1)::(:3)>
    |    (5:1):Course - <map:(4:3):key:(:1)>
    |     (6:1):ARTS - <Course:(5:1):value:(:1)>
    |    (5:2):Time - <map:(4:3):key:(:2)>
    |     (6:1):15:10 - <Time:(5:2):value:(:1)>
    |   (4:4):Psych::Nodes::Mapping - <seq:(3:1)::(:4)>
    |    (5:1):Course - <map:(4:4):key:(:1)>
    |     (6:1):COSC - <Course:(5:1):value:(:1)>
    |    (5:2):Time - <map:(4:4):key:(:2)>
    |     (6:1):13:10 - <Time:(5:2):value:(:1)>
    EOH
    )
  end
end
