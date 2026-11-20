part of 'blue_chart.dart';



class BlueChartPie<LType extends BaseModel> extends StatelessWidget {
  final ListBloc<LType> listBloc;

  /// Dilimin sayısal değeri
  final BlueChartYBuilder<LType> yBuilder;

  /// Dilimin üzerinde/yanında gösterilecek widget
  final BlueChartLabelBuilder<LType>? labelBuilder;

  /// Tooltip / bilgi metni
  final BlueChartInfoBuilder<LType>? titleBuilder;

  /// Her dilimin rengini belirlemek için
  final BlueChartColorBuilder<LType>? colorBuilder;

  final TextStyle? titleStyle;
  final EdgeInsets padding;
  final Widget title;
  final Widget icon;
  final Divider divider;
  final bool hideTile;
  final double sectionsSpace;

  const BlueChartPie({
    super.key,
    required this.listBloc,
    required this.yBuilder,
    this.labelBuilder,
    this.titleBuilder,
    this.colorBuilder,
    this.titleStyle,
    this.hideTile=false,
    this.padding = const EdgeInsets.all(0),
    this.title = const Text("Chart"),
    this.icon = const Icon(Icons.pie_chart_outline),
    this.divider = const Divider(),
    this.sectionsSpace = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          if(!hideTile)
          ...[
            Row(
              children: [
                icon,
                const SizedBox(width: 5),
                Expanded(
                  child: title,
                ),
                IconButton(
                  onPressed: () {
                    listBloc.add(
                      const ListRefreshPageEvent(),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),

            divider,

            const SizedBox(height: 5),

          ],
          Expanded(
            child: BlocBuilder<ListBloc<LType>, ListState<LType>>(
              bloc: listBloc,
              builder: (context, state) {
                if (state.listState == ListBlocDataState.init) {
                  listBloc.add(
                    const ListGetListEvent(),
                  );
                }

                if (state.listState != ListBlocDataState.loaded) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state.list.isEmpty) {
                  return const SizedBox.shrink();
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final size = math.min(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );

                    // Grafiğin toplam yarıçapı
                    final totalRadius = size / 2;

                    // Kenarlarda biraz boşluk bırak
                    const margin = 10.0;

                    // Donut iç boşluğu
                    final dynamicCenterRadius = totalRadius * 0.35;

                    // Dilimin kalınlığı
                    final sectionRadius = math.max(
                      0.0,
                      totalRadius - dynamicCenterRadius - margin,
                    );

                    return PieChart(
                      PieChartData(
                        centerSpaceRadius: dynamicCenterRadius,
                        sectionsSpace: sectionsSpace,
                        sections: List.generate(
                          state.list.length,
                              (index) {
                            final model = state.list[index];

                            return PieChartSectionData(
                              value: yBuilder(model),
                              color: colorBuilder?.call(
                                model,
                                index,
                              ) ??
                                  _defaultColor(index),
                              radius: sectionRadius,
                              showTitle: titleBuilder != null,
                              title: titleBuilder?.call(model) ?? '',

                              titleStyle: titleStyle ??
                                  const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),

                              badgeWidget: labelBuilder != null
                                  ? labelBuilder!(model)
                                  : null,
                              badgePositionPercentageOffset: 1.25,
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _defaultColor(int index) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.cyan,
      Colors.amber,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}