// GENERATED CODE - DO NOT MODIFY BY HAND
// Source: data-submodule/data/material_certifications_enum.yaml
enum MaterialCertificationsEnum {
  ul_2818(key: 0, name: 'UL 2818'),
  ul_94_v0(key: 1, name: 'UL 94 V0');

  final int key;
  final String name;

  const MaterialCertificationsEnum({required this.key, required this.name});

  static MaterialCertificationsEnum byKey(int key) =>
      values.firstWhere((e) => e.key == key);
}
