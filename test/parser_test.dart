import 'dart:typed_data';

import 'package:color/color.dart';
import 'package:open_print_tag/open_print_tag.dart';
import 'package:test/test.dart';

void main() {
  late OpenPrintTagParser parser;

  setUpAll(() {
    parser = OpenPrintTagParser.create();
  });

  group('OpenPrintTagParser', () {
    test('throws FormatException on invalid CBOR payload', () async {
      final Uint8List invalidPayload = Uint8List.fromList(<int>[
        0xFF,
        0xFF,
        0xFF,
      ]);

      await expectLater(
        parser.decode(invalidPayload),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException on non-map CBOR', () async {
      final Uint8List arrayPayload = Uint8List.fromList(<int>[
        0x83,
        0x01,
        0x02,
        0x03,
      ]);

      await expectLater(
        parser.decode(arrayPayload),
        throwsA(isA<FormatException>()),
      );
    });

    test('encodes and decodes basic payload', () async {
      const OpenPrintTagData data = OpenPrintTagData(
        main: OpenPrintTagMainData(materialClass: 'FFF', materialType: 'PLA'),
      );

      final Uint8List payload = parser.encode(data, size: 320);
      final OpenPrintTagData result = await parser.decode(payload);

      expect(result.meta, isNotNull);
      expect(result.main, isNotNull);
      expect(result.main!.materialClass, 'FFF');
      expect(result.main!.materialType, 'PLA');
    });

    test('encodes and decodes payload with primaryColor', () async {
      const OpenPrintTagData data = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialType: 'PLA',
          materialName: 'Orange PLA',
          primaryColor: RgbColor(255, 165, 0),
        ),
      );

      final Uint8List payload = parser.encode(data, size: 320);
      final OpenPrintTagData result = await parser.decode(payload);

      expect(result.meta, isNotNull);
      expect(result.main, isNotNull);
      expect(result.main!.materialClass, 'FFF');
      expect(result.main!.materialType, 'PLA');
      expect(result.main!.primaryColor, isNotNull);
      expect(result.main!.primaryColor!.toRgbColor().r, 255);
      expect(result.main!.primaryColor!.toRgbColor().g, 165);
      expect(result.main!.primaryColor!.toRgbColor().b, 0);
    });
  });

  group('Encoding', () {
    test('encodes basic main data', () {
      const OpenPrintTagData data = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialName: 'PLA Premium',
          materialType: 'PLA',
          minPrintTemperature: 215,
          minBedTemperature: 60,
        ),
      );

      final Uint8List payload = parser.encode(data, size: 320);

      expect(payload, isNotEmpty);
      expect(payload, isA<Uint8List>());
    });

    test('encodes data with primaryColor', () {
      const OpenPrintTagData data = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialName: 'Red PLA',
          materialType: 'PLA',
          minPrintTemperature: 215,
          minBedTemperature: 60,
          primaryColor: RgbColor(255, 0, 0),
        ),
      );

      final Uint8List payload = parser.encode(data, size: 320);

      expect(payload, isNotEmpty);
      expect(payload, isA<Uint8List>());
    });

    test('encodes data with meta and aux regions', () {
      const OpenPrintTagData data = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialName: 'PETG Premium',
          materialType: 'PETG',
          minPrintTemperature: 230,
          minBedTemperature: 85,
        ),
        aux: OpenPrintTagAuxData(workgroup: 'ProdGrp', consumedWeight: 50.5),
      );

      final Uint8List payload = parser.encode(data, size: 320);

      expect(payload, isNotEmpty);
      expect(payload, isA<Uint8List>());
    });

    test('throws when no main data provided', () {
      const OpenPrintTagData data = OpenPrintTagData();

      expect(() => parser.encode(data, size: 320), throwsArgumentError);
    });

    test('preserves data during round-trip', () async {
      const OpenPrintTagData originalData = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialName: 'ABS Premium',
          materialType: 'ABS',
          minPrintTemperature: 240,
          minBedTemperature: 100,
          density: 1.04,
        ),
      );

      final Uint8List payload = parser.encode(originalData, size: 320);
      final OpenPrintTagData decodedData = await parser.decode(payload);

      expect(decodedData.main, isNotNull);
      expect(decodedData.main!.materialClass, originalData.main!.materialClass);
      expect(decodedData.main!.materialName, originalData.main!.materialName);
      expect(decodedData.main!.materialType, originalData.main!.materialType);
      expect(
        decodedData.main!.minPrintTemperature,
        originalData.main!.minPrintTemperature,
      );
      expect(
        decodedData.main!.minBedTemperature,
        originalData.main!.minBedTemperature,
      );
      expect(decodedData.main!.density, originalData.main!.density);
      expect(decodedData.meta, isNotNull);
    });

    test('preserves primaryColor during round-trip', () async {
      const OpenPrintTagData originalData = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialName: 'Blue PETG',
          materialType: 'PETG',
          minPrintTemperature: 230,
          minBedTemperature: 85,
          primaryColor: RgbColor(0, 0, 255),
        ),
      );

      final Uint8List payload = parser.encode(originalData, size: 320);
      final OpenPrintTagData decodedData = await parser.decode(payload);

      expect(decodedData.main, isNotNull);
      expect(decodedData.main!.materialClass, originalData.main!.materialClass);
      expect(decodedData.main!.materialName, originalData.main!.materialName);
      expect(decodedData.main!.materialType, originalData.main!.materialType);
      expect(decodedData.main!.primaryColor, isNotNull);
      expect(
        decodedData.main!.primaryColor,
        equals(originalData.main!.primaryColor),
      );
      final RgbColor rgb = decodedData.main!.primaryColor!.toRgbColor();
      expect(rgb.r, 0);
      expect(rgb.g, 0);
      expect(rgb.b, 255);
      expect(decodedData.meta, isNotNull);
    });

    test('preserves all regions during round-trip', () async {
      const OpenPrintTagData originalData = OpenPrintTagData(
        meta: OpenPrintTagMetaData(),
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialName: 'TPU Flexible',
          materialType: 'TPU',
          minPrintTemperature: 220,
          minBedTemperature: 50,
        ),
        aux: OpenPrintTagAuxData(workgroup: 'TestGrp', consumedWeight: 123.45),
      );

      final Uint8List payload = parser.encode(originalData, size: 320);
      final OpenPrintTagData decodedData = await parser.decode(payload);

      expect(decodedData.main, isNotNull);
      expect(decodedData.main!.materialClass, originalData.main!.materialClass);
      expect(decodedData.main!.materialName, originalData.main!.materialName);
      expect(decodedData.main!.materialType, originalData.main!.materialType);
      expect(decodedData.aux, isNotNull);
      expect(decodedData.aux!.workgroup, originalData.aux!.workgroup);
      expect(decodedData.aux!.consumedWeight, originalData.aux!.consumedWeight);
      expect(decodedData.meta, isNotNull);
    });

    test('preserves all regions with primaryColor during round-trip', () async {
      const OpenPrintTagData originalData = OpenPrintTagData(
        meta: OpenPrintTagMetaData(),
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialName: 'Green PLA',
          materialType: 'PLA',
          minPrintTemperature: 215,
          minBedTemperature: 60,
          primaryColor: RgbColor(0, 255, 0),
        ),
        aux: OpenPrintTagAuxData(workgroup: 'ColorGrp', consumedWeight: 50.0),
      );

      final Uint8List payload = parser.encode(originalData, size: 320);
      final OpenPrintTagData decodedData = await parser.decode(payload);

      expect(decodedData.main, isNotNull);
      expect(decodedData.main!.materialClass, originalData.main!.materialClass);
      expect(decodedData.main!.materialName, originalData.main!.materialName);
      expect(decodedData.main!.materialType, originalData.main!.materialType);
      expect(decodedData.main!.primaryColor, isNotNull);
      expect(
        decodedData.main!.primaryColor,
        equals(originalData.main!.primaryColor),
      );
      expect(decodedData.aux, isNotNull);
      expect(decodedData.aux!.workgroup, originalData.aux!.workgroup);
      expect(decodedData.meta, isNotNull);
    });

    test('throws when required field is missing', () {
      const OpenPrintTagData data = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialName: 'PLA Premium',
          materialType: 'PLA',
          minPrintTemperature: 215,
          minBedTemperature: 60,
        ),
      );

      expect(
        () => parser.encode(data, size: 320),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.message,
            'message',
            contains('Missing required field: material_class'),
          ),
        ),
      );
    });
  });

  group('Meta region', () {
    test('creates minimal META without aux', () async {
      const OpenPrintTagData data = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialType: 'PLA',
          materialName: 'Test Material',
        ),
      );

      final Uint8List payload = parser.encode(data, size: 320);
      final OpenPrintTagData decoded = await parser.decode(payload);

      expect(decoded.meta, isNotNull);
      expect(decoded.main, isNotNull);
    });

    test('creates META with aux region', () async {
      const OpenPrintTagData data = OpenPrintTagData(
        main: OpenPrintTagMainData(materialClass: 'FFF', materialType: 'PLA'),
        aux: OpenPrintTagAuxData(workgroup: 'TestGrp', consumedWeight: 100.5),
      );

      final Uint8List payload = parser.encode(data, size: 320);
      final OpenPrintTagData decoded = await parser.decode(payload);

      expect(decoded.meta, isNotNull);
      expect(decoded.main, isNotNull);
      expect(decoded.aux, isNotNull);
    });

    test('validates meta structure', () async {
      const OpenPrintTagData data = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialType: 'PLA',
          materialName: 'Test Material',
        ),
      );

      final Uint8List payload = parser.encode(data, size: 320);
      final OpenPrintTagData decoded = await parser.decode(payload);

      expect(decoded.meta, isNotNull);
      expect(decoded.main, isNotNull);
    });
  });

  group('Fixed size encoding', () {
    test('creates tag with fixed size and padding', () async {
      const OpenPrintTagData data = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialType: 'PLA',
          materialName: 'Test Material',
        ),
      );

      final Uint8List payload = parser.encode(data, size: 320);

      expect(payload.length, 320);

      final OpenPrintTagData decoded = await parser.decode(payload);
      expect(decoded.main, isNotNull);
      expect(decoded.main!.materialClass, 'FFF');
      expect(decoded.meta, isNotNull);
    });

    test('returns exactly requested size in bytes', () {
      final DateTime now = DateTime.now();

      final int manufacturedTimestamp =
          (now.subtract(const Duration(days: 30)).millisecondsSinceEpoch / 1000)
              .round();
      final int expirationTimestamp =
          (now.add(const Duration(days: 365)).millisecondsSinceEpoch / 1000)
              .round();

      final OpenPrintTagData data = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialType: 'PLA',
          materialName: 'Prusament PLA Galaxy Black',
          minPrintTemperature: 200,
          maxPrintTemperature: 220,
          minBedTemperature: 50,
          maxBedTemperature: 60,
          minChamberTemperature: 0,
          maxChamberTemperature: 40,
          chamberTemperature: 20,
          filamentDiameter: 1.75,
          density: 1.24,
          actualNettoFullWeight: 980,
          nominalNettoFullWeight: 1000,
          emptyContainerWeight: 140,
          actualFullLength: 330000,
          nominalFullLength: 330000,
          manufacturedDate: manufacturedTimestamp,
          expirationDate: expirationTimestamp,
        ),
      );

      final Uint8List payload200 = parser.encode(data, size: 200);
      expect(payload200.length, 200);

      final Uint8List payload320 = parser.encode(data, size: 320);
      expect(payload320.length, 320);

      final Uint8List payload500 = parser.encode(data, size: 500);
      expect(payload500.length, 500);

      final Uint8List payload1000 = parser.encode(data, size: 1000);
      expect(payload1000.length, 1000);
    });

    test('throws when data exceeds totalSize', () {
      const OpenPrintTagData data = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialType: 'PLA',
          materialName: 'Very long material name that takes up lots of space',
        ),
      );

      expect(() => parser.encode(data, size: 10), throwsArgumentError);
    });

    test('encodes and decodes primaryColor with fixed size', () async {
      const OpenPrintTagData data = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialType: 'PETG',
          materialName: 'Purple PETG',
          minPrintTemperature: 230,
          minBedTemperature: 85,
          primaryColor: RgbColor(128, 0, 128),
        ),
      );

      final Uint8List payload = parser.encode(data, size: 320);
      expect(payload.length, 320);

      final OpenPrintTagData decoded = await parser.decode(payload);
      expect(decoded.main, isNotNull);
      expect(decoded.main!.primaryColor, isNotNull);
      expect(decoded.main!.primaryColor, equals(data.main!.primaryColor));
      expect(decoded.meta, isNotNull);
    });
  });

  group('Update mode', () {
    test('preserves META sizes when updating', () async {
      const OpenPrintTagData initialData = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialType: 'PLA',
          minPrintTemperature: 200,
        ),
      );

      final Uint8List initialPayload = parser.encode(initialData, size: 320);
      final OpenPrintTagData decoded = await parser.decode(initialPayload);

      expect(decoded.main, isNotNull);

      const OpenPrintTagData updatedData = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialType: 'PLA',
          minPrintTemperature: 220,
        ),
      );

      final Uint8List updatedPayload = parser.encode(updatedData, size: 320);
      final OpenPrintTagData decodedUpdated = await parser.decode(
        updatedPayload,
      );

      expect(decodedUpdated.main!.minPrintTemperature, 220);
    });

    test('throws when updated data exceeds fixed size', () async {
      const OpenPrintTagData initialData = OpenPrintTagData(
        main: OpenPrintTagMainData(materialClass: 'FFF', materialType: 'PLA'),
      );

      final Uint8List payload = parser.encode(initialData, size: 100);
      final OpenPrintTagData decoded = await parser.decode(payload);

      final OpenPrintTagData tooLarge = OpenPrintTagData(
        meta: decoded.meta,
        main: const OpenPrintTagMainData(
          materialClass: 'FFF',
          materialType: 'PLA',
          materialName: 'Very long name that will not fit',
        ),
      );

      expect(() => parser.encode(tooLarge, size: 10), throwsArgumentError);
    });

    test('updates primaryColor while preserving other data', () async {
      const OpenPrintTagData initialData = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialType: 'PLA',
          materialName: 'Color Changing PLA',
          minPrintTemperature: 210,
          primaryColor: RgbColor(255, 0, 0),
        ),
      );

      final Uint8List initialPayload = parser.encode(initialData, size: 320);
      final OpenPrintTagData decoded = await parser.decode(initialPayload);

      expect(decoded.main, isNotNull);
      expect(decoded.main!.primaryColor, isNotNull);
      final RgbColor initialRgb = decoded.main!.primaryColor!.toRgbColor();
      expect(initialRgb.r, 255);
      expect(initialRgb.g, 0);
      expect(initialRgb.b, 0);

      const OpenPrintTagData updatedData = OpenPrintTagData(
        main: OpenPrintTagMainData(
          materialClass: 'FFF',
          materialType: 'PLA',
          materialName: 'Color Changing PLA',
          minPrintTemperature: 210,
          primaryColor: RgbColor(0, 255, 0),
        ),
      );

      final Uint8List updatedPayload = parser.encode(updatedData, size: 320);
      final OpenPrintTagData decodedUpdated = await parser.decode(
        updatedPayload,
      );

      expect(decodedUpdated.main!.primaryColor, isNotNull);
      final RgbColor updatedRgb = decodedUpdated.main!.primaryColor!
          .toRgbColor();
      expect(updatedRgb.r, 0);
      expect(updatedRgb.g, 255);
      expect(updatedRgb.b, 0);
      expect(decodedUpdated.main!.materialName, initialData.main!.materialName);
    });
  });
}
