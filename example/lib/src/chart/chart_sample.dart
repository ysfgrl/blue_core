import 'package:blue_core/blue_core.dart';

class ChartSample extends BaseModel {
  ChartSample({required this.month, required this.label, required this.amount});

  final String month;
  final String label;
  final double amount;

  @override
  Map<String, dynamic> toJson() => {
    'month': month,
    'label': label,
    'amount': amount,
  };

  @override
  bool operator ==(Object other) =>
      other is ChartSample && other.month == month && other.amount == amount;

  @override
  int get hashCode => Object.hash(month, amount);
}
