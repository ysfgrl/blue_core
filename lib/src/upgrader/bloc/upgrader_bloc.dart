part of '../blue_upgrader.dart';

class UpgraderBloc extends Bloc<UpgraderEvent, UpgraderState> {
  UpgraderBloc({
    required PackageInfo current,
    required DeviceInfo device,
  })  : super(UpgraderState(
          available:  PackageInfo.init(),
          device:  device,
          current: current
      )) {

    on<UpgraderControlEvent>(_control);
    on<UpgraderLaterEvent>(_later);
  }


  Future<void> _later(UpgraderLaterEvent event, Emitter<UpgraderState> emitter,) async {
    if (state.status != UpgradeStatus.newVersion) return;
    emitter(state.copyWith(status: UpgradeStatus.later,));
  }
  Future<void> _control(UpgraderControlEvent event, Emitter<UpgraderState> emitter,) async {
    if (state.status == UpgradeStatus.checking){
      return;
    };
    StoreApi? api = StoreApi.api;
    if(api == null){
      emitter(state.copyWith(
        status: UpgradeStatus.failure,
        error: "Undefined Api",
      ));
      return;
    }
    emitter(state.copyWith(status: UpgradeStatus.checking,));

    try {
      final availableInfo = await api.get(state.current.packageName);
      if (emitter.isDone) {
        return;
      };
      if (availableInfo == null) {
        emitter(state.copyWith(
          status: UpgradeStatus.failure,
          error: "Not Found",
        ));
        return;
      }
      availableInfo.appName = state.current.appName;
      final current = _UpgradeVersion.parse(state.current.version);
      final available = _UpgradeVersion.parse(availableInfo.version);
      // debugPrint("${availableInfo.toJson()}");
      emitter(state.copyWith(
        status: available.compareTo(current) > 0
            ? UpgradeStatus.newVersion
            : UpgradeStatus.upToDate,
        available: availableInfo,
      ));
    } catch (error,st) {
      debugPrintStack(stackTrace: st);
      if (emitter.isDone) return;
      emitter(state.copyWith(
        status: UpgradeStatus.failure,
        error: error.toString(),
      ));
    }
  }
}

// Build metadata does not affect precedence. Short versions and four-component
// store versions are compared numerically, with missing components set to zero.
class _UpgradeVersion implements Comparable<_UpgradeVersion> {
  final List<BigInt> numbers;
  final List<String> prerelease;

  _UpgradeVersion(this.numbers, this.prerelease);

  factory _UpgradeVersion.parse(String value) {
    final match = RegExp(
      r'^(\d+(?:\.\d+){0,3})(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$',
    ).firstMatch(value.trim());
    if (match == null) throw FormatException('Invalid app version', value);
    return _UpgradeVersion(
      match.group(1)!.split('.').map(BigInt.parse).toList(),
      match.group(2)?.split('.') ?? [],
    );
  }

  @override
  int compareTo(_UpgradeVersion other) {
    for (var i = 0; i < numbers.length || i < other.numbers.length; i++) {
      final left = i < numbers.length ? numbers[i] : BigInt.zero;
      final right = i < other.numbers.length ? other.numbers[i] : BigInt.zero;
      final comparison = left.compareTo(right);
      if (comparison != 0) return comparison;
    }
    if (prerelease.isEmpty && other.prerelease.isEmpty) return 0;
    if (prerelease.isEmpty) return 1;
    if (other.prerelease.isEmpty) return -1;
    for (var i = 0; i < prerelease.length && i < other.prerelease.length; i++) {
      final left = prerelease[i];
      final right = other.prerelease[i];
      final numeric = RegExp(r'^\d+$');
      final leftNumber = numeric.hasMatch(left) ? BigInt.parse(left) : null;
      final rightNumber = numeric.hasMatch(right) ? BigInt.parse(right) : null;
      final int comparison;
      if (leftNumber != null && rightNumber != null) {
        comparison = leftNumber.compareTo(rightNumber);
      } else if (leftNumber != null) {
        comparison = -1;
      } else if (rightNumber != null) {
        comparison = 1;
      } else {
        comparison = left.compareTo(right);
      }
      if (comparison != 0) return comparison;
    }
    return prerelease.length.compareTo(other.prerelease.length);
  }
}
