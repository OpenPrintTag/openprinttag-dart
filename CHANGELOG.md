# Changelog

## 0.0.4

### Fixed
- **AUX data decoding**: Empty AUX section now returns empty `OpenPrintTagAuxData` object instead of `null` when AUX region exists but is empty

## 0.0.3

### Changed
- **AUX section encoding**: Changed from indefinite to definite CBOR container, saving 1 byte
- **AUX offset alignment**: AUX section now aligned to 4-byte boundary for better hardware compatibility
- **UUID generation tests**: Updated tests to match current behavior (UUIDs generated in `fromJson()` only)

## 0.0.2

### Added
- **UUID generation**: Added utility for generating brand and instance UUIDs
- **Brand-specific instance UUID**: New UUID namespace for brand-specific instance identification
- **Binary tests**: Added comprehensive binary test fixtures and tests for NDEF payload validation

### Changed
- **UUID behavior**: UUIDs are now only generated when needed (in `fromJson()` method)
- **UUID generator improvements**: Enhanced UUID generation logic and test coverage

## 0.0.1

Initial release with:

- Encode and decode OpenPrintTag data to/from CBOR
- Compatible with [Python OpenPrintTag library](https://github.com/prusa3d/OpenPrintTag)
- Works with any NDEF library you want
- Smart float compression (uses float16/float32 where possible)
- Automatic enum handling for material types and classes
- Supports meta, main, and auxiliary data sections
- Full test coverage
