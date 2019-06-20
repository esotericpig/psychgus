#!/usr/bin/env ruby
# encoding: UTF-8

###
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
###

require 'psych'

require 'psychgus/blueberry'
require 'psychgus/styled_document_stream'
require 'psychgus/styled_tree_builder'
require 'psychgus/styler'
require 'psychgus/super_sniffer'
require 'psychgus/version'

require 'psychgus/ext/core_ext'
require 'psychgus/ext/node_ext'
require 'psychgus/ext/yaml_tree_ext'

require 'psychgus/super_sniffer/parent'

module Psychgus
  def self.node_class(name)
    name = name.to_sym().capitalize()
    
    case name
    when :Doc
      name = :Document
    when :Map
      name = :Mapping
    when :Seq
      name = :Sequence
    end
    
    return Psych::Nodes.const_get(name)
  end
  
  def self.node_const(class_name,const_name,lenient=true)
    node_class = node_class(class_name)
    const_name = const_name.upcase()
    
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
  
  # Don't use keyword args for io & options so can be a drop-in-replacement for Psych
  def self.dump(object,io=nil,options={},**kargs)
    return dump_stream(object,io: io,options: options,**kargs)
  end
  
  # Mode can be 'w:UTF-8', 'a:UTF-16', etc.
  # stylers: MyStyler.new
  # stylers: [...]
  def self.dump_file(filename,*objects,mode: 'w',perm: nil,opt: nil,**kargs)
    File.open(filename,mode,perm,opt) do |file|
      file.write(dump_stream(*objects,**kargs))
    end
  end
  
  def self.dump_stream(*objects,io: nil,options: {},stylers: nil)
    if Hash === io
      options = io
      io = nil
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
    def add_builtin_type(*args,&block)
      Psych.add_builtin_type(*args,&block)
    end
    
    def add_domain_type(*args,&block)
      Psych.add_domain_type(*args,&block)
    end
    
    def add_tag(*args)
      Psych.add_tag(*args)
    end
    
    def load_file(*args,**kargs)
      Psych.load_file(*args,**kargs)
    end
    
    def load_stream(*args,**kargs)
      Psych.load_stream(*args,**kargs)
    end
    
    def remove_type(*args)
      Psych.remove_type(*args)
    end
    
    def to_json(*args)
      Psych.to_json(*args)
    end
  end
  
  extend PsychDropIn
end
