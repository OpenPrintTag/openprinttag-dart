import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:open_print_tag/models/open_print_tag_aux_data.dart';
import 'package:open_print_tag/models/open_print_tag_data.dart';
import 'package:open_print_tag/models/open_print_tag_main_data.dart';
import 'package:open_print_tag/models/open_print_tag_meta_data.dart';
import 'package:open_print_tag/src/cbor/cbor_utils.dart';
import 'package:open_print_tag/src/cbor/fields/fields_manager.dart';
import 'package:open_print_tag/src/cbor/fields/ndef_region.dart';

class OpenPrintTagDecoder {
  final FieldsManager metaFields;
  final FieldsManager mainFields;
  final FieldsManager auxFields;

  OpenPrintTagDecoder({
    required this.metaFields,
    required this.mainFields,
    required this.auxFields,
  });

  Future<OpenPrintTagData> decodePayload(Uint8List payload) async {
    final CborMap? metaCborMap = await CborUtils.getFirstCborMap(payload);

    if (metaCborMap == null) {
      throw const FormatException('Could not decode CBOR map from payload');
    }
    final int metaSize = cbor.encode(metaCborMap).length;

    final Map<String, dynamic> metaData = await _readMetaRegion(
      payload,
      metaSize,
    );
    final Map<String, dynamic> mainData = await _readMainRegion(
      payload,
      metaData,
      metaSize,
    );
    final Map<String, dynamic>? auxData = await _readAuxRegion(
      payload,
      metaData,
    );

    return OpenPrintTagData(
      meta: OpenPrintTagMetaData.fromJson(metaData),
      main: OpenPrintTagMainData.fromJson(mainData),
      aux: auxData != null ? OpenPrintTagAuxData.fromJson(auxData) : null,
    );
  }

  Future<Map<String, dynamic>> _readMetaRegion(
    Uint8List payload,
    int metaSize,
  ) async {
    return await _readRegion(
      payload,
      offset: 0,
      size: metaSize,
      fields: metaFields,
    );
  }

  Future<Map<String, dynamic>> _readMainRegion(
    Uint8List payload,
    Map<String, dynamic> metaData,
    int metaSize,
  ) async {
    final int mainOffset = metaData['main_region_offset'] as int? ?? metaSize;
    final int? mainSize = metaData['main_region_size'] as int?;
    final int? auxOffset = metaData['aux_region_offset'] as int?;

    final int actualMainSize =
        mainSize ?? (auxOffset ?? payload.length) - mainOffset;

    return await _readRegion(
      payload,
      offset: mainOffset,
      size: actualMainSize,
      fields: mainFields,
    );
  }

  Future<Map<String, dynamic>?> _readAuxRegion(
    Uint8List payload,
    Map<String, dynamic> metaData,
  ) async {
    final int? auxOffset = metaData['aux_region_offset'] as int?;
    if (auxOffset == null) {
      return null;
    }

    final int? auxSize = metaData['aux_region_size'] as int?;
    final int actualAuxSize = auxSize ?? payload.length - auxOffset;

    return await _readRegion(
      payload,
      offset: auxOffset,
      size: actualAuxSize,
      fields: auxFields,
    );
  }

  Future<Map<String, dynamic>> _readRegion(
    Uint8List payload, {
    required int offset,
    required int size,
    required FieldsManager fields,
  }) async {
    final NdefRegion region = NdefRegion(
      offset: offset,
      size: size,
      fields: fields,
    );
    return await region.read(payload);
  }
}
