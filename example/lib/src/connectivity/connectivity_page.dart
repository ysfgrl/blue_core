import 'package:blue_core/blue_core.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class ConnectivityPage extends StatelessWidget {
  const ConnectivityPage({super.key});

  static const _types = {
    'wifi': ('Wi-Fi', Icons.wifi_rounded),
    'ethernet': ('Ethernet', Icons.settings_ethernet_rounded),
    'mobile': ('Mobil veri', Icons.signal_cellular_alt_rounded),
    'bluetooth': ('Bluetooth', Icons.bluetooth_rounded),
    'vpn': ('VPN', Icons.vpn_lock_outlined),
    'satellite': ('Uydu', Icons.satellite_alt_rounded),
    'other': ('Diğer bağlantı', Icons.device_hub_rounded),
    'none': ('Bağlantı yok', Icons.wifi_off_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bağlantı durumu'),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ağ bağlantınız', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Bağlantı türü değiştiğinde bu ekran otomatik güncellenir.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlueConnectivity(
                    builder: (connections) {
                      final active = connections
                          .where((type) => type != 'none')
                          .toList();
                      final connected = active.isNotEmpty;
                      final visible = connected ? active : ['none'];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    connected
                                        ? Icons.check_circle_outline
                                        : Icons.wifi_off_rounded,
                                    size: 32,
                                    color: connected
                                        ? colors.primary
                                        : colors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          connected
                                              ? 'Ağ bağlantısı var'
                                              : 'Ağ bağlantısı yok',
                                          style: theme.textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          connected
                                              ? 'Aktif bağlantı türleri aşağıda gösteriliyor.'
                                              : 'Cihazınızı bir ağa bağlayarak tekrar deneyin.',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: colors.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final type in visible)
                                    Chip(
                                      avatar: Icon(
                                        (_types[type] ?? _types['other']!).$2,
                                        size: 18,
                                      ),
                                      label: Text(
                                        (_types[type] ?? _types['other']!).$1,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Wi-Fi, Ethernet veya mobil veri bağlantınızı değiştirerek deneyebilirsiniz. '
                    'Bu gösterge ağ türünü bildirir; internet erişimini doğrulamaz.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.5,
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
