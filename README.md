# OpenPrintTag

Encode and decode OpenPrintTag data to/from CBOR format.

## Features

- Works with any NDEF library (ndef, ndef_record, or your own)
- Handles material info: type, temperatures, brand, colors, etc.
- Smart float compression (saves space on NFC tags)
- Automatic enum conversion
- Supports meta, main, and aux data sections

## Usage

This library handles the CBOR encoding/decoding. You handle the NDEF and NFC parts with whatever library you like.

```dart
import 'dart:typed_data';
import 'package:open_print_tag/open_print_tag.dart';

// Example using package:ndef (you can use any NDEF library)
import 'package:ndef/ndef.dart' as ndef;

void main() async {
  // Create parser (uses generated data constants - synchronous)
  final parser = OpenPrintTagParser.create();
  
  // === READING ===
  // 1. Read NDEF message using your preferred NDEF library
  // final records = ndef.decodeRawNdefMessage(rawBytes);
  
  // 2. Find and extract the OpenPrintTag MIME record payload
  // Look for MIME type: OpenPrintTagConstants.mimeType
  // final payload = extractPayloadFromMimeRecord(records);
  
  // 3. Decode the binary payload
  // final data = await parser.decode(payload);
  // print('Material: ${data.main?.materialName}');
  // print('Type: ${data.main?.materialType}'); // Enums are automatically converted to strings
  
  // === WRITING ===
  // 1. Create material data
  final newData = OpenPrintTagData(
    main: OpenPrintTagMainData(
      materialClass: 'FFF',
      materialType: 'PLA',
      materialName: 'My PLA',
      minPrintTemperature: 200,
      minBedTemperature: 60,
    ),
  );
  
  // 2. Encode to binary payload
  final Uint8List payload = parser.encode(newData);
  
  // 3. Wrap in NDEF MIME record using your preferred NDEF library
  final record = ndef.MimeRecord(
    decodedType: OpenPrintTagConstants.mimeType,
    payload: payload,
  );
  
  // 4. Write to NFC tag using your NFC library
  // await nfcLib.writeNdefMessage([record]);
}
```

### MIME Type

Use `application/vnd.openprinttag` when creating NDEF MIME records.
It's available as `OpenPrintTagConstants.mimeType`.

### What this library does

- ✅ Converts `OpenPrintTagData` to CBOR bytes
- ✅ Converts CBOR bytes back to `OpenPrintTagData`
- ✅ Handles all the encoding details for you

### What you need to provide

- NDEF record handling (wrap/unwrap the CBOR payload)
- NFC tag communication
- Your choice of NDEF library

Think of it this way: you handle getting data on/off the NFC tag, we handle the OpenPrintTag format.