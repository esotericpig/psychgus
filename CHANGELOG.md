# Changelog | Psychgus

Format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [[Unreleased]](https://github.com/esotericpig/psychgus/compare/v1.2.1...master)

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
