import 'package:flutter/material.dart';

import 'chart/chart_page.dart';
import 'connectivity/connectivity_page.dart';
import 'upgrader/upgrader_page.dart';
import 'device_info/device_info_page.dart';
import 'list/list_page.dart';
import 'theme.dart';
import 'toast/toast_page.dart';
import 'version/version_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _pages = [
    (
      title: 'Bağlantı durumu',
      menuTitle: 'Connectivity',
      description: 'Aktif ağ türleri ve canlı değişiklikler',
      icon: Icons.wifi_rounded,
      page: ConnectivityPage(),
    ),
    (
      title: 'Sürüm bilgileri',
      menuTitle: 'Version',
      description: 'Uygulama adı, paket ve sürüm',
      icon: Icons.info_outline_rounded,
      page: VersionPage(),
    ),
    (
      title: 'Cihaz bilgileri',
      menuTitle: 'Device Info',
      description: 'Cihaz, platform ve sistem',
      icon: Icons.devices_rounded,
      page: DeviceInfoPage(),
    ),
    (
      title: 'Toast bildirimleri',
      menuTitle: 'Toast',
      description: 'Başarı, hata ve bilgi mesajları',
      icon: Icons.notifications_active_outlined,
      page: ToastPage(),
    ),
    (
      title: 'Liste örneği',
      menuTitle: 'List',
      description: 'Arama, sayfalama ve seçim',
      icon: Icons.view_list_outlined,
      page: ListPage(),
    ),
    (
      title: 'Grafik örnekleri',
      menuTitle: 'Chart',
      description: 'Sütun, çizgi ve pasta grafikleri',
      icon: Icons.bar_chart_rounded,
      page: ChartPage(),
    ),
    (
      title: 'Güncelleme kontrolü',
      menuTitle: 'Upgrader',
      description: 'Mağaza sürümü ve güncelleme penceresi',
      icon: Icons.system_update_outlined,
      page: UpgraderPage(),
    ),
  ];

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('blue_core'),
        actions: const [ThemeToggleButton()],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('blue_core', style: theme.textTheme.titleLarge),
              ),
              const Divider(),
              const SizedBox(height: 8),
              for (final item in _pages)
                ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.menuTitle),
                  onTap: () {
                    Navigator.of(context).pop();
                    _open(context, item.page);
                  },
                ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Örnekler', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Bir bileşen seçin.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (final (index, item) in _pages.indexed) ...[
                          if (index > 0)
                            const Divider(indent: 56, endIndent: 16),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            leading: Icon(item.icon, color: colors.primary),
                            title: Text(item.title),
                            subtitle: Text(item.description),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _open(context, item.page),
                          ),
                        ],
                      ],
                    ),
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
