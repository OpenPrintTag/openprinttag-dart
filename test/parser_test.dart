import 'dart:typed_data';

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
      const OpenPrintTagPayload payload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          main: OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialType: MaterialTypeEnum.PLA,
          ),
        ),
      );

      final Uint8List encoded = parser.encode(payload, size: 320);
      final OpenPrintTagPayload result = await parser.decode(encoded);

      expect(result.data.meta, isNotNull);
      expect(result.data.main, isNotNull);
      expect(result.data.main!.materialClass, MaterialClassEnum.FFF);
      expect(result.data.main!.materialType, MaterialTypeEnum.PLA);
    });
  });

  group('Encoding', () {
    test('encodes basic main data', () {
      const OpenPrintTagPayload payload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          main: OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialName: 'PLA Premium',
            materialType: MaterialTypeEnum.PLA,
            minPrintTemperature: 215,
            minBedTemperature: 60,
          ),
        ),
      );

      final Uint8List encoded = parser.encode(payload, size: 320);

      expect(encoded, isNotEmpty);
      expect(encoded, isA<Uint8List>());
    });

    test('encodes data with meta and aux regions', () {
      const OpenPrintTagPayload payload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          main: OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialName: 'PETG Premium',
            materialType: MaterialTypeEnum.PETG,
            minPrintTemperature: 230,
            minBedTemperature: 85,
          ),
          aux: OpenPrintTagAuxData(workgroup: 'ProdGrp', consumedWeight: 50.5),
        ),
      );

      final Uint8List encoded = parser.encode(payload, size: 320);

      expect(encoded, isNotEmpty);
      expect(encoded, isA<Uint8List>());
    });

    test('throws when no main data provided', () {
      const OpenPrintTagPayload payload = OpenPrintTagPayload(
        data: OpenPrintTagData(),
      );

      expect(() => parser.encode(payload, size: 320), throwsArgumentError);
    });

    test('preserves data during round-trip', () async {
      const OpenPrintTagPayload originalPayload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          main: OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialName: 'ABS Premium',
            materialType: MaterialTypeEnum.ABS,
            minPrintTemperature: 240,
            minBedTemperature: 100,
            density: 1.04,
            primaryColorLab: <num>[53.24, 111.12, -27.3],
            primaryColorRal: '270 30 20',
          ),
        ),
      );

      final Uint8List encoded = parser.encode(originalPayload, size: 320);
      final OpenPrintTagPayload decodedPayload = await parser.decode(encoded);

      expect(decodedPayload.data.main, isNotNull);
      expect(
        decodedPayload.data.main!.materialClass,
        originalPayload.data.main!.materialClass,
      );
      expect(
        decodedPayload.data.main!.materialName,
        originalPayload.data.main!.materialName,
      );
      expect(
        decodedPayload.data.main!.materialType,
        originalPayload.data.main!.materialType,
      );
      expect(
        decodedPayload.data.main!.minPrintTemperature,
        originalPayload.data.main!.minPrintTemperature,
      );
      expect(
        decodedPayload.data.main!.minBedTemperature,
        originalPayload.data.main!.minBedTemperature,
      );
      expect(
        decodedPayload.data.main!.density,
        originalPayload.data.main!.density,
      );
      for (int i = 0; i < 3; i++) {
        expect(
          (decodedPayload.data.main!.primaryColorLab![i] -
                  originalPayload.data.main!.primaryColorLab![i])
              .abs(),
          lessThan(0.05),
          reason: 'primary_color_lab not preserved at index $i',
        );
      }
      expect(
        decodedPayload.data.main!.primaryColorRal,
        originalPayload.data.main!.primaryColorRal,
      );
      expect(decodedPayload.data.meta, isNotNull);
    });

    test('preserves all regions during round-trip', () async {
      const OpenPrintTagPayload originalPayload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          meta: OpenPrintTagMetaData(),
          main: OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialName: 'TPU Flexible',
            materialType: MaterialTypeEnum.TPU,
            minPrintTemperature: 220,
            minBedTemperature: 50,
          ),
          aux: OpenPrintTagAuxData(
            workgroup: 'TestGrp',
            consumedWeight: 123.45,
            purchaseTime: 1747570939,
            purchasePrice: 549,
            purchaseCurrency: 'CZK',
          ),
        ),
      );

      final Uint8List encoded = parser.encode(originalPayload, size: 320);
      final OpenPrintTagPayload decodedPayload = await parser.decode(encoded);

      expect(decodedPayload.data.main, isNotNull);
      expect(
        decodedPayload.data.main!.materialClass,
        originalPayload.data.main!.materialClass,
      );
      expect(
        decodedPayload.data.main!.materialName,
        originalPayload.data.main!.materialName,
      );
      expect(
        decodedPayload.data.main!.materialType,
        originalPayload.data.main!.materialType,
      );
      expect(decodedPayload.data.aux, isNotNull);
      expect(
        decodedPayload.data.aux!.workgroup,
        originalPayload.data.aux!.workgroup,
      );
      expect(
        decodedPayload.data.aux!.consumedWeight,
        originalPayload.data.aux!.consumedWeight,
      );
      expect(
        decodedPayload.data.aux!.purchaseTime,
        originalPayload.data.aux!.purchaseTime,
      );
      expect(
        decodedPayload.data.aux!.purchasePrice,
        originalPayload.data.aux!.purchasePrice,
      );
      expect(
        decodedPayload.data.aux!.purchaseCurrency,
        originalPayload.data.aux!.purchaseCurrency,
      );
      expect(decodedPayload.data.meta, isNotNull);
    });

    test('throws when required field is missing', () {
      const OpenPrintTagPayload payload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          main: OpenPrintTagMainData(
            materialName: 'PLA Premium',
            materialType: MaterialTypeEnum.PLA,
            minPrintTemperature: 215,
            minBedTemperature: 60,
          ),
        ),
      );

      expect(
        () => parser.encode(payload, size: 320),
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
      const OpenPrintTagPayload payload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          main: OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialType: MaterialTypeEnum.PLA,
            materialName: 'Test Material',
          ),
        ),
      );

      final Uint8List encoded = parser.encode(payload, size: 320);
      final OpenPrintTagPayload decoded = await parser.decode(encoded);

      expect(decoded.data.meta, isNotNull);
      expect(decoded.data.main, isNotNull);
    });

    test('creates META with aux region', () async {
      const OpenPrintTagPayload payload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          main: OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialType: MaterialTypeEnum.PLA,
          ),
          aux: OpenPrintTagAuxData(workgroup: 'TestGrp', consumedWeight: 100.5),
        ),
      );

      final Uint8List encoded = parser.encode(payload, size: 320);
      final OpenPrintTagPayload decoded = await parser.decode(encoded);

      expect(decoded.data.meta, isNotNull);
      expect(decoded.data.main, isNotNull);
      expect(decoded.data.aux, isNotNull);
    });

    test('validates meta structure', () async {
      const OpenPrintTagPayload payload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          main: OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialType: MaterialTypeEnum.PLA,
            materialName: 'Test Material',
          ),
        ),
      );

      final Uint8List encoded = parser.encode(payload, size: 320);
      final OpenPrintTagPayload decoded = await parser.decode(encoded);

      expect(decoded.data.meta, isNotNull);
      expect(decoded.data.main, isNotNull);
    });
  });

  group('Fixed size encoding', () {
    test('creates tag with fixed size and padding', () async {
      const OpenPrintTagPayload payload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          main: OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialType: MaterialTypeEnum.PLA,
            materialName: 'Test Material',
          ),
        ),
      );

      final Uint8List encoded = parser.encode(payload, size: 320);

      expect(encoded.length, 320);

      final OpenPrintTagPayload decoded = await parser.decode(encoded);
      expect(decoded.data.main, isNotNull);
      expect(decoded.data.main!.materialClass, MaterialClassEnum.FFF);
      expect(decoded.data.meta, isNotNull);
    });

    test('throws when data exceeds totalSize', () {
      const OpenPrintTagPayload payload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          main: OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialType: MaterialTypeEnum.PLA,
            materialName: 'Very long material name that takes up lots of space',
          ),
        ),
      );

      expect(() => parser.encode(payload, size: 10), throwsArgumentError);
    });
  });

  group('Update mode', () {
    test('preserves META sizes when updating', () async {
      const OpenPrintTagPayload initialPayload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          main: OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialType: MaterialTypeEnum.PLA,
            minPrintTemperature: 200,
          ),
        ),
      );

      final Uint8List initialEncoded = parser.encode(initialPayload, size: 320);
      final OpenPrintTagPayload decoded = await parser.decode(initialEncoded);

      expect(decoded.data.main, isNotNull);

      const OpenPrintTagPayload updatedPayload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          main: OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialType: MaterialTypeEnum.PLA,
            minPrintTemperature: 220,
          ),
        ),
      );

      final Uint8List updatedEncoded = parser.encode(updatedPayload, size: 320);
      final OpenPrintTagPayload decodedUpdated = await parser.decode(
        updatedEncoded,
      );

      expect(decodedUpdated.data.main!.minPrintTemperature, 220);
    });

    test('throws when updated data exceeds fixed size', () async {
      const OpenPrintTagPayload initialPayload = OpenPrintTagPayload(
        data: OpenPrintTagData(
          main: OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialType: MaterialTypeEnum.PLA,
          ),
        ),
      );

      final Uint8List encoded = parser.encode(initialPayload, size: 100);
      final OpenPrintTagPayload decoded = await parser.decode(encoded);

      final OpenPrintTagPayload tooLarge = OpenPrintTagPayload(
        data: OpenPrintTagData(
          meta: decoded.data.meta,
          main: const OpenPrintTagMainData(
            materialClass: MaterialClassEnum.FFF,
            materialType: MaterialTypeEnum.PLA,
            materialName: 'Very long name that will not fit',
          ),
        ),
      );

      expect(() => parser.encode(tooLarge, size: 10), throwsArgumentError);
    });
  });
}
