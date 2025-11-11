import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:open_print_tag/models/open_print_tag_aux_data.dart';
import 'package:open_print_tag/models/open_print_tag_main_data.dart';
import 'package:open_print_tag/models/open_print_tag_meta_data.dart';
import 'package:open_print_tag/src/uuid_generator.dart';
import 'package:uuid/uuid.dart';

part 'open_print_tag_data.g.dart';

@CopyWith()
@JsonSerializable(explicitToJson: true)
class OpenPrintTagData {
  final OpenPrintTagMainData? main;
  final OpenPrintTagAuxData? aux;
  final OpenPrintTagMetaData? meta;

  const OpenPrintTagData({this.main, this.aux, this.meta});

  factory OpenPrintTagData.fromJson(Map<String, dynamic> json) =>
      _$OpenPrintTagDataFromJson(json);

  Map<String, dynamic> toJson() => _$OpenPrintTagDataToJson(this);

  OpenPrintTagData newInstanceUuid() {
    final OpenPrintTagMainData? mainData = main;
    if (mainData == null) {
      return this;
    }

    final String? brandSpecificId = mainData.brandSpecificInstanceId;
    final String? brandUuid = brandSpecificId?.isNotEmpty == true
        ? OpenPrintTagUuidGenerator.buildBrandUuid(mainData.brandName)
        : null;

    final String newUuid = brandUuid != null && brandSpecificId != null
        ? OpenPrintTagUuidGenerator.buildBrandSpecificInstanceUuid(
                brandUuid,
                brandSpecificId,
              ) ??
              const Uuid().v4()
        : const Uuid().v4();

    return OpenPrintTagData(
      main: mainData.copyWith(instanceUuid: newUuid),
      aux: aux,
      meta: meta,
    );
  }
}
