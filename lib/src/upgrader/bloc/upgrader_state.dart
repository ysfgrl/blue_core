part of '../blue_upgrader.dart';

enum UpgradeStatus {
  init,
  newVersion,
  later,
  checking,
  upToDate,
  unsupported,
  failure,
}

class UpgraderState extends Equatable {
  final UpgradeStatus status;
  final PackageInfo current;
  final DeviceInfo device;
  final PackageInfo available;
  final String? error;
  const UpgraderState({
    this.status = UpgradeStatus.init,
    required this.current,
    required this.device,
    required this.available,
    this.error,
  });

  UpgraderState copyWith({
    UpgradeStatus? status,
    PackageInfo? available,
    String? error,
  }) {
    return UpgraderState(
      status: status ?? this.status,
      current: current,
      device: device,
      available: available ?? this.available,
      error: error ,
    );
  }

  @override
  List<Object?> get props => [status, available, error];
}
