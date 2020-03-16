# Psychgus

[![Gem Version](https://badge.fury.io/rb/psychgus.svg)](https://badge.fury.io/rb/psychgus)

[![Documentation](https://img.shields.io/badge/doc-yard-%23A0522D.svg)](https://esotericpig.github.io/docs/psychgus/yardoc/index.html)
[![Source Code](https://img.shields.io/badge/source-github-%23211F1F.svg)](https://github.com/esotericpig/psychgus)
[![Changelog](https://img.shields.io/badge/changelog-md-%23A0522D.svg)](CHANGELOG.md)
[![License](https://img.shields.io/github/license/esotericpig/psychgus.svg)](LICENSE.txt)

Psychgus uses the core standard library [Psych](https://github.com/ruby/psych) for working with [YAML](https://yaml.org) and extends it so that developers can easily style the YAML according to their needs.

Turn this YAML...

```YAML
---
Psych Gus:
  Aliases:
  - Longbranch Pennywhistle
  - Squirts Macintosh
  - Clementine Woolysocks
  - Lavender Gooms
  - Big Baby Burton
  - Chocolate Einstein
  - MC Clap Yo Handz
  Skills:
  - The Blueberry
  - The Super Sniffer
  - Positive Work Attitude
```

Into this:

```YAML
---
Psych Gus:
  Aliases: [Longbranch Pennywhistle, Squirts Macintosh, Clementine Woolysocks, Lavender
      Gooms, Big Baby Burton, Chocolate Einstein, MC Clap Yo Handz]
  Skills: [The Blueberry, The Super Sniffer, Positive Work Attitude]
```

Thank you to the people that worked and continue to work hard on the Psych project.

The Psychgus name comes from the well-styled character Gus from the TV show Psych.

## Contents

- [Setup](#setup)
- [Using](#using)
    - [Simple Example](#simple-example)
    - [Hash Example](#hash-example)
    - [Class Example](#class-example)
    - [Advanced Usage](#advanced-usage)
    - [Common Stylers](#common-stylers)
        - [Stylers Example](#stylers-example)
- [Hacking](#hacking)
    - [Testing](#testing)
    - [Generating Doc](#generating-doc)
- [License](#license)

## [Setup](#contents)

Pick your poison...

With the RubyGems CLI package manager:

`$ gem install psychgus`

In your *Gemspec* (*&lt;project&gt;.gemspec*):

```Ruby
# Pick one...
spec.add_runtime_dependency 'psychgus', '~> X.X.X'
spec.add_development_dependency 'psychgus', '~> X.X.X'
```

In your *Gemfile*:

```Ruby
# Pick one...
gem 'psychgus', '~> X.X.X'
gem 'psychgus', '~> X.X.X', :group => :development
gem 'psychgus', :git => 'https://github.com/esotericpig/psychgus.git', :tag => 'vX.X.X'
```

Manually:

```
$ git clone 'https://github.com/esotericpig/psychgus.git'
$ cd psychgus
$ bundle install
$ bundle exec rake install:local
```

## [Using](#contents)

Documentation (YARDoc) is available on my [GitHub Page](https://esotericpig.github.io/docs/psychgus/yardoc/index.html) and on [RubyDoc.info](https://www.rubydoc.info/gems/psychgus).

To begin styling, create a class and mix in (include) `Psychgus::Styler`. Then pass it in as a keyword arg (`stylers: MyStyler.new` or `stylers: [MyStyler1.new,MyStyler2.new]`) into one of the Psychgus methods.

For classes, you can optionally include `Psychgus::Blueberry` and return the styler(s) for the class by defining the `psychgus_stylers(sniffer)` method.

Instead of making your own styler, you can also use one of the [pre-defined stylers](#common-stylers).

### Contents | Using

[Simple Example](#simple-example)
| [Hash Example](#hash-example)
| [Class Example](#class-example)
| [Advanced Usage](#advanced-usage)
| [Common Stylers](#common-stylers)

### [Simple Example](#using)

```Ruby
require 'psychgus'

class CoffeeStyler
  include Psychgus::Styler
  
  def style_sequence(sniffer,node)
    node.style = Psychgus::SEQUENCE_FLOW
  end
end

coffee = {
  'Roast'=>['Light', 'Medium', 'Dark', 'Extra Dark'],
  'Style'=>['Cappuccino', 'Espresso', 'Latte', 'Mocha']
}

puts coffee.to_yaml(stylers: CoffeeStyler.new)

# Output:
# ---
# Roast: [Light, Medium, Dark, Extra Dark]
# Style: [Cappuccino, Espresso, Latte, Mocha]

class Coffee
  include Psychgus::Blueberry
  
  def initialize
    @roast = ['Light', 'Medium', 'Dark', 'Extra Dark']
    @style = ['Cappuccino', 'Espresso', 'Latte', 'Mocha']
  end
  
  def psychgus_stylers(sniffer)
    CoffeeStyler.new
  end
end

puts Coffee.new.to_yaml

# Output:
# --- !ruby/object:Coffee
# roast: [Light, Medium, Dark, Extra Dark]
# style: [Cappuccino, Espresso, Latte, Mocha]
```

### [Hash Example](#using)

```Ruby
require 'psychgus'

class BurgerStyler
  include Psychgus::Styler # Mix in methods needed for styling
  
  # Style maps (Psych::Nodes::Mapping)
  # - Hashes (key/value pairs)
  # - Example: "Burgers: Classic {}"
  def style_mapping(sniffer,node)
    node.style = Psychgus::MAPPING_FLOW if sniffer.level >= 4
  end
  
  # Style scalars (Psych::Nodes::Scalar)
  # - Any text (non-alias)
  def style_scalar(sniffer,node)
    # Remove colon (change symbols into strings)
    node.value = node.value.sub(':','')
    
    # Capitalize each word
    node.value = node.value.split(' ').map do |v|
      if v.casecmp('BBQ') == 0
        v.upcase()
      else
        v.capitalize()
      end
    end.join(' ')
    
    # Change lettuce to spinach
    node.value = 'Spinach' if node.value == 'Lettuce'
  end
  
  # Style sequences (Psych::Nodes::Sequence)
  # - Arrays
  # - Example: "[Lettuce, Onions, Pickles, Tomatoes]"
  def style_sequence(sniffer,node)
    node.style = Psychgus::SEQUENCE_FLOW if sniffer.level >= 4
  end
end

burgers = {
  :burgers => {
    :classic => {:sauce  => %w(Ketchup Mustard),
                 :cheese => 'American',
                 :bun    => 'Sesame Seed'},
    :bbq     => {:sauce  => 'Honey BBQ',
                 :cheese => 'Cheddar',
                 :bun    => 'Kaiser'},
    :fancy   => {:sauce  => 'Spicy Wasabi',
                 :cheese => 'Smoked Gouda',
                 :bun    => 'Hawaiian'}
  },
  :toppings => [
    'Mushrooms',
    %w(Lettuce Onions Pickles Tomatoes),
    [%w(Ketchup Mustard), %w(Salt Pepper)]
  ]
}
burgers[:favorite] = burgers[:burgers][:bbq] # Alias

puts burgers.to_yaml(indent: 3,stylers: BurgerStyler.new)

# Output:
# ---
# Burgers:
#    Classic: {Sauce: [Ketchup, Mustard], Cheese: American, Bun: Sesame Seed}
#    BBQ: &1 {Sauce: Honey BBQ, Cheese: Cheddar, Bun: Kaiser}
#    Fancy: {Sauce: Spicy Wasabi, Cheese: Smoked Gouda, Bun: Hawaiian}
# Toppings:
# - Mushrooms
# - [Spinach, Onions, Pickles, Tomatoes]
# - [[Ketchup, Mustard], [Salt, Pepper]]
# Favorite: *1

# Or pass in a Hash. Can also dereference aliases.
puts burgers.to_yaml({:indent => 3,:stylers => BurgerStyler.new,:deref_aliases => true})

# Output:
# ---
# Burgers:
#    Classic: {Sauce: [Ketchup, Mustard], Cheese: American, Bun: Sesame Seed}
#    BBQ: {Sauce: Honey BBQ, Cheese: Cheddar, Bun: Kaiser}
#    Fancy: {Sauce: Spicy Wasabi, Cheese: Smoked Gouda, Bun: Hawaiian}
# Toppings:
# - Mushrooms
# - [Spinach, Onions, Pickles, Tomatoes]
# - [[Ketchup, Mustard], [Salt, Pepper]]
# Favorite:
#    Sauce: Honey BBQ
#    Cheese: Cheddar
#    Bun: Kaiser
```

### [Class Example](#using)

```Ruby
require 'psychgus'

class BurgerStyler
  include Psychgus::Styler # Mix in methods needed for styling
  
  def initialize(sniffer)
    @class_level    = sniffer.level
    @class_position = sniffer.position
  end
  
  # Style all nodes (Psych::Nodes::Node)
  def style(sniffer,node)
    # Remove "!ruby/object:..." for Burger classes (not Burgers class)
    node.tag = nil if node.node_of?(:mapping,:scalar,:sequence)
    
    # This is another way to do the above
    #node.tag = nil if node.respond_to?(:tag=)
  end
  
  # Style maps (Psych::Nodes::Mapping)
  # - Hashes (key/value pairs)
  # - Example: "Burgers: Classic {}"
  def style_mapping(sniffer,node)
    parent = sniffer.parent
    
    if !parent.nil?()
      # BBQ
      node.style = Psychgus::MAPPING_FLOW if parent.node_of?(:scalar) &&
                                             parent.value.casecmp('BBQ') == 0
    end
  end
  
  # Style scalars (Psych::Nodes::Scalar)
  # - Any text (non-alias)
  def style_scalar(sniffer,node)
    parent = sniffer.parent
    
    # Single quote scalars that are not keys to a map
    # - "child_key?" is the same as "child_type == :key"
    node.style = Psychgus::SCALAR_SINGLE_QUOTED unless parent.child_key?()
  end
  
  # Style sequences (Psych::Nodes::Sequence)
  # - Arrays
  # - Example: "[Lettuce, Onions, Pickles, Tomatoes]"
  def style_sequence(sniffer,node)
    relative_level = (sniffer.level - @class_level) + 1
    
    # "[Ketchup, Mustard]"
    node.style = Psychgus::SEQUENCE_FLOW if relative_level == 3
  end
end

class Burger
  include Psychgus::Blueberry # Mix in methods needed to be stylable
  
  attr_accessor :bun
  attr_accessor :cheese
  attr_accessor :sauce
  
  def initialize(sauce,cheese,bun)
    @bun    = bun
    @cheese = cheese
    @sauce  = sauce
  end
  
  # Return our styler(s)
  # - Can be an Array: [MyStyler1.new, MyStyler2.new]
  def psychgus_stylers(sniffer)
    return BurgerStyler.new(sniffer)
  end
  
  # You can still use Psych's encode_with(), no problem
  def encode_with(coder)
    coder['Bun']    = @bun
    coder['Cheese'] = @cheese
    coder['Sauce']  = @sauce
  end
end

class Burgers
  attr_accessor :burgers
  attr_accessor :toppings
  attr_accessor :favorite
  
  def initialize()
    @burgers = {
      'Classic' => Burger.new(['Ketchup','Mustard'],'American'    ,'Sesame Seed'),
      'BBQ'     => Burger.new('Honey BBQ'          ,'Cheddar'     ,'Kaiser'),
      'Fancy'   => Burger.new('Spicy Wasabi'       ,'Smoked Gouda','Hawaiian')
    }
    
    @toppings = [
      'Mushrooms',
      %w(Lettuce Onions Pickles Tomatoes),
      [%w(Ketchup Mustard),%w(Salt Pepper)]
    ]
    
    @favorite = @burgers['BBQ'] # Alias
  end
  
  # You can still use Psych's encode_with(), no problem
  def encode_with(coder)
    coder['Burgers']  = @burgers
    coder['Toppings'] = @toppings
    coder['Favorite'] = @favorite
  end
end

burgers = Burgers.new

puts burgers.to_yaml(indent: 3)

# Output:
# --- !ruby/object:Burgers
# Burgers:
#    Classic:
#       Bun: 'Sesame Seed'
#       Cheese: 'American'
#       Sauce: ['Ketchup', 'Mustard']
#    BBQ: &1 {Bun: 'Kaiser', Cheese: 'Cheddar', Sauce: 'Honey BBQ'}
#    Fancy:
#       Bun: 'Hawaiian'
#       Cheese: 'Smoked Gouda'
#       Sauce: 'Spicy Wasabi'
# Toppings:
# - Mushrooms
# -  - Lettuce
#    - Onions
#    - Pickles
#    - Tomatoes
# -  -  - Ketchup
#       - Mustard
#    -  - Salt
#       - Pepper
# Favorite: *1

# Or pass in a Hash. Can also dereference aliases.
puts burgers.to_yaml({:indent => 3,:deref_aliases => true})

# Output:
# --- !ruby/object:Burgers
# Burgers:
#    Classic:
#       Bun: 'Sesame Seed'
#       Cheese: 'American'
#       Sauce: ['Ketchup', 'Mustard']
#    BBQ: {Bun: 'Kaiser', Cheese: 'Cheddar', Sauce: 'Honey BBQ'}
#    Fancy:
#       Bun: 'Hawaiian'
#       Cheese: 'Smoked Gouda'
#       Sauce: 'Spicy Wasabi'
# Toppings:
# - Mushrooms
# -  - Lettuce
#    - Onions
#    - Pickles
#    - Tomatoes
# -  -  - Ketchup
#       - Mustard
#    -  - Salt
#       - Pepper
# Favorite:
#    Bun: 'Kaiser'
#    Cheese: 'Cheddar'
#    Sauce: 'Honey BBQ'
```

### [Advanced Usage](#using)

```Ruby
require 'psychgus'

class MyStyler
  include Psychgus::Styler
  
  def style_sequence(sniffer,node)
    node.style = Psychgus::SEQUENCE_FLOW
  end
end

coffee = {
  'Coffee' => {
    'Roast'=>['Light', 'Medium', 'Dark', 'Extra Dark'],
    'Style'=>['Cappuccino', 'Espresso', 'Latte', 'Mocha']
  }
}
eggs = {
  'Eggs' => {
    'Color'=>['Brown', 'White', 'Blue', 'Olive'],
    'Style'=>['Fried', 'Scrambled', 'Omelette', 'Poached']
  }
}

filename = 'coffee-and-eggs.yaml'
styler = MyStyler.new
options = {:indentation=>3, :stylers=>styler, :deref_aliases=>true}

coffee_yaml = coffee.to_yaml(options)
coffee_and_eggs_yaml = Psychgus.dump_stream(coffee,eggs,options)


# High-level emitting
puts Psychgus.dump(coffee,options)
puts

Psychgus.dump_file(filename,coffee,eggs,options)
puts File.readlines(filename)
puts

puts Psychgus.dump_stream(coffee,eggs,options)
puts

puts coffee.to_yaml(options)
puts

# High-level parsing
# - Because to_ruby() will be called, just use Psych:
#   - load(), load_file(), load_stream(), safe_load()

# Mid-level emitting
stream = Psychgus.parse_stream(coffee_and_eggs_yaml,options)

puts stream.to_yaml()
puts

# Mid-level parsing
puts Psychgus.parse(coffee_yaml,options).to_ruby
puts

puts Psychgus.parse_file(filename,options).to_ruby
puts

i = 0
Psychgus.parse_stream(coffee_and_eggs_yaml,options) do |doc|
  puts "Doc ##{i += 1}:"
  puts "  #{doc.to_ruby}"
end
puts

# Low-level emitting
tree_builder = Psychgus::StyledTreeBuilder.new(styler,options)
visitor = Psych::Visitors::YAMLTree.create(options,tree_builder)

visitor << coffee
visitor << eggs

puts visitor.tree.to_yaml
puts

# Low-level parsing
parser = Psychgus.parser(options)

parser.parse(coffee_yaml)

puts parser.handler.root.to_ruby
puts
```

### [Common Stylers](#using)

A collection of commonly-used [Stylers](https://esotericpig.github.io/docs/psychgus/yardoc/Psychgus/Stylers.html) and [Stylables](https://esotericpig.github.io/docs/psychgus/yardoc/Psychgus/Stylables.html) are included with Psychgus.

| Styler | Description |
| --- | --- |
| [CapStyler](https://esotericpig.github.io/docs/psychgus/yardoc/Psychgus/Stylers/CapStyler.html) | Capitalizer for Scalars |
| [FlowStyler](https://esotericpig.github.io/docs/psychgus/yardoc/Psychgus/Stylers/FlowStyler.html) | FLOW style changer for Mappings & Sequences |
| [MapFlowStyler](https://esotericpig.github.io/docs/psychgus/yardoc/Psychgus/Stylers/MapFlowStyler.html) | FLOW style changer for Mappings only |
| [NoSymStyler](https://esotericpig.github.io/docs/psychgus/yardoc/Psychgus/Stylers/NoSymStyler.html) | Symbol remover for Scalars |
| [NoTagStyler](https://esotericpig.github.io/docs/psychgus/yardoc/Psychgus/Stylers/NoTagStyler.html) | Tag remover for classes |
| [SeqFlowStyler](https://esotericpig.github.io/docs/psychgus/yardoc/Psychgus/Stylers/SeqFlowStyler.html) | FLOW style changer for Sequences only |

#### [Stylers Example](#common-stylers)

```Ruby
require 'psychgus'

class EggCarton
  def initialize
    @eggs = {
      :styles => ['fried', 'scrambled', ['BBQ', 'ketchup & mustard']],
      :colors => ['brown', 'white', ['blue', 'green']]
    }
  end
end

puts EggCarton.new.to_yaml(stylers: [
  Psychgus::NoSymStyler.new,
  Psychgus::NoTagStyler.new,
  Psychgus::CapStyler.new,
  Psychgus::FlowStyler.new(4)
])

# Output:
# ---
# Eggs:
#   Styles: [Fried, Scrambled, [BBQ, Ketchup & Mustard]]
#   Colors: [Brown, White, [Blue, Green]]

puts EggCarton.new.to_yaml

# Output (without Stylers):
# --- !ruby/object:EggCarton
# eggs:
#   :styles:
#   - fried
#   - scrambled
#   - - BBQ
#     - ketchup & mustard
#   :colors:
#   - brown
#   - white
#   - - blue
#     - green
```

## [Hacking](#contents)

```
$ git clone 'https://github.com/esotericpig/psychgus.git'
$ cd psychgus
$ bundle install
$ bundle exec rake -T
```

### [Testing](#hacking)

Run tests, excluding tests that create temp files:

`$ bundle exec rake test`

Run all tests:

`$ bundle exec rake test_all`

### [Generating Doc](#hacking)

Generate doc:

`$ bundle exec rake doc`

Clean &amp; generate pristine doc:

`$ bundle exec rake clobber doc`

## [License](#contents)

[GNU LGPL v3+](LICENSE.txt)

> Psychgus (<https://github.com/esotericpig/psychgus>)  
> Copyright (c) 2017-2020 Jonathan Bradley Whited (@esotericpig)  
> 
> Psychgus is free software: you can redistribute it and/or modify  
> it under the terms of the GNU Lesser General Public License as published by  
> the Free Software Foundation, either version 3 of the License, or  
> (at your option) any later version.  
> 
> Psychgus is distributed in the hope that it will be useful,  
> but WITHOUT ANY WARRANTY; without even the implied warranty of  
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
> GNU Lesser General Public License for more details.  
> 
> You should have received a copy of the GNU Lesser General Public License  
> along with Psychgus.  If not, see <http://www.gnu.org/licenses/>.  
