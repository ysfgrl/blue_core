part of 'blue_chart.dart';

typedef BlueChartLabelBuilder<LType extends BaseModel> = Widget Function(LType model);
typedef BlueChartYBuilder<LType extends BaseModel> = double Function(LType model);
typedef BlueChartInfoBuilder<LType extends BaseModel> = String Function(LType model);

typedef BlueChartColorBuilder<LType extends BaseModel> = Color Function(
    LType model,
    int index,
    );