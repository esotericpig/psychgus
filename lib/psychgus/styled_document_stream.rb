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

require 'psych'

require 'psychgus/styled_tree_builder'

module Psychgus
  ###
  # Use this wherever Psych::Handlers::DocumentStream would have been used, to enable styling.
  # 
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  1.0.0
  # 
  # @see Psychgus.parse_stream Psychgus.parse_stream
  # @see Psych::Handlers::DocumentStream
  ###
  class StyledDocumentStream < StyledTreeBuilder
    # Initialize this class with {Styler}(s) and a block.
    # 
    # @param styler [Styler] {Styler}(s) to use for styling this DocumentStream
    # @param block [Proc] a block to call in {#end_document} to denote a new YAML document
    def initialize(*styler,&block)
      super(*styler)
      
      @block = block
    end
    
    # This mimics the behavior of Psych::Handlers::DocumentStream#end_document.
    # 
    # @see Psych::Handlers::DocumentStream#end_document
    def end_document(implicit_end=!streaming?())
      @last.implicit_end = implicit_end
      @block.call(pop)
    end
    
    # This mimics the behavior of Psych::Handlers::DocumentStream#start_document.
    # 
    # @see Psych::Handlers::DocumentStream#start_document
    def start_document(version,tag_directives,implicit)
      node = Psych::Nodes::Document.new(version,tag_directives,implicit)
      push(node)
    end
  end
end
