// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_print_tag_aux_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OpenPrintTagAuxDataCWProxy {
  OpenPrintTagAuxData consumedWeight(num? consumedWeight);

  OpenPrintTagAuxData workgroup(String? workgroup);

  OpenPrintTagAuxData generalPurposeRangeUser(String? generalPurposeRangeUser);

  OpenPrintTagAuxData lastStirTime(int? lastStirTime);

  OpenPrintTagAuxData storageLocation(String? storageLocation);

  OpenPrintTagAuxData purchaseTime(int? purchaseTime);

  OpenPrintTagAuxData purchasePrice(num? purchasePrice);

  OpenPrintTagAuxData purchaseCurrency(String? purchaseCurrency);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `OpenPrintTagAuxData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// OpenPrintTagAuxData(...).copyWith(id: 12, name: "My name")
  /// ```
  OpenPrintTagAuxData call({
    num? consumedWeight,
    String? workgroup,
    String? generalPurposeRangeUser,
    int? lastStirTime,
    String? storageLocation,
    int? purchaseTime,
    num? purchasePrice,
    String? purchaseCurrency,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfOpenPrintTagAuxData.copyWith(...)` or call `instanceOfOpenPrintTagAuxData.copyWith.fieldName(value)` for a single field.
class _$OpenPrintTagAuxDataCWProxyImpl implements _$OpenPrintTagAuxDataCWProxy {
  const _$OpenPrintTagAuxDataCWProxyImpl(this._value);

  final OpenPrintTagAuxData _value;

  @override
  OpenPrintTagAuxData consumedWeight(num? consumedWeight) =>
      call(consumedWeight: consumedWeight);

  @override
  OpenPrintTagAuxData workgroup(String? workgroup) =>
      call(workgroup: workgroup);

  @override
  OpenPrintTagAuxData generalPurposeRangeUser(
    String? generalPurposeRangeUser,
  ) => call(generalPurposeRangeUser: generalPurposeRangeUser);

  @override
  OpenPrintTagAuxData lastStirTime(int? lastStirTime) =>
      call(lastStirTime: lastStirTime);

  @override
  OpenPrintTagAuxData storageLocation(String? storageLocation) =>
      call(storageLocation: storageLocation);

  @override
  OpenPrintTagAuxData purchaseTime(int? purchaseTime) =>
      call(purchaseTime: purchaseTime);

  @override
  OpenPrintTagAuxData purchasePrice(num? purchasePrice) =>
      call(purchasePrice: purchasePrice);

  @override
  OpenPrintTagAuxData purchaseCurrency(String? purchaseCurrency) =>
      call(purchaseCurrency: purchaseCurrency);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `OpenPrintTagAuxData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// OpenPrintTagAuxData(...).copyWith(id: 12, name: "My name")
  /// ```
  OpenPrintTagAuxData call({
    Object? consumedWeight = const $CopyWithPlaceholder(),
    Object? workgroup = const $CopyWithPlaceholder(),
    Object? generalPurposeRangeUser = const $CopyWithPlaceholder(),
    Object? lastStirTime = const $CopyWithPlaceholder(),
    Object? storageLocation = const $CopyWithPlaceholder(),
    Object? purchaseTime = const $CopyWithPlaceholder(),
    Object? purchasePrice = const $CopyWithPlaceholder(),
    Object? purchaseCurrency = const $CopyWithPlaceholder(),
  }) {
    return OpenPrintTagAuxData(
      consumedWeight: consumedWeight == const $CopyWithPlaceholder()
          ? _value.consumedWeight
          // ignore: cast_nullable_to_non_nullable
          : consumedWeight as num?,
      workgroup: workgroup == const $CopyWithPlaceholder()
          ? _value.workgroup
          // ignore: cast_nullable_to_non_nullable
          : workgroup as String?,
      generalPurposeRangeUser:
          generalPurposeRangeUser == const $CopyWithPlaceholder()
          ? _value.generalPurposeRangeUser
          // ignore: cast_nullable_to_non_nullable
          : generalPurposeRangeUser as String?,
      lastStirTime: lastStirTime == const $CopyWithPlaceholder()
          ? _value.lastStirTime
          // ignore: cast_nullable_to_non_nullable
          : lastStirTime as int?,
      storageLocation: storageLocation == const $CopyWithPlaceholder()
          ? _value.storageLocation
          // ignore: cast_nullable_to_non_nullable
          : storageLocation as String?,
      purchaseTime: purchaseTime == const $CopyWithPlaceholder()
          ? _value.purchaseTime
          // ignore: cast_nullable_to_non_nullable
          : purchaseTime as int?,
      purchasePrice: purchasePrice == const $CopyWithPlaceholder()
          ? _value.purchasePrice
          // ignore: cast_nullable_to_non_nullable
          : purchasePrice as num?,
      purchaseCurrency: purchaseCurrency == const $CopyWithPlaceholder()
          ? _value.purchaseCurrency
          // ignore: cast_nullable_to_non_nullable
          : purchaseCurrency as String?,
    );
  }
}

extension $OpenPrintTagAuxDataCopyWith on OpenPrintTagAuxData {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfOpenPrintTagAuxData.copyWith(...)` or `instanceOfOpenPrintTagAuxData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OpenPrintTagAuxDataCWProxy get copyWith =>
      _$OpenPrintTagAuxDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenPrintTagAuxData _$OpenPrintTagAuxDataFromJson(Map<String, dynamic> json) =>
    OpenPrintTagAuxData(
      consumedWeight: json['consumed_weight'] as num?,
      workgroup: json['workgroup'] as String?,
      generalPurposeRangeUser: json['general_purpose_range_user'] as String?,
      lastStirTime: (json['last_stir_time'] as num?)?.toInt(),
      storageLocation: json['storage_location'] as String?,
      purchaseTime: (json['purchase_time'] as num?)?.toInt(),
      purchasePrice: json['purchase_price'] as num?,
      purchaseCurrency: json['purchase_currency'] as String?,
    );

Map<String, dynamic> _$OpenPrintTagAuxDataToJson(
  OpenPrintTagAuxData instance,
) => <String, dynamic>{
  'consumed_weight': instance.consumedWeight,
  'workgroup': instance.workgroup,
  'general_purpose_range_user': instance.generalPurposeRangeUser,
  'last_stir_time': instance.lastStirTime,
  'storage_location': instance.storageLocation,
  'purchase_time': instance.purchaseTime,
  'purchase_price': instance.purchasePrice,
  'purchase_currency': instance.purchaseCurrency,
};
