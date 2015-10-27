# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
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


[unreleased]: https://github.com/c-rack/cidr-elixir/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/c-rack/cidr-elixir/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/c-rack/cidr-elixir/commit/c58275a952ec308e5509bb13455e186c894dc3e0
