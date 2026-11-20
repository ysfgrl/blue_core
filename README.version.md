# Sürüm bilgileri — version

[Ana menü](README.md#menü)

[Kaynak dosya](example/lib/src/version/version_page.dart)

`VersionPage`, `BlueCore.packageInfo` üzerinden yüklenmiş uygulama bilgilerini
okur ve `InfoPage` ile gösterir. Alanlar uygulama adı (`appName`), paket adı
(`packageName`), sürüm (`version`) ve build numarasıdır (`buildNumber`).
Okunan sürüm örnek uygulamanın `pubspec.yaml` sürümüdür.

## Kullanım

```dart
import 'package:blue_core/blue_core.dart';
import 'package:blue_core_example/src/version/version_page.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BlueCore.init();
  runApp(const MaterialApp(home: VersionPage()));
}
```

Yüklenmiş veriye erişim:

```dart
final info = BlueCore.packageInfo;
print('${info.appName}: ${info.version}+${info.buildNumber}');
```

Yeni bir platform okuması için `await BlueCoreImpl.getPackageInfo()` kullanılabilir.
`VersionPage` kendi başına yeni istek veya yenileme yapmaz; güncellenen verinin
arayüze yansıması için sayfanın yeniden oluşturulması gerekir.

[Ana menüye dön](README.md#menü)
