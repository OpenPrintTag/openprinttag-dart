# Changelog

## 0.1.1

### Added
- **Material certifications**: New `MaterialCertificationsEnum` enum with `UL 2818` and `UL 94 V0` certifications
- **Certifications field**: New `certifications` field in `OpenPrintTagMainData` for storing material certifications

### Changed
- **Color field type**: Colors (`primary_color`, `secondary_color_*`) now use dedicated `color_rgba` field type instead of generic `bytes`
- **Builder refactoring**: Simplified `yaml_enum_builder.dart` with dynamic loop instead of hardcoded mappings
- **Data submodule update**: Updated to latest OpenPrintTag data definitions

## 0.1.0

### Breaking Changes
- **Enums refactored to native Dart enums**: All enums (`MaterialClassEnum`, `MaterialTypeEnum`, `TagsEnum`, `TagCategoriesEnum`, `WriteProtectionEnum`) are now proper Dart enums instead of maps
  - Previously: `Map<int, String>` in `lib/src/data/*.data.g.dart`
  - Now: `enum MaterialClassEnum` in `lib/src/enums/*.enum.g.dart`
  - Enums have `key` property and static `byKey(int)` method
  - Some enums have additional properties: `name`, `category`
  - Access via `MaterialClassEnum.FFF.name` instead of map lookup

### Added
- **Dart enum generator**: New `yaml_enum_builder` generates native Dart enums from YAML definitions
- **Enum utilities**: Shared utilities in `yaml_builder_utils.dart` for enum generation
- **Enum barrel file**: All enums exported via `lib/src/enums/enums.dart`

### Changed
- **FieldsManager simplified**: No longer requires `enumsData` parameter, uses enum classes directly
- **Enum location**: Moved from `lib/src/data/` to `lib/src/enums/`
- **Build configuration**: Updated `build.yaml` for new enum generator
- **Tests updated**: All tests adapted to use new enum structure

## 0.0.14

### Added
- **Tests**: Comprehensive color encoding tests for RGB and RGBA formats including alpha channel support

## 0.0.13

### Added
- **Tests**: Added coverage for handling and preserving unknown fields in `FieldsManager` (decode collects unknown CBOR keys into `unknown_fields`; encode merges them back).
- **NDEF binary tests**: Extended suite to include `03_data.bin` fixture and verified round-trip encoding preserves unknown fields.

## 0.0.12

### Added
- **Tests**: Schema vs model sync tests to ensure all fields from generated schemas are present in models (MAIN, AUX, META)

### Docs
- **README**: Removed confusing note about "Common tag sizes" for NTAG21x

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
