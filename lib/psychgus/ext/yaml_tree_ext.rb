# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'psych'
require 'rubygems/version'

require 'psychgus/styled_tree_builder'

module Psychgus
  module Ext
    PSYCHGUS_PSYCH_VERSION = Gem::Version.create(Psych::VERSION)
    PSYCHGUS_PSYCH_VERSION_5_1_2 = Gem::Version.create('5.1.2')

    ###
    # Extensions to Psych::Visitors::YAMLTree::Registrar.
    ###
    module RegistrarExt
      # Remove +target+ from this Registrar to prevent it becoming an alias.
      #
      # @param target [Object] the Object to remove from this Registrar
      def psychgus_unregister(target)
        if PSYCHGUS_PSYCH_VERSION < PSYCHGUS_PSYCH_VERSION_5_1_2
          return unless key?(target) && target.respond_to?(:object_id)

          @obj_to_node.delete(target.object_id)
        else # 5.1.2+
          return unless key?(target)

          @obj_to_node.delete(target)
        end
      end
    end

    ###
    # Extensions to Psych::Visitors::YAMLTree.
    ###
    module YAMLTreeExt
      # Accepts a new Object to convert to YAML.
      #
      # This is roughly the same place where Psych checks if +target+ responds to +:encode_with+.
      #
      # 1. Check if +@emitter+ is a {StyledTreeBuilder}.
      # 2. If #1 and +target+ is a {Blueberry}, get the {Styler}(s) from +target+ and add them to +@emitter+.
      # 3. If #1 and +@emitter.deref_aliases?+, prevent +target+ from becoming an alias.
      # 4. Call +super+ and store the result.
      # 5. If #2, remove the {Styler}(s) from +@emitter+.
      # 6. Return the result of +super+.
      #
      # @param target [Object] the Object to pass to super
      #
      # @return the result of super
      #
      # @see Psych::Visitors::YAMLTree
      # @see Blueberry
      # @see Blueberry#psychgus_stylers
      # @see Styler
      # @see StyledTreeBuilder
      def accept(target)
        styler_count = 0

        if @emitter.is_a?(StyledTreeBuilder)
          # Blueberry?
          if target.respond_to?(:psychgus_stylers)
            stylers = target.psychgus_stylers(@emitter.sniffer)
            stylers_old_len = @emitter.stylers.length

            @emitter.add_styler(*stylers)

            styler_count = @emitter.stylers.length - stylers_old_len
          end

          # Dereference aliases?
          @st.psychgus_unregister(target) if @emitter.deref_aliases?
        end

        result = super(target)

        # Check styler_count because @emitter may not be a StyledTreeBuilder and target may not be a Blueberry
        @emitter.pop_styler(styler_count) if styler_count > 0

        return result
      end
    end
  end
end

Psych::Visitors::YAMLTree.prepend(Psychgus::Ext::YAMLTreeExt)
Psych::Visitors::YAMLTree::Registrar.prepend(Psychgus::Ext::RegistrarExt)
