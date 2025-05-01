# encoding: UTF-8
# frozen_string_literal: true

source 'https://rubygems.org'

group(:development,:test) do
  # Build.
  gem 'bundler'   ,'~> 2.6'
  gem 'rake'      ,'~> 13.2'

  # Doc.
  gem 'rdoc'      ,'~> 6.13'  # RDoc (*.rb).
  gem 'redcarpet' ,'~> 3.6'   # Markdown (*.md).
  gem 'yard'      ,'~> 0.9'   # Doc.
  gem 'yard_ghurt','~> 1.2'   # Rake tasks for fixing YARD.
end

group(:test) do
  gem 'minitest'  ,'~> 5.25'
end

gemspec
