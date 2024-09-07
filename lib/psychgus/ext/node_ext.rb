# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'psych'

module Psychgus
  module Ext
    ###
    # Extensions to Psych::Nodes::Node.
    ###
    module NodeExt
      # Check if this Node is of a certain type (Alias, Mapping, Scalar, Sequence, etc.).
      #
      # New versions of Psych have alias?(), mapping?(), etc., so this is for old versions.
      #
      # This is equivalent to the following (with less typing):
      #   node.is_a?(Psych::Nodes::Alias)
      #   node.is_a?(Psych::Nodes::Mapping)
      #   node.is_a?(Psych::Nodes::Scalar)
      #   node.is_a?(Psych::Nodes::Sequence)
      #
      # @example
      #   node.node_of?(:alias)
      #   node.node_of?(:mapping)
      #   node.node_of?(:scalar)
      #   node.node_of?(:sequence)
      #   node.node_of?(:alias,:mapping,:scalar,:sequence) # OR
      #   node.node_of?(:doc,:map,:seq) # OR
      #
      # @param names [Symbol,String] the type(s) to check using OR
      #
      # @return [true,false] true if this Node is one of the +names+ type, else false
      #
      # @see Psychgus.node_class
      def node_of?(*names)
        names.each do |name|
          return true if is_a?(Psychgus.node_class(name))
        end

        return false
      end
    end
  end
end

Psych::Nodes::Node.prepend(Psychgus::Ext::NodeExt)
