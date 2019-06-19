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

module Psychgus
  module ObjectExt
    # Don't use keyword args for options so can be a drop-in-replacement for Psych
    def to_yaml(options={},**kargs)
      # Do not use Psych.dump() if no Stylers, because a class might be a Blueberry
      return Psychgus.dump(self,options,**kargs)
    end
  end
end

Object.prepend(Psychgus::ObjectExt)
