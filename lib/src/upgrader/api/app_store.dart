
part of '../blue_upgrader.dart';

class AppStoreApi with StoreApi {
  final String iTunesDocumentationURL = 'https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/';
  final String lookupPrefixURL = 'https://itunes.apple.com/lookup';
  final String searchPrefixURL = 'https://itunes.apple.com/search';

  Dio client = Dio();
  Map<String, String>? clientHeaders;

  @override
  Future<PackageInfo?> get(String packageId, {String country = 'US', String locale = 'en'}) async {
    assert(packageId.isNotEmpty);
    if (packageId.isEmpty) return null;

    final url = createUrl(package: packageId, country: country, locale: locale);

    try {
      final response = await client.get<String>(url, options: Options(headers: clientHeaders, responseType: ResponseType.plain));
      final decodedResults = _decodeResults(response.data ?? '');

      if (decodedResults == null) return null;

      final results = decodedResults['results'];
      if (results is! List || results.isEmpty) return null;
      final app = results.first;
      if (app is! Map) return null;
      final version = app['version'];
      if (version is! String || version.trim().isEmpty) return null;

      return PackageInfo()
        ..packageName = packageId
        ..appName = ""
        ..version = version.trim()
        ..buildNumber = "0"
        ..description = app['description']
        ..releaseNotes = app['releaseNotes']
        ..storeUrl = app['trackViewUrl'];
    } catch (e) {
      debugPrint('AppStoreApi Error: $e');
      return null;
    }
  }

  String createUrl({required String package, required String country, required String locale}) {
    final parameters = <String>[
      "bundleId=$package",
      "country=${country.toLowerCase()}",
      "lang=$locale",
      "_cb=${DateTime.now().microsecondsSinceEpoch}"
    ];
    return '$lookupPrefixURL?${parameters.join('&')}';
  }

  Map? _decodeResults(String jsonResponse) {
    if (jsonResponse.isNotEmpty) {
      final decodedResults = json.decode(jsonResponse);
      if (decodedResults is Map) {
        if (decodedResults['resultCount'] == 0) return null;
        return decodedResults;
      }
    }
    return null;
  }
}
