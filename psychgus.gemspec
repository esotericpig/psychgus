# encoding: UTF-8
# frozen_string_literal: true

require_relative 'lib/psychgus/version'

Gem::Specification.new do |spec|
  spec.name        = 'psychgus'
  spec.version     = Psychgus::VERSION
  spec.authors     = ['Bradley Whited']
  spec.email       = ['code@esotericpig.com']
  spec.licenses    = ['LGPL-3.0-or-later']
  spec.homepage    = 'https://github.com/esotericpig/psychgus'
  spec.summary     = 'Easily style YAML files using Psych.'
  spec.description = 'Easily style YAML files using Psych, like Sequence/Mapping Flow style.'

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'homepage_uri'          => spec.homepage,
    'source_code_uri'       => 'https://github.com/esotericpig/psychgus',
    'bug_tracker_uri'       => 'https://github.com/esotericpig/psychgus/issues',
    'changelog_uri'         => 'https://github.com/esotericpig/psychgus/blob/main/CHANGELOG.md',
    'documentation_uri'     => 'https://esotericpig.github.io/docs/psychgus/yardoc/index.html',
  }

  spec.required_ruby_version = '>= 3.1'
  spec.require_paths         = ['lib']
  spec.bindir                = 'bin'

  spec.files = [
    Dir.glob("{#{spec.require_paths.join(',')}}/**/*.{erb,rb}"),
    Dir.glob("#{spec.bindir}/*"),
    Dir.glob('{spec,test}/**/*.{erb,rb}'),
    %W[Gemfile #{spec.name}.gemspec Rakefile .yardopts],
    %w[CHANGELOG.md LICENSE.txt README.md],
  ].flatten

  # Test using different Gem versions:
  #   GST=1 bundle update && bundle exec rake test
  gemspec_test = ENV.fetch('GST','').to_s.strip
  psych_gemv = false

  if !gemspec_test.empty?
    case gemspec_test
    when '1' then psych_gemv = '<= 5.1.1'
    when '2' then psych_gemv = '5.1.2'
    when '3' then psych_gemv = '5.2.0'
    end

    puts 'Using Gem versions:'
    puts "  psych: #{psych_gemv.inspect}"
  end

  # 3.0 is needed for this issue:
  # - https://bugs.ruby-lang.org/issues/13115
  # - https://github.com/ruby/psych/commit/712a65a53f3c15105cd86e8ad3ee3c779050ada4
  spec.add_dependency 'psych',psych_gemv || '>= 3.0'
end
