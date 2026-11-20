# Liste örneği — list

[Ana menü](README.md#menü)

## Açıklama

[`example/lib/src/list/list_page.dart`](example/lib/src/list/list_page.dart),
paketteki [`BlueList`](lib/src/list/blue_list.dart) ve
[`ListBloc`](lib/src/list/bloc/list_bloc.dart) bileşenlerini kullanır.
Ana ekrandaki **Liste örneği** bağlantısı veya Drawer içindeki **List** menüsüyle açılır.

Örnek 48 yerel ürünle çalışır; sunucu bağlantısı gerekmez. Ürün veya kategori
adıyla arama yapılabilir. Aramayı uygulamak için Enter'a veya arama alanındaki
ok düğmesine basın. Aramayı kaldırmak için alanı boşaltıp tekrar arayın.

- Liste, tablo ve kart görünümü arasında geçiş yapılabilir.
- Sayfa başına 10, 20 veya 50 ürün gösterilebilir.
- Satır veya kartlara dokunarak birden fazla ürün seçilebilir.
- Seçimler alttaki **Seçimi temizle** düğmesiyle kaldırılabilir.
- Yenile düğmesi veya listeyi aşağı çekme hareketi veriyi yeniden yükler.

`DemoProduct`, `BaseModel` sınıfını genişletir; eşitliği ürün kimliğine göre
tanımlar. [`DemoProductRepository`](example/lib/src/list/demo_product_repository.dart),
`ListRepo<DemoProduct>` üzerinden arama ve sayfalama uygular. `ListResponse.total`
eşleşen toplam ürün sayısını, `page` mevcut sayfayı belirtir. Arama ve sayfa
yüklemeleri `ListBloc` tarafından yönetilir; sayfa yüklenirken seçimler temizlenir.

## Sayfayı açma

```dart
import 'package:blue_core_example/src/list/list_page.dart';
import 'package:flutter/material.dart';

void openList(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const ListPage()),
  );
}
```

## BlueList kullanımı

`BlueList` esnek yükseklik kullandığı için `Column` içinde `Expanded` ile sarılır.
Aşağıdaki örnek, mevcut ürün modelini ve yerel repository'yi kullanır:

```dart
import 'package:blue_core/blue_core.dart';
import 'package:blue_core_example/src/list/demo_product.dart';
import 'package:blue_core_example/src/list/demo_product_repository.dart';
import 'package:flutter/material.dart';

class ProductListDemo extends StatefulWidget {
  const ProductListDemo({super.key});

  @override
  State<ProductListDemo> createState() => _ProductListDemoState();
}

class _ProductListDemoState extends State<ProductListDemo> {
  late final ListBloc<DemoProduct> bloc;

  @override
  void initState() {
    super.initState();
    final repository = DemoProductRepository();
    bloc = ListBloc<DemoProduct>(
      getRepo: () => repository,
      viewType: ListViewType.listView,
      pageSize: 10,
      filters: <String, FilterModel>{},
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
      appBar: AppBar(title: const Text('Ürünler')),
      body: Column(
        children: [
          Expanded(
            child: BlueList<DemoProduct>(
              listBloc: bloc,
              title: const Text('Ürünler'),
              listViewBuilder: (product, selected, index) => ListTile(
                title: Text(product.name),
                subtitle: Text(product.category),
                trailing: Text('${product.price} ₺'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

`BlueList`, ilk gösterimde listeyi otomatik yükler. Tam örnek sayfada dar
ekranlara uyumlu arama ve sayfalama kontrolleri kullanıldığı için bileşenin
kendi başlığı ve alt çubuğu `hideTitle: true`, `hideFooter: true` ile gizlenir.
`listViewBuilder`, `dataTableBuilder` ve `sliverGridBuilder` aynı ürünleri farklı
görünümlerde gösterir; seçilen görünüm `ListSetViewTypeEvent` ile değiştirilir.

[Ana menüye dön](README.md#menü)
