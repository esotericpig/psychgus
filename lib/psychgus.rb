#!/usr/bin/env ruby
# encoding: UTF-8

#--
# This file is part of Psychgus.
# Copyright (c) 2017-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++


require 'psych'

require 'psychgus/blueberry'
require 'psychgus/ext'
require 'psychgus/stylables'
require 'psychgus/styled_document_stream'
require 'psychgus/styled_tree_builder'
require 'psychgus/styler'
require 'psychgus/stylers'
require 'psychgus/super_sniffer'
require 'psychgus/version'

require 'psychgus/ext/core_ext'
require 'psychgus/ext/node_ext'
require 'psychgus/ext/yaml_tree_ext'

require 'psychgus/super_sniffer/parent'

###
# Psychgus uses the core standard library {https://github.com/ruby/psych Psych} for working with YAML
# and extends it so that developers can easily style the YAML according to their needs.
# Thank you to the people that worked and continue to work hard on that project.
#
# The name comes from the well-styled character Gus from the TV show Psych.
#
# == Create a Styler
#
# First, we will create a {Styler}.
#
# All you need to do is add +include Psychgus::Styler+ to a class.
#
# Here is a complex {Styler} for the examples below:
#   require 'psychgus'
#
#   class BurgerStyler
#     # Mix in methods needed for styling
#     include Psychgus::Styler
#
#     def initialize(sniffer=nil)
#       if sniffer.nil?()
#         @class_level = 0
#         @class_position = 0
#       else
#         # For the Class Example
#         @class_level = sniffer.level
#         @class_position = sniffer.position
#       end
#     end
#
#     # Style all nodes (Psych::Nodes::Node)
#     def style(sniffer,node)
#       # Remove "!ruby/object:..." for classes
#       node.tag = nil if node.node_of?(:mapping,:scalar,:sequence)
#
#       # This is another way to do the above
#       #node.tag = nil if node.respond_to?(:tag=)
#     end
#
#     # Style aliases (Psych::Nodes::Alias)
#     def style_alias(sniffer,node)
#     end
#
#     # Style maps (Psych::Nodes::Mapping)
#     # - Hashes (key/value pairs)
#     # - Example: "Burgers: Classic {}"
#     def style_mapping(sniffer,node)
#       parent = sniffer.parent
#
#       if !parent.nil?()
#         # BBQ
#         node.style = Psychgus::MAPPING_FLOW if parent.node_of?(:scalar) &&
#                                                parent.value.casecmp('BBQ') == 0
#       end
#     end
#
#     # Style scalars (Psych::Nodes::Scalar)
#     # - Any text (non-alias)
#     def style_scalar(sniffer,node)
#       parent = sniffer.parent
#
#       # Single quote scalars that are not keys to a map
#       # - "child_key?" is the same as "child_type == :key"
#       node.style = Psychgus::SCALAR_SINGLE_QUOTED unless parent.child_key?()
#
#       # Remove colon (change symbols into strings)
#       node.value = node.value.sub(':','')
#
#       # Change lettuce to spinach
#       node.value = 'Spinach' if node.value.casecmp('Lettuce') == 0
#
#       # Capitalize each word
#       node.value = node.value.split(' ').map do |v|
#         if v.casecmp('BBQ') == 0
#           v.upcase()
#         else
#           v.capitalize()
#         end
#       end.join(' ')
#     end
#
#     # Style sequences (Psych::Nodes::Sequence)
#     # - Arrays
#     # - Example: "[Lettuce, Onions, Pickles, Tomatoes]"
#     def style_sequence(sniffer,node)
#       relative_level = (sniffer.level - @class_level) + 1
#
#       node.style = Psychgus::SEQUENCE_FLOW if sniffer.level >= 4
#
#       # Make "[Ketchup, Mustard]" a block for the Class Example
#       node.style = Psychgus::SEQUENCE_BLOCK if relative_level == 7
#     end
#   end
#
# @example Hash example
#   require 'psychgus'
#
#   burgers = {
#     :Burgers => {
#       :Classic => {
#         :Sauce  => %w(Ketchup Mustard),
#         :Cheese => 'American',
#         :Bun    => 'Sesame Seed'
#       },
#       :BBQ => {
#         :Sauce  => 'Honey BBQ',
#         :Cheese => 'Cheddar',
#         :Bun    => 'Kaiser'
#       },
#       :Fancy => {
#         :Sauce  => 'Spicy Wasabi',
#         :Cheese => 'Smoked Gouda',
#         :Bun    => 'Hawaiian'
#       }
#     },
#     :Toppings => [
#       'Mushrooms',
#       %w(Lettuce Onions Pickles Tomatoes),
#       [%w(Ketchup Mustard), %w(Salt Pepper)]
#     ]
#   }
#   burgers[:Favorite] = burgers[:Burgers][:BBQ] # Alias
#
#   puts burgers.to_yaml(indent: 3,stylers: BurgerStyler.new,deref_aliases: true)
#
#   # Output:
#   # ---
#   # Burgers:
#   #    Classic:
#   #       Sauce: ['Ketchup', 'Mustard']
#   #       Cheese: 'American'
#   #       Bun: 'Sesame Seed'
#   #    BBQ: {Sauce: 'Honey BBQ', Cheese: 'Cheddar', Bun: 'Kaiser'}
#   #    Fancy:
#   #       Sauce: 'Spicy Wasabi'
#   #       Cheese: 'Smoked Gouda'
#   #       Bun: 'Hawaiian'
#   # Toppings:
#   # - 'Mushrooms'
#   # - ['Spinach', 'Onions', 'Pickles', 'Tomatoes']
#   # - [['Ketchup', 'Mustard'], ['Salt', 'Pepper']]
#   # Favorite:
#   #    Sauce: 'Honey BBQ'
#   #    Cheese: 'Cheddar'
#   #    Bun: 'Kaiser'
#
# @example Class example
#   require 'psychgus'
#
#   class Burger
#     attr_accessor :bun
#     attr_accessor :cheese
#     attr_accessor :sauce
#
#     def initialize(sauce,cheese,bun)
#       @bun = bun
#       @cheese = cheese
#       @sauce = sauce
#     end
#
#     # You can still use Psych's encode_with(), no problem
#     #def encode_with(coder)
#     #  coder['Bun'] = @bun
#     #  coder['Cheese'] = @cheese
#     #  coder['Sauce'] = @sauce
#     #end
#   end
#
#   class Burgers
#     include Psychgus::Blueberry
#
#     attr_accessor :burgers
#     attr_accessor :toppings
#     attr_accessor :favorite
#
#     def initialize()
#       @burgers = {
#         'Classic' => Burger.new(['Ketchup','Mustard'],'American','Sesame Seed'),
#         'BBQ'     => Burger.new('Honey BBQ','Cheddar','Kaiser'),
#         'Fancy'   => Burger.new('Spicy Wasabi','Smoked Gouda','Hawaiian')
#       }
#
#       @toppings = [
#         'Mushrooms',
#         %w(Lettuce Onions Pickles Tomatoes),
#         [%w(Ketchup Mustard),%w(Salt Pepper)]
#       ]
#
#       @favorite = @burgers['BBQ'] # Alias
#     end
#
#     def psychgus_stylers(sniffer)
#       return BurgerStyler.new(sniffer)
#     end
#
#     # You can still use Psych's encode_with(), no problem
#     #def encode_with(coder)
#     #  coder['Burgers'] = @burgers
#     #  coder['Toppings'] = @toppings
#     #  coder['Favorite'] = @favorite
#     #end
#   end
#
#   burgers = Burgers.new
#   puts burgers.to_yaml(indent: 3,deref_aliases: true)
#
#   # Output:
#   # ---
#   # Burgers:
#   #    Classic:
#   #       Bun: 'Sesame Seed'
#   #       Cheese: 'American'
#   #       Sauce:
#   #       - 'Ketchup'
#   #       - 'Mustard'
#   #    BBQ: {Bun: 'Kaiser', Cheese: 'Cheddar', Sauce: 'Honey BBQ'}
#   #    Fancy:
#   #       Bun: 'Hawaiian'
#   #       Cheese: 'Smoked Gouda'
#   #       Sauce: 'Spicy Wasabi'
#   # Toppings:
#   # - 'Mushrooms'
#   # - ['Spinach', 'Onions', 'Pickles', 'Tomatoes']
#   # - [['Ketchup', 'Mustard'], ['Salt', 'Pepper']]
#   # Favorite:
#   #    Bun: 'Kaiser'
#   #    Cheese: 'Cheddar'
#   #    Sauce: 'Honey BBQ'
#
# @example Emitting / Parsing examples
#   styler = BurgerStyler.new()
#   options = {:indentation=>3,:stylers=>styler,:deref_aliases=>true}
#   yaml = burgers.to_yaml(options)
#
#   # High-level emitting
#   Psychgus.dump(burgers,options)
#   Psychgus.dump_file('burgers.yaml',burgers,options)
#   burgers.to_yaml(options)
#
#   # High-level parsing
#   # - Because to_ruby() will be called, just use Psych:
#   #   - load(), load_file(), load_stream(), safe_load()
#
#   # Mid-level emitting
#   stream = Psychgus.parse_stream(yaml,stylers: styler,deref_aliases: true)
#
#   stream.to_yaml()
#
#   # Mid-level parsing
#   Psychgus.parse(yaml,stylers: styler,deref_aliases: true)
#   Psychgus.parse_file('burgers.yaml',stylers: styler,deref_aliases: true)
#   Psychgus.parse_stream(yaml,stylers: styler,deref_aliases: true)
#
#   # Low-level emitting
#   tree_builder = Psychgus::StyledTreeBuilder.new(styler,deref_aliases: true)
#   visitor = Psych::Visitors::YAMLTree.create(options,tree_builder)
#
#   visitor << burgers
#   visitor.tree.to_yaml
#
#   # Low-level parsing
#   parser = Psychgus.parser(stylers: styler,deref_aliases: true)
#
#   parser.parse(yaml)
#   parser.handler
#   parser.handler.root
#
# @author Jonathan Bradley Whited
# @since  1.0.0
###
module Psychgus
  # Include these in the top namespace for convenience (i.e., less typing).
  include Stylables # @since 1.2.0
  include Stylers # @since 1.2.0

  NODE_CLASS_ALIASES = {:Doc => :Document,:Map => :Mapping,:Seq => :Sequence}
  OPTIONS_ALIASES = {:canon => :canonical,:indent => :indentation}

  # Get a Class (constant) from Psych::Nodes.
  #
  # Some +name+s have aliases:
  #   :doc => :document
  #   :map => :mapping
  #   :seq => :sequence
  #
  # @param name [Symbol,String] the name of the class from Psych::Nodes
  #
  # @return [Class] a class from Psych::Nodes
  #
  # @see Psych::Nodes
  # @see NODE_CLASS_ALIASES
  def self.node_class(name)
    name = name.to_sym().capitalize()

    actual_name = NODE_CLASS_ALIASES[name]
    name = actual_name unless actual_name.nil?()

    return Psych::Nodes.const_get(name)
  end

  # Get a constant from a Psych::Nodes class (using {.node_class}).
  #
  # @param class_name [Symbol,String] the name of the class to get using {.node_class}
  # @param const_name [Symbol,String] the constant to get from the class
  # @param lenient [true,false] if true, will return 0 if not const_defined?(), else raise an error
  #
  # @return [Integer,Object] the constant value from the class (usually an int)
  #
  # @see .node_class
  def self.node_const(class_name,const_name,lenient=true)
    node_class = node_class(class_name)
    const_name = const_name.to_sym().upcase()

    return 0 if lenient && !node_class.const_defined?(const_name,true)
    return node_class.const_get(const_name,true)
  end

  MAPPING_ANY = node_const(:mapping,:any)
  MAPPING_BLOCK = node_const(:mapping,:block)
  MAPPING_FLOW = node_const(:mapping,:flow)
  MAP_ANY = MAPPING_ANY
  MAP_BLOCK = MAPPING_BLOCK
  MAP_FLOW = MAPPING_FLOW

  SCALAR_ANY = node_const(:scalar,:any)
  SCALAR_PLAIN = node_const(:scalar,:plain)
  SCALAR_SINGLE_QUOTED = node_const(:scalar,:single_quoted)
  SCALAR_DOUBLE_QUOTED = node_const(:scalar,:double_quoted)
  SCALAR_LITERAL = node_const(:scalar,:literal)
  SCALAR_FOLDED = node_const(:scalar,:folded)

  SEQUENCE_ANY = node_const(:sequence,:any)
  SEQUENCE_BLOCK = node_const(:sequence,:block)
  SEQUENCE_FLOW = node_const(:sequence,:flow)
  SEQ_ANY = SEQUENCE_ANY
  SEQ_BLOCK = SEQUENCE_BLOCK
  SEQ_FLOW = SEQUENCE_FLOW

  STREAM_ANY = node_const(:stream,:any)
  STREAM_UTF8 = node_const(:stream,:utf8)
  STREAM_UTF16LE = node_const(:stream,:utf16le)
  STREAM_UTF16BE = node_const(:stream,:utf16be)

  # Convert +object+ to YAML and dump to +io+.
  #
  # +object+, +io+, and +options+ are used like in Psych.dump so can be a drop-in replacement for Psych.
  #
  # @param object [Object] the Object to convert to YAML and dump
  # @param io [nil,IO,Hash] the IO to dump the YAML to or the +options+ Hash; if nil, will use StringIO
  # @param options [Hash] the options (or keyword args) to use; see {.dump_stream}
  #
  # @return [String,Object] the result of converting +object+ to YAML using the params
  #
  # @see .dump_stream
  # @see Psych.dump_stream
  def self.dump(object,io=nil,**options)
    return dump_stream(object,io: io,**options)
  end

  # Convert +objects+ to YAML and dump to a file.
  #
  # @example
  #   Psychgus.dump_file('my_dir/my_file.yaml',my_object1,my_object2,mode: 'w:UTF-16',
  #                      stylers: MyStyler.new())
  #   Psychgus.dump_file('my_file.yaml',my_object,stylers: [MyStyler1.new(),MyStyler2.new()])
  #
  # @param filename [String] the name of the file (and path) to dump to
  # @param objects [Object,Array<Object>] the Object(s) to convert to YAML and dump
  # @param mode [String,Integer] the IO open mode to use; examples:
  #                              [+'w:UTF-8'+]  create a new file or truncate an existing file
  #                                             and use UTF-8 encoding;
  #                              [+'a:UTF-16'+] create a new file or append to an existing file
  #                                             and use UTF-16 encoding
  # @param perm [Integer] the permission bits to use (platform dependent)
  # @param opt [Hash] Hash of keyword args to pass to +File.open()+
  # @param options [Hash] the options (or keyword args) to use; see {.dump_stream}
  #
  # @see .dump_stream
  # @see File.open
  # @see IO.new
  # @see https://ruby-doc.org/core/IO.html#method-c-new
  def self.dump_file(filename,*objects,mode: 'w',perm: nil,opt: nil,**options)
    opt = Hash(opt)

    File.open(filename,mode,perm,**opt) do |file|
      file.write(dump_stream(*objects,**options))
    end
  end

  # Convert +objects+ to YAML and dump to +io+.
  #
  # +io+ and +options+ are used like in Psych.dump so can be a drop-in replacement for Psych.
  #
  # @param objects [Object,Array<Object>] the Object(s) to convert to YAML and dump
  # @param io [nil,IO,Hash] the IO to dump the YAML to or the +options+ Hash; if nil, will use StringIO
  # @param stylers [nil,Styler,Array<Styler>] the Styler(s) to use when converting to YAML
  # @param deref_aliases [true,false] whether to dereference aliases; output the actual value
  #                                   instead of the alias
  # @param options [Hash] the options (or keyword args) to use when converting to YAML:
  #                       [+:indent+]      Alias for +:indentation+. +:indentation+ will override this.
  #                       [+:indentation+] Default: +2+.
  #                                        Number of space characters used to indent.
  #                                        Acceptable value should be in +0..9+ range, else ignored.
  #                       [+:line_width+]  Default: +0+ (meaning "wrap at 81").
  #                                        Max character to wrap line at.
  #                       [+:canon+]       Alias for +:canonical+. +:canonical+ will override this.
  #                       [+:canonical+]   Default: +false+.
  #                                        Write "canonical" YAML form (very verbose, yet strictly formal).
  #                       [+:header+]      Default: +false+.
  #                                        Write +%YAML [version]+ at the beginning of document.
  #
  # @return [String,Object] the result of converting +object+ to YAML using the params
  #
  # @see Psych.dump_stream
  # @see OPTIONS_ALIASES
  def self.dump_stream(*objects,io: nil,stylers: nil,deref_aliases: false,**options)
    # If you call this method with only a Hash that uses symbols as keys,
    # then options will be set to the Hash, instead of objects.
    #
    # For example, the below will be stored in options, not objects:
    # - dump_stream({:coffee => {:roast => [],:style => []}})
    #
    # This if-statement is guaranteed because dump_stream([]) and dump_stream(nil)
    # will produce [[]] and [nil], which are not empty.
    #
    # dump_stream() w/o any args is the only problem, but resolved w/ [nil].
    if objects.empty?()
      objects = options.empty?() ? [nil] : [options]
      options = {}
    end

    if Hash === io
      options = io
      io = nil
    end

    if !options.empty?()
      OPTIONS_ALIASES.each do |option_alias,actual_option|
        if options.key?(option_alias) && !options.key?(actual_option)
          options[actual_option] = options[option_alias]
        end
      end
    end

    visitor = Psych::Visitors::YAMLTree.create(options,StyledTreeBuilder.new(*stylers,
      deref_aliases: deref_aliases))

    if objects.empty?()
      # Else, will throw a cryptic NoMethodError:
      # - "psych/tree_builder.rb:in `set_end_location': undefined method `end_line=' for nil:NilClass (NoMethodError)"
      #
      # This should never occur because of the if-statement at the top of this method.
      visitor << nil
    else
      objects.each do |object|
        visitor << object
      end
    end

    return visitor.tree.yaml(io,options)
  end

  # Get a visual hierarchy of the levels as a String.
  #
  # This is useful for determining the correct level/position when writing a {Styler}.
  #
  # @example
  #   require 'psychgus'
  #
  #   burgers = {
  #     :burgers => {
  #       :classic => {:sauce  => %w(Ketchup Mustard),
  #                    :cheese => 'American',
  #                    :bun    => 'Sesame Seed'},
  #       :bbq     => {:sauce  => 'Honey BBQ',
  #                    :cheese => 'Cheddar',
  #                    :bun    => 'Kaiser'},
  #       :fancy   => {:sauce  => 'Spicy Wasabi',
  #                    :cheese => 'Smoked Gouda',
  #                    :bun    => 'Hawaiian'}
  #     },
  #     :toppings => [
  #       'Mushrooms',
  #       %w(Lettuce Onions Pickles Tomatoes),
  #       [%w(Ketchup Mustard), %w(Salt Pepper)]
  #     ]
  #   }
  #
  #   puts Psychgus.hierarchy(burgers)
  #
  #   # Output:
  #   # ---
  #   # (level:position):current_node - <parent:(parent_level:parent_position)>
  #   # ---
  #   # (1:1):Psych::Nodes::Stream - <root:(0:0)>
  #   # (1:1):Psych::Nodes::Document - <stream:(1:1)>
  #   # (1:1):Psych::Nodes::Mapping - <doc:(1:1)>
  #   #  (2:1)::burgers - <map:(1:1)>
  #   #   (3:1):Psych::Nodes::Mapping - <:burgers:(2:1)>
  #   #    (4:1)::classic - <map:(3:1)>
  #   #     (5:1):Psych::Nodes::Mapping - <:classic:(4:1)>
  #   #      (6:1)::sauce - <map:(5:1)>
  #   #       (7:1):Psych::Nodes::Sequence - <:sauce:(6:1)>
  #   #        (8:1):Ketchup - <seq:(7:1)>
  #   #        (8:2):Mustard - <seq:(7:1)>
  #   #      (6:2)::cheese - <map:(5:1)>
  #   #       (7:1):American - <:cheese:(6:2)>
  #   #      (6:3)::bun - <map:(5:1)>
  #   #       (7:1):Sesame Seed - <:bun:(6:3)>
  #   #    (4:2)::bbq - <map:(3:1)>
  #   #     (5:1):Psych::Nodes::Mapping - <:bbq:(4:2)>
  #   #      (6:1)::sauce - <map:(5:1)>
  #   #       (7:1):Honey BBQ - <:sauce:(6:1)>
  #   #      (6:2)::cheese - <map:(5:1)>
  #   #       (7:1):Cheddar - <:cheese:(6:2)>
  #   #      (6:3)::bun - <map:(5:1)>
  #   #       (7:1):Kaiser - <:bun:(6:3)>
  #   #    (4:3)::fancy - <map:(3:1)>
  #   #     (5:1):Psych::Nodes::Mapping - <:fancy:(4:3)>
  #   #      (6:1)::sauce - <map:(5:1)>
  #   #       (7:1):Spicy Wasabi - <:sauce:(6:1)>
  #   #      (6:2)::cheese - <map:(5:1)>
  #   #       (7:1):Smoked Gouda - <:cheese:(6:2)>
  #   #      (6:3)::bun - <map:(5:1)>
  #   #       (7:1):Hawaiian - <:bun:(6:3)>
  #   #  (2:2)::toppings - <map:(1:1)>
  #   #   (3:1):Psych::Nodes::Sequence - <:toppings:(2:2)>
  #   #    (4:1):Mushrooms - <seq:(3:1)>
  #   #    (4:2):Psych::Nodes::Sequence - <seq:(3:1)>
  #   #     (5:1):Lettuce - <seq:(4:2)>
  #   #     (5:2):Onions - <seq:(4:2)>
  #   #     (5:3):Pickles - <seq:(4:2)>
  #   #     (5:4):Tomatoes - <seq:(4:2)>
  #   #    (4:3):Psych::Nodes::Sequence - <seq:(3:1)>
  #   #     (5:1):Psych::Nodes::Sequence - <seq:(4:3)>
  #   #      (6:1):Ketchup - <seq:(5:1)>
  #   #      (6:2):Mustard - <seq:(5:1)>
  #   #     (5:2):Psych::Nodes::Sequence - <seq:(4:3)>
  #   #      (6:1):Salt - <seq:(5:2)>
  #   #      (6:2):Pepper - <seq:(5:2)>
  #
  # @param objects [Object,Array<Object>] the Object(s) to get a visual hierarchy of
  # @param kargs [Hash] the keyword args to pass to {Stylers::HierarchyStyler} and to {dump_stream}
  #
  # @return [String] the visual hierarchy of levels
  #
  # @see Stylers::HierarchyStyler
  # @see dump_stream
  #
  # @since 1.2.0
  def self.hierarchy(*objects,**kargs)
    styler = Stylers::HierarchyStyler.new(**kargs)

    dump_stream(*objects,stylers: styler,**kargs)

    return styler.to_s()
  end

  # Parse +yaml+ into a Psych::Nodes::Document.
  #
  # If you're just going to call to_ruby(), then using this method is unnecessary,
  # and the styler(s) will do nothing for you.
  #
  # @param yaml [String] the YAML to parse
  # @param kargs [Hash] the keyword args to use; see {.parse_stream}
  #
  # @return [Psych::Nodes::Document] the parsed Document node
  #
  # @see .parse_stream
  # @see Psych.parse
  # @see Psych::Nodes::Document
  def self.parse(yaml,**kargs)
    parse_stream(yaml,**kargs) do |node|
      return node
    end

    return false
  end

  # Parse a YAML file into a Psych::Nodes::Document.
  #
  # If you're just going to call to_ruby(), then using this method is unnecessary,
  # and the styler(s) will do nothing for you.
  #
  # @param filename [String] the name of the YAML file (and path) to parse
  # @param fallback [Object] the return value when nothing is parsed
  # @param mode [String,Integer] the IO open mode to use; example: +'r:BOM|UTF-8'+
  # @param opt [Hash] Hash of keyword args to pass to +File.open()+
  # @param kargs [Hash] the keyword args to use; see {.parse_stream}
  #
  # @return [Psych::Nodes::Document] the parsed Document node
  #
  # @see .parse_stream
  # @see Psych.parse_file
  # @see Psych::Nodes::Document
  # @see File.open
  # @see IO.new
  def self.parse_file(filename,fallback: false,mode: 'r:BOM|UTF-8',opt: nil,**kargs)
    opt = Hash(opt)

    result = File.open(filename,mode,**opt) do |file|
      parse(file,filename: filename,**kargs)
    end

    return result || fallback
  end

  # Parse +yaml+ into a Psych::Nodes::Stream for one document or for multiple documents in one YAML.
  #
  # If you're just going to call to_ruby(), then using this method is unnecessary,
  # and the styler(s) will do nothing for you.
  #
  # @example
  #   burgers = <<EOY
  #   ---
  #   Burgers:
  #     Classic:
  #       BBQ: {Sauce: Honey BBQ, Cheese: Cheddar, Bun: Kaiser}
  #   ---
  #   Toppings:
  #   - [Mushrooms, Mustard]
  #   - [Salt, Pepper, Pickles]
  #   ---
  #   `Invalid`
  #   EOY
  #
  #   i = 0
  #
  #   begin
  #     Psychgus.parse_stream(burgers,filename: 'burgers.yaml') do |document|
  #       puts "Document ##{i += 1}"
  #       puts document.to_ruby
  #     end
  #   rescue Psych::SyntaxError => err
  #     puts "File: #{err.file}"
  #   end
  #
  #   # Output:
  #   #   Document #1
  #   #   {"Burgers"=>{"Classic"=>{"BBQ"=>{"Sauce"=>"Honey BBQ", "Cheese"=>"Cheddar", "Bun"=>"Kaiser"}}}}
  #   #   Document #2
  #   #   {"Toppings"=>[["Mushrooms", "Mustard"], ["Salt", "Pepper", "Pickles"]]}
  #   #   File: burgers.yaml
  #
  # @param yaml [String] the YAML to parse
  # @param filename [String] the filename to pass as +file+ to the Error potentially raised
  # @param stylers [nil,Styler,Array<Styler>] the Styler(s) to use when parsing the YAML
  # @param deref_aliases [true,false] whether to dereference aliases; output the actual value
  #                                   instead of the alias
  # @param block [Proc] an optional block for parsing multiple documents
  #
  # @return [Psych::Nodes::Stream] the parsed Stream node
  #
  # @see StyledDocumentStream
  # @see Psych.parse_stream
  # @see Psych::Nodes::Stream
  # @see Psych::SyntaxError
  def self.parse_stream(yaml,filename: nil,stylers: nil,deref_aliases: false,**options,&block)
    if block_given?()
      parser = Psych::Parser.new(StyledDocumentStream.new(*stylers,deref_aliases: deref_aliases,**options,
        &block))

      return parser.parse(yaml,filename)
    else
      parser = self.parser(stylers: stylers,deref_aliases: deref_aliases,**options)
      parser.parse(yaml,filename)

      return parser.handler.root
    end
  end

  # Create a new styled Psych::Parser for parsing YAML.
  #
  # @example
  #   class CoffeeStyler
  #     include Psychgus::Styler
  #
  #     def style_sequence(sniffer,node)
  #       node.style = Psychgus::SEQUENCE_FLOW
  #     end
  #   end
  #
  #   coffee = <<EOY
  #   Coffee:
  #     Roast:
  #       - Light
  #       - Medium
  #       - Dark
  #     Style:
  #       - Cappuccino
  #       - Latte
  #       - Mocha
  #   EOY
  #
  #   parser = Psychgus.parser(stylers: CoffeeStyler.new)
  #   parser.parse(coffee)
  #   puts parser.handler.root.to_yaml
  #
  #   # Output:
  #   #   Coffee:
  #   #     Roast: [Light, Medium, Dark]
  #   #     Style: [Cappuccino, Latte, Mocha]
  #
  # @param stylers [nil,Styler,Array<Styler>] the Styler(s) to use when parsing the YAML
  # @param deref_aliases [true,false] whether to dereference aliases; output the actual value
  #                                   instead of the alias
  #
  # @return [Psych::Parser] the new styled Parser
  #
  # @see StyledTreeBuilder
  # @see Psych.parser
  def self.parser(stylers: nil,deref_aliases: false,**options)
    return Psych::Parser.new(StyledTreeBuilder.new(*stylers,deref_aliases: deref_aliases,**options))
  end

  ###
  # Unnecessary Methods
  #
  # All of the below methods are not needed, but are defined
  # so that Psychgus can be a drop-in replacement for Psych.
  #
  # Instead, you should probably use Psych.
  # This is also the recommended practice in case your version
  # of Psych defines the method differently.
  #
  # Private methods of Psych are not defined.
  #
  # @note For devs/hacking: because extend is used, do not prefix methods with "self."
  #
  # @author Jonathan Bradley Whited
  # @since  1.0.0
  ###
  module PsychDropIn
    # @see Psych.add_builtin_type
    def add_builtin_type(*args,&block)
      Psych.add_builtin_type(*args,&block)
    end

    # @see Psych.add_domain_type
    def add_domain_type(*args,&block)
      Psych.add_domain_type(*args,&block)
    end

    # @see Psych.add_tag
    def add_tag(*args)
      Psych.add_tag(*args)
    end

    # @see Psych.load
    def load(*args,**kargs)
      Psych.load(*args,**kargs)
    end

    # @see Psych.load_file
    def load_file(*args,**kargs)
      Psych.load_file(*args,**kargs)
    end

    # @see Psych.load_stream
    def load_stream(*args,**kargs)
      Psych.load_stream(*args,**kargs)
    end

    # @see Psych.remove_type
    def remove_type(*args)
      Psych.remove_type(*args)
    end

    # @see Psych.safe_load
    def safe_load(*args,**kargs)
      Psych.safe_load(*args,**kargs)
    end

    # @see Psych.to_json
    def to_json(*args)
      Psych.to_json(*args)
    end
  end

  extend PsychDropIn
end
