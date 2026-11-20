import 'package:flutter/foundation.dart';

import '../blue_core_messages.g.dart';

/// Browser detection from its advertised user agent. Browsers do not expose
/// a hardware device name or model, so [DeviceInfoMessage.model] is empty.
DeviceInfoMessage deviceInfoFromUserAgent(String userAgent) {
  final browsers = <String, String>{
    'Edge': r'(?:Edg|EdgA|EdgiOS)/([\d.]+)',
    'Opera': r'(?:OPR|OPiOS)/([\d.]+)',
    'Chrome': r'(?:Chrome|CriOS)/([\d.]+)',
    'Chromium': r'Chromium/([\d.]+)',
    'Firefox': r'(?:Firefox|FxiOS)/([\d.]+)',
    'Safari': r'Version/([\d.]+).*Safari/',
  };
  var name = 'Browser';
  var version = '';
  for (final browser in browsers.entries) {
    final match = RegExp(browser.value).firstMatch(userAgent);
    if (match != null) {
      name = browser.key;
      version = match.group(1)!;
      break;
    }
  }
  return DeviceInfoMessage(
    platform: defaultTargetPlatform.name,
    type: 'browser',
    name: name,
    model: '',
    version: version,
  );
}
