// ignore_for_file: always_use_package_imports

import 'package:build/build.dart';
import 'package:yaml/yaml.dart';

import 'src/enum_field_models.dart';
import 'src/yaml_builder_utils.dart';

const Set<String> _enumBasenames = <String>{
  'tags_enum',
  'tag_categories_enum',
  'write_protection_enum',
  'material_type_enum',
  'material_class_enum',
  'material_certifications_enum',
};

const Set<String> _enumExcludedKeys = <String>{'description'};

/// Generates enhanced Dart enums from YAML with type inference and cross-enum refs.
Builder yamlEnumBuilder([BuilderOptions? _]) => _YamlEnumBuilder();

class _YamlEnumBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => <String, List<String>>{
    for (final String basename in _enumBasenames)
      'data-submodule/data/$basename.yaml': <String>[
        'lib/src/enums/$basename.enum.g.dart',
      ],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final AssetId inputId = buildStep.inputId;
    if (!inputId.path.startsWith('data-submodule/data/')) {
      return;
    }

    final String basename = inputId.path
        .split('/')
        .last
        .replaceFirst(RegExp(r'\.(yaml|yml)$'), '');
    if (!_enumBasenames.contains(basename)) {
      // Not one of the targeted enum YAMLs; skip.
      return;
    }

    final String content = await buildStep.readAsString(inputId);
    final dynamic raw = loadYaml(content);
    if (raw is! YamlList) {
      return;
    }

    final List<Map<String, Object?>> items = raw
        .map(
          (dynamic e) =>
              YamlBuilderUtils.flattenYaml(e, excludedKeys: _enumExcludedKeys),
        )
        .whereType<Map<String, Object?>>()
        .toList();

    final AssetId outputId = AssetId(
      inputId.package,
      'lib/src/enums/$basename.enum.g.dart',
    );

    final String source = _generateEnumSource(inputId.path, basename, items);
    await buildStep.writeAsString(
      outputId,
      YamlBuilderUtils.formatSource(source),
    );
  }

  String _generateEnumSource(
    String sourcePath,
    String basename,
    List<Map<String, Object?>> items,
  ) {
    final String enumName = YamlBuilderUtils.toUpperCamelCase(
      basename,
      fallback: 'DataEnum',
    );

    // Collect necessary imports for enum references
    final Set<String> imports = <String>{};

    if (items.isEmpty) {
      return <String>[
        YamlBuilderUtils.generateHeader(sourcePath),
        'enum $enumName { }',
      ].join('\n');
    }

    final StringBuffer out = StringBuffer();

    // Determine union of keys across items
    final Set<String> yamlKeys = <String>{};
    for (final Map<String, Object?> it in items) {
      yamlKeys.addAll(it.keys.cast<String>());
    }

    // We never generate fields for 'deprecated'
    yamlKeys.remove('deprecated');

    // Collect field infos
    final List<FieldInfo> fields = <FieldInfo>[];

    final bool hasKey = yamlKeys.contains('key');
    if (hasKey) {
      fields.add(
        FieldInfo(
          yamlKey: 'key',
          fieldName: 'key',
          type: 'int',
          isNullable: false,
          isPositional: false, // Changed to named parameter
        ),
      );
      yamlKeys.remove('key');
    }

    // Determine which field to use as 'name':
    // - If 'display_name' exists, use it (e.g., tag_categories)
    // - Otherwise, if 'name' exists and differs from abbreviation, use it (e.g., material_type)
    if (yamlKeys.contains('display_name')) {
      fields.add(
        FieldInfo(
          yamlKey: 'display_name',
          fieldName: 'name',
          type: 'String',
          isNullable: false,
          isPositional: false,
        ),
      );
      yamlKeys.remove('display_name');
      yamlKeys.remove('name'); // Skip 'name' if we have 'display_name'
    } else if (yamlKeys.contains('name') && yamlKeys.contains('abbreviation')) {
      // Has both 'name' and 'abbreviation' - use 'name' as field
      fields.add(
        FieldInfo(
          yamlKey: 'name',
          fieldName: 'name',
          type: 'String',
          isNullable: false,
          isPositional: false,
        ),
      );
      yamlKeys.remove('name');
    } else {
      // Only has 'name' (used as identifier) - don't create field
      yamlKeys.remove('name');
    }

    yamlKeys.remove('abbreviation'); // Always remove - it's the enum identifier

    // Infer other fields, use nullable if missing in any item
    for (final String key in yamlKeys) {
      // Infer type based on first non-null occurrence
      dynamic sample;
      bool seenNonNull = false;
      bool hasNullOrMissing = false;
      for (final Map<String, Object?> it in items) {
        if (!it.containsKey(key) || it[key] == null) {
          hasNullOrMissing = true;
          continue;
        }
        if (!seenNonNull) {
          seenNonNull = true;
          sample = it[key];
        }
      }
      final String fieldName = _mapYamlKeyToFieldName(key);

      // Special handling for enum references
      String typeStr;
      bool isEnumRef = false;
      String? refEnumType;

      if (key == 'implies' || key == 'hints') {
        // Self-referencing list (e.g., TagsEnum.implies -> List<TagsEnum>)
        typeStr = 'List<$enumName>';
        isEnumRef = true;
      } else {
        // Check if field should reference another enum
        final EnumFieldConfig? enumRef = _getEnumReference(basename, key);
        if (enumRef != null) {
          typeStr = enumRef.enumType;
          isEnumRef = true;
          refEnumType = enumRef.enumType;
          imports.add(enumRef.importPath);
        } else {
          typeStr = seenNonNull ? _typeStringForValue(sample) : 'Object?';
        }
      }

      fields.add(
        FieldInfo(
          yamlKey: key,
          fieldName: fieldName,
          type: hasNullOrMissing ? '$typeStr?' : typeStr,
          isNullable: hasNullOrMissing,
          isPositional: false,
          isEnumReference: isEnumRef,
          referencedEnumType: refEnumType,
        ),
      );
    }

    // Build final output with header and imports
    final StringBuffer finalOut = StringBuffer();
    finalOut.write(YamlBuilderUtils.generateHeader(sourcePath));
    final String importsCode = YamlBuilderUtils.generateImports(imports);
    if (importsCode.isNotEmpty) {
      finalOut.writeln(importsCode);
    }

    out.writeln('enum $enumName {');

    // Emit enum values
    for (final Map<String, Object?> it in items) {
      // Skip items without a name (e.g., some deprecated entries)
      final String? nameValue = it['name'] as String?;
      if (nameValue == null) {
        continue;
      }

      if (it['deprecated'] == true) {
        out.writeln('  @Deprecated(\'deprecated\')');
      }

      // Use 'abbreviation' as identifier if available, otherwise sanitize 'name'
      final String? abbreviation = it['abbreviation'] as String?;
      final String valueIdent = YamlBuilderUtils.sanitizeIdentifier(
        abbreviation ?? nameValue,
      );

      final List<String> namedArgs = <String>[];
      for (final FieldInfo f in fields) {
        final dynamic value = it[f.yamlKey];
        String argValue;

        if (f.isEnumReference && value != null) {
          if (value is List) {
            // Convert list of strings to list of enum references
            final List<String> enumRefs = <String>[];
            for (final dynamic item in value) {
              if (item is String) {
                enumRefs.add('$enumName.$item');
              }
            }
            argValue = 'const [${enumRefs.join(', ')}]';
          } else if (value is String && f.referencedEnumType != null) {
            // Single enum reference (e.g., category: MaterialClassEnum.FFF)
            argValue = '${f.referencedEnumType}.$value';
          } else {
            argValue = YamlBuilderUtils.referenceToCode(
              YamlBuilderUtils.toLiteral(value),
            );
          }
        } else {
          argValue = YamlBuilderUtils.referenceToCode(
            YamlBuilderUtils.toLiteral(value),
          );
        }

        namedArgs.add('${f.fieldName}: $argValue');
      }
      out.writeln('  $valueIdent(${namedArgs.join(', ')}),');
    }

    out.writeln(';');
    out.writeln('');

    // Emit fields
    for (final FieldInfo f in fields) {
      out.writeln('  final ${f.type} ${f.fieldName};');
    }
    out.writeln('');

    // Emit constructor - all fields as named parameters for enhanced enum
    final String namedParams = fields
        .map(
          (FieldInfo f) =>
              '${f.isNullable ? '' : 'required '}this.${f.fieldName}',
        )
        .join(', ');
    out.writeln('  const $enumName({$namedParams});');
    out.writeln('');

    // Lookup helpers
    if (hasKey) {
      out.writeln(
        '  static $enumName byKey(int key) => values.firstWhere((e) => e.key == key);',
      );
    }

    out.writeln('}');

    finalOut.write(out.toString());
    return finalOut.toString();
  }
}

String _mapYamlKeyToFieldName(String yamlKey) {
  if (yamlKey == 'name') {
    return 'id'; // Avoid conflict with Enum.name getter
  }
  return YamlBuilderUtils.toLowerCamelCase(yamlKey, fallback: 'value');
}

String _typeStringForValue(dynamic value) {
  return YamlBuilderUtils.inferTypeCode(value);
}

/// Cross-enum reference configuration. Add new enum refs here.
const Map<String, Map<String, EnumFieldConfig>> _enumFieldReferences =
    <String, Map<String, EnumFieldConfig>>{
      'material_type_enum': <String, EnumFieldConfig>{
        'category': EnumFieldConfig(
          enumType: 'MaterialClassEnum',
          importPath: 'material_class_enum.enum.g.dart',
        ),
      },
      'tags_enum': <String, EnumFieldConfig>{
        'category': EnumFieldConfig(
          enumType: 'TagCategoriesEnum',
          importPath: 'tag_categories_enum.enum.g.dart',
        ),
      },
    };

EnumFieldConfig? _getEnumReference(String basename, String fieldKey) {
  return _enumFieldReferences[basename]?[fieldKey];
}
