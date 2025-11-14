# OpenPrintTag (Dart)

Dart/Flutter library for encoding and decoding OpenPrintTag data on NFC tags. Based on the [Python OpenPrintTag library](https://github.com/prusa3d/OpenPrintTag).

## Installation

```yaml
dependencies:
  open_print_tag: ^0.1.0
```

## Usage

```dart
import 'package:open_print_tag/open_print_tag.dart';

// Create parser
final parser = OpenPrintTagParser.create();

// Write data
final data = OpenPrintTagData(
  main: OpenPrintTagMainData(
    materialClass: MaterialClassEnum.FFF,
    materialType: MaterialTypeEnum.PLA,
    materialName: 'My PLA',
    minPrintTemperature: 200,
    minBedTemperature: 60,
  ),
);

final payload = parser.encode(data, size: 320); // 320 bytes for NTAG213

// Read data
final decoded = await parser.decode(payload);
print('Material: ${decoded.main?.materialName}');
```

### Working with NDEF

The library handles OpenPrintTag CBOR encoding. You'll need an NDEF library to actually read/write NFC tags.

MIME type: `application/vnd.openprinttag` (available as `OpenPrintTagConstants.mimeType`)

## Development

### Updating Data Definitions

This library uses a Git submodule to track data definitions (field schemas, enums) from the upstream [OpenPrintTag repository](https://github.com/prusa3d/OpenPrintTag).

To update to the latest definitions:

```bash
make update-data
```

## Links

- [OpenPrintTag (Python)](https://github.com/prusa3d/OpenPrintTag) - Original implementation
- [Specification](https://specs.prusa3d.tech/) - Format docs
- [Repository](https://github.com/prusa3d/OpenPrintTag-dart)

## License

MIT