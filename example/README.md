# blue_core Example

Material 3 kullanan örnek Flutter uygulaması. Ana ekrandaki hızlı erişim kartları
ve Drawer menüsü üzerinden sürüm ve cihaz bilgilerine ulaşılır. Geniş ekranlarda
kartlar yan yana, dar ekranlarda alt alta gösterilir. Bilgi sayfalarındaki değerler
seçilip kopyalanabilir.

Üst bardaki güneş/ay düğmesi tüm sayfalarda açık ve koyu tema arasında geçiş yapar.
İlk açılışta sistem teması kullanılır; elle seçilen tema uygulama açık kaldığı
sürece korunur.

**Version / Sürüm bilgileri** sayfası uygulama adı, paket adı, sürüm ve build
numarasını gösterir. **Device Info / Cihaz bilgileri** sayfası platform, cihaz türü,
adı, modeli ve sistem/tarayıcı sürümünü gösterir. Veriler uygulama başlangıcında
`BlueCore.init()` ile yüklenir. Okunan sürüm `example/pubspec.yaml` içindeki
uygulama sürümüdür.

**Toast / Toast bildirimleri** sayfası `lib/src/toast` bileşenlerinin yerel
kullanımını `example/lib/src/toast/toast_page.dart` içinde gösterir. İçerik
`BlueToast.local` ile sarılır; onun altındaki context üzerinden
`BlueToast.of(context).add(ToastAddEvent(ToastModel.success(...)))` çağrısı yapılır.
Başarı, hata ve bilgi mesajlarını yedi farklı konumda deneyebilir; süreyi seçebilir
ve otomatik kapanmayı kapatabilirsiniz. `timeout: null` verilen mesajlar elle
kapatılır. Sayfa kapandığında yerel bloc ve bildirimler temizlenir.

```sh
cd example
/Volumes/macos/flutter/bin/flutter pub get
/Volumes/macos/flutter/bin/flutter run
```

Android, iOS ve macOS üzerinde native platform arayüzü; web üzerinde
`BlueCoreWebApi` kullanılır.
Web örneğini `/Volumes/macos/flutter/bin/flutter run -d chrome` ile çalıştırabilirsiniz.

```sh
/Volumes/macos/flutter/bin/flutter analyze
/Volumes/macos/flutter/bin/flutter test
```
