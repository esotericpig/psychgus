# Psychgus

Psychgus uses the core standard library [Psych](https://github.com/ruby/psych) for working with [YAML](https://yaml.org) and extends it so that developers can easily style the YAML according to their needs.

Thank you to the people that worked and continue to work hard on the Psych project.

The Psychgus name comes from the well-styled character Gus from the TV show Psych.

## Contents

- [Setup](#setup)
- [Using](#using)
    - [Hash Example](#hash-example)
    - [Class Example](#class-example)
    - []()
- [Hacking](#hacking)
    - [Testing](#testing)
    - [Generating Doc](#generating-doc)
- [License](#license)

## [Setup](#contents)

Pick your poison...

- With the RubyGems CLI package manager:
    - `$ gem install psychgus`
- In your *Gemspec* (*&lt;project&gt;.gemspec*):
    - `spec.add_runtime_dependency 'psychgus','~> x.x.x'`
    - Or, if you only need Psychgus in development (e.g., tests, rake, documentation):
        - `spec.add_development_dependency 'psychgus','~> x.x.x'`
- In your *Gemfile*:
    - `gem 'psychgus','~> x.x.x'`
    - Or, with GitHub:
        - `gem 'psychgus',:git=>'https://github.com/esotericpig/psychgus.git'`
- Manually:
    - `$ git clone 'https://github.com/esotericpig/psychgus.git'`
    - `$ cd psychgus`
    - `$ bundle install`
    - `$ bundle exec rake install:local`

## [Using](#contents)

To begin styling, simply create a class and mix in (include) `Psychgus::Styler`.

Then pass it in as a keyword arg (`stylers: MyStyler.new` or `stylers: [MyStyler1.new,MyStyler2.new]`) into one of the Psychgus methods.

For classes, you can optionally include `Psychgus::Blueberry` and return the styler(s) for the class by defining the `psychgus_stylers(sniffer)` method.

### [Hash Example](#contents)

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

### [Class Example](#contents)

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
      node.style = Psychgus::MAPPING_FLOW if parent.respond_to?(:value) &&
                                             parent.value.casecmp('BBQ') == 0
    end
  end
  
  # Style scalars (Psych::Nodes::Scalar)
  # - Any text (non-alias)
  def style_scalar(sniffer,node)
    parent = sniffer.parent
    
    # Single quote scalars that are not keys to a map
    node.style = Psychgus::SCALAR_SINGLE_QUOTED if !parent.nil?() &&
                                                   parent.child_type != :key
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

### [](#contents)

## [Hacking](#contents)

```
$ git clone 'https://github.com/esotericpig/psychgus.git'
$ bundle install
$ bundle exec rake -T
```

### [Testing](#contents)

Run tests, excluding tests that create temp files:

`$ bundle exec rake test`

Run all tests:

`$ bundle exec rake test_all`

### [Generating Doc](#contents)

Generate basic doc:

`$ bundle exec rake yard`

Fix GitHub-specific differences:

`$ bundle exec rake yard_fix`

Clean doc &amp; run all of the above:

`$ bundle exec rake yard_fresh`

Deploy doc to my GitHub Page (not useful for others):

`$ bundle exec rake ghp_doc`

## [License](#contents)

[GNU LGPL v3+](LICENSE.txt)

> Psychgus (<https://github.com/esotericpig/psychgus>)  
> Copyright (c) 2017-2019 Jonathan Bradley Whited (@esotericpig)  
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
