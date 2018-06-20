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

require 'bundler/setup'

require 'psych'

require 'psychgus/blueberry'
require 'psychgus/shooer'
require 'psychgus/sniffer'
require 'psychgus/unset'
require 'psychgus/version'
require 'psychgus/wafter'

module Psychgus
end

# TODO: put this in a test
if $0 == __FILE__
  y = <<-EOS
Class:
  Blue:
    Type:  EU
    Level: 2
  Green:
    Type:  BB
    Level: 1
Sched:
  - Class: Blue
    UL:    U1-L1
  - Class: Green
    UL:    U2-L2
EOS
end
