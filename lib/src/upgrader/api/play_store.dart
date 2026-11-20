
part of '../blue_upgrader.dart';



class PlayStoreApi with StoreApi{
  final String playStorePrefixURL = 'https://play.google.com/store/apps/details';

  Dio client = Dio();
  Map<String, String>? clientHeaders;

  @override
  Future<PackageInfo?> get(String package, {String country = 'US', String locale = 'en'}) async {
    assert(package.isNotEmpty);
    if (package.isEmpty) return null;

    final url = createUrl(package: package, country: country, locale: locale);

    try {
      final response = await client.get<String>(url, options: Options(headers: clientHeaders, responseType: ResponseType.plain));
      final document = _decodeResults(response.data ?? '');

      if (document == null) return null;

      final description = _description(document);
      if (description == null) return null;

      return PackageInfo()
        ..packageName = package
        ..appName =  ""
        ..version =  _version(description) ?? _storeVersion(document) ?? "1.0.0"
        ..description =  description
        ..releaseNotes =  _releaseNotes(document)
        ..storeUrl =  url;
    } catch (e) {
      debugPrint('PlayStoreApi Error: $e');
      return null;
    }
  }

  String createUrl({required String package, required String country, required String locale}) {
    return Uri.https('play.google.com', '/store/apps/details', {
      'id': package,
      'gl': country.toUpperCase(),
      'hl': locale,
      '_cb': DateTime.now().microsecondsSinceEpoch.toString(),
    }).toString();
  }

  html_dom.Document? _decodeResults(String response) {
    if (response.isEmpty) return null;
    return html_parser.parse(response);
  }

  String? _description(html_dom.Document document) {
    final sections = document.getElementsByClassName('bARER');
    if (sections.isNotEmpty) return sections.last.text.trim();

    final legacy = document.querySelector('.W4P4ne .PHBdkd .DWPxHb');
    if (legacy != null) return legacy.text.trim();

    return null;
  }

  String? _releaseNotes(html_dom.Document document) {
    final elements = document.querySelectorAll('[itemprop="description"]');
    if (elements.isNotEmpty) return _multiline(elements.last);

    final sections = document.getElementsByClassName('W4P4ne');
    for (final section in sections) {
      if (section.querySelector('.wSaTQd')?.text.trim() == "What's New") {
        final notes = section.querySelector('.PHBdkd .DWPxHb');
        if (notes != null) return _multiline(notes);
      }
    }
    return null;
  }

  String _multiline(html_dom.Element element) {
    final content = element.innerHtml.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    return html_parser.parseFragment(content).text?.trim() ?? '';
  }

  String? _version(String desc, {String tagName = 'mav'}) {
    try {
      String regExpSource = r'\[\:tagName\:[\s]*(?<version>[^\s]+)[\s]*\]';
      regExpSource = regExpSource.replaceAll('tagName', tagName);
      final match = RegExp(regExpSource, caseSensitive: false).firstMatch(desc);
      return match?.namedGroup('version');
    } catch (e) {
      debugPrint('PlayStoreApi version tag error: $e');
      return null;
    }
  }

  String? _storeVersion(html_dom.Document document) {
    try {
      final metadataVersion = document.querySelector('[itemprop="softwareVersion"]')?.attributes['content'];
      if (metadataVersion != null && _validVersion(metadataVersion)) return metadataVersion;

      final sections = document.getElementsByClassName('hAyfc');
      for (final section in sections) {
        if (section.querySelector('.BgcNfc')?.text.trim() == 'Current Version') {
          final value = section.querySelector('.htlgb')?.text.trim();
          if (value != null && _validVersion(value)) return value;
        }
      }

      final regExp = RegExp(r'"(?:140|141|142|143|144|145)":\s*\[\[\["(\d+(?:\.\d+){1,3})"');

      for (final script in document.getElementsByTagName('script')) {
        final content = script.text;
        if (!content.contains('AF_initDataCallback')) continue;

        final match = regExp.firstMatch(content);
        if (match != null) return match.group(1);
      }
    } catch (e) {
      debugPrint('PlayStoreApi storeVersion error: $e');
    }
    return null;
  }

  bool _validVersion(String value) {
    return RegExp(r'^\d+(?:\.\d+){1,3}$').hasMatch(value);
  }
}
