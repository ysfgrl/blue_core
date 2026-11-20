part of 'toast_bloc.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

class ToastUtil {
  static final Random _rnd = Random();
  static String newKey(){
    return String.fromCharCodes(Iterable.generate(
        8, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
}

enum ToastLevel{
  success,
  error,
  info
}
enum ToastPosition{
  topLeft,
  topCenter,
  topRight,
  center,
  bottomLeft,
  bottomCenter,
  bottomRight
}
class ToastModel{
  final String id;
  final String title;
  final String msg;
  final ToastLevel level;
  final Duration? timeout;
  final ToastPosition position;

  bool get haveTimeout => timeout!= null && timeout!.inMilliseconds > 0;
  ToastModel({
    required this.msg,
    this.title = "Info",
    this.level = ToastLevel.info,
    this.position = ToastPosition.bottomCenter,
    this.timeout
  }): id = ToastUtil.newKey();

  ToastModel.info(this.msg, {
    String? title,
    this.level = ToastLevel.info,
    this.position = ToastPosition.bottomCenter,
    this.timeout = const Duration(seconds: 2)
  }): title = title ?? "Info",
        id = ToastUtil.newKey();

  ToastModel.error(this.msg, {
    String? title,
    this.level = ToastLevel.error,
    this.position = ToastPosition.bottomCenter,
    this.timeout = const Duration(seconds: 2)
  }): title = title ?? "Error",
        id = ToastUtil.newKey();

  ToastModel.success(this.msg, {
    String? title,
    this.level = ToastLevel.success,
    this.position = ToastPosition.bottomCenter,
    this.timeout = const Duration(seconds: 2)
  }):   title = title ?? "Success",
        id = ToastUtil.newKey();
}

