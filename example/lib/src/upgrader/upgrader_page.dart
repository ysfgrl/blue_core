import 'package:blue_core/blue_core.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import 'demo_upgrader_bloc.dart';

class UpgraderPage extends StatelessWidget {
  const UpgraderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // BlueCore.init() uygulama başlangıcında çağrılmış olmalıdır.
    return const BlueUpgrader(child: _UpgraderContent());
  }
}

class _UpgraderContent extends StatelessWidget {
  const _UpgraderContent();

  Future<void> _preview(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => BlocProvider<UpgraderBloc>(
        create: (_) => DemoUpgraderBloc(
          current: BlueCore.packageInfo,
          device: BlueCore.deviceInfo,
        ),
        child: BlocListener<UpgraderBloc, UpgraderState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == UpgradeStatus.later)
              Navigator.of(context).pop();
          },
          child: BlocBuilder<UpgraderBloc, UpgraderState>(
            builder: (context, state) => BlueUpgraderAlert(state: state),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Güncelleme kontrolü'),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: BlocBuilder<UpgraderBloc, UpgraderState>(
                builder: (context, state) {
                  final checking = state.status == UpgradeStatus.checking;
                  final (
                    statusTitle,
                    description,
                    icon,
                  ) = switch (state.status) {
                    UpgradeStatus.init => (
                      'Kontrole hazır',
                      'Mağaza sürümü kontrol edilecek.',
                      Icons.system_update_outlined,
                    ),
                    UpgradeStatus.checking => (
                      'Kontrol ediliyor',
                      'Mağazadaki sürüm bilgisi alınıyor.',
                      Icons.sync,
                    ),
                    UpgradeStatus.upToDate => (
                      'Uygulama güncel',
                      'Daha yeni bir mağaza sürümü bulunamadı.',
                      Icons.check_circle_outline,
                    ),
                    UpgradeStatus.newVersion => (
                      'Yeni sürüm mevcut',
                      'Güncelleme penceresinden mağazaya geçebilirsiniz.',
                      Icons.system_update,
                    ),
                    UpgradeStatus.later => (
                      'Güncelleme ertelendi',
                      'İsterseniz tekrar kontrol edebilirsiniz.',
                      Icons.schedule,
                    ),
                    UpgradeStatus.unsupported => (
                      'Mağaza kontrolü desteklenmiyor',
                      'Kontrol Android ve iOS için kullanılabilir. Güncelleme penceresini önizleyebilirsiniz.',
                      Icons.devices_outlined,
                    ),
                    UpgradeStatus.failure => (
                      'Kontrol tamamlanamadı',
                      'Bağlantınızı ve uygulamanın mağazada yayınlandığını kontrol edip tekrar deneyin.',
                      Icons.error_outline,
                    ),
                  };
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uygulama güncellemeleri',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mağaza sürümünü kontrol edin veya güncelleme penceresini önizleyin.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.current.appName,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              SelectableText(state.current.packageName),
                              const SizedBox(height: 16),
                              Text(
                                'Yüklü sürüm: ${state.current.version}+${state.current.buildNumber}',
                              ),
                              if ({
                                UpgradeStatus.upToDate,
                                UpgradeStatus.newVersion,
                                UpgradeStatus.later,
                              }.contains(state.status)) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Mağaza sürümü: ${state.available.version}',
                                ),
                              ],
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    icon,
                                    color: state.status == UpgradeStatus.failure
                                        ? colors.error
                                        : colors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          statusTitle,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          description,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (checking) ...[
                                const SizedBox(height: 20),
                                const LinearProgressIndicator(),
                              ],
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  FilledButton.icon(
                                    onPressed:
                                        checking ||
                                            state.status ==
                                                UpgradeStatus.unsupported
                                        ? null
                                        : () {
                                            context.read<UpgraderBloc>().add(
                                              const UpgraderControlEvent(),
                                            );
                                          },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Tekrar kontrol et'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: checking
                                        ? null
                                        : () => _preview(context),
                                    icon: const Icon(Icons.visibility_outlined),
                                    label: const Text('Pencereyi önizle'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
