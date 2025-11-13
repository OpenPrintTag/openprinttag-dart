import 'package:cbor/cbor.dart';
import 'package:open_print_tag/open_print_tag.dart';
import 'package:open_print_tag/src/data/aux_fields.data.g.dart' as aux_data;
import 'package:open_print_tag/src/data/main_fields.data.g.dart' as main_data;
import 'package:open_print_tag/src/data/material_class_enum.data.g.dart'
    as material_class_data;
import 'package:open_print_tag/src/data/material_type_enum.data.g.dart'
    as material_type_data;
import 'package:open_print_tag/src/data/tags_enum.data.g.dart' as tags_data;
import 'package:open_print_tag/src/data/write_protection_enum.data.g.dart'
    as write_protection_data;
import 'package:test/test.dart';

void main() {
  late FieldsManager mainFields;
  late FieldsManager auxFields;

  setUpAll(() {
    final Map<String, List<Map<String, Object?>>> enumsData =
        <String, List<Map<String, Object?>>>{
          'material_class_enum.yaml': material_class_data.materialClassEnum,
          'material_type_enum.yaml': material_type_data.materialTypeEnum,
          'tags_enum.yaml': tags_data.tagsEnum,
          'write_protection_enum.yaml':
              write_protection_data.writeProtectionEnum,
        };

    mainFields = FieldsManager.fromData(
      main_data.mainFields,
      enumsData: enumsData,
    );
    auxFields = FieldsManager.fromData(
      aux_data.auxFields,
      enumsData: enumsData,
    );
  });

  group('FieldsManager unknown fields', () {
    test('decode collects unknown CBOR keys into unknown_fields', () {
      final Map<CborSmallInt, CborValue> input = <CborSmallInt, CborValue>{
        const CborSmallInt(999): const CborSmallInt(42),
        const CborSmallInt(998): CborString('future'),
      };

      final Map<String, dynamic> decoded = mainFields.decode(input);

      expect(decoded.containsKey('unknown_fields'), true);
      final Map<int, CborValue> uf =
          decoded['unknown_fields'] as Map<int, CborValue>;
      expect(uf.length, 2);
      expect(uf[999], isA<CborSmallInt>());
      expect((uf[999] as CborSmallInt).value, 42);
      expect(uf[998], isA<CborString>());
      expect((uf[998] as CborString).toString(), 'future');
    });

    test('encode merges unknown_fields into CBOR map (MAIN)', () {
      final Map<String, dynamic> data = <String, dynamic>{
        'material_class': 'FFF',
        'material_type': 'PLA',
        'unknown_fields': <int, CborValue>{
          777: const CborSmallInt(7),
          778: CborString('x'),
        },
      };

      final Map<int, CborValue> encoded = mainFields.encode(data);

      // Unknown keys should be present unchanged
      expect(encoded[777], isA<CborSmallInt>());
      expect((encoded[777] as CborSmallInt).value, 7);
      expect(encoded[778], isA<CborString>());
      expect((encoded[778] as CborString).toString(), 'x');
    });

    test('encode merges unknown_fields into CBOR map (AUX)', () {
      final Map<String, dynamic> data = <String, dynamic>{
        // Provide at least optional/valid known aux field(s) if needed later
        'unknown_fields': <int, CborValue>{701: const CborSmallInt(123)},
      };

      final Map<int, CborValue> encoded = auxFields.encode(data);
      expect(encoded[701], isA<CborSmallInt>());
      expect((encoded[701] as CborSmallInt).value, 123);
    });
  });
}
