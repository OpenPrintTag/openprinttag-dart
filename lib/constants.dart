import 'package:uuid/uuid.dart';

class OpenPrintTagConstants {
  static const String mimeType = 'application/vnd.openprinttag';

  static const UuidValue uuidNamespaceBrand = UuidValue.raw(
    '5269dfb7-1559-440a-85be-aba5f3eff2d2',
  );
  static const UuidValue uuidNamespaceMaterial = UuidValue.raw(
    '616fc86d-7d99-4953-96c7-46d2836b9be9',
  );
  static const UuidValue uuidNamespacePackage = UuidValue.raw(
    '6f7d485e-db8d-4979-904e-a231cd6602b2',
  );
  static const UuidValue uuidNamespaceInstance = UuidValue.raw(
    '31062f81-b5bd-4f86-a5f8-46367e841508',
  );
  static const UuidValue uuidNamespaceBrandSpecificInstanceId = UuidValue.raw(
    '2d9f5f88-1d02-44c5-8c66-754479453743',
  );
}
