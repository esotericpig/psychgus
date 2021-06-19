# encoding: UTF-8
# frozen_string_literal: true


require_relative 'lib/psychgus/version'


Gem::Specification.new() do |spec|
  spec.name        = 'psychgus'
  spec.version     = Psychgus::VERSION
  spec.authors     = ['Jonathan Bradley Whited']
  spec.email       = ['code@esotericpig.com']
  spec.licenses    = ['LGPL-3.0-or-later']
  spec.homepage    = 'https://github.com/esotericpig/psychgus'
  spec.summary     = %q(Easily style YAML files using Psych.)
  spec.description = %q(Easily style YAML files using Psych, like Sequence/Mapping Flow style.)

  spec.metadata = {
    'bug_tracker_uri'   => 'https://github.com/esotericpig/psychgus/issues',
    'changelog_uri'     => 'https://github.com/esotericpig/psychgus/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://esotericpig.github.io/docs/psychgus/yardoc/index.html',
    'homepage_uri'      => 'https://github.com/esotericpig/psychgus',
    'source_code_uri'   => 'https://github.com/esotericpig/psychgus'
  }

  spec.require_paths = ['lib']

  spec.files = Dir.glob(File.join("{#{spec.require_paths.join(',')}}",'**','*.{erb,rb}')) +
               Dir.glob(File.join('{test,yard}','**','*.{erb,rb}')) +
               %W( Gemfile #{spec.name}.gemspec Rakefile ) +
               %w( CHANGELOG.md LICENSE.txt README.md )

  spec.required_ruby_version = '>= 2.1.10'

  # 3.0 is needed for this issue:
  # - https://bugs.ruby-lang.org/issues/13115
  # - https://github.com/ruby/psych/commit/712a65a53f3c15105cd86e8ad3ee3c779050ada4
  spec.add_runtime_dependency 'psych','>= 3.0'

  spec.add_development_dependency 'bundler'   ,'~> 2.1'
  spec.add_development_dependency 'minitest'  ,'~> 5.14' # For testing
  spec.add_development_dependency 'rake'      ,'~> 13.0'
  spec.add_development_dependency 'rdoc'      ,'~> 6.2'  # For RDoc for YARD (*.rb)
  spec.add_development_dependency 'redcarpet' ,'~> 3.5'  # For Markdown for YARD (*.md)
  spec.add_development_dependency 'yard'      ,'~> 0.9'  # For documentation
  spec.add_development_dependency 'yard_ghurt','~> 1.2'  # For YARD GitHub rake tasks
end
