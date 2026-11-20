# Connectivity widget örneği

[Ana menü](README.md#menü)

## Açıklama

[`example/lib/src/connectivity/connectivity_page.dart`](example/lib/src/connectivity/connectivity_page.dart),
[`BlueConnectivity`](lib/src/connectivity/blue_connectivity.dart) widget'ını kullanır.
Ana ekrandaki **Bağlantı durumu** bağlantısı veya Drawer içindeki **Connectivity**
menüsüyle açılır.

Widget, ilk bağlantı durumunu sorgular ve sonraki değişiklikleri dinleyerek
`builder` fonksiyonunu yeniden çalıştırır. Builder `List<String>` alır:
`wifi`, `ethernet`, `mobile`, `vpn`, `bluetooth`, `satellite`, `other` veya `none`.
`none`, bağlantı olmadığını belirtir; aktif bağlantılarla birlikte döndürülmez.
Örnek sayfa bu değerleri ikon ve Türkçe etiketlerle gösterir.

## Kullanım

```dart
import 'package:blue_core/blue_core.dart';
import 'package:flutter/material.dart';

class ConnectivityDemo extends StatelessWidget {
  const ConnectivityDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bağlantı durumu')),
      body: BlueConnectivity(
        builder: (connections) {
          final connected = connections.any((type) => type != 'none');
          return ListTile(
            leading: Icon(connected ? Icons.wifi : Icons.wifi_off),
            title: Text(connected ? 'Ağ bağlantısı var' : 'Ağ bağlantısı yok'),
            subtitle: Text(connections.join(', ')),
          );
        },
      ),
    );
  }
}
```

Bir `MaterialApp` altında kullanın. Örnek uygulamanın Flutter başlangıcı ve
platform kayıtları zaten hazırdır. Bu widget için ayrıca bir BlocProvider veya
manuel StreamSubscription oluşturmak gerekmez.

## Yaşam döngüsü

`BlueConnectivity`, aboneliği oluşturur ve kaldırıldığında iptal eder. Sayfa
kapandıktan sonra tamamlanan ilk sorgu arayüzü güncellemez. Geciken sorgular daha
yeni stream sonuçlarını ezmez. Uygulama yeniden ön plana geldiğinde durum tekrar
sorgulanır.

Web'de çevrimiçi bağlantı `other`, çevrimdışı bağlantı `none` olarak gösterilir.
Linux/Windows'ta değişiklikler dinleyici varken iki saniyede bir kontrol edilir.
Ağ türünün bulunması internet erişimini doğrulamaz.

Tek seferlik sorgu ve ham stream kullanımı için [bağlantı API rehberine](README.connection.md)
bakabilirsiniz.

[Ana menüye dön](README.md#menü)
