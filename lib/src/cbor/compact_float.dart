import 'package:cbor/cbor.dart';
import 'package:ieee754/ieee754.dart';

/// Picks the most compact CBOR representation for a decimal number — int,
/// float16, float32, or native double — matching `CompactFloat` from
/// `data-submodule/utils/fields.py`.
class CompactFloat {
  final num value;

  CompactFloat(num input) : value = _compactRepresentation(input);

  static num _compactRepresentation(num input) {
    final num value = input.toDouble();
    if (value == value.toInt()) {
      return value.toInt();
    }

    final FloatParts parts = FloatParts.fromDouble(value.toDouble());

    final double f16 = FloatParts.fromFloat16Bytes(
      parts.toFloat16Bytes(),
    ).toDouble();
    if ((value - f16).abs() < 1e-3) {
      return f16;
    }

    final double f32 = FloatParts.fromFloat32Bytes(
      parts.toFloat32Bytes(),
    ).toDouble();
    if ((value - f32).abs() < 1e-3) {
      return f32;
    }

    return value.toDouble();
  }

  static num decode(CborValue data) {
    final num value;
    if (data is CborSmallInt) {
      value = data.value;
    } else if (data is CborFloat) {
      value = data.value;
    } else {
      throw ArgumentError(
        'Expected CborSmallInt or CborFloat, got ${data.runtimeType}',
      );
    }
    if (value == value.toInt()) {
      return value.toInt();
    }
    return (value * 1000).round() / 1000;
  }

  CborValue toCbor() {
    if (value is int) {
      return CborSmallInt(value as int);
    }
    return CborFloat(value.toDouble());
  }
}
