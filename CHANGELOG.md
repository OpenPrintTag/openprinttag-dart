# Changelog

## 0.2.5

### Added
- **New aux fields**: Added `purchase_time`, `purchase_price` and `purchase_currency` to `OpenPrintTagAuxData` for customer-private purchase tracking (purchase timestamp, amount paid and ISO 4217 currency code; not filled by the manufacturer)
- **New main fields**: Added `primary_color_lab` (CIELAB `[L*, a*, b*]` values) and `primary_color_ral` (RAL code string, max 16 chars) to `OpenPrintTagMainData`
- **New field type**: Added `color_lab` field type with compact per-component number encoding and validation (`L*` range 0–100)
- **New material type**: Added `PA612` (Polyamide 612) to `MaterialTypeEnum`

### Changed
- **Number encoding**: Extracted `CompactFloat` helper that picks the most compact CBOR representation (int → float16 → float32 → float64); decimals that don't fit float16/float32 are now encoded as float64 instead of throwing
- **Dependencies update**: Updated all dependencies to latest versions
  - `copy_with_extension`: ^14.0.0 → ^15.0.1
  - `json_annotation`: ^4.11.0 → ^4.12.0
  - `build`: ^4.0.4 → ^4.0.6
  - `build_runner`: ^2.11.1 → ^2.15.0
  - `copy_with_extension_gen`: ^14.0.0 → ^15.0.1
  - `dart_style`: ^3.1.2 → ^3.1.9
  - `json_serializable`: ^6.11.3 → ^6.14.0
  - `lints`: ^6.0.0 → ^6.1.0
  - `test`: ^1.26.3 → ^1.31.1
- **Data submodule update**: Updated to latest OpenPrintTag data definitions

## 0.2.4

### Added
- **New aux field**: Added `storage_location` to `OpenPrintTagAuxData` (free-form string, max 8 chars) for recording the physical storage location of a container (e.g. `Shelf B3`, `DB2/S4`). Intended for inventory management workflows.

### Changed
- **Field metadata**: Increased `material_name` `max_length` from 31 to 63 bytes to fit existing materials in the OpenPrintTag database
- **Instance UUID generation**: Refactored `OpenPrintTagData.newInstanceUuid()` to extract UUID derivation into a private helper for clearer fallback handling
- **Data submodule update**: Updated to latest OpenPrintTag data definitions (NFC Data Format spec revision, documentation naming fixes)

## 0.2.3

### Changed
- **Dependencies update**: Updated all dependencies to latest versions
  - `cbor`: ^6.3.7 → ^6.5.1
  - `copy_with_extension`: ^11.0.0 → ^14.0.0
  - `crypto`: ^3.0.6 → ^3.0.7
  - `json_annotation`: ^4.9.0 → ^4.11.0
  - `uuid`: ^4.5.1 → ^4.5.3
  - `build`: ^4.0.1 → ^4.0.4
  - `build_runner`: ^2.9.0 → ^2.11.1
  - `code_builder`: ^4.11.0 → ^4.11.1
  - `copy_with_extension_gen`: ^11.0.0 → ^14.0.0
- **Field metadata**: Added `required: recommended` attribute to `nominal_full_length` and `actual_full_length` fields
- **Data submodule update**: Updated to latest OpenPrintTag data definitions
- **Documentation**: Updated README installation instructions to use git dependency

## 0.2.2

### Added
- **New material type**: Added `EVA` (Ethylene Vinyl Acetate) to `MaterialTypeEnum`
- **New tags**: Added `high_speed` and `contains_graphene` to `TagsEnum`
- **New certification**: Added `UL 2904` to `MaterialCertificationsEnum`
- **Drying fields**: Added `drying_temperature` and `drying_time` fields to `OpenPrintTagMainData`

### Changed
- **Documentation**: Updated specification URL to https://specs.openprinttag.org/#/
- **Repository**: Moved repository to OpenPrintTag organization (git@github.com:OpenPrintTag/openprinttag-dart.git)
- **Data submodule update**: Updated to latest OpenPrintTag data definitions

## 0.2.1

### Changed
- **Dependencies update**: Updated dependencies to latest versions
  - `copy_with_extension`: ^10.0.1 → ^11.0.0
  - `copy_with_extension_gen`: ^10.0.1 → ^11.0.0
  - `json_serializable`: ^6.11.1 → ^6.11.3
  - `ndef`: ^0.3.4 → ^0.4.0

## 0.2.0

### Breaking Changes
- **API refactoring**: `OpenPrintTagParser.decode()` and `encode()` now work with `OpenPrintTagPayload` instead of `OpenPrintTagData`
  - Previously: `Future<OpenPrintTagData> decode(Uint8List payload)`
  - Now: `Future<OpenPrintTagPayload> decode(Uint8List payload)`
  - Previously: `Uint8List encode(OpenPrintTagData data, {required int size})`
  - Now: `Uint8List encode(OpenPrintTagPayload payload, {required int size})`
  - `OpenPrintTagPayload` wraps `OpenPrintTagData` with optional `unknownFields` support

### Added
- **Unknown fields support**: Decode now preserves unknown CBOR fields and encode merges them back
  - New `OpenPrintTagPayload` model wrapping data with `unknownFields`
  - New `UnknownFields` model storing unknown CBOR keys/values as hex strings
  - Unknown fields preserved across decode/encode round-trips
- **CBOR hex utilities**: New `CborHexUtils` class for converting between CBOR values and hex strings
- **JSON validation**: New `JsonValidator` class for validating OpenPrintTag data against schema
  - Validates required fields, types, values, and max lengths
  - Returns structured `ValidationResult` with categorized errors

### Changed
- **Decoder refactoring**: `OpenPrintTagDecoder.decodePayload()` now returns `OpenPrintTagPayload` with unknown fields
- **Encoder refactoring**: `OpenPrintTagEncoder.encodePayload()` now accepts `OpenPrintTagPayload` and merges unknown fields
- **Data submodule update**: Updated to latest OpenPrintTag data definitions

## 0.1.2

### Added
- **Enum array max length validation**: `EnumArrayField` now validates that the number of items doesn't exceed `max_length` constraint (tags max 16, certifications max 8)
- **New test fixture**: Added `04_data.bin` for additional binary parsing tests

### Changed
- **Data submodule update**: Updated to latest OpenPrintTag data definitions with `max_length` support for enum arrays

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
