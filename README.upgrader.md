# Güncelleme kontrolü — upgrader

[Ana menü](README.md#menü)

## Açıklama

[`example/lib/upgrader/upgrader_page.dart`](example/lib/upgrader/upgrader_page.dart),
paketteki [`BlueUpgrader`](lib/src/upgrader/blue_upgrader.dart), `UpgraderBloc`
ve `BlueUpgraderAlert` bileşenlerini gösterir. Ana ekrandaki **Güncelleme kontrolü**
bağlantısı veya Drawer içindeki **Upgrader** menüsüyle açılır.

Sayfa yüklü uygulamanın adını, paket kimliğini ve sürümünü gösterir. Açıldığında
`BlueUpgrader` mağaza kontrolünü otomatik başlatır. Android için Play Store,
iOS için App Store kullanılır; web ve masaüstünde `unsupported` durumu gösterilir.
Örnek uygulama mağazada yayınlanmamışsa kontrol başarısız olabilir.

Yeni bir sürüm bulunduğunda güncelleme penceresi otomatik açılır. **SONRA**
kontrolü erteler ve pencereyi kapatır. **ŞİMDİ GÜNCELLE** mağaza bağlantısını açar.

## Kullanım

`BlueCore.init()` mağaza kontrolünden önce tamamlanmalıdır:

```dart
import 'package:blue_core/blue_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BlueCore.init();
  runApp(const MaterialApp(
    home: BlueUpgrader(child: UpgradeDemo()),
  ));
}

class UpgradeDemo extends StatelessWidget {
  const UpgradeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Güncelleme kontrolü')),
      body: BlocBuilder<UpgraderBloc, UpgraderState>(
        builder: (context, state) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Yüklü sürüm: ${state.current.version}'),
              Text('Durum: ${state.status.name}'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.status == UpgradeStatus.checking
                    ? null
                    : () => context.read<UpgraderBloc>().add(
                        const UpgraderControlEvent(),
                      ),
                child: const Text('Tekrar kontrol et'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

`BlueUpgrader`, kendi `UpgraderBloc` örneğini sağlar ve kontrol olayını gönderir.
Durum okumaları ve tekrar kontrol çağrıları onun altındaki context ile yapılır.
Widget kaldırıldığında bloc ve onun açtığı güncelleme penceresi temizlenir.

## Durumlar

| Durum | Anlamı |
| --- | --- |
| `init` | Henüz kontrol yapılmadı |
| `checking` | Mağaza bilgileri alınıyor |
| `upToDate` | Daha yeni sürüm bulunamadı |
| `newVersion` | Yeni sürüm bulundu |
| `later` | Güncelleme ertelendi |
| `unsupported` | Platform desteklenmiyor |
| `failure` | Mağaza verisi alınamadı veya sürüm karşılaştırılamadı |

`state.current` yüklü uygulama bilgilerini, `state.available` başarılı kontrolde
bulunan mağaza bilgilerini içerir. `state.error` hata ayrıntısını taşır.
Sürüm karşılaştırması sayısal sürüm bileşenleri ve ön sürüm bilgisiyle yapılır;
build metadata sıralamayı değiştirmez.

## Pencere önizlemesi

**Pencereyi önizle** düğmesi, mağazaya istek yapmadan örnek bir yeni sürüm ve yayın
notlarıyla `BlueUpgraderAlert` gösterir. Web ve masaüstünde de kullanılabilir.

[`DemoUpgraderBloc`](example/lib/upgrader/demo_upgrader_bloc.dart), yalnızca bu
önizleme için `newVersion` durumuyla başlar. **SONRA** olayını alarak `later`
durumuna geçer; sayfadaki listener önizlemeyi kapatır. Önizlemede mağaza adresi
tanımlı değildir; **ŞİMDİ GÜNCELLE** düğmesi bir mağaza açmaz.

## Mağaza sürüm verisi

Mevcut Play Store okuyucusu önce açıklamadaki `[:mav: 2.0.0]` etiketini, ardından
desteklediği mağaza sayfası alanlarını arar. App Store okuyucusu sürümü açıklamadaki
aynı etiketten alır. Sürüm bilgisi bulunamazsa mevcut uygulamada `1.0.0` varsayılır.
Mağaza açıklaması yapılandırılırken bu davranış dikkate alınmalıdır.

[Ana menüye dön](README.md#menü)
