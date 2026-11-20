import 'dart:async';

import 'package:flutter/material.dart';

import '../platform_interface/blue_core_platform.dart';

typedef BlueNetBuilder = Widget Function(List<String> connections);

/// Rebuilds its child with the initial connection state and subsequent updates.
class BlueConnectivity extends StatefulWidget {
  final BlueNetBuilder builder;
  const BlueConnectivity({super.key, required this.builder});

  @override
  State<BlueConnectivity> createState() => _BlueConnectivityState();
}

class _BlueConnectivityState extends State<BlueConnectivity>
    with WidgetsBindingObserver {
  StreamSubscription<List<String>>? _subscription;
  List<String> _connections = const ['none'];
  int _revision = 0;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = BlueCorePlatform.instance.onConnectionStatus().listen(
      _updateConnectionStatus,
      onError: (Object error, StackTrace stack) {
        debugPrint('Connection monitor failed: $error');
      },
    );
    unawaited(_readCurrentStatus());
  }

  Future<void> _readCurrentStatus() async {
    final revision = _revision;
    final request = ++_request;
    try {
      final connections = await BlueCorePlatform.instance.getConnectionStaus();
      // A delayed query must not overwrite a newer stream update.
      if (mounted && revision == _revision && request == _request) {
        _updateConnectionStatus(connections);
      }
    } catch (error) {
      if (mounted) debugPrint('Connection query failed: $error');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_readCurrentStatus());
  }

  void _updateConnectionStatus(List<String> connections) {
    if (!mounted) return;
    _revision++;
    setState(() => _connections = List<String>.unmodifiable(connections));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final subscription = _subscription;
    if (subscription != null) unawaited(subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_connections);
}
