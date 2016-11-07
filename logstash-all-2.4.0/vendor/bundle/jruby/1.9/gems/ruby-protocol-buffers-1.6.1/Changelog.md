# Change Log
All notable changes to this project will be documented in this file.

## 1.6.1 - 2014-09-24
### Changed
- Fix gem packaging error.

## 1.6.0 - 2014-09-22
### Added
- More metaprogramming support via `get_expected_field`, `get_optional_field`.
- Ruby 2.1 support.
- Protocol Buffers text format support.

### Changed
- Fixed Windows line ending bug in encoder.
- README syntax highlighting.

### Removed
- Dropped Ruby 1.8.7 support.

## 1.5.1 - 2013-10-28
### Added
- Better value semantics for `Message`, including `==`, `eql?`, and `hash`.

## 1.5.0 - 2013-09-19
### Added
- `Message#to_hash`
- Service and RPC classes, as a common interface for other libraries to build on.

### Changed
- Fix for repeated fields being set to itself.

## 1.4.1 - 2013-07-19
### Changed
- Fix for frozen strings as input.

## 1.4.0 - 2013-06-18
### Added
- Support protobuf groups.
- Add new executable protoc-gen-ruby, for the new protoc plugin support.

## 1.3.3 - 2013-03-22
### Added
- Validate UTF8 while encoding.
- Support packed fields.

## 1.3.1 - 2013-02-17
### Added
- Move deactivated varint c extension to a separate gem.
- Use the varint gem, if it has been loaded.

## 1.3.0 - 2013-01-17
### Added
- Improved documentation and README.

## 1.2.3.beta2 - 2012-12-18
### Added
- Better error reporting while parsing invalid messages.
- UTF-8 validation of string fields in ruby 1.9+.

### Changed
- Fixed 32-bit negative numbers.
- Fix encoding of strings in parsed messages.
- Fix for recursive message types.

## 1.2.1 - 2011-10-01
### Added
- Translate package names to submodules.
- Mirror packages as directory structure.

## 1.1.0 - 2011-09-19
### Removed
- Remove package unloading support.

## 1.0.1 - 2011-03-20
### Added
- Treat unknown enum values as unknown fields.

## 1.0.0

## 0.8.5
### Added
- Add support for Microsoft Windows (tested on Windows 7)
- Fix StringIO encoding issues on Ruby 1.9.2 by explicitly setting binary encoding.
