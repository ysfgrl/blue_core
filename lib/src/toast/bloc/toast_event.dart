
part of 'toast_bloc.dart';

abstract class ToastEvent extends Equatable{
  const ToastEvent();
  @override
  List<Object?> get props => [];
}

class ToastAddEvent extends ToastEvent{
  final ToastModel msg;
  const ToastAddEvent(this.msg);
  @override
  List<Object> get props => [msg];
}




class ToastRemoveEvent extends ToastEvent{
  final String key;
  const ToastRemoveEvent(this.key);
  @override
  List<Object> get props => [key];
}
