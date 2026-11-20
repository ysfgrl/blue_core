
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as html_dom;
import 'package:html/parser.dart' as html_parser;
import '../model/blue_model.dart';
import '../platform_interface/blue_core.dart';

part 'api/store_api.dart';
part 'api/app_store.dart';
part 'api/play_store.dart';

part 'bloc/upgrader_bloc.dart';
part 'bloc/upgrader_event.dart';
part 'bloc/upgrader_state.dart';
part 'alert.dart';

class BlueUpgrader extends StatefulWidget {
  final Widget child;
  const BlueUpgrader({super.key, required this.child});

  @override
  State<BlueUpgrader> createState() => _BlueUpgraderState();
}

class _BlueUpgraderState extends State<BlueUpgrader> {
  DialogRoute<void>? _dialogRoute;

  void _onState(BuildContext context, UpgraderState state) {
    if (state.status != UpgradeStatus.newVersion) {
      final route = _dialogRoute;
      _dialogRoute = null;
      if (route != null && route.isActive) {
        if (route.isCurrent) {
          route.navigator?.pop();
        } else {
          route.navigator?.removeRoute(route);
        }
      }
      return;
    }
    if (_dialogRoute != null) return;

    final bloc = context.read<UpgraderBloc>();
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xB3000000),
      builder: (context) => BlocProvider.value(
        value: bloc,
        child: PopScope(
          canPop: false,
          child: BlocBuilder<UpgraderBloc, UpgraderState>(
            builder: (context, state) => BlueUpgraderAlert(state: state),
          ),
        ),
      ),
    );
    _dialogRoute = route;
    Navigator.of(context, rootNavigator: true).push(route).whenComplete(() {
      if (_dialogRoute == route) _dialogRoute = null;
    });
  }

  @override
  void dispose() {
    final route = _dialogRoute;
    _dialogRoute = null;
    if (route != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (route.isActive) route.navigator?.removeRoute(route);
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UpgraderBloc>(
      create: (context) => UpgraderBloc(
        current: BlueCoreImpl.getCurrentPackageInfo(),
        device: BlueCoreImpl.getCurrentDeviceInfo(),
      )..add(const UpgraderControlEvent()),
      child: BlocListener<UpgraderBloc, UpgraderState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: _onState,
        child: widget.child,
      ),
    );
  }
}
