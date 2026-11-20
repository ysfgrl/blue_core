import 'package:blue_core/blue_core.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class ToastPage extends StatelessWidget {
  const ToastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toast örnekleri'),
        actions: const [ThemeToggleButton()],
      ),
      // Yerel bloc sayfa kapandığında otomatik olarak temizlenir.
      body: const BlueToast.local(child: _ToastControls()),
    );
  }
}

class _ToastControls extends StatefulWidget {
  const _ToastControls();

  @override
  State<_ToastControls> createState() => _ToastControlsState();
}

class _ToastControlsState extends State<_ToastControls> {
  ToastPosition _position = ToastPosition.bottomCenter;
  int _seconds = 4;
  bool _autoDismiss = true;

  static const _positions = {
    ToastPosition.topLeft: 'Sol üst',
    ToastPosition.topCenter: 'Üst orta',
    ToastPosition.topRight: 'Sağ üst',
    ToastPosition.center: 'Orta',
    ToastPosition.bottomLeft: 'Sol alt',
    ToastPosition.bottomCenter: 'Alt orta',
    ToastPosition.bottomRight: 'Sağ alt',
  };

  void _showToast(ToastLevel level) {
    final timeout = _autoDismiss ? Duration(seconds: _seconds) : null;
    final toast = switch (level) {
      ToastLevel.success => ToastModel.success(
        'Değişiklikleriniz başarıyla kaydedildi.',
        title: 'Başarılı',
        position: _position,
        timeout: timeout,
      ),
      ToastLevel.error => ToastModel.error(
        'İşlem tamamlanamadı. Lütfen tekrar deneyin.',
        title: 'Hata',
        position: _position,
        timeout: timeout,
      ),
      ToastLevel.info => ToastModel.info(
        'Bu, blue_core ile gösterilen bir bilgi mesajıdır.',
        title: 'Bilgi',
        position: _position,
        timeout: timeout,
      ),
    };

    // Bu context, BlueToast.local altındaki yerel ToastBloc'a erişir.
    BlueToast.of(context).add(ToastAddEvent(toast));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
                  size: 32,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Toast bildirimlerini deneyin.',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Konumu ve süreyi seçin, ardından bir mesaj gösterin. '
                'Bildirimleri üzerlerindeki kapatma düğmesiyle de kapatabilirsiniz.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<ToastPosition>(
                        initialValue: _position,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Bildirim konumu',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final position in _positions.entries)
                            DropdownMenuItem(
                              value: position.key,
                              child: Text(position.value),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _position = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Otomatik kapat'),
                        subtitle: const Text(
                          'Kapalıysa bildirim siz kapatana kadar görünür.',
                        ),
                        value: _autoDismiss,
                        onChanged: (value) =>
                            setState(() => _autoDismiss = value),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<int>(
                        initialValue: _seconds,
                        decoration: const InputDecoration(
                          labelText: 'Gösterim süresi',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final seconds in [2, 4, 8])
                            DropdownMenuItem(
                              value: seconds,
                              child: Text('$seconds saniye'),
                            ),
                        ],
                        onChanged: _autoDismiss
                            ? (value) {
                                if (value != null)
                                  setState(() => _seconds = value);
                              }
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () => _showToast(ToastLevel.success),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Başarı mesajı'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () => _showToast(ToastLevel.error),
                            icon: const Icon(Icons.error_outline),
                            label: const Text('Hata mesajı'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _showToast(ToastLevel.info),
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Bilgi mesajı'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
