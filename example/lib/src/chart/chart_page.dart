import 'package:blue_core/blue_core.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import 'chart_repository.dart';
import 'chart_sample.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final _repository = ChartRepository();
  late final ListBloc<ChartSample> _bloc;

  static const _palette = [
    Color(0xFF3563E9),
    Color(0xFF0D9488),
    Color(0xFF9333EA),
    Color(0xFFB45309),
    Color(0xFFDB2777),
    Color(0xFF475569),
  ];

  @override
  void initState() {
    super.initState();
    _bloc = ListBloc<ChartSample>(
      getRepo: () => _repository,
      initValues: _repository.samples,
      pageSize: 6,
    );
  }

  @override
  void dispose() {
    _bloc.close();
    _bloc.scroll.dispose();
    _bloc.searchController.dispose();
    super.dispose();
  }

  Widget _label(ChartSample sample) =>
      Text(sample.label, style: Theme.of(context).textTheme.labelSmall);

  String _info(ChartSample sample) =>
      '${sample.month}: ${sample.amount.toStringAsFixed(0)} bin ₺';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const tooltipStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grafik örnekleri'),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aylık satışlar', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'İlk altı ayın örnek satış verileri, bin ₺ cinsinden. '
                    'Detay için sütunlara veya çizgiye dokunun.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        child: DropdownButtonFormField<int>(
                          initialValue: _repository.year,
                          decoration: const InputDecoration(
                            labelText: 'Yıl',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 2025, child: Text('2025')),
                            DropdownMenuItem(value: 2026, child: Text('2026')),
                          ],
                          onChanged: (year) {
                            if (year == null) return;
                            _repository.year = year;
                            _bloc.add(const ListRefreshPageEvent());
                          },
                        ),
                      ),
                      BlocBuilder<
                        ListBloc<ChartSample>,
                        ListState<ChartSample>
                      >(
                        bloc: _bloc,
                        builder: (context, state) {
                          final total = state.list.fold<double>(
                            0,
                            (sum, sample) => sum + sample.amount,
                          );
                          return Text(
                            'Toplam ${total.toStringAsFixed(0)} bin ₺',
                            style: theme.textTheme.titleMedium,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth >= 840
                          ? (constraints.maxWidth - 20) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _ChartCard(
                            width: width,
                            title: 'Sütun grafiği',
                            description: 'Aylara göre satış tutarı',
                            child: BlueChartBar<ChartSample>(
                              listBloc: _bloc,
                              hideTile: true,
                              padding: const EdgeInsets.fromLTRB(0, 16, 12, 0),
                              labelBuilder: _label,
                              yBuilder: (sample) => sample.amount,
                              infoBuilder: _info,
                              infoStyle: tooltipStyle,
                              color: colors.primary,
                            ),
                          ),
                          _ChartCard(
                            width: width,
                            title: 'Çizgi grafiği',
                            description: 'Satışların zaman içindeki değişimi',
                            child: BlueChartLine<ChartSample>(
                              listBloc: _bloc,
                              hideTile: true,
                              padding: const EdgeInsets.fromLTRB(0, 16, 12, 0),
                              labelBuilder: _label,
                              yBuilder: (sample) => sample.amount,
                              infoBuilder: _info,
                              infoStyle: tooltipStyle,
                              color: colors.tertiary,
                            ),
                          ),
                          _ChartCard(
                            width: width,
                            title: 'Pasta grafiği',
                            description: 'Her ayın toplam satış içindeki payı',
                            child: BlueChartPie<ChartSample>(
                              listBloc: _bloc,
                              hideTile: true,
                              padding: const EdgeInsets.all(16),
                              yBuilder: (sample) => sample.amount,
                              titleBuilder: (sample) => sample.label,
                              colorBuilder: (sample, index) =>
                                  _palette[index % _palette.length],
                            ),
                            footer: Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                for (final (index, month) in [
                                  'Ocak',
                                  'Şubat',
                                  'Mart',
                                  'Nisan',
                                  'Mayıs',
                                  'Haziran',
                                ].indexed)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color: _palette[index],
                                        size: 10,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        month,
                                        style: theme.textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.width,
    required this.title,
    required this.description,
    required this.child,
    this.footer,
  });

  final double width;
  final String title;
  final String description;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(height: 280, child: child),
              if (footer != null) ...[const SizedBox(height: 16), footer!],
            ],
          ),
        ),
      ),
    );
  }
}
