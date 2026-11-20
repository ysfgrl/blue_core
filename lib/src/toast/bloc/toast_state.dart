
part of 'toast_bloc.dart';

class ToastState extends Equatable{
  final Map<String, ToastModel> msg;
  const ToastState({
    required this.msg,
  });
  @override
  List<Object> get props => [msg];
}
