# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [1.1.0] - 2017-06-12
### Added
- Provide stream of hosts for a cidr range (@tehhobbit)
- String.Chars for easy printing (@tehhobbit)
- CIDR.split + tests for split and hosts (@tehhobbit)
- Methods for comparing (@tehhobbit)

### Changed
- Updated Elixir version to 1.3
- Updated dependencies

### Fixed
- Elixir 1.4 compiler warning (@tmepple)
- Elixir 1.3 compiler warnings
- Credo warnings

## [1.0.0] - 2016-03-06
### Changed
- Changed license to MPLv2
- Updated dependencies

### Removed
- `start`/`end` in CIDR struct

## [0.5.0] - 2016-01-16
### Added
- CIDR struct now uses `first`/`end` for IP range
- Credo code lint checker to dev/test dependencies

### Changed
- Travis-CI uses now caching
- Updated dependencies

### Deprecated
- Usage of `start`/`end` in CIDR struct

### Fixed
- All warnings produced by credo code lint checker

### Removed
- Link to hexdocs, because hex.pm shows this automatically

## [0.4.0] - 2015-11-22
### Added
- Code documentation
- Code coverage and badge
- Inch-CI reporting and badge
- Tests for IPv6 `match/2`
- Usage examples

### Fixed
- Error reason is not promoted
- Number of hosts not correct for IPv6 CIDR

### Removed
- Unused method `mask_by_ip/1`

## [0.3.0] - 2015-10-27
### Added
- Support for IPv6 ([Laurens Duijvesteijn](https://github.com/duijf))
- `match!/2` ([Laurens Duijvesteijn](https://github.com/duijf))

### Changed
- `match/2` return type
- `%CIDR{}` struct
- `min/1` and `max/1` are now private
- min/max values are now stored directly in CIDR struct

## [0.2.0] - 2015-05-03
### Added
- `min/1` and `max/1`

### Fixed
- Warnings

## [0.1.0] - 2015-04-26
### Added
- Initial commit


[unreleased]: https://github.com/c-rack/cidr-elixir/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/c-rack/cidr-elixir/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/c-rack/cidr-elixir/compare/v0.5.0...v1.0.0
[0.5.0]: https://github.com/c-rack/cidr-elixir/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/c-rack/cidr-elixir/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/c-rack/cidr-elixir/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/c-rack/cidr-elixir/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/c-rack/cidr-elixir/commit/c58275a952ec308e5509bb13455e186c894dc3e0
