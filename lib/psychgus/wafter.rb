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

require 'psychgus/shooer'
require 'psychgus/sniffer'

module Psychgus
  class Wafter
    attr_accessor :shooer
    attr_accessor :sniffer
    
    def initialize(sniffer=Sniffer.new(),shooer=Shooer.new())
      set(sniffer,shooer)
    end
    
    def waft(node)
      @shooer.shoo(node) if (odorful = @sniffer.sniff(node))
      return odorful
    end
    
    def set(sniffer=Sniffer.new(),shooer=Shooer.new())
      self.sniffer = sniffer
      
      if shooer.nil?()
        @shooer = Shooer.new(@sniffer.odors.clone())
      else
        self.shooer = shooer
      end
    end
    
    def shooer=(value)
      if !value.is_a?(Shooer)
        if value.is_a?(Sniffer)
          value = Shooer.new(value.odors.clone())
        elsif value.is_a?(Hash)
          value = Shooer.new(value) 
        end
      end
      return @shooer = value
    end
    
    def sniffer=(value)
      value = Sniffer.new(value) if value.is_a?(Hash)
      return @sniffer = value
    end
  end
end
