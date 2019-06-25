#!/usr/bin/env ruby
# encoding: UTF-8

#--
# This file is part of Psychgus.
# Copyright (c) 2017-2019 Jonathan Bradley Whited (@esotericpig)
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

require 'psychgus/blueberry'
require 'psychgus/ext'
require 'psychgus/styled_document_stream'
require 'psychgus/styled_tree_builder'
require 'psychgus/styler'
require 'psychgus/super_sniffer'
require 'psychgus/version'

require 'psychgus/ext/core_ext'
require 'psychgus/ext/node_ext'
require 'psychgus/ext/yaml_tree_ext'

require 'psychgus/super_sniffer/parent'

###
# @author Jonathan Bradley Whited (@esotericpig)
# @since  1.0.0
###
module Psychgus
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
    
    name_alias = NODE_CLASS_ALIASES[name]
    name = name_alias unless name_alias.nil?()
    
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
  # @param options [Hash] the options to use; see {.dump_stream}
  # @param kargs [Hash] the keyword args to use; see {.dump_stream}
  # 
  # @return [String,Object] the result of converting +object+ to YAML using the params
  # 
  # @see .dump_stream
  # @see Psych.dump_stream
  def self.dump(object,io=nil,options={},**kargs)
    return dump_stream(object,io: io,options: options,**kargs)
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
  # @param opt [Symbol] the option(s) to use, more readable alternative to +mode+;
  #                     examples: :textmode, :autoclose
  # @param kargs [Hash] the keyword args to use; see {.dump_stream}
  # 
  # @see .dump_stream
  # @see File.open
  # @see IO.new
  # @see https://ruby-doc.org/core/IO.html#method-c-new
  def self.dump_file(filename,*objects,mode: 'w',perm: nil,opt: nil,**kargs)
    File.open(filename,mode,perm,opt) do |file|
      file.write(dump_stream(*objects,**kargs))
    end
  end
  
  # Convert +objects+ to YAML and dump to +io+.
  # 
  # +io+ and +options+ are used like in Psych.dump so can be a drop-in replacement for Psych.
  # 
  # @param objects [Object,Array<Object>] the Object(s) to convert to YAML and dump
  # @param io [nil,IO,Hash] the IO to dump the YAML to or the +options+ Hash; if nil, will use StringIO
  # @param options [Hash] the options to use when converting to YAML:
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
  # @param stylers [nil,Styler,Array<Styler>] the Styler(s) to use when converting to YAML
  # 
  # @return [String,Object] the result of converting +object+ to YAML using the params
  # 
  # @see Psych.dump_stream
  # @see OPTIONS_ALIASES
  def self.dump_stream(*objects,io: nil,options: {},stylers: nil)
    if Hash === io
      options = io
      io = nil
    end
    
    if !options.nil?()
      OPTIONS_ALIASES.each do |option_alias,option|
        if options.key?(option_alias) && !options.key?(option)
          options[option] = options[option_alias]
        end
      end
    end
    
    visitor = Psych::Visitors::YAMLTree.create(options,StyledTreeBuilder.new(*stylers))
    
    objects.each do |object|
      visitor << object
    end
    
    return visitor.tree.yaml(io,options)
  end
  
  # You don't need to pass in stylers, if you're just going to call to_ruby()
  def self.parse(yaml,**kargs)
    parse_stream(yaml,**kargs) do |node|
      return node
    end
    
    return false
  end
  
  # You don't need to pass in stylers, if you're just going to call to_ruby()
  def self.parse_file(filename,fallback: false,**kargs)
    result = File.open(filename,'r:BOM|UTF-8') do |file|
      parse(file,filename: filename,**kargs)
    end
    
    return result || fallback
  end
  
  # You don't need to pass in stylers, if you're just going to call to_ruby()
  def self.parse_stream(yaml,filename: nil,stylers: nil,&block)
    if block_given?()
      parser = Psych::Parser.new(StyledDocumentStream.new(*stylers,&block))
      
      return parser.parse(yaml,filename)
    else
      parser = self.parser(stylers: stylers)
      parser.parse(yaml,filename)
      
      return parser.handler.root
    end
  end
  
  def self.parser(stylers: nil)
    return Psych::Parser.new(StyledTreeBuilder.new(*stylers))
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
  # Because extend is used, do not prefix methods with "self."
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
