#!/usr/bin/env ruby

###
# This file is part of psychgus.
# Copyright (c) 2017-2018 Jonathan Bradley Whited (@esotericpig)
# 
# psychgus is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# psychgus is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with psychgus.  If not, see <http://www.gnu.org/licenses/>.
###

require 'psychgus/sniffer'
require 'psychgus/wafter'

module Psychgus
  class Blueberry
    attr_accessor :child
    attr_accessor :me
    attr_accessor :vars
    
    def initialize()
      @child = Wafter.new()
      @me = Wafter.new()
      @vars = {}
    end
    
    def child=(value)
      value = Wafter.new(value) if value.is_a?(Sniffer) || value.is_a?(Hash)
      return @child = value
    end
    
    def me=(value)
      value = Wafter.new(value) if value.is_a?(Sniffer) || value.is_a?(Hash)
      return @me = value
    end
  end
end
