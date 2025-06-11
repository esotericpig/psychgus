# encoding: UTF-8
# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group(:development,:test) do
  # Build.
  gem 'bundler'   ,'~> 2.6'
  gem 'rake'      ,'~> 13.3'

  # Doc.
  gem 'irb'       ,'~> 1.15'  # Fix for Yard Ruby v3.5+.
  gem 'rdoc'      ,'~> 6.14'  # RDoc (*.rb).
  gem 'redcarpet' ,'~> 3.6'   # Markdown (*.md).
  gem 'yard'      ,'~> 0.9'   # Doc.
  gem 'yard_ghurt','~> 1.2'   # Rake tasks for fixing YARD.
end

group(:test) do
  gem 'minitest'  ,'~> 5.25'
end
