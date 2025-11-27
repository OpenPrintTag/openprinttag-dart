import 'package:cbor/cbor.dart';
import 'package:open_print_tag/src/cbor/fields/field_types.dart';
import 'package:open_print_tag/src/enums/enums.dart';

typedef AssetLoader = Future<String> Function(String assetPath);

class FieldsManager {
  final Map<int, Field> fieldsByKey = <int, Field>{};
  final Map<String, Field> fieldsByName = <String, Field>{};

  /// Creates a FieldsManager from generated data constants
  static FieldsManager fromData(List<Map<String, Object?>> fieldsData) {
    final FieldsManager manager = FieldsManager();

    for (final Map<String, Object?> item in fieldsData) {
      if (item['deprecated'] == true) {
        continue;
      }

      final Field field = _createFieldFromData(item);
      manager._addField(field);
    }

    return manager;
  }

  static Field _createFieldFromData(Map<String, Object?> config) {
    final int key = config['key'] as int;
    final String name = config['name'] as String;
    final String type = config['type'] as String;
    final bool required = _parseRequired(config['required']);

    final FieldType fieldType = FieldType.fromString(type);

    return switch (fieldType) {
      FieldType.bool => BoolField(key: key, name: name, required: required),

      FieldType.int ||
      FieldType.timestamp => IntField(key: key, name: name, required: required),

      FieldType.number => NumberField(key: key, name: name, required: required),

      FieldType.string => StringField(
        key: key,
        name: name,
        maxLength: config['max_length'] as int,
        required: required,
      ),

      FieldType.enumeration => () {
        // Get enum data directly from enum classes based on field name
        final Map<int, String>? itemsByKey = _getEnumItemsFromClass(name);

        if (itemsByKey == null) {
          throw ArgumentError(
            'Unknown enum field: $name. Add it to _getEnumItemsFromClass.',
          );
        }

        return EnumField(
          key: key,
          name: name,
          itemsByKey: itemsByKey,
          required: required,
        );
      }(),

      FieldType.enumArray => () {
        // Get enum data directly from enum classes based on field name
        final Map<int, String>? itemsByKey = _getEnumItemsFromClass(name);

        if (itemsByKey == null) {
          throw ArgumentError(
            'Unknown enum field: $name. Add it to _getEnumItemsFromClass.',
          );
        }

        return EnumArrayField(
          key: key,
          name: name,
          itemsByKey: itemsByKey,
          required: required,
        );
      }(),

      FieldType.colorRgba => ColorRgbaField(
        key: key,
        name: name,
        required: required,
      ),

      FieldType.bytes => BytesField(
        key: key,
        name: name,
        maxLength: config['max_length'] as int?,
        required: required,
      ),

      FieldType.uuid => UuidField(key: key, name: name, required: required),
    };
  }

  static Map<int, String>? _getEnumItemsFromClass(String fieldName) {
    switch (fieldName) {
      case 'material_class':
        return <int, String>{
          for (final MaterialClassEnum value in MaterialClassEnum.values)
            value.key: (value as Enum).name, // 'FFF', 'SLA'
        };
      case 'material_type':
        return <int, String>{
          for (final MaterialTypeEnum value in MaterialTypeEnum.values)
            value.key: (value as Enum).name, // 'PLA', 'PETG', etc.
        };
      case 'tags':
        return <int, String>{
          for (final TagsEnum value in TagsEnum.values)
            value.key: (value as Enum).name, // 'filtration_recommended', etc.
        };
      case 'write_protection':
        return <int, String>{
          for (final WriteProtectionEnum value in WriteProtectionEnum.values)
            value.key: (value as Enum).name, // 'no', 'irreversible', etc.
        };
      case 'certifications':
        return <int, String>{
          for (final MaterialCertificationsEnum value
              in MaterialCertificationsEnum.values)
            value.key: (value as Enum).name, // 'ul_2818', 'ul_94_v0', etc.
        };
      default:
        return null;
    }
  }

  static bool _parseRequired(dynamic value) {
    if (value == true) {
      return true;
    }
    if (value == 'recommended') {
      return false;
    }
    return false;
  }

  Map<String, dynamic> decode(Map<CborSmallInt, CborValue> data) {
    final Map<String, dynamic> result = <String, dynamic>{};
    final Map<int, CborValue> unknownFields = <int, CborValue>{};

    for (final MapEntry<CborSmallInt, CborValue> entry in data.entries) {
      final int key = entry.key.value;
      final Field? field = fieldsByKey[key];

      if (field == null) {
        unknownFields[key] = entry.value;
        continue;
      }

      try {
        result[field.name] = field.decode(entry.value);
      } catch (e) {
        throw ArgumentError(
          'Error decoding field ${field.name} (key $key): $e',
        );
      }
    }

    if (unknownFields.isNotEmpty) {
      result['unknown_fields'] = unknownFields;
    }

    return result;
  }

  void validate(Map<String, dynamic> data) {
    for (final Field field in fieldsByName.values) {
      if (!data.containsKey(field.name) || data[field.name] == null) {
        if (field.required) {
          throw ArgumentError('Missing required field: ${field.name}');
        }
      }
    }
  }

  Map<int, CborValue> encode(Map<String, dynamic> data) {
    validate(data);

    final Map<int, CborValue> result = <int, CborValue>{};

    for (final MapEntry<String, dynamic> entry in data.entries) {
      if (entry.value == null) {
        continue;
      }

      if (entry.key == 'unknown_fields') {
        if (entry.value is Map<int, CborValue>) {
          final Map<int, CborValue> unknownFields =
              entry.value as Map<int, CborValue>;
          result.addAll(unknownFields);
        }
        continue;
      }

      final Field? field = fieldsByName[entry.key];

      if (field == null) {
        throw ArgumentError('Unknown field name: ${entry.key}');
      }

      try {
        result[field.key] = field.encode(entry.value);
      } catch (e) {
        throw ArgumentError('Error encoding field ${entry.key}: $e');
      }
    }

    return result;
  }

  void _addField(Field field) {
    if (fieldsByKey.containsKey(field.key)) {
      throw ArgumentError('Duplicate field key: ${field.key}');
    }
    if (fieldsByName.containsKey(field.name)) {
      throw ArgumentError('Duplicate field name: ${field.name}');
    }
    fieldsByKey[field.key] = field;
    fieldsByName[field.name] = field;
  }
}
