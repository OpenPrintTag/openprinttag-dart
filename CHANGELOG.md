# Changelog

## 0.0.13

### Added
- **Tests**: Added coverage for handling and preserving unknown fields in `FieldsManager` (decode collects unknown CBOR keys into `unknown_fields`; encode merges them back).
- **NDEF binary tests**: Extended suite to include `03_data.bin` fixture and verified round-trip encoding preserves unknown fields.

## 0.0.12

### Added
- **Tests**: Schema vs model sync tests to ensure all fields from generated schemas are present in models (MAIN, AUX, META)

### Docs
- **README**: Removed confusing note about “Common tag sizes” for NTAG21x

## 0.0.11

### Added
- **Main data**: New `country_of_origin` field (2-letter country code)

### Changed
- **Data submodule update**: Updated to latest OpenPrintTag data definitions
- **Generated data**: Regenerated `lib/src/data/main_fields.data.g.dart`
- **Model**: Updated `OpenPrintTagMainData` to include `country_of_origin`

## 0.0.10

### Added
- **CopyWith extension**: `OpenPrintTagData` now supports `copyWith()` method
- **Tag categories**: Tags now include category and display name metadata

### Changed
- **Data submodule update**: Updated to latest OpenPrintTag data definitions

## 0.0.9

### Added
- **`newInstanceUuid()` method**: Generate new instance UUID for `OpenPrintTagData`

### Changed
- **UUID generator refactoring**: Simplified code structure with shared helper methods

## 0.0.8

### Changed
- **AUX section encoding**: Changed back to indefinite CBOR container for better flexibility

### Added
- **`encodeAuxSection` method**: New public method in `OpenPrintTagParser` for encoding AUX data directly to bytes

### Removed
- **BREAKING**: Removed `updateAux` method from `OpenPrintTagParser` - use `encodeAuxSection` instead for lower-level AUX encoding
- **Internal**: Removed `OpenPrintTagUpdate` class and `lib/src/cbor/update.dart`

## 0.0.7

### Added
- **Makefile**: Added `make update-data` command for easy submodule updates
- **CI check**: Automated validation of generated files freshness
- **Development docs**: Added instructions for maintaining data definitions

## 0.0.6

### Changed
- **Data files**: Replaced local YAML files with Git submodule from upstream OpenPrintTag repository for automatic updates

## 0.0.5

### Changed
- **Enum field refactoring**: Extracted common logic from `EnumField` and `EnumArrayField` into shared `EnumFieldBase` class to reduce code duplication

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
