import 'dart:typed_data';
import 'package:cbor/cbor.dart';
import 'package:open_print_tag/src/cbor/fields/field_types.dart';
import 'package:test/test.dart';

void main() {
  group('IntField', () {
    test('round-trip encode and decode', () {
      final IntField field = IntField(key: 1, name: 'count');

      for (final int value in <int>[0, 42, -100, 255, 65535, -999]) {
        final CborValue encoded = field.encode(value);
        expect(encoded, isA<CborSmallInt>());
        final int decoded = field.decode(encoded);
        expect(decoded, equals(value));
      }
    });
  });

  group('NumberField', () {
    test('encodes integers as CborSmallInt', () {
      final NumberField field = NumberField(key: 2, name: 'temperature');

      final CborValue encoded100 = field.encode(100.0);
      expect(encoded100, isA<CborSmallInt>());
      expect((encoded100 as CborSmallInt).value, equals(100));

      expect(field.encode(0.0), isA<CborSmallInt>());
    });

    test('encodes decimals as CborFloat', () {
      final NumberField field = NumberField(key: 2, name: 'temperature');

      final CborValue encoded = field.encode(3.14);
      expect(encoded, isA<CborFloat>());
      expect(((encoded as CborFloat).value - 3.14).abs(), lessThan(1e-3));
    });

    test('uses float16 for small decimals', () {
      final NumberField field = NumberField(key: 2, name: 'value');

      final List<double> float16Values = <double>[
        0.4,
        0.6,
        1.75,
        2.85,
        210.5,
        99.9,
      ];

      for (final double value in float16Values) {
        final CborValue encoded = field.encode(value);
        expect(encoded, isA<CborFloat>());
        expect(((encoded as CborFloat).value - value).abs(), lessThan(1e-3));
      }
    });

    test('uses float32 for larger values', () {
      final NumberField field = NumberField(key: 2, name: 'value');

      final List<double> float32Values = <double>[12345.67, 0.000123];

      for (final double value in float32Values) {
        final CborValue encoded = field.encode(value);
        expect(encoded, isA<CborFloat>());
        expect(((encoded as CborFloat).value - value).abs(), lessThan(1e-3));
      }
    });

    test('decode rounds to 3 decimal places', () {
      final NumberField field = NumberField(key: 2, name: 'value');

      expect(field.decode(CborFloat(3.14159)), equals(3.142));
      expect(field.decode(CborFloat(1.2345)), equals(1.235));
      expect(field.decode(CborFloat(10.9999)), equals(11.0));
    });

    test('round-trip preserves type', () {
      final NumberField field = NumberField(key: 2, name: 'value');

      expect(field.decode(field.encode(42)), isA<int>());
      expect(field.decode(field.encode(100.0)), isA<int>());

      expect(field.decode(field.encode(3.14)), isA<double>());
      expect(field.decode(field.encode(-10.5)), isA<double>());
    });

    test('round-trip maintains precision', () {
      final NumberField field = NumberField(key: 2, name: 'value');

      final List<double> testValues = <double>[210.5, 0.4, 1.75, 60.5, 100.25];

      for (final double value in testValues) {
        final CborValue encoded = field.encode(value);
        final num decoded = field.decode(encoded);
        expect((decoded - value).abs(), lessThan(1e-3));
      }
    });
  });

  group('StringField', () {
    test('validates maxLength on encode', () {
      final StringField field = StringField(
        key: 3,
        name: 'name',
        maxLength: 10,
      );

      final CborValue encoded = field.encode('hello');
      expect(encoded, isA<CborString>());
      expect((encoded as CborString).toString(), equals('hello'));

      final CborValue encoded2 = field.encode('');
      expect((encoded2 as CborString).toString(), equals(''));

      final CborValue encoded3 = field.encode('1234567890');
      expect((encoded3 as CborString).toString(), equals('1234567890'));

      expect(() => field.encode('too long string'), throwsArgumentError);
    });

    test('round-trip with special characters', () {
      final StringField field = StringField(
        key: 3,
        name: 'name',
        maxLength: 50,
      );

      for (final String value in <String>[
        '',
        'hello',
        'Prusa 🚀',
        'PETG-HF',
        'ěščřžýáí',
      ]) {
        expect(field.decode(field.encode(value)), equals(value));
      }
    });
  });

  group('EnumField', () {
    final Map<int, String> enumItems = <int, String>{
      0: 'PLA',
      1: 'PETG',
      2: 'ABS',
      10: 'FLEX',
    };

    test('encodes name to int key', () {
      final EnumField field = EnumField(
        key: 4,
        name: 'material',
        itemsByKey: enumItems,
      );

      final CborValue encoded1 = field.encode('PLA');
      expect((encoded1 as CborSmallInt).value, equals(0));

      final CborValue encoded2 = field.encode('PETG');
      expect((encoded2 as CborSmallInt).value, equals(1));

      final CborValue encoded3 = field.encode('FLEX');
      expect((encoded3 as CborSmallInt).value, equals(10));
    });

    test('decodes int key to name', () {
      final EnumField field = EnumField(
        key: 4,
        name: 'material',
        itemsByKey: enumItems,
      );

      expect(field.decode(const CborSmallInt(0)), equals('PLA'));
      expect(field.decode(const CborSmallInt(2)), equals('ABS'));
      expect(field.decode(const CborSmallInt(10)), equals('FLEX'));
    });

    test('validates unknown values', () {
      final EnumField field = EnumField(
        key: 4,
        name: 'material',
        itemsByKey: enumItems,
      );

      expect(() => field.encode('UNKNOWN'), throwsArgumentError);
      expect(() => field.decode(const CborSmallInt(99)), throwsArgumentError);
    });

    test('round-trip preserves value', () {
      final EnumField field = EnumField(
        key: 4,
        name: 'material',
        itemsByKey: enumItems,
      );

      for (final String name in <String>['PLA', 'PETG', 'ABS', 'FLEX']) {
        expect(field.decode(field.encode(name)), equals(name));
      }
    });
  });

  group('EnumArrayField', () {
    final Map<int, String> tagItems = <int, String>{
      0: 'FLEXIBLE',
      1: 'SUPPORT',
      2: 'TRANSLUCENT',
    };

    test('encodes array of names to array of int keys', () {
      final EnumArrayField field = EnumArrayField(
        key: 5,
        name: 'tags',
        itemsByKey: tagItems,
        maxLength: 16,
      );

      final CborValue encoded = field.encode(<String>[
        'FLEXIBLE',
        'TRANSLUCENT',
      ]);
      expect(encoded, isA<CborList>());
      final List<CborValue> encodedList = (encoded as CborList).toList();
      expect(encodedList.length, equals(2));
      expect((encodedList[0] as CborSmallInt).value, equals(0));
      expect((encodedList[1] as CborSmallInt).value, equals(2));
      expect(field.encode(<dynamic>[]), isEmpty);
    });

    test('decodes array of keys to array of names', () {
      final EnumArrayField field = EnumArrayField(
        key: 5,
        name: 'tags',
        itemsByKey: tagItems,
        maxLength: 16,
      );

      expect(
        field.decode(
          CborList(<CborValue>[
            const CborSmallInt(0),
            const CborSmallInt(1),
            const CborSmallInt(2),
          ]),
        ),
        equals(<String>['FLEXIBLE', 'SUPPORT', 'TRANSLUCENT']),
      );
      expect(field.decode(CborList(<CborValue>[])), isEmpty);
    });

    test('validates all items in array', () {
      final EnumArrayField field = EnumArrayField(
        key: 5,
        name: 'tags',
        itemsByKey: tagItems,
        maxLength: 16,
      );

      expect(
        () => field.encode(<String>['FLEXIBLE', 'INVALID']),
        throwsArgumentError,
      );
      expect(
        () => field.decode(
          CborList(<CborValue>[const CborSmallInt(0), const CborSmallInt(99)]),
        ),
        throwsArgumentError,
      );
    });

    test('round-trip preserves order', () {
      final EnumArrayField field = EnumArrayField(
        key: 5,
        name: 'tags',
        itemsByKey: tagItems,
        maxLength: 16,
      );

      final List<String> tags = <String>['TRANSLUCENT', 'FLEXIBLE', 'SUPPORT'];
      expect(field.decode(field.encode(tags)), equals(tags));
    });

    test('validates maxLength constraint', () {
      final EnumArrayField field = EnumArrayField(
        key: 5,
        name: 'tags',
        itemsByKey: tagItems,
        maxLength: 2,
      );

      // Should pass with 2 items
      expect(
        () => field.encode(<String>['FLEXIBLE', 'SUPPORT']),
        returnsNormally,
      );

      // Should fail with 3 items
      expect(
        () => field.encode(<String>['FLEXIBLE', 'SUPPORT', 'TRANSLUCENT']),
        throwsArgumentError,
      );
    });
  });

  group('BytesField', () {
    test('decodes to hex dict format', () {
      final BytesField field = BytesField(key: 6, name: 'data', maxLength: 32);
      final Uint8List bytes = Uint8List.fromList(<int>[0xDE, 0xAD, 0xBE, 0xEF]);

      final Map<String, dynamic> result = field.decode(CborBytes(bytes));
      expect(result, isA<Map<String, dynamic>>());
      expect(result['hex'], equals('deadbeef'));
    });

    test('encodes from hex dict', () {
      final BytesField field = BytesField(key: 6, name: 'data', maxLength: 32);

      final CborValue encoded1 = field.encode(<String, String>{
        'hex': 'deadbeef',
      });
      expect(encoded1, isA<CborBytes>());
      expect(
        (encoded1 as CborBytes).bytes,
        equals(<int>[0xDE, 0xAD, 0xBE, 0xEF]),
      );

      final CborValue encoded2 = field.encode(<String, String>{
        'hex': 'de:ad:be:ef',
      });
      expect(encoded2, isA<CborBytes>());
      expect(
        (encoded2 as CborBytes).bytes,
        equals(<int>[0xDE, 0xAD, 0xBE, 0xEF]),
      );
    });

    test('encodes from List<int> and Uint8List', () {
      final BytesField field = BytesField(key: 6, name: 'data', maxLength: 32);

      final CborValue encoded1 = field.encode(<int>[0xAB, 0xCD]);
      expect(encoded1, isA<CborBytes>());
      expect((encoded1 as CborBytes).bytes, equals(<int>[0xAB, 0xCD]));

      final CborValue encoded2 = field.encode(
        Uint8List.fromList(<int>[1, 2, 3]),
      );
      expect(encoded2, isA<CborBytes>());
      expect((encoded2 as CborBytes).bytes, equals(<int>[1, 2, 3]));
    });

    test('encodes from integer', () {
      final BytesField field = BytesField(key: 6, name: 'data', maxLength: 32);

      final CborValue encoded1 = field.encode(0x0102);
      expect((encoded1 as CborBytes).bytes, equals(<int>[0x02, 0x01]));

      final CborValue encoded2 = field.encode(255);
      expect((encoded2 as CborBytes).bytes, equals(<int>[0xFF]));

      final CborValue encoded3 = field.encode(0);
      expect((encoded3 as CborBytes).bytes, equals(<int>[]));
    });

    test('validates maxLength', () {
      final BytesField field = BytesField(key: 6, name: 'data', maxLength: 4);

      expect(() => field.encode(<int>[1, 2, 3, 4, 5]), throwsArgumentError);

      final CborValue encoded = field.encode(<int>[1, 2, 3, 4]);
      expect((encoded as CborBytes).bytes, hasLength(4));
    });

    test('round-trip through hex dict', () {
      final BytesField field = BytesField(
        key: 6,
        name: 'serial',
        maxLength: 16,
      );
      final Uint8List originalBytes = Uint8List.fromList(<int>[
        1,
        2,
        3,
        0xAB,
        0xCD,
        0xEF,
      ]);

      final Map<String, dynamic> decoded = field.decode(
        CborBytes(originalBytes),
      );
      final CborValue reencodedCbor = field.encode(decoded);
      expect(reencodedCbor, isA<CborBytes>());
      final Uint8List reencoded = Uint8List.fromList(
        (reencodedCbor as CborBytes).bytes,
      );
      expect(reencoded, equals(originalBytes));
    });
  });

  group('UuidField', () {
    test('encodes UUID string to exactly 16 bytes', () {
      final UuidField field = UuidField(key: 7, name: 'id');

      const String uuid = '550e8400-e29b-41d4-a716-446655440000';
      final CborValue encodedCbor = field.encode(uuid);

      expect(encodedCbor, isA<CborBytes>());
      final List<int> result = (encodedCbor as CborBytes).bytes;
      expect(result.length, equals(16));
    });

    test('decodes 16 bytes to formatted UUID string', () {
      final UuidField field = UuidField(key: 7, name: 'id');

      final Uint8List bytes = Uint8List.fromList(<int>[
        0x55, 0x0e, 0x84, 0x00, //
        0xe2, 0x9b, //
        0x41, 0xd4, //
        0xa7, 0x16, //
        0x44, 0x66, 0x55, 0x44, 0x00, 0x00,
      ]);

      final String result = field.decode(CborBytes(bytes));
      expect(result, equals('550e8400-e29b-41d4-a716-446655440000'));
      expect(result, contains('-'));
      expect(result.length, equals(36));
    });

    test('round-trip preserves UUID', () {
      final UuidField field = UuidField(key: 7, name: 'id');

      const String originalUuid = '123e4567-e89b-12d3-a456-426614174000';
      final CborValue encoded = field.encode(originalUuid);
      final String decoded = field.decode(encoded);

      expect(decoded, equals(originalUuid));
    });
  });
}
