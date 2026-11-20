import 'package:blue_core/blue_core.dart';

// Yalnızca dialog önizlemesi: mağaza isteği veya platform değişikliği yapılmaz.
class DemoUpgraderBloc extends UpgraderBloc {
  DemoUpgraderBloc({required PackageInfo current, required DeviceInfo device})
    : super(current: current, device: device) {
    final major = int.tryParse(current.version.split('.').first) ?? 1;
    final available = PackageInfo.init()
      ..appName = current.appName
      ..packageName = current.packageName
      ..version = '${major + 1}.0.0'
      ..buildNumber = '100'
      ..releaseNotes =
          '• Arayüz iyileştirmeleri\n'
          '• Performans güncellemeleri\n'
          '• Hata düzeltmeleri\n\n'
          'Bu bir önizlemedir. Mağaza bağlantısı tanımlı değildir.'
      ..storeUrl = null;
    emit(
      state.copyWith(status: UpgradeStatus.newVersion, available: available),
    );
  }
}
