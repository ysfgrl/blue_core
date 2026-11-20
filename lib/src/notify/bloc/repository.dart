
part of 'notification_bloc.dart';


mixin class NotifyTokenRepository{
  const NotifyTokenRepository();
  Future<String> save({
    required String token,
    required String platform,
    required String runTarget,
    Map<String, dynamic>? params
  }) {
    throw UnimplementedError();
  }
}

typedef NotifyTokenRepoGetter = NotifyTokenRepository Function();