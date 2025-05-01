# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of Psychgus.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module Psychgus
  module Ext
    ###
    # Core extensions to Object.
    #
    # @see https://github.com/ruby/psych/blob/master/lib/psych/core_ext.rb
    ###
    module ObjectExt
      # Convert an Object to YAML.
      #
      # +options+ can also be a Hash, so can be a drop-in-replacement for Psych.
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
      #   puts my_obj.to_yaml(indentation: 5,stylers: MyStyler.new)
      #
      #   # Or, pass in a Hash:
      #   #puts my_obj.to_yaml({:indentation=>5,:stylers=>MyStyler.new})
      #
      #   # Output:
      #   # ---
      #   # :Foods:
      #   #      :Fruits: [Apple, Banana, Blueberry, Pear]
      #   #      :Veggies: [Bean, Carrot, Celery, Pea]
      #
      # @param options [Hash] the options (or keyword args) to pass to {Psychgus.dump}
      #
      # @return [String] the YAML generated from this Object
      #
      # @see Psychgus.dump
      def to_yaml(options = {})
        # NOTE: This method signature must use old-style `options={}` instead of `**options`!
        #       Because some Gems, like `Moneta`, depend on this.

        # Do not use Psych.dump() if no Stylers, because a class might be a Blueberry
        return Psychgus.dump(self,**options)
      end
    end
  end
end

Object.prepend(Psychgus::Ext::ObjectExt)
