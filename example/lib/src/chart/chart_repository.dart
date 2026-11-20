import 'package:blue_core/blue_core.dart';

import 'chart_sample.dart';

class ChartRepository extends ListRepo<ChartSample> {
  int year = 2026;

  static const _months = [
    ('Ocak', 'Oca'),
    ('Şubat', 'Şub'),
    ('Mart', 'Mar'),
    ('Nisan', 'Nis'),
    ('Mayıs', 'May'),
    ('Haziran', 'Haz'),
  ];

  List<ChartSample> get samples {
    final amounts = year == 2025
        ? [24.0, 32.0, 28.0, 45.0, 39.0, 52.0]
        : [35.0, 42.0, 38.0, 56.0, 49.0, 68.0];
    return [
      for (final (index, month) in _months.indexed)
        ChartSample(month: month.$1, label: month.$2, amount: amounts[index]),
    ];
  }

  @override
  Future<ResponseModel<ListResponse<ChartSample>>> list(
    ListRequest request,
  ) async {
    return ResponseModel<ListResponse<ChartSample>>.create(
      ListResponse<ChartSample>.fromList(samples),
    );
  }
}
