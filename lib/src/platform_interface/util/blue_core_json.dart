import 'dart:convert';

import '../blue_core_messages.g.dart';

/// Decodes Flutter's version.json, reporting missing or malformed fields.
PackageInfoMessage decodePackageInfoJson(String source) {
  final value = jsonDecode(source);
  if (value is! Map<String, dynamic>) {
    throw const FormatException('version.json must contain a JSON object');
  }

  String field(String name) {
    final result = value[name];
    if (result is! String) {
      throw FormatException('version.json field "$name" must be a string');
    }
    return result;
  }

  return PackageInfoMessage(
    appName: field('app_name'),
    packageName: field('package_name'),
    version: field('version'),
    buildNumber: field('build_number'),
  );
}
