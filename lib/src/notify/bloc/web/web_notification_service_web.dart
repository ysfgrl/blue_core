import 'dart:convert';
import 'dart:js_interop';

@JS('showWebNotification')
external JSPromise<JSBoolean> _showWebNotification(
    JSString title,
    JSString body,
    JSAny? data,
    );

Future<bool> showWebNotification({
  required String title,
  required String body,
  Map<String, dynamic>? data,
}) async {
  final JSString? rawData = data == null
      ? null
      : jsonEncode(data).toJS;

  final JSBoolean result =
  await _showWebNotification(
    title.toJS,
    body.toJS,
    rawData,
  ).toDart;

  return result.toDart;
}