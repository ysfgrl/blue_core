

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/notification_bloc.dart';
export 'bloc/notification_bloc.dart';
typedef BlueNotifyOnMessage = Future<void> Function(NotifyMessage msg);
class BlueNotify extends StatelessWidget{

  static late final NotifyBloc _bloc;
  static NotifyBloc get instance => _bloc;
  static Future<void> init({
    required NotifyTokenRepoGetter getRepo,
    String webVapidKey = "",
    FirebaseOptions? web,
    FirebaseOptions? android,
    FirebaseOptions? ios,
  }) async{
    if(kIsWeb) {
      await Firebase.initializeApp(options: web,);
    }else if(defaultTargetPlatform == TargetPlatform.android){
      await Firebase.initializeApp(options: android,);
    }else if(defaultTargetPlatform == TargetPlatform.iOS){
      await Firebase.initializeApp(options: ios,);
    }else{
      throw UnsupportedError('DefaultFirebaseOptions are not supported',);
    }

    _bloc = NotifyBloc(
        webVapidKey: webVapidKey,
        getRepo: getRepo
    );

  }

  final Widget child;
  final BlueNotifyOnMessage onMessage;
  const BlueNotify({
    super.key,
    required this.onMessage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotifyBloc, NotifyState>(
      builder: (context, state) {
        if(state.initStatus == NotifyStatus.init){
          instance.add(const NotifyInitLocalEvent());
        }else if(state.initStatus == NotifyStatus.localInitialized){
          instance.add(const NotifyInitAndroidEvent());
        }else if(state.initStatus == NotifyStatus.androidChannelCreated){
          instance.add(const NotifyPermissionEvent());
        }else if(state.initStatus == NotifyStatus.requestPermissionFinished){
          instance.add(const NotifyInitForegroundEvent());
        }else if(state.initStatus == NotifyStatus.configureForegroundFinished){
          instance.add(const NotifyCreateTokenEvent());
        }else if(state.initStatus == NotifyStatus.tokenCreated){
          instance.add(const NotifyLoadInitMsgEvent());
        }else if(state.initStatus == NotifyStatus.loadedInitMessages){
          instance.add(const NotifyTokenSendEvent());
        }else if(state.initStatus == NotifyStatus.tokenSaved){
          instance.add(const NotifySetReady());
        }
        return child;
      },
      listener: (context, state) {
        //
        // if(state.initStatus == NotifyStatus.failure){
        //   context.read<ToastBloc>().add(ToastAddEvent(ToastModel.error(
        //       state.initError ??"Notification Init Error")
        //   ));
        //   return;
        // }

        if(state.messages.isNotEmpty){
          final newMessage = state.messages.values.first;
          unawaited(onMessage(newMessage));
          instance.add(NotifyDeleteEvent(newMessage.id));
        }
      },
    );
  }

}