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

require 'psychgus/styler'
require 'psychgus/super_sniffer'

module Psychgus
  class StyledTreeBuilder < Psych::TreeBuilder
    attr_accessor :sniffer
    attr_reader :styler
    
    def initialize(styler=Styler::EMPTY)
      super()
      
      @sniffer = (styler == Styler::EMPTY) ? SuperSniffer::EMPTY : SuperSniffer.new()
      @styler = styler
    end
    
    def alias(*)
      node = super
      
      @styler.style(sniffer,node)
      @styler.style_alias(sniffer,node)
      @sniffer.add_alias(node)
      
      return node
    end
    
    def end_mapping(*)
      super
      @sniffer.end_mapping()
    end
    
    def end_sequence(*)
      super
      @sniffer.end_sequence()
    end
    
    def scalar(*)
      node = super
      
      @styler.style(sniffer,node)
      @styler.style_scalar(sniffer,node)
      @sniffer.add_scalar(node)
      
      return node
    end
    
    def start_mapping(*)
      node = super
      
      @styler.style(sniffer,node)
      @styler.style_mapping(sniffer,node)
      @sniffer.start_mapping(node)
      
      return node
    end
    
    def start_sequence(*)
      node = super
      
      @styler.style(sniffer,node)
      @styler.style_sequence(sniffer,node)
      @sniffer.start_sequence(node)
      
      return node
    end
    
    def styler=(styler)
      @sniffer = SuperSniffer.new() if styler != Styler::EMPTY && @sniffer == SuperSniffer::EMPTY
      @styler = styler
      
      return @styler
    end
  end
end
