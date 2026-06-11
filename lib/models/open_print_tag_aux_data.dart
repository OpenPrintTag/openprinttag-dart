import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'open_print_tag_aux_data.g.dart';

@CopyWith()
@JsonSerializable(explicitToJson: true)
class OpenPrintTagAuxData {
  @JsonKey(name: 'consumed_weight')
  final num? consumedWeight;

  final String? workgroup;

  @JsonKey(name: 'general_purpose_range_user')
  final String? generalPurposeRangeUser;

  @JsonKey(name: 'last_stir_time')
  final int? lastStirTime;

  @JsonKey(name: 'storage_location')
  final String? storageLocation;

  @JsonKey(name: 'purchase_time')
  final int? purchaseTime;

  @JsonKey(name: 'purchase_price')
  final num? purchasePrice;

  @JsonKey(name: 'purchase_currency')
  final String? purchaseCurrency;

  const OpenPrintTagAuxData({
    this.consumedWeight,
    this.workgroup,
    this.generalPurposeRangeUser,
    this.lastStirTime,
    this.storageLocation,
    this.purchaseTime,
    this.purchasePrice,
    this.purchaseCurrency,
  });

  factory OpenPrintTagAuxData.fromJson(Map<String, dynamic> json) =>
      _$OpenPrintTagAuxDataFromJson(json);

  Map<String, dynamic> toJson() => _$OpenPrintTagAuxDataToJson(this);
}
