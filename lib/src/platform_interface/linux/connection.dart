import 'dart:io';

import '../util/connection_status.dart';

Future<List<String>> readLinuxConnectionStatus() async {
  if (!Platform.isLinux) {
    throw UnsupportedError('Linux connection status requires Linux');
  }
  final interfaces = await NetworkInterface.list(
      includeLoopback: false, includeLinkLocal: false);
  final types = <String>[];
  for (final interface in interfaces) {
    if (interface.addresses.isEmpty) continue;
    final name = interface.name;
    final base = '/sys/class/net/$name';
    final state = File('$base/operstate');
    try {
      if (await state.exists()) {
        final value = (await state.readAsString()).trim();
        if (value != 'up' && value != 'unknown') continue;
      }
      if (await Directory('$base/wireless').exists() || name.startsWith('wl')) {
        types.add('wifi');
      } else if (name.startsWith('wwan') || name.startsWith('rmnet')) {
        types.add('mobile');
      } else if (name.startsWith('tun') ||
          name.startsWith('tap') ||
          name.startsWith('wg') ||
          name.startsWith('ppp')) {
        types.add('vpn');
      } else if (name.startsWith('bnep')) {
        types.add('bluetooth');
      } else {
        final type = File('$base/type');
        types.add(
            await type.exists() && (await type.readAsString()).trim() == '1'
                ? 'ethernet'
                : 'other');
      }
    } on FileSystemException {
      // Interface removed between enumeration and reading sysfs.
      if (await Directory(base).exists()) rethrow;
    }
  }
  return normalizeConnectionStatus(types);
}
