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


require 'psych'

module Psychgus
  module Ext
    ###
    # Extensions to Psych::Nodes::Node.
    # 
    # @author Jonathan Bradley Whited (@esotericpig)
    # @since  1.0.0
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
      # 
      # @param name [Symbol,String] the type to check
      # 
      # @return [true,false] true if this Node is of type +name+, else false
      # 
      # @see Psychgus.node_class
      def node_of?(name)
        return is_a?(Psychgus.node_class(name))
      end
    end
  end
end

Psych::Nodes::Node.prepend(Psychgus::Ext::NodeExt)
