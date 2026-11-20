part of '../blue_model.dart';

enum BlocDataState{
  init,
  loading,
  sending,
  loaded,
}


class ModelState<DType extends BaseModel> extends Equatable {
  final BlocDataState infoState;
  final DType info;
  final ResponseError? message;
  final bool refresh;
  final Map<String, dynamic>? params;
  final bool created;
  final bool edited;
  final String? lastErrorCode;
  final int? lastStatusCode;
  const ModelState({
    this.infoState = BlocDataState.init,
    required this.info,
    this.message,
    this.params,
    this.refresh = false,
    this.created = false,
    this.edited = false,
    this.lastStatusCode,
    this.lastErrorCode,

  });
  @override
  List<Object?> get props => [refresh,infoState, info, message];

  ModelState<DType> copyWidth({
    BlocDataState? infoState,
    DType? info,
    String? id,
    String? lastErrorCode,
    int? lastStatusCode,
    ResponseError? message,
    bool? readyShow,
    bool? refresh,
    bool? created,
    bool? edited,
  }){
    return ModelState<DType>(
      infoState: infoState ?? this.infoState,
      info: info ?? this.info,
      refresh: refresh ?? this.refresh,
      created: created ?? this.created,
      edited: edited ?? this.edited,
      message: message,
      lastStatusCode: lastStatusCode,
      lastErrorCode: lastErrorCode,
      params: params
    );
  }
}
