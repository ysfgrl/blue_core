import 'dart:async';

List<String> normalizeConnectionStatus(Iterable<String?> values) {
  final active = values
      .whereType<String>()
      .where((value) => value.isNotEmpty && value != 'none')
      .toSet()
      .toList()
    ..sort();
  return active.isEmpty ? ['none'] : active;
}

bool sameConnectionStatus(List<String> a, List<String> b) => a.length == b.length && a.every(b.contains);

/// Desktop fallback: starts on first listener, stops on last cancellation.
Stream<List<String>> pollConnectionStatus(Future<List<String>> Function() read) {
  late StreamController<List<String>> controller;
  Timer? timer;
  var generation = 0;
  controller = StreamController<List<String>>.broadcast(
    onListen: () {
      final session = ++generation;
      var reading = false;
      List<String>? previous;
      Future<void> check() async {
        if (reading) return;
        reading = true;
        try {
          final status = normalizeConnectionStatus(await read());
          if (session != generation || !controller.hasListener) return;
          if (previous == null || !sameConnectionStatus(previous!, status)) {
            previous = status;
            controller.add(status);
          }
        } catch (error, stack) {
          if (session == generation && controller.hasListener) {
            controller.addError(error, stack);
          }
        } finally {
          reading = false;
        }
      }

      unawaited(check());
      timer =
          Timer.periodic(const Duration(seconds: 2), (_) => unawaited(check()));
    },
    onCancel: () {
      generation++;
      timer?.cancel();
      timer = null;
    },
  );
  return controller.stream;
}
