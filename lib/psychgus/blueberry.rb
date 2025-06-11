# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2017 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module Psychgus
  ###
  # This is the OOP way to style your classes/modules/etc.
  #
  # Even though it's unnecessary to mix in (include) this module, it's recommended because new methods may be
  # added in the future, so this pseudo-guarantees your class won't break in a new version.
  #
  # A complete example:
  #   require 'psychgus'
  #
  #   class MyClass
  #     include Psychgus::Blueberry
  #
  #     attr_reader :my_hash
  #
  #     def initialize()
  #       @my_hash = {key1: 'val1',key2: 'val2'}
  #     end
  #
  #     def psychgus_stylers(sniffer)
  #       return MyClassStyler.new(sniffer)
  #     end
  #   end
  #
  #   class MyClassStyler
  #     include Psychgus::Styler
  #
  #     def initialize(sniffer)
  #       @level = sniffer.level
  #     end
  #
  #     def style_mapping(sniffer,node)
  #       node.style = Psychgus::MAPPING_FLOW
  #
  #       relative_level = sniffer.level - @level
  #     end
  #   end
  #
  #   my_class = MyClass.new()
  #   puts my_class.to_yaml()
  #
  # Alternatively, MyClass could have been the {Blueberry} and the {Styler}, without the need for
  # MyClassStyler:
  #   class MyClass
  #     include Psychgus::Blueberry
  #     include Psychgus::Styler
  #
  #     # ...
  #
  #     def psychgus_stylers(sniffer)
  #       @level = sniffer.level # This will be included in the output of to_yaml()
  #
  #       return self
  #     end
  #
  #     def style_mapping(sniffer,node)
  #       # ...
  #     end
  #   end
  #
  # However, it's best to put the styling logic inside of a separate class (or inner class) away from the main
  # logic. This also prevents extra helper vars, like @level, from showing up in the output.
  #
  # After your class and its children have been processed, the styler(s) will be removed from the logic for
  # the next sibling object(s). Therefore, you can safely do class-specific checks on level, etc. without it
  # affecting the sibling object(s). See {Ext::YAMLTreeExt} and {Ext::YAMLTreeExt#accept} for details.
  #
  # "The Blueberry" is the name of Gus's car from the TV show Psych.
  #
  # @see Ext::YAMLTreeExt
  # @see Ext::YAMLTreeExt#accept
  ###
  module Blueberry
    # Duck Type this method to return the {Styler}(s) for your class/module/etc.
    #
    # @param _sniffer [SuperSniffer] passed in from {StyledTreeBuilder}; use this for storing the level,
    #                                position, etc. for styling your instance variables later relative to your
    #                                class/module/etc.
    #
    # @return [Styler,Array<Styler>,nil] {Styler}(s) for this class/module/etc.
    def psychgus_stylers(_sniffer)
      return nil
    end
  end
end
