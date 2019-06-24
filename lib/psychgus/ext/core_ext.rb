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
  module Ext
    ###
    # Core extensions to Object.
    # 
    # @author Jonathan Bradley Whited (@esotericpig)
    # @since  1.0.0
    # 
    # @see https://github.com/ruby/psych/blob/master/lib/psych/core_ext.rb
    ###
    module ObjectExt
      # Convert an Object to YAML.
      # 
      # +options+ does not use keyword args in order to mimic Psych, so can be a drop-in-replacement.
      # 
      # @example
      #   class MyStyler
      #     include Psychgus::Styler
      #     
      #     def style_sequence(sniffer,node)
      #       node.style = Psychgus::SEQUENCE_FLOW
      #     end
      #   end
      #   
      #   my_obj = {
      #     :Foods => {
      #       :Fruits  => %w(Apple Banana Blueberry Pear),
      #       :Veggies => %w(Bean Carrot Celery Pea)
      #   }}
      #   
      #   puts my_obj.to_yaml({:indentation=>5},stylers: MyStyler.new)
      #   
      #   # Output:
      #   # ---
      #   # :Foods:
      #   #      :Fruits: [Apple, Banana, Blueberry, Pear]
      #   #      :Veggies: [Bean, Carrot, Celery, Pea]
      # 
      # @param options [Hash] the options to pass to {Psychgus.dump}
      # @param kargs [Hash] the keyword args to pass to {Psychgus.dump}
      # 
      # @return [String] the YAML generated from this Object
      # 
      # @see Psychgus.dump
      def to_yaml(options={},**kargs)
        # Do not use Psych.dump() if no Stylers, because a class might be a Blueberry
        return Psychgus.dump(self,options,**kargs)
      end
    end
  end
end

Object.prepend(Psychgus::Ext::ObjectExt)
