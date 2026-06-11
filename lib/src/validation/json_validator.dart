import 'dart:typed_data';

import 'package:open_print_tag/src/cbor/fields/field_types.dart';
import 'package:open_print_tag/src/cbor/fields/fields_manager.dart';

class ValidationError {
  final String field;
  final String message;
  final ValidationErrorType type;

  const ValidationError({
    required this.field,
    required this.message,
    required this.type,
  });

  @override
  String toString() => '[$type] $field: $message';
}

enum ValidationErrorType {
  missingRequired,
  invalidType,
  invalidValue,
  maxLengthExceeded,
  unknownField,
}

class ValidationResult {
  final List<ValidationError> errors;

  const ValidationResult(this.errors);

  bool get isValid => errors.isEmpty;

  List<ValidationError> get requiredErrors => errors
      .where(
        (ValidationError e) => e.type == ValidationErrorType.missingRequired,
      )
      .toList();

  List<ValidationError> get typeErrors => errors
      .where((ValidationError e) => e.type == ValidationErrorType.invalidType)
      .toList();

  List<ValidationError> get valueErrors => errors
      .where((ValidationError e) => e.type == ValidationErrorType.invalidValue)
      .toList();

  @override
  String toString() {
    if (isValid) {
      return 'Valid';
    }
    return 'Invalid: ${errors.length} error(s)\n${errors.join('\n')}';
  }
}

class JsonValidator {
  final FieldsManager fields;
  final bool allowUnknownFields;

  JsonValidator({required this.fields, this.allowUnknownFields = true});

  ValidationResult validate(Map<String, dynamic> data) {
    final List<ValidationError> errors = <ValidationError>[];

    // Check required fields
    for (final Field field in fields.fieldsByName.values) {
      if (field.required &&
          (!data.containsKey(field.name) || data[field.name] == null)) {
        errors.add(
          ValidationError(
            field: field.name,
            message: 'Required field is missing',
            type: ValidationErrorType.missingRequired,
          ),
        );
      }
    }

    // Validate each provided field
    for (final MapEntry<String, dynamic> entry in data.entries) {
      if (entry.value == null) {
        continue;
      }

      final Field? field = fields.fieldsByName[entry.key];

      if (field == null) {
        if (!allowUnknownFields) {
          errors.add(
            ValidationError(
              field: entry.key,
              message: 'Unknown field',
              type: ValidationErrorType.unknownField,
            ),
          );
        }
        continue;
      }

      final ValidationError? error = _validateField(field, entry.value);
      if (error != null) {
        errors.add(error);
      }
    }

    return ValidationResult(errors);
  }

  ValidationError? _validateField(Field field, dynamic value) {
    switch (field.type) {
      case FieldType.bool:
        if (value is! bool) {
          return ValidationError(
            field: field.name,
            message: 'Expected bool, got ${value.runtimeType}',
            type: ValidationErrorType.invalidType,
          );
        }

      case FieldType.int:
      case FieldType.timestamp:
        if (value is! int && value is! num) {
          return ValidationError(
            field: field.name,
            message: 'Expected int, got ${value.runtimeType}',
            type: ValidationErrorType.invalidType,
          );
        }

      case FieldType.number:
        if (value is! num) {
          return ValidationError(
            field: field.name,
            message: 'Expected number, got ${value.runtimeType}',
            type: ValidationErrorType.invalidType,
          );
        }

      case FieldType.string:
        if (value is! String) {
          return ValidationError(
            field: field.name,
            message: 'Expected string, got ${value.runtimeType}',
            type: ValidationErrorType.invalidType,
          );
        }
        final StringField stringField = field as StringField;
        if (value.length > stringField.maxLength) {
          return ValidationError(
            field: field.name,
            message:
                'String length ${value.length} exceeds max ${stringField.maxLength}',
            type: ValidationErrorType.maxLengthExceeded,
          );
        }

      case FieldType.enumeration:
        if (value is! String) {
          return ValidationError(
            field: field.name,
            message: 'Expected string enum value, got ${value.runtimeType}',
            type: ValidationErrorType.invalidType,
          );
        }
        final EnumField enumField = field as EnumField;
        if (!enumField.itemsByName.containsKey(value)) {
          return ValidationError(
            field: field.name,
            message:
                'Invalid enum value "$value". Valid: ${enumField.itemsByName.keys.join(', ')}',
            type: ValidationErrorType.invalidValue,
          );
        }

      case FieldType.enumArray:
        if (value is! List) {
          return ValidationError(
            field: field.name,
            message: 'Expected list, got ${value.runtimeType}',
            type: ValidationErrorType.invalidType,
          );
        }
        final EnumArrayField enumArrayField = field as EnumArrayField;
        if (value.length > enumArrayField.maxLength) {
          return ValidationError(
            field: field.name,
            message:
                'Array length ${value.length} exceeds max ${enumArrayField.maxLength}',
            type: ValidationErrorType.maxLengthExceeded,
          );
        }
        for (final dynamic item in value) {
          if (item is! String ||
              !enumArrayField.itemsByName.containsKey(item)) {
            return ValidationError(
              field: field.name,
              message:
                  'Invalid enum value "$item". Valid: ${enumArrayField.itemsByName.keys.join(', ')}',
              type: ValidationErrorType.invalidValue,
            );
          }
        }

      case FieldType.colorRgba:
        if (value is! String && value is! Uint8List && value is! List<int>) {
          return ValidationError(
            field: field.name,
            message:
                'Expected color string (#RRGGBB) or bytes, got ${value.runtimeType}',
            type: ValidationErrorType.invalidType,
          );
        }
        if (value is String) {
          final String cleaned = value.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
          if (cleaned.length != 6 && cleaned.length != 8) {
            return ValidationError(
              field: field.name,
              message:
                  'Color must be 6 (RGB) or 8 (RGBA) hex characters, got ${cleaned.length}',
              type: ValidationErrorType.invalidValue,
            );
          }
        }

      case FieldType.colorLab:
        if (value is! List) {
          return ValidationError(
            field: field.name,
            message: 'Expected [L*, a*, b*] list, got ${value.runtimeType}',
            type: ValidationErrorType.invalidType,
          );
        }
        if (value.length != 3) {
          return ValidationError(
            field: field.name,
            message:
                'color_lab must have exactly 3 values, got ${value.length}',
            type: ValidationErrorType.invalidValue,
          );
        }
        for (final dynamic item in value) {
          if (item is! num) {
            return ValidationError(
              field: field.name,
              message:
                  'color_lab values must be numbers, got ${item.runtimeType}',
              type: ValidationErrorType.invalidType,
            );
          }
        }
        final num l = value[0] as num;
        if (l < 0 || l > 100) {
          return ValidationError(
            field: field.name,
            message: 'L* must be in [0, 100], got $l',
            type: ValidationErrorType.invalidValue,
          );
        }

      case FieldType.bytes:
        if (value is! String &&
            value is! Uint8List &&
            value is! List<int> &&
            value is! int) {
          return ValidationError(
            field: field.name,
            message:
                'Expected bytes (Uint8List, List<int>, String, or int), got ${value.runtimeType}',
            type: ValidationErrorType.invalidType,
          );
        }
        final BytesField bytesField = field as BytesField;
        if (bytesField.maxLength != null) {
          int? length;
          if (value is Uint8List) {
            length = value.length;
          }
          if (value is List<int>) {
            length = value.length;
          }
          if (length != null && length > bytesField.maxLength!) {
            return ValidationError(
              field: field.name,
              message:
                  'Bytes length $length exceeds max ${bytesField.maxLength}',
              type: ValidationErrorType.maxLengthExceeded,
            );
          }
        }

      case FieldType.uuid:
        if (value is! String) {
          return ValidationError(
            field: field.name,
            message: 'Expected UUID string, got ${value.runtimeType}',
            type: ValidationErrorType.invalidType,
          );
        }
        final RegExp uuidRegex = RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        );
        if (!uuidRegex.hasMatch(value)) {
          return ValidationError(
            field: field.name,
            message: 'Invalid UUID format',
            type: ValidationErrorType.invalidValue,
          );
        }
    }

    return null;
  }
}
