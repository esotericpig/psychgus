#!/usr/bin/env ruby
# encoding: UTF-8

#--
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
#++


require 'psych'

require 'psychgus/styled_tree_builder'

module Psychgus
  module Ext
    ###
    # Extensions to Psych::Visitors::YAMLTree::Registrar.
    # 
    # @author Jonathan Bradley Whited (@esotericpig)
    # @since  1.0.0
    ###
    module RegistrarExt
      # Remove +target+ from this Registrar to prevent it becoming an alias.
      # 
      # @param target [Object] the Object to remove from this Registrar
      def remove_alias(target)
        @obj_to_node.delete(target.object_id)
      end
    end
    
    ###
    # Extensions to Psych::Visitors::YAMLTree.
    # 
    # @author Jonathan Bradley Whited (@esotericpig)
    # @since  1.0.0
    ###
    module YAMLTreeExt
      # Accepts a new Object to convert to YAML.
      # 
      # This is roughly the same place where Psych checks if +target+ responds to +:encode_with+.
      # 
      # 1. Check if +@emitter+ is a {StyledTreeBuilder}.
      # 2. If #1 and +target+ is a {Blueberry}, get the {Styler}(s) from +target+ and add them to +@emitter+.
      # 3. If #1 and +@emitter.deref_aliases?+, prevent +target+ from becoming an alias.
      # 4. Call +super+ and store the result.
      # 5. If #2, remove the {Styler}(s) from +@emitter+.
      # 6. Return the result of +super+.
      # 
      # @param target [Object] the Object to pass to super
      # 
      # @return the result of super
      # 
      # @see Psych::Visitors::YAMLTree
      # @see Blueberry
      # @see Blueberry#psychgus_stylers
      # @see Styler
      # @see StyledTreeBuilder
      def accept(target)
        styler_count = 0
        
        if @emitter.is_a?(StyledTreeBuilder)
          # Blueberry?
          if target.respond_to?(:psychgus_stylers)
            stylers = target.psychgus_stylers(@emitter.sniffer)
            stylers_old_len = @emitter.stylers.length
            
            @emitter.add_styler(*stylers)
            
            styler_count = @emitter.stylers.length - stylers_old_len
          end
          
          # Dereference aliases?
          if @emitter.deref_aliases?()
            @st.remove_alias(target) if target.respond_to?(:object_id) && @st.key?(target)
          end
        end
        
        result = super(target)
        
        # Check styler_count because @emitter may not be a StyledTreeBuilder and target may not be a Blueberry
        @emitter.pop_styler(styler_count) if styler_count > 0
        
        return result
      end
    end
  end
end

Psych::Visitors::YAMLTree.prepend(Psychgus::Ext::YAMLTreeExt)
Psych::Visitors::YAMLTree::Registrar.prepend(Psychgus::Ext::RegistrarExt)
