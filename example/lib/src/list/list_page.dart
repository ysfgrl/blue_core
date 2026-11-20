import 'package:blue_core/blue_core.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import 'demo_product.dart';
import 'demo_product_repository.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late final ListBloc<DemoProduct> _bloc;

  @override
  void initState() {
    super.initState();
    final repository = DemoProductRepository();
    _bloc = ListBloc<DemoProduct>(
      getRepo: () => repository,
      viewType: ListViewType.listView,
      selectMode: ListSelectMode.multi,
      pageSize: 10,
      filters: <String, FilterModel>{},
    );
  }

  @override
  void dispose() {
    _bloc.close();
    _bloc.scroll.dispose();
    _bloc.searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(DemoProduct product, bool selected) {
    if (selected) {
      _bloc.add(ListRemoveSelectedEvent<DemoProduct>(product));
    } else {
      _bloc.add(ListAddSelectedEvent<DemoProduct>(product));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste örneği'),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ürünleri keşfedin.',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Arayın, görünümü değiştirin ve ürünleri seçin.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _bloc.searchController,
                          decoration: InputDecoration(
                            hintText: 'Ürün veya kategori ara',
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              tooltip: 'Ara',
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () =>
                                  _bloc.add(const ListSearchValueEvent()),
                            ),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) =>
                              _bloc.add(const ListSearchValueEvent()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Yenile',
                        onPressed: () =>
                            _bloc.add(const ListRefreshPageEvent()),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<ListBloc<DemoProduct>, ListState<DemoProduct>>(
                    bloc: _bloc,
                    builder: (context, state) => Wrap(
                      spacing: 8,
                      children: [
                        for (final (type, label, icon) in [
                          (
                            ListViewType.listView,
                            'Liste',
                            Icons.view_list_outlined,
                          ),
                          (
                            ListViewType.dataTable,
                            'Tablo',
                            Icons.table_chart_outlined,
                          ),
                          (
                            ListViewType.sliverGrid,
                            'Kartlar',
                            Icons.grid_view_outlined,
                          ),
                        ])
                          ChoiceChip(
                            avatar: Icon(icon, size: 18),
                            label: Text(label),
                            selected: state.viewType == type,
                            onSelected: (_) =>
                                _bloc.add(ListSetViewTypeEvent(type)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: BlueList<DemoProduct>(
                        listBloc: _bloc,
                        hideTitle: true,
                        hideFooter: true,
                        emptyWidget: const Center(
                          child: Text('Aramanıza uygun ürün bulunamadı.'),
                        ),
                        errorBuilder: (_) => Center(
                          child: FilledButton.icon(
                            onPressed: () =>
                                _bloc.add(const ListRefreshPageEvent()),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tekrar dene'),
                          ),
                        ),
                        listViewBuilder: (product, selected, index) => ListTile(
                          selected: selected,
                          leading: CircleAvatar(
                            child: Icon(
                              selected
                                  ? Icons.check
                                  : Icons.shopping_bag_outlined,
                            ),
                          ),
                          title: Text(product.name),
                          subtitle: Text(
                            '${product.category} · ${product.price} ₺',
                          ),
                          trailing: Checkbox(
                            value: selected,
                            onChanged: (_) =>
                                _toggleSelection(product, selected),
                          ),
                          onTap: () => _toggleSelection(product, selected),
                        ),
                        columns: const [
                          DataColumn(label: Text('Ürün')),
                          DataColumn(label: Text('Kategori')),
                          DataColumn(label: Text('Fiyat'), numeric: true),
                        ],
                        dataTableBuilder: (product, selected) => DataRow(
                          selected: selected,
                          onSelectChanged: (_) =>
                              _toggleSelection(product, selected),
                          cells: [
                            DataCell(Text(product.name)),
                            DataCell(Text(product.category)),
                            DataCell(Text('${product.price} ₺')),
                          ],
                        ),
                        delegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 360,
                              mainAxisExtent: 180,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        sliverGridBuilder: (product, selected, index) => Card(
                          color: selected ? colors.secondaryContainer : null,
                          child: InkWell(
                            onTap: () => _toggleSelection(product, selected),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    selected
                                        ? Icons.check_circle
                                        : Icons.shopping_bag_outlined,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        '${product.name}\n${product.category}',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${product.price} ₺',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        selectedBuilder: (context, selected) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: Wrap(
                            spacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text('${selected.length} ürün seçildi'),
                              TextButton(
                                onPressed: () => _bloc.add(const ListClearSelectedEvent()),
                                child: const Text('Seçimi temizle'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  BlocBuilder<ListBloc<DemoProduct>, ListState<DemoProduct>>(
                    bloc: _bloc,
                    builder: (context, state) {
                      final pages = state.total == 0
                          ? 1
                          : (state.total / state.pageSize).ceil();
                      final loading =
                          state.listState != ListBlocDataState.loaded;
                      return Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IconButton(
                            tooltip: 'Önceki sayfa',
                            onPressed: !loading && state.page > 1
                                ? () => _bloc.add(const ListPreviousPageEvent())
                                : null,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text('${state.page} / $pages · ${state.total} ürün'),
                          IconButton(
                            tooltip: 'Sonraki sayfa',
                            onPressed: !loading && state.page < pages
                                ? () => _bloc.add(const ListNextPageEvent())
                                : null,
                            icon: const Icon(Icons.chevron_right),
                          ),
                          DropdownButton<int>(
                            value: state.pageSize,
                            items: [
                              for (final size in [10, 20, 50])
                                DropdownMenuItem(
                                  value: size,
                                  child: Text('$size / sayfa'),
                                ),
                            ],
                            onChanged: loading
                                ? null
                                : (value) {
                                    if (value != null)
                                      _bloc.add(ListSetPageSizeEvent(value));
                                  },
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
