import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'package:open_print_tag/open_print_tag.dart';
import 'package:test/test.dart';

void main() {
  late OpenPrintTagParser parser;

  setUpAll(() {
    parser = OpenPrintTagParser.create();
  });

  group('NDEF Binary Tag Tests', () {
    test('loads and parses 01_data.bin', () async {
      await _testBinaryFile('test/fixtures/01_data.bin', parser);
    });

    test('loads and parses 02_data.bin', () async {
      await _testBinaryFile('test/fixtures/02_data.bin', parser);
    });

    test('loads and parses 03_data.bin', () async {
      await _testBinaryFile('test/fixtures/03_data.bin', parser);
    });

    test('loads and parses 04_data.bin', () async {
      await _testBinaryFile('test/fixtures/04_data.bin', parser);
    });

    test('loads and parses unknown_data_1.bin', () async {
      await _testBinaryFile('test/fixtures/unknown_data_1.bin', parser);
    });

    test('loads and parses unknown_data_2.bin', () async {
      await _testBinaryFile('test/fixtures/unknown_data_2.bin', parser);
    });
  });

  group('Round-trip encode/decode with modifications', () {
    test(
      '01_data.bin: modify value and verify unknown fields preserved',
      () async {
        await _testRoundTripWithModification(
          'test/fixtures/01_data.bin',
          parser,
        );
      },
    );

    test(
      '02_data.bin: modify value and verify unknown fields preserved',
      () async {
        await _testRoundTripWithModification(
          'test/fixtures/02_data.bin',
          parser,
        );
      },
    );

    test(
      'unknown_data_1.bin: modify value and verify unknown fields preserved',
      () async {
        await _testRoundTripWithModification(
          'test/fixtures/unknown_data_1.bin',
          parser,
        );
      },
    );

    test(
      'unknown_data_2.bin: modify value and verify unknown fields preserved',
      () async {
        await _testRoundTripWithModification(
          'test/fixtures/unknown_data_2.bin',
          parser,
        );
      },
    );
  });
}

Future<void> _testBinaryFile(String filePath, OpenPrintTagParser parser) async {
  final File file = File(filePath);
  final Uint8List bytes = await file.readAsBytes();

  print('Loaded ${bytes.length} bytes from ${filePath.split('/').last}');

  final Uint8List? ndefBytes = _extractNdefTlv(bytes);
  expect(ndefBytes, isNotNull, reason: 'Should find NDEF TLV in binary data');

  final List<ndef.NDEFRecord> records = ndef.decodeRawNdefMessage(ndefBytes!);
  print('Found ${records.length} NDEF records');

  final Uint8List? openPrintTagPayload = _findOpenPrintTagPayload(records);
  expect(
    openPrintTagPayload,
    isNotNull,
    reason: 'Should find OpenPrintTag MIME record',
  );

  print('Found OpenPrintTag payload: ${openPrintTagPayload!.length} bytes');

  final OpenPrintTagData data = await parser.decode(openPrintTagPayload);
  expect(data, isNotNull);
  print('✅ Successfully decoded\n');

  _inspectData(data);
}

void _inspectData(OpenPrintTagData data) {
  final Map<String, dynamic> json = data.toJson();

  final JsonEncoder encoder = JsonEncoder.withIndent(
    '  ',
    (dynamic obj) => obj.toString(),
  );
  final String prettyJson = encoder.convert(json);

  print('📦 Decoded OpenPrintTag Data:');
  print(prettyJson);
  print('');
}

Uint8List? _extractNdefTlv(Uint8List data) {
  const int ndefMagic = 0xE1;
  const int ndefTlvType = 0x03;
  const int nullTlv = 0x00;
  const int terminatorTlv = 0xFE;
  const int extendedLengthMarker = 0xFF;
  const int capabilityContainerSize = 4;

  int offset = data.length >= 4 && data[0] == ndefMagic
      ? capabilityContainerSize
      : 0;

  while (offset < data.length) {
    if (data[offset] == ndefTlvType) {
      offset++;
      if (offset >= data.length) {
        break;
      }

      int length = data[offset++];

      if (length == extendedLengthMarker) {
        if (offset + 1 >= data.length) {
          break;
        }
        length = (data[offset] << 8) | data[offset + 1];
        offset += 2;
      }

      if (offset + length > data.length) {
        break;
      }

      return data.sublist(offset, offset + length);
    } else if (data[offset] == nullTlv) {
      offset++;
    } else if (data[offset] == terminatorTlv) {
      break;
    } else {
      offset++;
      if (offset < data.length) {
        offset += 1 + data[offset];
      }
    }
  }

  return null;
}

Uint8List? _findOpenPrintTagPayload(List<ndef.NDEFRecord> records) {
  for (final ndef.NDEFRecord record in records) {
    if (record is ndef.MimeRecord &&
        record.decodedType == OpenPrintTagConstants.mimeType) {
      return record.payload;
    }
  }
  return null;
}

Future<void> _testRoundTripWithModification(
  String filePath,
  OpenPrintTagParser parser,
) async {
  final File file = File(filePath);
  final Uint8List bytes = await file.readAsBytes();

  final Uint8List? ndefBytes = _extractNdefTlv(bytes);
  expect(ndefBytes, isNotNull);

  final List<ndef.NDEFRecord> records = ndef.decodeRawNdefMessage(ndefBytes!);
  final Uint8List? openPrintTagPayload = _findOpenPrintTagPayload(records);
  expect(openPrintTagPayload, isNotNull);

  final OpenPrintTagData originalData = await parser.decode(
    openPrintTagPayload!,
  );

  final Map<int, dynamic>? originalMainUnknownFields =
      originalData.main?.unknownFields;
  final Map<int, dynamic>? originalAuxUnknownFields =
      originalData.aux?.unknownFields;
  final OpenPrintTagMetaData? originalMeta = originalData.meta;

  final OpenPrintTagMainData? modifiedMain = originalData.main?.copyWith(
    materialClass: originalData.main?.materialClass ?? MaterialClassEnum.FFF,
    materialType: originalData.main?.materialType ?? MaterialTypeEnum.PLA,
    minPrintTemperature: (originalData.main?.minPrintTemperature ?? 200) + 10,
  );

  final OpenPrintTagData modifiedData = OpenPrintTagData(
    meta: originalData.meta,
    main: modifiedMain,
    aux: originalData.aux,
  );

  final Uint8List encodedPayload = originalMeta != null
      ? parser.encode(modifiedData, size: openPrintTagPayload.length)
      : parser.encode(modifiedData, size: 320);

  final OpenPrintTagData redecodedData = await parser.decode(encodedPayload);

  expect(
    redecodedData.main?.minPrintTemperature,
    (originalData.main?.minPrintTemperature ?? 200) + 10,
  );

  if (originalMainUnknownFields != null) {
    expect(redecodedData.main?.unknownFields, isNotNull);
    expect(
      redecodedData.main!.unknownFields!.length,
      originalMainUnknownFields.length,
    );

    for (final MapEntry<int, dynamic> entry
        in originalMainUnknownFields.entries) {
      expect(redecodedData.main!.unknownFields!.containsKey(entry.key), true);
      _compareUnknownFieldValues(
        entry.value,
        redecodedData.main!.unknownFields![entry.key],
        'MAIN field ${entry.key}',
      );
    }
  }

  if (originalAuxUnknownFields != null) {
    expect(redecodedData.aux?.unknownFields, isNotNull);
    expect(
      redecodedData.aux!.unknownFields!.length,
      originalAuxUnknownFields.length,
    );

    for (final MapEntry<int, dynamic> entry
        in originalAuxUnknownFields.entries) {
      expect(redecodedData.aux!.unknownFields!.containsKey(entry.key), true);
      _compareUnknownFieldValues(
        entry.value,
        redecodedData.aux!.unknownFields![entry.key],
        'AUX field ${entry.key}',
      );
    }
  }

  expect(redecodedData.meta, isNotNull);
  expect(redecodedData.meta!.auxRegionOffset, isNotNull);
}

void _compareUnknownFieldValues(
  dynamic original,
  dynamic redecoded,
  String fieldName,
) {
  if (original.runtimeType != redecoded.runtimeType) {
    fail(
      '$fieldName: type mismatch - ${original.runtimeType} vs ${redecoded.runtimeType}',
    );
  }

  if (original is CborSmallInt && redecoded is CborSmallInt) {
    expect(
      redecoded.value,
      original.value,
      reason: '$fieldName value mismatch',
    );
  } else if (original is CborInt && redecoded is CborInt) {
    expect(
      redecoded.toInt(),
      original.toInt(),
      reason: '$fieldName value mismatch',
    );
  } else if (original is CborString && redecoded is CborString) {
    expect(
      redecoded.toString(),
      original.toString(),
      reason: '$fieldName value mismatch',
    );
  } else if (original is CborBytes && redecoded is CborBytes) {
    expect(
      redecoded.bytes,
      original.bytes,
      reason: '$fieldName value mismatch',
    );
  } else if (original is CborFloat && redecoded is CborFloat) {
    expect(
      redecoded.value,
      original.value,
      reason: '$fieldName value mismatch',
    );
  } else {
    expect(redecoded, original, reason: '$fieldName value mismatch');
  }
}
