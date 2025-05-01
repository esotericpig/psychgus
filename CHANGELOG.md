# Changelog | Psychgus

- [Keep a Changelog v1.0.0](https://keepachangelog.com/en/1.0.0)
- [Semantic Versioning v2.0.0](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
- https://github.com/esotericpig/psychgus/compare/v1.3.6...HEAD


## [v1.3.6] - 2025-05-01
### Fixed
- Fixed deref aliases for Psych v5.2.0+.

### Changed
- Renamed `master` branch to `main`.
- Applied RuboCop suggestions.
- Refactored tests.
- Removed `yard_ghurt` gem.


## [v1.3.5] - 2024-09-06
### Fixed
- Fixed to_yaml() to work with older-style gems.
  - Example Gem: moneta
- Fixed deref aliases to work with Psych v5.1.2.

### Changed
- Updated min Ruby to v2.2.
- Updated Gems.


## [v1.3.4] - 2021-06-20
### Fixed
- Fixed test file to use `unsafe_load()` for Psych v4+.

### Changed
- Changed `SuperSniffer::Parent` to use `SimpleDelegator`.
- Updated Gems.
- Formatted files with RuboCop.


## [v1.3.3] - 2020-04-25
### Fixed
- SuperSniffer::Parent
    - Added require of `delegate` for Delegator
    - Rake test task didn't catch this (must already include it)


## [v1.3.2] - 2020-04-23
### Changed
- SuperSniffer::Parent
    - Changed to use Delegator to delegate all methods of `node`
- Psychgus.dump_file()/parse_file()
    - Changed `opt` to expect a Hash

### Fixed
- Fixed some Ruby 2.7 warnings in tests


## [v1.2.2] - 2020-03-15
### Fixed
- Fixed Psych version to be >= 3.0 for `to_yaml/encode_with` warnings
    - This is mainly for Windows
    - [Ruby-lang Bug #13115](https://bugs.ruby-lang.org/issues/13115)
    - [GitHub Psych Commit](https://github.com/ruby/psych/commit/712a65a53f3c15105cd86e8ad3ee3c779050ada4)


## [v1.2.1] - 2019-12-18
### Added
- Use of YardGhurt gem for Rakefile tasks

### Changed
- Some comments/doc in SuperSniffer, README
- yard_fix task in Rakefile to be cleaner
- Test constants in PsychgusTest
- Summary & files in Gemspec

### Fixed
- Updated gems


## [v1.2.0] - 2019-07-11
### Added
- Commonly-used Stylers and Stylables
- Changelog
- Psychgus.hierarchy()
- SuperSniffer::Parent#child_key?() & #child_value?()

### Changed
- SuperSniffer's parent will never be nil, so don't have to check for nil in Stylers
- Some doc comments & README
- Gemspec's included files to be more specific (to prevent accidentally adding non-gem-related files)

### Fixed
- Psychgus.dump_stream() if you only pass in a Hash w/ symbols as keys (options would be set to it, instead of objects)


## [v1.0.0] - 2019-07-03
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
