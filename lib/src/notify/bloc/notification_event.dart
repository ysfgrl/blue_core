part of 'notification_bloc.dart';

sealed class NotifyEvent extends Equatable {
  const NotifyEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class NotifyInitLocalEvent extends NotifyEvent {
  const NotifyInitLocalEvent();
}
//CreateAndroidChannel
final class NotifyInitAndroidEvent extends NotifyEvent {
  const NotifyInitAndroidEvent();
}
// Request Permission
final class NotifyPermissionEvent extends NotifyEvent {
  const NotifyPermissionEvent();
}

//Configure Foreground
final class NotifyInitForegroundEvent extends NotifyEvent {
  const NotifyInitForegroundEvent();
}

final class NotifySetReady extends NotifyEvent {
  const NotifySetReady();
}

final class NotifyCreateTokenEvent extends NotifyEvent {
  const NotifyCreateTokenEvent();
}
final class NotifyLoadInitMsgEvent extends NotifyEvent {
  const NotifyLoadInitMsgEvent();
}

final class NotifyTokenSendEvent extends NotifyEvent {
  const NotifyTokenSendEvent();
}


/// İlk token veya yenilenmiş token.
final class NotifySetTokenEvent extends NotifyEvent {
  const NotifySetTokenEvent(this.token);

  final String token;

  @override
  List<Object?> get props => <Object?>[token];
}

final class NotifyAddEvent extends NotifyEvent {
  const NotifyAddEvent({
    required this.message,
  });
  final NotifyMessage message;
  @override
  List<Object?> get props => <Object?>[
    message,
  ];
}
final class NotifyDeleteEvent extends NotifyEvent {
  const NotifyDeleteEvent(this.messageId);
  final String messageId;
  @override
  List<Object?> get props => <Object?>[messageId];
}
//
final class NotifySendSystemEvent extends NotifyEvent {
  const NotifySendSystemEvent(this.message);
  final NotifyMessage message;
  @override
  List<Object?> get props => <Object?>[message];
}