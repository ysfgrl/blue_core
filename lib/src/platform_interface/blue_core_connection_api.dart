import 'blue_core_messages.g.dart' as pigeon;
import 'util/connection_status.dart';

export 'blue_core_messages.g.dart' show BlueCoreApi;

final Map<String, Stream<List<String>>> _streams = {};

/// Adds the generated event stream alongside the generated connection query.
extension BlueCoreApiConnectionEvents on pigeon.BlueCoreApi {
  Stream<List<String>> onConnectionStatus() {
    final suffix = pigeonVar_messageChannelSuffix;
    return _streams.putIfAbsent(suffix, () => pigeon
            .onConnectionStatus(
              instanceName: suffix.isEmpty ? '' : suffix.substring(1),
            )
            .map((event) => normalizeConnectionStatus(event.cast<String?>()))
            .distinct(sameConnectionStatus));
  }
}
