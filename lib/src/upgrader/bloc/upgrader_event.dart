part of '../blue_upgrader.dart';

abstract class UpgraderEvent extends Equatable {
  const UpgraderEvent();
  @override
  List<Object?> get props => [];
}

class UpgraderControlEvent extends UpgraderEvent {
  const UpgraderControlEvent();
  @override
  List<Object> get props => [];
}

class UpgraderLaterEvent extends UpgraderEvent {
  const UpgraderLaterEvent();
}
