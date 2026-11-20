part of 'blue_upgrader.dart';

class BlueUpgraderAlert extends StatelessWidget {
  final UpgraderState state;
  const BlueUpgraderAlert({super.key, required this.state});
  static const _surface = Color(0xFF0A1C22);
  static const _bodyColor = Color(0xFFD4F8F1);
  static const _accent = Color(0xFF00F5C8);

  @override
  Widget build(BuildContext context) {
    final current = state.current;
    final available = state.available;
    final releaseNotes = available.releaseNotes?.trim();
    const bodyStyle = TextStyle(
      color: _bodyColor,
      fontSize: 14,
      height: 1.4,
      letterSpacing: 0.4,
    );

    return Dialog(
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                namesRoute: true,
                header: true,
                child: const Text(
                  'Uygulamayı Güncelle?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${current.appName} uygulamanızın yeni bir versiyonu mevcut! '
                'Versiyon ${available.version} şu anda erişilebilir, '
                'mevcut sürümünüz ${current.version}.',
                style: bodyStyle,
              ),
              const SizedBox(height: 16),
              const Text(
                'Şimdi güncellemek ister misiniz?',
                style: bodyStyle,
              ),
              if (releaseNotes != null && releaseNotes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Yayın Notları',
                  style: TextStyle(
                    color: _bodyColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(releaseNotes, style: bodyStyle),
              ],
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _action('SONRA', () {
                      context.read<UpgraderBloc>().add(
                            const UpgraderLaterEvent(),
                          );
                    }),
                    _action('ŞİMDİ GÜNCELLE', () async {
                      final url = Uri.tryParse(available.storeUrl ?? '');
                      if (url == null || !url.hasScheme) {
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                          const SnackBar(
                              content: Text('Mağaza bağlantısı açılamadı.')),
                        );
                        return;
                      }
                      try {
                        await launchUrl(url,
                            mode: state.device.isAndroid
                                ? LaunchMode.externalNonBrowserApplication
                                : LaunchMode.platformDefault);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                          const SnackBar(
                              content: Text('Mağaza bağlantısı açılamadı.')),
                        );
                      }
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _action(String label, VoidCallback? onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: _accent,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      child: Text(label),
    );
  }
}
