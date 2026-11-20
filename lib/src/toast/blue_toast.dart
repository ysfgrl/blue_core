
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/toast_bloc.dart';

typedef ToastBuilder = Widget Function(BuildContext context, ToastModel toast, double? progress, VoidCallback hide );


class BlueToast extends StatelessWidget{
  static ToastBloc? _bloc;
  static ToastBloc get instance => _bloc ??= ToastBloc();
  static void add(ToastModel msg){
    instance.add(ToastAddEvent(msg));
  }
  static ToastBloc of(BuildContext context){
    return context.read<ToastBloc>();
  }


  final Widget child;
  final ToastBuilder builder;
  final bool local;
  const BlueToast({super.key, required this.child,
    this.builder = defaultToastBuilder,
  }): local = false;
  const BlueToast.local({super.key,
    this.child = const SizedBox(),
    this.builder = defaultToastBuilder,
  }): local =true;
  @override
  Widget build(BuildContext context) {
    if(local){
      return BlocProvider(
        create: (context) => ToastBloc(),
        child: _builder(),
      );
    }
    return _builder();

  }
  Widget _builder(){
    return SafeArea(child: Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          child: Center(
            child: BlocBuilder<ToastBloc, ToastState>(
              builder: (context, state) {
                if(state.msg.isEmpty) {
                  return SizedBox();
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.msg.entries.where((element) => element.value.position == ToastPosition.center,).map((e) => _BlueMsgWidget(
                    e.value,
                    builder: builder,
                    remove: () {
                      context.read<ToastBloc>().add(ToastRemoveEvent(e.key));
                    }, key: Key(e.key),
                  )).toList(),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: Center(
            child: BlocBuilder<ToastBloc, ToastState>(
              builder: (context, state) {
                if(state.msg.isEmpty) {
                  return SizedBox();
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.msg.entries.where((element) => element.value.position == ToastPosition.topLeft,).map((e) => _BlueMsgWidget(
                    e.value,
                    builder: builder,
                    remove: () {
                      context.read<ToastBloc>().add(ToastRemoveEvent(e.key));
                    }, key: Key(e.key),
                  )).toList(),
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Center(
            child: BlocBuilder<ToastBloc, ToastState>(
              builder: (context, state) {
                if(state.msg.isEmpty) {
                  return SizedBox();
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.msg.entries.where((element) =>
                  element.value.position == ToastPosition.topRight,).map((e) => _BlueMsgWidget(
                    e.value,
                    builder: builder,
                    remove: () {
                      context.read<ToastBloc>().add(ToastRemoveEvent(e.key));
                    }, key: Key(e.key),
                  )).toList(),
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 0,
          left: 0,
          top: 0,
          child: Center(
            child: BlocBuilder<ToastBloc, ToastState>(
              builder: (context, state) {
                if(state.msg.isEmpty) {
                  return SizedBox();
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.msg.entries.where((element) =>
                  element.value.position == ToastPosition.topCenter,).map((e) => _BlueMsgWidget(
                    e.value,
                    builder: builder,
                    remove: () {
                      context.read<ToastBloc>().add(ToastRemoveEvent(e.key));
                    }, key: Key(e.key),
                  )).toList(),
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 0,
          left: 0,
          bottom: 0,
          child: Center(
            child: BlocBuilder<ToastBloc, ToastState>(
              builder: (context, state) {
                if(state.msg.isEmpty) {
                  return SizedBox();
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.msg.entries.where((element) =>
                  element.value.position == ToastPosition.bottomCenter,).map((e) => _BlueMsgWidget(
                    e.value,
                    builder: builder,
                    remove: () {
                      context.read<ToastBloc>().add(ToastRemoveEvent(e.key));
                    }, key: Key(e.key),
                  )).toList(),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Center(
            child: BlocBuilder<ToastBloc, ToastState>(
              builder: (context, state) {
                if(state.msg.isEmpty) {
                  return SizedBox();
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.msg.entries.where((element) =>
                  element.value.position == ToastPosition.bottomLeft,).map((e) => _BlueMsgWidget(
                    e.value,
                    builder: builder,
                    remove: () {
                      context.read<ToastBloc>().add(ToastRemoveEvent(e.key));
                    }, key: Key(e.key),
                  )).toList(),
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Center(
            child: BlocBuilder<ToastBloc, ToastState>(
              builder: (context, state) {
                if(state.msg.isEmpty) {
                  return SizedBox();
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.msg.entries.where((element) =>
                  element.value.position == ToastPosition.bottomRight,).map((e) => _BlueMsgWidget(
                    e.value,
                    builder: builder,
                    remove: () {
                      context.read<ToastBloc>().add(ToastRemoveEvent(e.key));
                    }, key: Key(e.key),
                  )).toList(),
                );
              },
            ),
          ),
        ),
      ],
    ));
  }
}

class _BlueMsgWidget extends StatefulWidget{
  final ToastModel msg;
  final VoidCallback remove;
  final ToastBuilder builder;
  const _BlueMsgWidget(this.msg, {
    super.key,
    required this.remove,
    required this.builder,
  });
  @override
  State<StatefulWidget> createState() => _BlueMsgWidgetState();
}

class _BlueMsgWidgetState extends State<_BlueMsgWidget> {
  Timer? timer;
  Duration timeout = Duration(seconds: 0);
  @override
  void initState() {
    super.initState();
    if(widget.msg.haveTimeout){
      timeout = widget.msg.timeout!;
      timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (timeout.inMilliseconds <= 0) {
          widget.remove();
          return;
        }
        setState(() {
          timeout = timeout - Duration(milliseconds: 100);
        });
      });
    }
  }
  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    final progress = widget.msg.haveTimeout? timeout.inMilliseconds/widget.msg.timeout!.inMilliseconds: null;
    return widget.builder(context, widget.msg, progress, widget.remove);
  }
}


class _ToastStyle {
  final Color color;
  final IconData icon;

  const _ToastStyle({
    required this.color,
    required this.icon,
  });

  factory _ToastStyle.fromLevel(ToastLevel level) {
    return switch (level) {
      ToastLevel.success => const _ToastStyle(
        color: Color(0xFF16A34A),
        icon: Icons.check_circle_rounded,
      ),
      ToastLevel.error => const _ToastStyle(
        color: Color(0xFFDC2626),
        icon: Icons.error_rounded,
      ),
      ToastLevel.info => const _ToastStyle(
        color: Color(0xFF2563EB),
        icon: Icons.info_rounded,
      ),
    };
  }
}

Widget defaultToastBuilder(BuildContext context,
    ToastModel toast,
    double? progress,
    VoidCallback hide,
    {bool compact =false}
    ){
  final _ToastStyle style = _ToastStyle.fromLevel(toast.level);
  return Container(
    constraints: const BoxConstraints(
      minHeight: 72,
      maxWidth: 300,
    ),
    margin:  EdgeInsets.symmetric(
      horizontal: compact ? 6: 12,
      vertical: compact ? 3: 5,
    ),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: style.color.withAlpha(80),
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: compact ? const EdgeInsets.fromLTRB(7, 6, 7, 6)
              :const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: compact ? 20:40,
                height: compact ? 20:40,
                decoration: BoxDecoration(
                  color: style.color.withAlpha(28),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  style.icon,
                  color: style.color,
                  size: compact ? 12: 22,
                ),
              ),
              SizedBox(width: compact ? 6:12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      toast.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: style.color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      toast.msg,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: const Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                visualDensity: VisualDensity.compact,
                onPressed: () => hide(),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        if (progress != null && progress > 0)
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 3,
            color: style.color,
            backgroundColor: style.color.withAlpha(25),
          ),
      ],
    ),
  );
}

