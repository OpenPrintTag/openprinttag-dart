// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_print_tag_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OpenPrintTagDataCWProxy {
  OpenPrintTagData main(OpenPrintTagMainData? main);

  OpenPrintTagData aux(OpenPrintTagAuxData? aux);

  OpenPrintTagData meta(OpenPrintTagMetaData? meta);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `OpenPrintTagData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// OpenPrintTagData(...).copyWith(id: 12, name: "My name")
  /// ```
  OpenPrintTagData call({
    OpenPrintTagMainData? main,
    OpenPrintTagAuxData? aux,
    OpenPrintTagMetaData? meta,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfOpenPrintTagData.copyWith(...)` or call `instanceOfOpenPrintTagData.copyWith.fieldName(value)` for a single field.
class _$OpenPrintTagDataCWProxyImpl implements _$OpenPrintTagDataCWProxy {
  const _$OpenPrintTagDataCWProxyImpl(this._value);

  final OpenPrintTagData _value;

  @override
  OpenPrintTagData main(OpenPrintTagMainData? main) => call(main: main);

  @override
  OpenPrintTagData aux(OpenPrintTagAuxData? aux) => call(aux: aux);

  @override
  OpenPrintTagData meta(OpenPrintTagMetaData? meta) => call(meta: meta);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `OpenPrintTagData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// OpenPrintTagData(...).copyWith(id: 12, name: "My name")
  /// ```
  OpenPrintTagData call({
    Object? main = const $CopyWithPlaceholder(),
    Object? aux = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return OpenPrintTagData(
      main: main == const $CopyWithPlaceholder()
          ? _value.main
          // ignore: cast_nullable_to_non_nullable
          : main as OpenPrintTagMainData?,
      aux: aux == const $CopyWithPlaceholder()
          ? _value.aux
          // ignore: cast_nullable_to_non_nullable
          : aux as OpenPrintTagAuxData?,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as OpenPrintTagMetaData?,
    );
  }
}

extension $OpenPrintTagDataCopyWith on OpenPrintTagData {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfOpenPrintTagData.copyWith(...)` or `instanceOfOpenPrintTagData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OpenPrintTagDataCWProxy get copyWith => _$OpenPrintTagDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenPrintTagData _$OpenPrintTagDataFromJson(Map<String, dynamic> json) =>
    OpenPrintTagData(
      main: json['main'] == null
          ? null
          : OpenPrintTagMainData.fromJson(json['main'] as Map<String, dynamic>),
      aux: json['aux'] == null
          ? null
          : OpenPrintTagAuxData.fromJson(json['aux'] as Map<String, dynamic>),
      meta: json['meta'] == null
          ? null
          : OpenPrintTagMetaData.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenPrintTagDataToJson(OpenPrintTagData instance) =>
    <String, dynamic>{
      'main': instance.main?.toJson(),
      'aux': instance.aux?.toJson(),
      'meta': instance.meta?.toJson(),
    };
