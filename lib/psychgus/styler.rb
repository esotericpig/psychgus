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


require 'psychgus/super_sniffer'

module Psychgus
  module Styler
    ###
    # An empty {Styler} as a class.
    # 
    # @author Jonathan Bradley Whited (@esotericpig)
    # @since  1.0.0
    ###
    class Empty
      include Styler
    end
  end
  
  ###
  # Mix in (include) this module to make a class/module/etc. a styler for YAML.
  # 
  # Although it's unnecessary (because of Duck Typing), it's the recommended practice in case a new method is
  # added in the future, and also so you don't have to define methods that you don't use.
  # 
  # You can either use this as is (see example) or inside of a class (see {Blueberry}).
  # 
  # @example
  #   class MyStyler
  #     include Psychgus::Styler
  #     
  #     def style_sequence(sniffer,node)
  #       node.style = Psychgus::SEQUENCE_FLOW if sniffer.level == 3
  #     end
  #   end
  #   
  #   hash = {'Coffee'=>{
  #             'Roast'=>['Light','Medium','Dark','Extra Dark'],
  #             'Style'=>['Cappuccino','Espresso','Latte','Mocha']
  #          }}
  #   puts hash.to_yaml(stylers: MyStyler.new())
  #   
  #   # Output:
  #   # ---
  #   # Coffee:
  #   #   Roast: [Light, Medium, Dark, Extra Dark]
  #   #   Style: [Cappuccino, Espresso, Latte, Mocha]
  # 
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  1.0.0
  # 
  # @see Psychgus
  # @see Ext::ObjectExt#to_yaml
  # @see Blueberry
  # @see StyledTreeBuilder#initialize
  # @see StyledDocumentStream#initialize
  # @see Ext::YAMLTreeExt#accept
  ###
  module Styler
    EMPTY = Empty.new().freeze()
    
    # Style a node of any type.
    # 
    # You can use {Ext::NodeExt#node_of?} to determine its type:
    #   puts node.value if node.node_of?(:scalar)
    # 
    # @param sniffer [SuperSniffer] passed in from {StyledTreeBuilder}
    # @param node [Psych::Nodes::Node] passed in from {StyledTreeBuilder}
    # 
    # @see Ext::NodeExt#node_of?
    def style(sniffer,node) end
    
    # Style a node guaranteed to be of type Psych::Nodes::Alias, to avoid if statements.
    # 
    # @param sniffer [SuperSniffer] passed in from {StyledTreeBuilder}
    # @param node [Psych::Nodes::Alias] of type Alias passed in from {StyledTreeBuilder}
    def style_alias(sniffer,node) end
    
    # Style a node guaranteed to be of type Psych::Nodes::Mapping, to avoid if statements.
    # 
    # @param sniffer [SuperSniffer] passed in from {StyledTreeBuilder}
    # @param node [Psych::Nodes::Mapping] of type Mapping passed in from {StyledTreeBuilder}
    def style_mapping(sniffer,node) end
    
    # Style a node guaranteed to be of type Psych::Nodes::Scalar, to avoid if statements.
    # 
    # @param sniffer [SuperSniffer] passed in from {StyledTreeBuilder}
    # @param node [Psych::Nodes::Scalar] of type Scalar passed in from {StyledTreeBuilder}
    def style_scalar(sniffer,node) end
    
    # Style a node guaranteed to be of type Psych::Nodes::Sequence, to avoid if statements.
    # 
    # @param sniffer [SuperSniffer] passed in from {StyledTreeBuilder}
    # @param node [Psych::Nodes::Sequence] of type Sequence passed in from {StyledTreeBuilder}
    def style_sequence(sniffer,node) end
  end
end
