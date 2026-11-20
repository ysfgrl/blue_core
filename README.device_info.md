# Cihaz bilgileri — device_info

[Ana menü](README.md#menü)

[Kaynak dosya](example/lib/src/device_info/device_info_page.dart)

`DeviceInfoPage`, başlangıçta yüklenen `BlueCore.deviceInfo` verisini `InfoPage`
ile gösterir.

| Alan | Açıklama |
| --- | --- |
| `platform` | Çalışılan platform |
| `type` | Cihaz kategorisi |
| `name` | Cihaz veya tarayıcı adı |
| `model` | Donanım modeli |
| `version` | İşletim sistemi veya tarayıcı sürümü |

Boş alanlar ekranda `Kullanılamıyor` olarak gösterilir. Web'de donanım modeli
sunulmaz; sistemden okunamayan masaüstü model bilgisi de boş olabilir.

## Kullanım

```dart
import 'package:blue_core/blue_core.dart';
import 'package:blue_core_example/src/device_info/device_info_page.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BlueCore.init();
  runApp(const MaterialApp(home: DeviceInfoPage()));
}
```

Yüklenmiş cihaz verisine erişim:

```dart
final info = BlueCore.deviceInfo;
print('${info.platform}: ${info.name} (${info.model}), ${info.version}');
```

Yeni bir platform okuması için `await BlueCoreImpl.getDeviceInfo()` kullanılabilir.
Sayfa veriyi senkron okur; yenilenen bilgiyi göstermek için tekrar oluşturulmalıdır.

[Ana menüye dön](README.md#menü)
