# Toast bildirimleri — toast

[Ana menü](README.md#menü)

[Kaynak dosya](example/lib/src/toast/toast_page.dart)

`ToastPage`, `blue_core` paketindeki `BlueToast`, `ToastModel` ve `ToastBloc`
bileşenlerini kullanır. Başarı, hata ve bilgi bildirimleri gösterilebilir.
Sayfadan yedi konum seçilebilir; otomatik kapanma süresi 2, 4 veya 8 saniye
olabilir. Otomatik kapanma kapatıldığında mesaj, kapatma düğmesine basılana kadar
kalır.

`BlueToast.local`, kendi `ToastBloc` örneğini oluşturur. Sayfa kaldırıldığında
bloc kapatılır ve toast widget'larının zamanlayıcıları temizlenir. Bu nedenle
bu sayfadaki bildirimler başka sayfalara taşınmaz.

## Yerel kullanım

`BlueToast.of(context)` çağrısındaki context, `BlueToast.local` altında olmalıdır.
`Builder` bu context'i sağlar:

```dart
import 'package:blue_core/blue_core.dart';
import 'package:flutter/material.dart';

class LocalToastDemo extends StatelessWidget {
  const LocalToastDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toast')),
      body: BlueToast.local(
        child: Builder(
          builder: (toastContext) => Center(
            child: FilledButton(
              onPressed: () {
                BlueToast.of(toastContext).add(
                  ToastAddEvent(ToastModel.success(
                    'Değişiklikler kaydedildi.',
                    title: 'Başarılı',
                    position: ToastPosition.bottomCenter,
                    timeout: const Duration(seconds: 4),
                  )),
                );
              },
              child: const Text('Bildirim göster'),
            ),
          ),
        ),
      ),
    );
  }
}
```

Bu widget bir `MaterialApp` altında kullanılmalıdır.

## Mesaj türleri ve süre

Aşağıdaki modeller `ToastAddEvent` içinde yerel bloc'a gönderilebilir:

```dart
final success = ToastModel.success('Kaydedildi.', title: 'Başarılı');
final error = ToastModel.error('İşlem tamamlanamadı.', title: 'Hata');
final info = ToastModel.info('Yeni bir güncelleme var.', title: 'Bilgi');

final persistent = ToastModel.info(
  'Bu bildirimi elle kapatabilirsiniz.',
  title: 'Bilgi',
  position: ToastPosition.topRight,
  timeout: null,
);
```

Adlandırılmış `success`, `error` ve `info` kurucuları varsayılan olarak 2 saniye
ve `bottomCenter` konumunu kullanır. `timeout: null` otomatik kapanmayı kapatır.
Konumlar: `topLeft`, `topCenter`, `topRight`, `center`, `bottomLeft`,
`bottomCenter`, `bottomRight`.

## Global kullanım

Uygulama genelinde `BlueToast.add` kullanmak için ortak bloc ayrıca sağlanmalıdır:

```dart
BlocProvider<ToastBloc>.value(
  value: BlueToast.instance,
  child: BlueToast(
    child: const Scaffold(body: Center(child: Text('Uygulama sayfası'))),
  ),
);

// Bildirim, yukarıdaki BlueToast widget'ında gösterilir:
BlueToast.add(ToastModel.info('Uygulama genelinde bildirim.'));
```

Yerel kullanımda `BlueToast.of(context)`, global kullanımda `BlueToast.add`
kullanılır. Örnek uygulamadaki `ToastPage` yerel yaklaşımı kullanır.

[Ana menüye dön](README.md#menü)
