
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'toast_event.dart';
part 'toast_state.dart';
part 'toast_model.dart';


class ToastBloc extends Bloc<ToastEvent, ToastState> {
  ToastBloc(): super(const ToastState(msg: {})) {
    on<ToastRemoveEvent>(_removeMsg);
    on<ToastAddEvent>(_addMsg);
  }

  void _removeMsg(ToastRemoveEvent event, Emitter<ToastState> emitter) async {
    if(state.msg.containsKey(event.key)){
      emitter(ToastState(
          msg: Map<String, ToastModel>.fromEntries(
              state.msg.entries.where((value) => value.key != event.key,)
          ),
      ));
    }
  }
  void _addMsg(ToastAddEvent event, Emitter<ToastState> emitter) async {
    emitter(ToastState(
        msg:  {...state.msg, ...{event.msg.id: event.msg}},
    ));
  }
}


