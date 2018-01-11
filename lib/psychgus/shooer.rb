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

module Psychgus
  class Shooer < Sniffer
    # @param odors (see Sniffer) :level and :index cannot be changed
    def initialize(**odors)
      @odors = odors
    end
    
    def shoo(node)
      @odors.each() do |key,value|
        key_setter = "#{key.to_s()}="
        next unless node.respond_to?(key_setter)
        value = self.class.to_value(node,key,value)
        node.send(key_setter,value) unless value == Unset
      end
    end
  end
end
