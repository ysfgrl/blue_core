import 'package:blue_core/blue_core.dart';

import 'demo_product.dart';

class DemoProductRepository extends ListRepo<DemoProduct> {
  static const _names = [
    ('Kablosuz kulaklık', 'Elektronik'),
    ('Mekanik klavye', 'Elektronik'),
    ('Masa lambası', 'Ev ve yaşam'),
    ('Seramik kupa', 'Ev ve yaşam'),
    ('Sırt çantası', 'Aksesuar'),
    ('Spor ayakkabı', 'Spor'),
    ('Akıllı saat', 'Elektronik'),
    ('Not defteri', 'Kırtasiye'),
  ];

  final List<DemoProduct> _products = List.generate(48, (index) {
    final (name, category) = _names[index % _names.length];
    return DemoProduct(
      id: index + 1,
      name: '$name ${index ~/ _names.length + 1}',
      category: category,
      price: 199 + index * 75,
    );
  });

  String _normalize(String value) =>
      value.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

  @override
  Future<ResponseModel<ListResponse<DemoProduct>>> list(ListRequest request,) async {
    final keyword = _normalize(
      request.filters['keyword']?.value?.toString().trim() ?? '',
    );
    final filtered = _products.where((product) {
      return _normalize(
        '${product.name} ${product.category}',
      ).contains(keyword);
    }).toList();
    final size = request.pageSize > 0 ? request.pageSize : 10;
    final pageCount = filtered.isEmpty ? 1 : (filtered.length / size).ceil();
    final page = request.page.clamp(1, pageCount);
    final response = ListResponse<DemoProduct>()
      ..page = page
      ..pageSize = size
      ..total = filtered.length
      ..list = filtered.skip((page - 1) * size).take(size).toList();
    return ResponseModel<ListResponse<DemoProduct>>.create(response);
  }
}
