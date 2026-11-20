# Grafik örnekleri — chart

[Ana menü](README.md#menü)

## Açıklama

[`example/lib/chart/chart_page.dart`](example/lib/chart/chart_page.dart),
paketin [`lib/src/chart`](lib/src/chart/blue_chart.dart) bileşenlerini gösterir:

- `BlueChartBar`: aylık satış tutarlarını sütunlarla karşılaştırır.
- `BlueChartLine`: satışların zaman içindeki değişimini gösterir.
- `BlueChartPie`: her ayın toplam satış içindeki payını gösterir.

Ana ekrandaki **Grafik örnekleri** bağlantısı veya Drawer içindeki **Chart**
menüsüyle açılır. 2025 ve 2026 yıllarının ilk altı ayı için yerel örnek veriler
kullanılır; tutarlar bin ₺ cinsindendir. Sütunlara veya çizgiye dokununca ay ve
tutar bilgisi gösterilir. Pasta grafiğindeki renkler alttaki ay listesiyle eşleşir.

[`ChartSample`](example/lib/chart/chart_sample.dart), `BaseModel` sınıfını
genişletir. [`ChartRepository`](example/lib/chart/chart_repository.dart),
`ListRepo<ChartSample>` üzerinden seçilen yılın verilerini sağlar. Üç grafik aynı
`ListBloc<ChartSample>` örneğine bağlıdır; yıl değiştiğinde birlikte güncellenirler.
Geniş ekranda grafik kartları iki sütun, dar ekranda tek sütun gösterilir.

## Sayfayı açma

```dart
import 'package:blue_core_example/chart/chart_page.dart';
import 'package:flutter/material.dart';

void openCharts(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const ChartPage()),
  );
}
```

## Sütun grafiği kullanımı

Grafik bileşenleri esnek yükseklik kullanır; `SizedBox` veya `Expanded` ile
yükseklik verilmelidir. Bu örneği bir `MaterialApp` altında kullanabilirsiniz:

```dart
import 'package:blue_core/blue_core.dart';
import 'package:blue_core_example/chart/chart_repository.dart';
import 'package:blue_core_example/chart/chart_sample.dart';
import 'package:flutter/material.dart';

class SalesChartDemo extends StatefulWidget {
  const SalesChartDemo({super.key});

  @override
  State<SalesChartDemo> createState() => _SalesChartDemoState();
}

class _SalesChartDemoState extends State<SalesChartDemo> {
  late final ListBloc<ChartSample> bloc;

  @override
  void initState() {
    super.initState();
    final repository = ChartRepository();
    bloc = ListBloc<ChartSample>(
      getRepo: () => repository,
      initValues: repository.samples,
      pageSize: 6,
    );
  }

  @override
  void dispose() {
    bloc.close();
    bloc.scroll.dispose();
    bloc.searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Satışlar')),
      body: SizedBox(
        height: 320,
        child: BlueChartBar<ChartSample>(
          listBloc: bloc,
          title: const Text('Aylık satışlar'),
          labelBuilder: (sample) => Text(sample.label),
          yBuilder: (sample) => sample.amount,
          infoBuilder: (sample) => '${sample.month}: ${sample.amount} bin ₺',
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
```

`initValues` veriyi ilk anda hazır sağlar. Bu parametre verilmezse grafik ilk
gösterimde `ListGetListEvent` ile repository'den veri yükler. Bileşenin başlığındaki
yenile düğmesi `ListRefreshPageEvent` gönderir. `hideTile: true`, bileşenin kendi
başlık ve yenileme satırını gizler.

## Çizgi grafiği

Aynı `bloc` ile sütun bileşeni yerine kullanılabilir:

```dart
BlueChartLine<ChartSample>(
  listBloc: bloc,
  title: const Text('Satış eğilimi'),
  labelBuilder: (sample) => Text(sample.label),
  yBuilder: (sample) => sample.amount,
  infoBuilder: (sample) => '${sample.month}: ${sample.amount} bin ₺',
  color: Colors.teal,
);
```

## Pasta grafiği

`yBuilder` dilim büyüklüğünü, `titleBuilder` dilim üzerindeki metni belirler.
`colorBuilder` ile her dilime ayrı bir renk verilebilir:

```dart
BlueChartPie<ChartSample>(
  listBloc: bloc,
  title: const Text('Aylık paylar'),
  yBuilder: (sample) => sample.amount,
  titleBuilder: (sample) => sample.label,
  colorBuilder: (sample, index) => const [
    Colors.blue,
    Colors.teal,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.indigo,
  ][index % 6],
);
```

Bu çizgi ve pasta örneklerine de yükseklik verilmelidir. Pasta grafiğinde
`labelBuilder`, istenirse dilim dışında bir badge widget'ı göstermek için
kullanılabilir; örnek sayfada sade görünüm için renk açıklaması kartın altında
sunulur.

[Ana menüye dön](README.md#menü)
