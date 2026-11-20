import 'package:blue_core/blue_core.dart';
import 'package:flutter/material.dart';

import '../widgets/info_page.dart';

class VersionPage extends StatelessWidget {
  const VersionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final info = BlueCore.packageInfo;
    return InfoPage(
      title: 'Sürüm bilgileri',
      description: 'Yüklü uygulamanın kimlik ve sürüm bilgileri.',
      icon: Icons.info_outline_rounded,
      fields: {
        'Uygulama': info.appName,
        'Paket adı': info.packageName,
        'Sürüm': info.version,
        'Build numarası': info.buildNumber,
      },
    );
  }
}
