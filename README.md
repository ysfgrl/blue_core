# blue_core

Flutter uygulamaları için cihaz ve sürüm bilgileri, toast bildirimleri ve ortak
arayüz bileşenleri sunan paket. `example/lib` altındaki klasörlerin
açıklamaları ve kullanım kodları bu dosyanın yanındaki `README.*.md`
dokümanlarında bulunur.

## Menü

- [Bağlantı durumu API](README.connection.md)
- [Connectivity widget örneği](README.connectivity.md)
- [Sürüm bilgileri — version](README.version.md)
- [Cihaz bilgileri — device_info](README.device_info.md)
- [Toast bildirimleri — toast](README.toast.md)
- [Liste örneği — list](README.list.md)
- [Grafik örnekleri — chart](README.chart.md)
- [Güncelleme kontrolü — upgrader](README.upgrader.md)

<a id="calistirma"></a>

## Örnek uygulamayı çalıştırma

```sh
cd example
flutter pub get
flutter run
```

Web için `flutter run -d chrome` kullanabilirsiniz. Flutter PATH üzerinde değilse
`flutter` yerine SDK'nızdaki tam yolu kullanın;
örneğin `/Volumes/macos/flutter/bin/flutter`.

Örnek uygulama Material 3 kullanır. Ana ekrandaki sade bağlantı listesi ve Drawer menüsü üzerinden
bağlantı, sürüm, cihaz, toast, liste, grafik ve güncelleme sayfaları açılır. Tema düğmesi tüm sayfalarda kullanılabilir.
Aşağıdaki `blue_core_example` import'ları örnek uygulamanın kendi dosyalarıdır;
`blue_core` import'u ise paket API'sidir.

```text
example/lib/
├── main.dart
└── src/
    ├── theme.dart
    ├── home_page.dart
    ├── connectivity/connectivity_page.dart
    ├── chart/
    ├── upgrader/
    ├── version/
    ├── device_info/
    ├── toast/
    ├── list/
    └── widgets/
```



[Menüye dön](#menü)
