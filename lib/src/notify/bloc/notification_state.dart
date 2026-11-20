part of 'notification_bloc.dart';

enum NotifyStatus {
  init,
  localInitialized,
  androidChannelCreated,
  requestPermissionFinished,
  configureForegroundFinished,
  tokenCreated,
  loadedInitMessages,
  tokenSaved,
  loading,
  ready,
  failure,
}


enum NotifySource {
  /// Uygulama background durumundayken FCM bildirimiyle açıldı.
  fcmBackground,
  fcmForeground,

  /// Uygulama tamamen kapalıyken FCM bildirimiyle açıldı.
  fcmTerminated,

  /// flutter_local_notifications callback'i üzerinden geldi.
  localResponse,

  /// Local notification uygulamayı kapalı durumdan açtı.
  localTerminated,
}

typedef NotifyEmit = Emitter<NotifyState>;

final class NotifyMessage extends Equatable {
  const NotifyMessage({
    required this.id,
    required this.title,
    required this.data,
    required this.body,
    required this.route,
    required this.source,
  });

  final String id;
  final String title;
  final String body;
  final String route;
  final Map<String, dynamic> data;
  final NotifySource source;
  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    body,
    route,
    data,
    source,
  ];
}

final class NotifyState extends Equatable {
  const NotifyState({
    required this.initStatus,
    required this.webVapidKey,
    this.settings,
    this.token,
    this.messages = const {},
    this.initError,
  });

  factory NotifyState.initial({
    required String webVapidKey,
  }) {
    return NotifyState(
      initStatus: NotifyStatus.init,
      webVapidKey: webVapidKey,
    );
  }

  final NotifyStatus initStatus;
  final String webVapidKey;
  final NotificationSettings? settings;
  final String? token;
  final Map<String,NotifyMessage> messages;

  /// Initialization sırasında oluşan kritik hata.
  final String? initError;

  bool get isReady => initStatus == NotifyStatus.ready;

  bool get permissionGranted {final AuthorizationStatus? authorizationStatus = settings?.authorizationStatus;
    return authorizationStatus == AuthorizationStatus.authorized ||
        authorizationStatus == AuthorizationStatus.provisional;
  }

  NotifyState copyWith({
    NotifyStatus? initStatus,
    NotificationSettings? settings,
    String? token,
    Map<String,NotifyMessage>? messages,
    String? error,
    bool clearError = false,
    bool clearTokenError = false,
  }) {
    return NotifyState(
      initStatus: initStatus ?? this.initStatus,
      webVapidKey: webVapidKey,
      settings: settings ?? this.settings,
      token: token ?? this.token,
      messages: messages ?? this.messages,
      initError: clearError ? null : error ?? this.initError,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    initStatus,
    webVapidKey,
    settings,
    token,
    messages,
    initError,
  ];
}