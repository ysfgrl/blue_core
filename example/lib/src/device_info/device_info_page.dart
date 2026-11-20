import 'package:blue_core/blue_core.dart';
import 'package:flutter/material.dart';

import '../widgets/info_page.dart';

class DeviceInfoPage extends StatelessWidget {
  const DeviceInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final info = BlueCore.deviceInfo;
    return InfoPage(
      title: 'Cihaz bilgileri',
      description: 'Çalıştığınız cihaz, işletim sistemi ve tarayıcı bilgileri.',
      icon: Icons.devices_rounded,
      fields: {
        'Platform': info.platform,
        'Cihaz türü': info.type,
        'Cihaz adı / Tarayıcı': info.name,
        'Model': info.model,
        'İşletim sistemi / Tarayıcı sürümü': info.version,
      },
    );
  }
}
