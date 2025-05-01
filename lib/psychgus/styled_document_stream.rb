# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'psych'

require 'psychgus/styled_tree_builder'

module Psychgus
  ###
  # Use this wherever Psych::Handlers::DocumentStream would have been used, to enable styling.
  #
  # @see Psychgus.parse_stream Psychgus.parse_stream
  # @see Psych::Handlers::DocumentStream
  ###
  class StyledDocumentStream < StyledTreeBuilder
    # Initialize this class with {Styler}(s) and a block.
    #
    # @param stylers [Styler] {Styler}(s) to use for styling this DocumentStream
    # @param deref_aliases [true,false] whether to dereference aliases; output the actual value
    #                                   instead of the alias
    # @param block [Proc] a block to call in {#end_document} to denote a new YAML document
    def initialize(*stylers,deref_aliases: false,**options,&block)
      super(*stylers,deref_aliases: deref_aliases,**options)

      @block = block
    end

    # This mimics the behavior of Psych::Handlers::DocumentStream#end_document.
    #
    # @see Psych::Handlers::DocumentStream#end_document
    def end_document(implicit_end = !streaming?)
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
