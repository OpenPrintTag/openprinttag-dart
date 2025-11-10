import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:open_print_tag/constants.dart';
import 'package:uuid/uuid.dart';

class OpenPrintTagUuidGenerator {
  static const Uuid _uuid = Uuid();

  static String _uuidV5FromBytes(String namespace, List<int> data) {
    final List<int> combined = <int>[
      ...Uuid.parseAsByteList(namespace),
      ...data,
    ];
    final List<int> hashBytes = sha1.convert(combined).bytes.toList();
    hashBytes[6] = (hashBytes[6] & 0x0F) | 0x50;
    hashBytes[8] = (hashBytes[8] & 0x3F) | 0x80;
    return Uuid.unparse(hashBytes.sublist(0, 16));
  }

  static String? _buildUuidFromString(String namespace, String? value) {
    return value != null ? _uuid.v5(namespace, value) : null;
  }

  static String? _buildUuidWithBrandPrefix(
    String namespace,
    String? brandUuid,
    List<int>? data,
  ) {
    if (brandUuid == null || data == null || data.isEmpty) {
      return null;
    }
    return _uuidV5FromBytes(namespace, <int>[
      ...Uuid.parseAsByteList(brandUuid),
      ...data,
    ]);
  }

  static String? buildBrandUuid(String? brandName) => _buildUuidFromString(
    OpenPrintTagConstants.uuidNamespaceBrand.toString(),
    brandName,
  );

  static String? buildMaterialUuid(String? brandUuid, String? materialName) =>
      _buildUuidWithBrandPrefix(
        OpenPrintTagConstants.uuidNamespaceMaterial.toString(),
        brandUuid,
        materialName != null ? utf8.encode(materialName) : null,
      );

  static String? buildPackageUuid(String? brandUuid, num? gtin) =>
      _buildUuidWithBrandPrefix(
        OpenPrintTagConstants.uuidNamespacePackage.toString(),
        brandUuid,
        gtin != null ? utf8.encode(gtin.toString()) : null,
      );

  static String? buildInstanceUuid(String? brandUuid, List<int> nfcUidBytes) =>
      _buildUuidWithBrandPrefix(
        OpenPrintTagConstants.uuidNamespaceInstance.toString(),
        brandUuid,
        nfcUidBytes,
      );

  static String? buildBrandSpecificInstanceUuid(
    String? brandUuid,
    String? brandSpecificInstanceId,
  ) => _buildUuidWithBrandPrefix(
    OpenPrintTagConstants.uuidNamespaceBrandSpecificInstanceId.toString(),
    brandUuid,
    brandSpecificInstanceId != null
        ? utf8.encode(brandSpecificInstanceId)
        : null,
  );
}
