import 'package:open_print_tag/models/open_print_tag_aux_data.dart';
import 'package:open_print_tag/models/open_print_tag_main_data.dart';
import 'package:open_print_tag/models/open_print_tag_meta_data.dart';
import 'package:open_print_tag/src/data/aux_fields.data.g.dart';
import 'package:open_print_tag/src/data/main_fields.data.g.dart';
import 'package:open_print_tag/src/data/meta_fields.data.g.dart';
import 'package:test/test.dart';

void main() {
  group('Schema vs model field coverage', () {
    test('main_fields are all present in OpenPrintTagMainData', () {
      final Set<String> schemaNames = mainFields
          .where((Map<String, Object?> m) => m.containsKey('name'))
          .map((Map<String, Object?> m) => m['name']! as String)
          .toSet();

      // Build a minimal instance (all nulls) to get the generated JSON keys
      const OpenPrintTagMainData model = OpenPrintTagMainData();
      final Set<String> modelKeys = model.toJson().keys.toSet();

      final Set<String> missingInModel = schemaNames
          .difference(modelKeys)
          .toSet();
      expect(
        missingInModel,
        isEmpty,
        reason: 'Missing main fields in model: $missingInModel',
      );
    });

    test('aux_fields are all present in OpenPrintTagAuxData', () {
      final Set<String> schemaNames = auxFields
          .where((Map<String, Object?> m) => m.containsKey('name'))
          .map((Map<String, Object?> m) => m['name']! as String)
          .toSet();

      const OpenPrintTagAuxData model = OpenPrintTagAuxData();
      final Set<String> modelKeys = model.toJson().keys.toSet();

      final Set<String> missingInModel = schemaNames
          .difference(modelKeys)
          .toSet();
      expect(
        missingInModel,
        isEmpty,
        reason: 'Missing aux fields in model: $missingInModel',
      );
    });

    test('meta_fields are all present in OpenPrintTagMetaData', () {
      final Set<String> schemaNames = metaFields
          .where((Map<String, Object?> m) => m.containsKey('name'))
          .map((Map<String, Object?> m) => m['name']! as String)
          .toSet();

      const OpenPrintTagMetaData model = OpenPrintTagMetaData();
      final Set<String> modelKeys = model.toJson().keys.toSet();

      final Set<String> missingInModel = schemaNames
          .difference(modelKeys)
          .toSet();
      expect(
        missingInModel,
        isEmpty,
        reason: 'Missing meta fields in model: $missingInModel',
      );
    });
  });
}
