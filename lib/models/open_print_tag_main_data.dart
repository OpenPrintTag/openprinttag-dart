import 'dart:typed_data';
import 'package:cbor/cbor.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:open_print_tag/src/uuid_generator.dart';

part 'open_print_tag_main_data.g.dart';

@CopyWith()
@JsonSerializable(explicitToJson: true)
class OpenPrintTagMainData {
  // UUIDs
  @JsonKey(name: 'instance_uuid')
  final String? instanceUuid;

  @JsonKey(name: 'package_uuid')
  final String? packageUuid;

  @JsonKey(name: 'material_uuid')
  final String? materialUuid;

  @JsonKey(name: 'brand_uuid')
  final String? brandUuid;

  // Product identification
  final num? gtin;

  @JsonKey(name: 'brand_specific_instance_id')
  final String? brandSpecificInstanceId;

  @JsonKey(name: 'brand_specific_package_id')
  final String? brandSpecificPackageId;

  @JsonKey(name: 'brand_specific_material_id')
  final String? brandSpecificMaterialId;

  // Material properties
  @JsonKey(name: 'material_class')
  final String? materialClass;

  @JsonKey(name: 'material_type')
  final String? materialType;

  @JsonKey(name: 'material_name')
  final String? materialName;

  @JsonKey(name: 'material_abbreviation')
  final String? materialAbbreviation;

  @JsonKey(name: 'brand_name')
  final String? brandName;

  @JsonKey(name: 'write_protection')
  final String? writeProtection;

  // Timestamps
  @JsonKey(name: 'manufactured_date')
  final int? manufacturedDate;

  @JsonKey(name: 'country_of_origin')
  final String? countryOfOrigin;

  @JsonKey(name: 'expiration_date')
  final int? expirationDate;

  // Packaging weights
  @JsonKey(name: 'nominal_netto_full_weight')
  final num? nominalNettoFullWeight;

  @JsonKey(name: 'actual_netto_full_weight')
  final num? actualNettoFullWeight;

  @JsonKey(name: 'nominal_full_length')
  final num? nominalFullLength;

  @JsonKey(name: 'actual_full_length')
  final num? actualFullLength;

  @JsonKey(name: 'empty_container_weight')
  final num? emptyContainerWeight;

  // Colors
  @JsonKey(
    name: 'primary_color',
    fromJson: _uint8ListFromJson,
    toJson: _uint8ListToJson,
  )
  final Uint8List? primaryColor;

  @JsonKey(
    name: 'secondary_color_0',
    fromJson: _uint8ListFromJson,
    toJson: _uint8ListToJson,
  )
  final Uint8List? secondaryColor0;

  @JsonKey(
    name: 'secondary_color_1',
    fromJson: _uint8ListFromJson,
    toJson: _uint8ListToJson,
  )
  final Uint8List? secondaryColor1;

  @JsonKey(
    name: 'secondary_color_2',
    fromJson: _uint8ListFromJson,
    toJson: _uint8ListToJson,
  )
  final Uint8List? secondaryColor2;

  @JsonKey(
    name: 'secondary_color_3',
    fromJson: _uint8ListFromJson,
    toJson: _uint8ListToJson,
  )
  final Uint8List? secondaryColor3;

  @JsonKey(
    name: 'secondary_color_4',
    fromJson: _uint8ListFromJson,
    toJson: _uint8ListToJson,
  )
  final Uint8List? secondaryColor4;

  // Material properties
  @JsonKey(name: 'transmission_distance')
  final num? transmissionDistance;

  final List<String>? tags;

  final num? density;

  // FFF-specific properties
  @JsonKey(name: 'filament_diameter')
  final num? filamentDiameter;

  @JsonKey(name: 'shore_hardness_a')
  final int? shoreHardnessA;

  @JsonKey(name: 'shore_hardness_d')
  final int? shoreHardnessD;

  @JsonKey(name: 'min_nozzle_diameter')
  final num? minNozzleDiameter;

  @JsonKey(name: 'min_print_temperature')
  final int? minPrintTemperature;

  @JsonKey(name: 'max_print_temperature')
  final int? maxPrintTemperature;

  @JsonKey(name: 'preheat_temperature')
  final int? preheatTemperature;

  @JsonKey(name: 'min_bed_temperature')
  final int? minBedTemperature;

  @JsonKey(name: 'max_bed_temperature')
  final int? maxBedTemperature;

  @JsonKey(name: 'min_chamber_temperature')
  final int? minChamberTemperature;

  @JsonKey(name: 'max_chamber_temperature')
  final int? maxChamberTemperature;

  @JsonKey(name: 'chamber_temperature')
  final int? chamberTemperature;

  // FFF container dimensions
  @JsonKey(name: 'container_width')
  final int? containerWidth;

  @JsonKey(name: 'container_outer_diameter')
  final int? containerOuterDiameter;

  @JsonKey(name: 'container_inner_diameter')
  final int? containerInnerDiameter;

  @JsonKey(name: 'container_hole_diameter')
  final int? containerHoleDiameter;

  // SLA-specific properties
  @JsonKey(name: 'viscosity_18c')
  final num? viscosity18c;

  @JsonKey(name: 'viscosity_25c')
  final num? viscosity25c;

  @JsonKey(name: 'viscosity_40c')
  final num? viscosity40c;

  @JsonKey(name: 'viscosity_60c')
  final num? viscosity60c;

  @JsonKey(name: 'container_volumetric_capacity')
  final num? containerVolumetricCapacity;

  @JsonKey(name: 'cure_wavelength')
  final int? cureWavelength;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<int, CborValue>? unknownFields;

  const OpenPrintTagMainData({
    this.instanceUuid,
    this.packageUuid,
    this.materialUuid,
    this.brandUuid,
    this.gtin,
    this.brandSpecificInstanceId,
    this.brandSpecificPackageId,
    this.brandSpecificMaterialId,
    this.materialClass,
    this.materialType,
    this.materialName,
    this.materialAbbreviation,
    this.brandName,
    this.writeProtection,
    this.manufacturedDate,
    this.countryOfOrigin,
    this.expirationDate,
    this.nominalNettoFullWeight,
    this.actualNettoFullWeight,
    this.nominalFullLength,
    this.actualFullLength,
    this.emptyContainerWeight,
    this.primaryColor,
    this.secondaryColor0,
    this.secondaryColor1,
    this.secondaryColor2,
    this.secondaryColor3,
    this.secondaryColor4,
    this.transmissionDistance,
    this.tags,
    this.density,
    this.filamentDiameter,
    this.shoreHardnessA,
    this.shoreHardnessD,
    this.minNozzleDiameter,
    this.minPrintTemperature,
    this.maxPrintTemperature,
    this.preheatTemperature,
    this.minBedTemperature,
    this.maxBedTemperature,
    this.minChamberTemperature,
    this.maxChamberTemperature,
    this.chamberTemperature,
    this.containerWidth,
    this.containerOuterDiameter,
    this.containerInnerDiameter,
    this.containerHoleDiameter,
    this.viscosity18c,
    this.viscosity25c,
    this.viscosity40c,
    this.viscosity60c,
    this.containerVolumetricCapacity,
    this.cureWavelength,
    this.unknownFields,
  });

  factory OpenPrintTagMainData.fromJson(Map<String, dynamic> json) {
    final OpenPrintTagMainData data = _$OpenPrintTagMainDataFromJson(json);

    final String? brandUuid =
        data.brandUuid ??
        OpenPrintTagUuidGenerator.buildBrandUuid(data.brandName);

    final String? materialUuid =
        data.materialUuid ??
        OpenPrintTagUuidGenerator.buildMaterialUuid(
          brandUuid,
          data.materialName,
        );

    final String? packageUuid =
        data.packageUuid ??
        OpenPrintTagUuidGenerator.buildPackageUuid(brandUuid, data.gtin);

    return data.copyWith(
      brandUuid: brandUuid,
      materialUuid: materialUuid,
      packageUuid: packageUuid,
      unknownFields: json['unknown_fields'] as Map<int, CborValue>?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$OpenPrintTagMainDataToJson(this);

    if (brandUuid != null && brandName != null) {
      json.remove('brand_uuid');
    }

    if (materialUuid != null && materialName != null && brandName != null) {
      json.remove('material_uuid');
    }

    if (packageUuid != null && materialName != null && brandName != null) {
      json.remove('package_uuid');
    }

    if (unknownFields?.isNotEmpty ?? false) {
      json['unknown_fields'] = unknownFields;
    }

    return json;
  }

  /// Converts JSON value to Uint8List
  static Uint8List? _uint8ListFromJson(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Uint8List) {
      return value;
    }
    if (value is List) {
      return Uint8List.fromList(value.cast<int>());
    }
    if (value is Map && value.containsKey('hex')) {
      return _hexToBytes(value['hex'] as String);
    }
    return null;
  }

  /// Converts Uint8List to JSON value
  static dynamic _uint8ListToJson(Uint8List? bytes) {
    if (bytes == null) {
      return null;
    }
    return <String, String>{'hex': _toHex(bytes)};
  }

  static Uint8List _hexToBytes(String hex) {
    final String cleaned = hex.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    final List<int> bytes = <int>[];
    for (int i = 0; i < cleaned.length; i += 2) {
      bytes.add(int.parse(cleaned.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  static String _toHex(Uint8List bytes) {
    return bytes
        .map((int byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
