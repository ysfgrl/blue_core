

part of 'blue_chart.dart';

class BlueChartBar<LType extends BaseModel> extends StatelessWidget {
  final ListBloc<LType> listBloc;
  final BlueChartLabelBuilder<LType> labelBuilder;
  final BlueChartYBuilder<LType> yBuilder;
  final BlueChartInfoBuilder<LType>? infoBuilder;
  final TextStyle? infoStyle;
  final EdgeInsets padding;
  final FlGridData gridData;
  final Widget title;
  final Widget icon;
  final Divider divider;
  final Color color;
  final bool hideTile;
  const BlueChartBar({
    super.key,
    required this.listBloc,
    required this.labelBuilder,
    required this.yBuilder,
    this.infoBuilder,
    this.infoStyle,
    this.hideTile = false,
    this.padding = const EdgeInsets.all(5),
    this.gridData = const FlGridData(show: true),
    this.title = const Text("Chart"),
    this.icon = const Icon(Icons.bar_chart),
    this.divider = const Divider(),
    this.color = Colors.green,
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
                Expanded(child: title),
                IconButton(
                  onPressed: () {
                    listBloc.add(const ListRefreshPageEvent());
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
                  listBloc.add(const ListGetListEvent());
                }

                if (state.listState != ListBlocDataState.loaded) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return BarChart(
                  BarChartData(
                    minY: 0,
                    gridData: gridData,
                    borderData: FlBorderData(
                      show: false,
                    ),

                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),

                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),

                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();

                            if (index < 0 ||
                                index >= state.list.length) {
                              return const SizedBox.shrink();
                            }

                            return SideTitleWidget(
                              meta: meta,
                              child: labelBuilder(
                                state.list[index],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    barTouchData: BarTouchData(
                      enabled: infoBuilder != null,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (
                            group,
                            groupIndex,
                            rod,
                            rodIndex,
                            ) {
                          if (infoBuilder == null) {
                            return null;
                          }

                          return BarTooltipItem(
                            infoBuilder!(
                              state.list[group.x],
                            ),
                            infoStyle ??
                                const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                          );
                        },
                      ),
                    ),

                    barGroups: List.generate(
                      state.list.length,
                          (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: yBuilder(
                                state.list[index],
                              ),
                              width: 16,
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}