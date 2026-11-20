import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'web/web_notification_service.dart';

part 'notification_event.dart';

part 'notification_state.dart';

part 'repository.dart';

final _random = Random.secure();

String _generateUuid() {
  const chars = '0123456789abcdef';
  String part(int length) => List.generate(
        length,
        (_) => chars[_random.nextInt(chars.length)],
      ).join();

  return '${part(8)}-${part(4)}-${part(4)}-${part(12)}';
}

class NotifyBloc extends Bloc<NotifyEvent, NotifyState> {
  static const String androidChannelId = 'fixture_reminders';
  static const String androidChannelName = 'Önemli Bildirimler';
  static const String androidChannelDescription = 'Maç ve uygulama bildirimleri';
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    androidChannelId,
    androidChannelName,
    description: androidChannelDescription,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotify;
  final NotifyTokenRepoGetter getRepo;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;

  NotifyBloc({
    required String webVapidKey,
    required this.getRepo,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _messaging = FirebaseMessaging.instance,
        _localNotify = localNotifications ?? FlutterLocalNotificationsPlugin(),
        super(NotifyState.initial(
          webVapidKey: webVapidKey.trim(),
        )) {
    on<NotifyInitLocalEvent>(_initLocal);
    on<NotifyInitAndroidEvent>(_initAndroid);
    on<NotifyPermissionEvent>(_requestPermission);
    on<NotifyInitForegroundEvent>(_configureForeground);
    on<NotifySetReady>(_setReady);
    on<NotifyCreateTokenEvent>(_crateToken);
    on<NotifyLoadInitMsgEvent>(_loadInitMessages);
    on<NotifyTokenSendEvent>(_sendToken);

    on<NotifySetTokenEvent>(_setToken);
    on<NotifyAddEvent>(_addMessage);
    on<NotifyDeleteEvent>(_deleteMessage);
    on<NotifySendSystemEvent>(_sendToSystem);

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        if (isClosed) {
          return;
        }
        debugPrint("NotificationTapSource.fcmForeground: ${message.data}");
        add(NotifyAddEvent(
          message: NotifyMessage(
            id: message.messageId ?? _generateUuid(),
            title: message.notification?.title ??
                message.data['title']?.toString() ??
                "New Message",
            body: message.notification?.body ??
                message.data['body']?.toString() ??
                "You Have Notification",
            route: message.data["route"] ?? "/",
            data: message.data,
            source: NotifySource.fcmForeground,
          ),
        ));
      },
      onError: _onStreamError,
    );

    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        if (isClosed) {
          return;
        }
        debugPrint("NotificationTapSource.fcmBackground: ${message.data}");
        add(NotifyAddEvent(
          message: NotifyMessage(
            id: message.messageId ?? _generateUuid(),
            title: message.notification?.title ??
                message.data['title']?.toString() ??
                "New Message",
            body: message.notification?.body ??
                message.data['body']?.toString() ??
                "You Have Notification",
            route: message.data["route"] ?? "/",
            data: message.data,
            source: NotifySource.fcmBackground,
          ),
        ));
      },
      onError: _onStreamError,
    );

    _tokenSubscription = _messaging.onTokenRefresh.listen(
      (String token) {
        if (!isClosed) {
          add(NotifySetTokenEvent(token));
        }
      },
      onError: _onStreamError,
    );
  }

  Future<void> _initLocal(
    NotifyInitLocalEvent event,
    NotifyEmit emitter,
  ) async {
    if (state.initStatus != NotifyStatus.init) {
      debugPrint("_initializeLocal: ${state.initStatus}");
      return;
    }
    try {
      if (kIsWeb) {
        debugPrint("NotificationInitStatus.localInitialized");
        emitter(state.copyWith(initStatus: NotifyStatus.localInitialized));
        return;
      }
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings(
        '@drawable/ic_notification',
      );
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotify.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _onLocalNotifyResponse,
        onDidReceiveBackgroundNotificationResponse:
            onBackgroundLocalNotificationResponse,
      );
      emitter(state.copyWith(initStatus: NotifyStatus.localInitialized));
    } catch (error, stackTrace) {
      debugPrint(
        'Error : $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );
      emitter(
          state.copyWith(initStatus: NotifyStatus.failure, error: "$error"));
    }
  }

  Future<void> _initAndroid(
    NotifyInitAndroidEvent event,
    NotifyEmit emitter,
  ) async {
    if (state.initStatus != NotifyStatus.localInitialized) {
      debugPrint("_createAndroidChannel: ${state.initStatus}");
      return;
    }
    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
        emitter(state.copyWith(initStatus: NotifyStatus.androidChannelCreated));
        return;
      }
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _localNotify.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) {
        throw StateError(
          'Android local notification plugin bulunamadı.',
        );
      }
      await androidPlugin.createNotificationChannel(
        _androidChannel,
      );
      emitter(state.copyWith(initStatus: NotifyStatus.androidChannelCreated));
    } catch (error, stackTrace) {
      debugPrint(
        'Error : $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );
      emitter(
          state.copyWith(initStatus: NotifyStatus.failure, error: "$error"));
    }
  }

  Future<void> _requestPermission(
    NotifyPermissionEvent event,
    NotifyEmit emitter,
  ) async {
    if (state.initStatus != NotifyStatus.androidChannelCreated) {
      debugPrint("_requestPermission: ${state.initStatus}");
      return;
    }
    try {
      final NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      debugPrint(
        'Notification authorization status: ${settings.authorizationStatus}',
      );
      emitter(state.copyWith(
          settings: settings,
          initStatus: NotifyStatus.requestPermissionFinished));
    } catch (error, stackTrace) {
      debugPrint(
        'Error : $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );
      emitter(
          state.copyWith(initStatus: NotifyStatus.failure, error: "$error"));
    }
  }

  Future<void> _configureForeground(
    NotifyInitForegroundEvent event,
    NotifyEmit emitter,
  ) async {
    if (state.initStatus != NotifyStatus.requestPermissionFinished) {
      debugPrint("_configureForeground: ${state.initStatus}");
      return;
    }
    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
        emitter(state.copyWith(
            initStatus: NotifyStatus.configureForegroundFinished));
        return;
      }
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      emitter(
          state.copyWith(initStatus: NotifyStatus.configureForegroundFinished));
    } catch (error, stackTrace) {
      debugPrint(
        'Error : $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );
      emitter(
          state.copyWith(initStatus: NotifyStatus.failure, error: "$error"));
    }
  }

  Future<void> _crateToken(
    NotifyCreateTokenEvent event,
    NotifyEmit emitter,
  ) async {
    if (state.initStatus != NotifyStatus.configureForegroundFinished) {
      debugPrint("_crateToken: ${state.initStatus}");
      return;
    }
    try {
      String? token;
      if (_canCreateToken(state.settings!)) {
        token = await _getFcmToken();
        if (token == null || token.isEmpty) {
          throw ("FCM token boş döndü.");
        }
      } else {
        throw ("Token Can Not Create");
      }
      emitter(state.copyWith(
        token: token,
        initStatus: NotifyStatus.tokenCreated,
        clearError: true,
      ));
    } catch (error, stackTrace) {
      debugPrint(
        'Error : $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );
      emitter(
          state.copyWith(initStatus: NotifyStatus.failure, error: "$error"));
    }
  }

  Future<void> _loadInitMessages(
    NotifyLoadInitMsgEvent event,
    NotifyEmit emitter,
  ) async {
    if (state.initStatus != NotifyStatus.tokenCreated) {
      debugPrint("_loadInitMessages: ${state.initStatus}");
      return;
    }
    try {
      Map<String, NotifyMessage> initMessages = {};
      final RemoteMessage? initialRemoteMessage =
          await _messaging.getInitialMessage();
      if (initialRemoteMessage != null) {
        var id = initialRemoteMessage.messageId ?? _generateUuid();
        debugPrint(
            "NotificationTapSource.fcmTerminated: ${initialRemoteMessage.data}");
        initMessages.putIfAbsent(
            id,
            () => NotifyMessage(
                  id: id,
                  title: initialRemoteMessage.notification?.title ??
                      initialRemoteMessage.data['title']?.toString() ??
                      "New Message",
                  body: initialRemoteMessage.notification?.body ??
                      initialRemoteMessage.data['body']?.toString() ??
                      "You Have Notification",
                  route: initialRemoteMessage.data["route"] ?? "/",
                  data: initialRemoteMessage.data,
                  source: NotifySource.fcmTerminated,
                ));
      }

      if (!kIsWeb) {
        final NotificationAppLaunchDetails? launchDetails =
            await _localNotify.getNotificationAppLaunchDetails();
        if (launchDetails?.didNotificationLaunchApp ?? false) {
          final String? payload = launchDetails?.notificationResponse?.payload;
          final Map<String, dynamic>? decoded = _decodePayload(payload);

          if (decoded != null) {
            debugPrint("NotificationTapSource.localTerminated: ${decoded}");
            var id = _generateUuid();
            initMessages.putIfAbsent(
                id,
                () => NotifyMessage(
                      id: id,
                      title: decoded['title']?.toString() ?? "New Message",
                      body: decoded['body']?.toString() ??
                          "You Have Notification",
                      route: decoded["route"] ?? "/",
                      data: decoded,
                      source: NotifySource.localTerminated,
                    ));
          }
        }
      }
      emitter(state.copyWith(
        messages: {...state.messages, ...initMessages},
        initStatus: NotifyStatus.loadedInitMessages,
        clearError: true,
      ));
    } catch (error, stackTrace) {
      debugPrint(
        'Error : $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );
      emitter(state.copyWith(
          initStatus: NotifyStatus.loadedInitMessages, error: "$error"));
    }
  }

  Future<void> _sendToken(
    NotifyTokenSendEvent event,
    NotifyEmit emitter,
  ) async {
    if (state.initStatus != NotifyStatus.loadedInitMessages) {
      debugPrint("_sendToken: ${state.initStatus}");
      return;
    }
    try {
      var err = await getRepo().save(
          token: state.token!,
          platform: defaultTargetPlatform.name,
          runTarget: kIsWeb ? "web" : "mobile");
      if (err.isNotEmpty) {
        throw (err);
      }
      emitter(state.copyWith(
        initStatus: NotifyStatus.tokenSaved,
        clearError: true,
      ));
    } catch (error, stackTrace) {
      debugPrint(
        'Error : $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );
      emitter(
          state.copyWith(initStatus: NotifyStatus.failure, error: "$error"));
    }
  }

  Future<void> _setReady(
    NotifySetReady event,
    NotifyEmit emitter,
  ) async {
    if (state.initStatus != NotifyStatus.tokenSaved) {
      debugPrint("_setReady: ${state.initStatus}");
      return;
    }

    try {
      emitter(state.copyWith(initStatus: NotifyStatus.ready));
    } catch (error, stackTrace) {
      debugPrint(
        'Error : $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );
      emitter(
          state.copyWith(initStatus: NotifyStatus.failure, error: "$error"));
    }
  }

  bool _canCreateToken(NotificationSettings settings) {
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> _getFcmToken() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      final String? apnsToken = await _waitForApnsToken();
      if (apnsToken == null || apnsToken.isEmpty) {
        throw StateError(
          'APNs token alınamadığı için FCM token istenemedi.',
        );
      }
    }

    if (kIsWeb && state.webVapidKey.isEmpty) {
      throw StateError(
        'Web VAPID public key boş.',
      );
    }

    final String? token = await _messaging.getToken(
      vapidKey: kIsWeb ? state.webVapidKey : null,
    );

    final String? normalizedToken = token?.trim();

    debugPrint(
      'FCM token: $normalizedToken',
    );

    if (normalizedToken == null || normalizedToken.isEmpty) {
      return null;
    }
    return normalizedToken;
  }

  //
  Future<void> _sendToSystem(
    NotifySendSystemEvent event,
    NotifyEmit emitter,
  ) async {
    if (state.initStatus != NotifyStatus.ready) {
      add(NotifyDeleteEvent(event.message.id));
      return;
    }
    if (kIsWeb) {
      try {
        final bool shown = await showWebNotification(
            title: event.message.title,
            body: event.message.body,
            data: {...event.message.data, "messageId": event.message.id});
      } catch (error, stackTrace) {
        debugPrint(
          'Web foreground notification error: $error',
        );
        debugPrintStack(
          stackTrace: stackTrace,
        );
      }
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
          androidChannelId,
          androidChannelName,
          channelDescription: androidChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/ic_notification',
        );

        const NotificationDetails notificationDetails = NotificationDetails(
          android: androidDetails,
        );

        await _localNotify.show(
          id: _sequence++,
          title: event.message.title,
          body: event.message.body,
          notificationDetails: notificationDetails,
          payload: jsonEncode(event.message.data),
        );
      } catch (error, stackTrace) {
        debugPrint(
          'Android foreground notification error: $error',
        );
        debugPrintStack(
          stackTrace: stackTrace,
        );
      }
    }
    return;
  }

  //
  void _setToken(
    NotifySetTokenEvent event,
    NotifyEmit emitter,
  ) {
    final String token = event.token.trim();
    if (token.isEmpty || token == state.token) {
      return;
    }
    debugPrint(
      'FCM token changed: $token',
    );
    emitter(state.copyWith(
      token: token,
      clearTokenError: true,
    ));
  }

  void _addMessage(
    NotifyAddEvent event,
    NotifyEmit emitter,
  ) {
    emitter(state.copyWith(
      messages: {
        ...state.messages,
        ...{event.message.id: event.message},
      },
    ));
  }

  void _deleteMessage(
    NotifyDeleteEvent event,
    NotifyEmit emitter,
  ) {
    if (state.messages.containsKey(event.messageId)) {
      emitter(state.copyWith(
        messages:
            Map<String, NotifyMessage>.fromEntries(state.messages.entries.where(
          (value) => value.key != event.messageId,
        )),
      ));
    }
  }

  int _sequence = 0;

  void _onLocalNotifyResponse(
    NotificationResponse response,
  ) {
    final Map<String, dynamic>? decoded = _decodePayload(response.payload);
    if (decoded == null || isClosed) {
      return;
    }
    debugPrint("NotificationTapSource.localResponse ${decoded}");
    add(NotifyAddEvent(
      message: NotifyMessage(
        id: _generateUuid(),
        title: decoded['title']?.toString() ?? "New Message",
        body: decoded['body']?.toString() ?? "You Have Notification",
        route: decoded["route"] ?? "/",
        data: decoded,
        source: NotifySource.localResponse,
      ),
    ));
  }

  Map<String, dynamic>? _decodePayload(
    String? payload,
  ) {
    if (payload == null || payload.trim().isEmpty) {
      return null;
    }
    try {
      final dynamic decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.unmodifiable(
          decoded,
        );
      }

      if (decoded is Map) {
        return Map<String, dynamic>.unmodifiable(
          decoded.map<String, dynamic>(
            (dynamic key, dynamic value) {
              return MapEntry<String, dynamic>(
                key.toString(),
                value,
              );
            },
          ),
        );
      }

      debugPrint(
        'Notification payload bir JSON object değil.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Notification payload decode error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }

    return null;
  }

  Future<String?> _waitForApnsToken() async {
    for (int attempt = 0; attempt < 10; attempt++) {
      final String? apnsToken = await _messaging.getAPNSToken();

      if (apnsToken != null && apnsToken.isNotEmpty) {
        debugPrint(
          'APNs token: $apnsToken',
        );

        return apnsToken;
      }

      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      );
    }

    debugPrint(
      'APNs token alınamadı.',
    );

    return null;
  }

  void _onStreamError(
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint(
      'Notification stream error: $error',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );
  }

  @override
  Future<void> close() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _tokenSubscription?.cancel();

    return super.close();
  }
}

/// flutter_local_notifications background callback'i
/// top-level fonksiyon olmak zorundadır.
@pragma('vm:entry-point')
void onBackgroundLocalNotificationResponse(NotificationResponse response,) {
  debugPrint(
    'Background local notification clicked.',
  );

  debugPrint(
    'Background local notification payload: '
    '${response.payload}',
  );

  /*
   * Bu callback ayrı isolate üzerinde çalışabilir.
   * Buradan Bloc, BuildContext veya Navigator kullanma.
   *
   * UI açmayan notification action kullanacaksan payload'u
   * SharedPreferences/Hive gibi bir alana yazabilirsin.
   */
}
