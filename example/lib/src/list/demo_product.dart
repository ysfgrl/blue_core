import 'package:blue_core/blue_core.dart';

class DemoProduct extends BaseModel {
  DemoProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
  });

  final int id;
  final String name;
  final String category;
  final int price;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
  };

  @override
  bool operator ==(Object other) => other is DemoProduct && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
