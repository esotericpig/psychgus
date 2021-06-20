# encoding: UTF-8
# frozen_string_literal: true


require_relative 'lib/psychgus/version'


Gem::Specification.new do |spec|
  spec.name        = 'psychgus'
  spec.version     = Psychgus::VERSION
  spec.authors     = ['Jonathan Bradley Whited']
  spec.email       = ['code@esotericpig.com']
  spec.licenses    = ['LGPL-3.0-or-later']
  spec.homepage    = 'https://github.com/esotericpig/psychgus'
  spec.summary     = 'Easily style YAML files using Psych.'
  spec.description = 'Easily style YAML files using Psych, like Sequence/Mapping Flow style.'

  spec.metadata = {
    'homepage_uri'      => 'https://github.com/esotericpig/psychgus',
    'source_code_uri'   => 'https://github.com/esotericpig/psychgus',
    'bug_tracker_uri'   => 'https://github.com/esotericpig/psychgus/issues',
    'changelog_uri'     => 'https://github.com/esotericpig/psychgus/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://esotericpig.github.io/docs/psychgus/yardoc/index.html',
  }

  spec.required_ruby_version = '>= 2.1.10'
  spec.require_paths         = ['lib']
  spec.bindir                = 'bin'

  spec.files = [
    Dir.glob(File.join("{#{spec.require_paths.join(',')}}",'**','*.{erb,rb}')),
    Dir.glob(File.join(spec.bindir,'*')),
    Dir.glob(File.join('{samples,test,yard}','**','*.{erb,rb}')),
    %W[ Gemfile #{spec.name}.gemspec Rakefile .yardopts ],
    %w[ LICENSE.txt CHANGELOG.md README.md ],
  ].flatten

  # Test using different Gem versions:
  #   GST=1 bundle update && bundle exec rake test_all
  gemspec_test = ENV.fetch('GST','').to_s.strip
  psych_gemv = false

  if !gemspec_test.empty?
    case gemspec_test
    when '1' then psych_gemv = '~> 3.0'
    end

    puts 'Using Gem versions:'
    puts "  psych: #{psych_gemv.inspect}"
  end

  # 3.0 is needed for this issue:
  # - https://bugs.ruby-lang.org/issues/13115
  # - https://github.com/ruby/psych/commit/712a65a53f3c15105cd86e8ad3ee3c779050ada4
  spec.add_runtime_dependency 'psych',psych_gemv || '>= 3.0'

  spec.add_development_dependency 'bundler'   ,'~> 2.2'
  spec.add_development_dependency 'minitest'  ,'~> 5.14' # For testing
  spec.add_development_dependency 'rake'      ,'~> 13.0'
  spec.add_development_dependency 'rdoc'      ,'~> 6.3'  # For RDoc for YARD (*.rb)
  spec.add_development_dependency 'redcarpet' ,'~> 3.5'  # For Markdown for YARD (*.md)
  spec.add_development_dependency 'yard'      ,'~> 0.9'  # For documentation
  spec.add_development_dependency 'yard_ghurt','~> 1.2'  # For YARD GitHub rake tasks
end
