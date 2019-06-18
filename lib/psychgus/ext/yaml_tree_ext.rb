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
  module YAMLTreeExt
    def accept(target)
      styled = @emitter.is_a?(StyledTreeBuilder) && target.respond_to?(:psychgus_styler)
      
      if styled
        styler = target.psychgus_styler(@emitter.sniffer)
        stylers_old_len = @emitter.stylers.length
        
        @emitter.add_styler(*styler)
        
        styled = @emitter.stylers.length > stylers_old_len
      end
      
      result = super(target)
      
      @emitter.pop_styler() if styled
      
      return result
    end
  end
end

Psych::Visitors::YAMLTree.prepend(Psychgus::YAMLTreeExt)