import 'dart:convert';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:open_print_tag/src/cbor/cbor_hex_utils.dart';
import 'package:open_print_tag/src/cbor/compact_float.dart';
import 'package:uuid/uuid.dart';

enum FieldType {
  bool('bool'),
  int('int'),
  number('number'),
  string('string'),
  enumeration('enum'),
  enumArray('enum_array'),
  colorRgba('color_rgba'),
  colorLab('color_lab'),
  bytes('bytes'),
  uuid('uuid'),
  timestamp('timestamp');

  const FieldType(this.configName);

  final String configName;

  static FieldType fromString(String value) {
    return values.firstWhere(
      (FieldType type) => type.configName == value,
      orElse: () => throw ArgumentError('Unknown field type: $value'),
    );
  }
}

abstract class Field {
  final int key;
  final String name;
  final bool required;
  final FieldType type;

  Field({
    required this.key,
    required this.name,
    required this.type,
    this.required = false,
  });

  dynamic decode(CborValue data);

  CborValue encode(dynamic data);
}

class BoolField extends Field {
  BoolField({required super.key, required super.name, super.required})
    : super(type: FieldType.bool);

  @override
  bool decode(CborValue data) => (data as CborBool).value;

  @override
  CborValue encode(dynamic data) => CborBool(data as bool);
}

class IntField extends Field {
  IntField({required super.key, required super.name, super.required})
    : super(type: FieldType.int);

  @override
  int decode(CborValue data) => (data as CborSmallInt).value;

  @override
  CborValue encode(dynamic data) => CborSmallInt((data as num).toInt());
}

class NumberField extends Field {
  NumberField({required super.key, required super.name, super.required})
    : super(type: FieldType.number);

  @override
  num decode(CborValue data) => CompactFloat.decode(data);

  @override
  CborValue encode(dynamic data) => CompactFloat(data as num).toCbor();
}

class StringField extends Field {
  final int maxLength;

  StringField({
    required super.key,
    required super.name,
    required this.maxLength,
    super.required,
  }) : super(type: FieldType.string);

  @override
  String decode(CborValue data) => (data as CborString).toString();

  @override
  CborValue encode(dynamic data) {
    final String value = data as String;
    if (value.length > maxLength) {
      throw ArgumentError(
        'String "$value" exceeds maximum length of $maxLength',
      );
    }
    return CborString(value);
  }
}

abstract class EnumFieldBase extends Field {
  final Map<int, String> itemsByKey;
  final Map<String, int> itemsByName;

  EnumFieldBase({
    required super.key,
    required super.name,
    required super.type,
    required this.itemsByKey,
    super.required,
  }) : itemsByName = <String, int>{
         for (MapEntry<int, String> e in itemsByKey.entries) e.value: e.key,
       };

  String keyToValue(int key) {
    return itemsByKey[key] ??
        (throw ArgumentError('Unknown enum key $key for field $name'));
  }

  int valueToKey(String value) {
    final int? enumKey = itemsByName[value];
    if (enumKey == null) {
      throw ArgumentError('Unknown enum value "$value" for field $name');
    }
    return enumKey;
  }
}

class EnumField extends EnumFieldBase {
  EnumField({
    required super.key,
    required super.name,
    required super.itemsByKey,
    super.required,
  }) : super(type: FieldType.enumeration);

  @override
  String decode(CborValue data) {
    final int key = (data as CborSmallInt).value;
    return keyToValue(key);
  }

  @override
  CborValue encode(dynamic data) {
    final int enumKey = valueToKey(data as String);
    return CborSmallInt(enumKey);
  }
}

class EnumArrayField extends EnumFieldBase {
  final int maxLength;

  EnumArrayField({
    required super.key,
    required super.name,
    required super.itemsByKey,
    required this.maxLength,
    super.required,
  }) : super(type: FieldType.enumArray);

  @override
  List<String> decode(CborValue data) {
    final CborList list = data as CborList;
    return list.map((CborValue item) {
      final int key = (item as CborSmallInt).value;
      return keyToValue(key);
    }).toList();
  }

  @override
  CborValue encode(dynamic data) {
    final List<int> keys = (data as List<dynamic>).map((dynamic item) {
      return valueToKey(item as String);
    }).toList();

    if (keys.length > maxLength) {
      throw ArgumentError(
        'Enum array for field $name has ${keys.length} items, '
        'but maximum is $maxLength',
      );
    }

    return CborList(keys.map((int k) => CborSmallInt(k)).toList());
  }
}

class ColorLabField extends Field {
  ColorLabField({required super.key, required super.name, super.required})
    : super(type: FieldType.colorLab);

  @override
  List<num> decode(CborValue data) {
    final CborList list = data as CborList;
    if (list.length != 3) {
      throw ArgumentError(
        'Expected 3 values for color_lab, got ${list.length}',
      );
    }
    return list.map(CompactFloat.decode).toList();
  }

  @override
  CborValue encode(dynamic data) {
    final List<dynamic> values = data as List<dynamic>;
    if (values.length != 3) {
      throw ArgumentError(
        'color_lab must have exactly 3 values, got ${values.length}',
      );
    }
    return CborList(
      values.map((dynamic v) => CompactFloat(v as num).toCbor()).toList(),
    );
  }
}

class ColorRgbaField extends BytesField {
  ColorRgbaField({
    required super.key,
    required super.name,
    super.maxLength = 4,
    super.required = false,
  });

  @override
  FieldType get type => FieldType.colorRgba;

  @override
  dynamic decode(CborValue data) {
    final List<int> bytes = (data as CborBytes).bytes;
    return '#${CborHexUtils.bytesToHex(bytes)}';
  }

  @override
  Uint8List convertToBytes(dynamic data) {
    if (data is String) {
      return CborHexUtils.hexToBytes(data);
    }
    return super.convertToBytes(data);
  }
}

class BytesField extends Field {
  final int? maxLength;

  BytesField({
    required super.key,
    required super.name,
    this.maxLength,
    super.required,
  }) : super(type: FieldType.bytes);

  @override
  dynamic decode(CborValue data) {
    final List<int> bytes = (data as CborBytes).bytes;
    return CborHexUtils.bytesToHex(bytes);
  }

  @override
  CborValue encode(dynamic data) {
    final Uint8List bytes = convertToBytes(data);

    if (maxLength != null && bytes.length > maxLength!) {
      throw ArgumentError(
        'Bytes length ${bytes.length} exceeds maximum length of $maxLength',
      );
    }

    return CborBytes(bytes);
  }

  Uint8List convertToBytes(dynamic data) {
    if (data is Uint8List) {
      return data;
    }
    if (data is List<int>) {
      return Uint8List.fromList(data);
    }
    if (data is String) {
      return Uint8List.fromList(utf8.encode(data));
    }
    if (data is int) {
      return _intToBytes(data);
    }
    throw ArgumentError('Cannot encode ${data.runtimeType} to bytes');
  }

  Uint8List _intToBytes(int value) {
    final List<int> bytes = <int>[];
    int remaining = value;
    while (remaining > 0) {
      bytes.add(remaining & 0xFF);
      remaining >>= 8;
    }
    return Uint8List.fromList(bytes);
  }
}

class UuidField extends Field {
  UuidField({required super.key, required super.name, super.required})
    : super(type: FieldType.uuid);

  @override
  String decode(CborValue data) {
    final List<int> bytes = (data as CborBytes).bytes;
    final Uint8List byteList = bytes is Uint8List
        ? bytes
        : Uint8List.fromList(bytes);
    return UuidValue.fromByteList(byteList).toString();
  }

  @override
  CborValue encode(dynamic data) {
    final Uint8List bytes = Uint8List.fromList(
      UuidValue.fromString(data as String).toBytes(),
    );
    return CborBytes(bytes);
  }
}
