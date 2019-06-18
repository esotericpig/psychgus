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
    attr_reader :sniffer
    attr_reader :stylers
    
    def initialize(*stylers)
      super()
      
      @sniffer = SuperSniffer.new()
      @stylers = []
      
      if !stylers.nil?()
        if stylers.respond_to?(:each)
          stylers.each do |styler|
            @stylers.push(styler)
          end
        else
          @stylers.push(stylers)
        end
      end
    end
    
    def add_styler(styler)
      @stylers.push(styler)
      
      return self
    end
    
    def alias(*)
      node = super
      
      @stylers.each do |styler|
        styler.style(sniffer,node)
        styler.style_alias(sniffer,node)
      end
      
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
    
    def insert_styler(index,*styler)
      return @stylers.insert(index,*styler)
    end
    
    def pop_styler()
      return @stylers.pop()
    end
    
    def remove_styler(styler,&block)
      return @stylers.delete(styler,&block)
    end
    
    def remove_styler_at(index)
      return @stylers.delete_at(index)
    end
    
    def scalar(*)
      node = super
      
      @stylers.each do |styler|
        styler.style(sniffer,node)
        styler.style_scalar(sniffer,node)
      end
      
      @sniffer.add_scalar(node)
      
      return node
    end
    
    def start_mapping(*)
      node = super
      
      @stylers.each do |styler|
        styler.style(sniffer,node)
        styler.style_mapping(sniffer,node)
      end
      
      @sniffer.start_mapping(node)
      
      return node
    end
    
    def start_sequence(*)
      node = super
      
      @stylers.each do |styler|
        styler.style(sniffer,node)
        styler.style_sequence(sniffer,node)
      end
      
      @sniffer.start_sequence(node)
      
      return node
    end
  end
end
