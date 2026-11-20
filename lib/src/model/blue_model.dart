import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../util/unique/process_unique.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

import '../repository/repository.dart';
import '../upload/upload_bloc.dart';
part 'package_info.dart';
part 'device_info.dart';
part 'error.dart';
part 'factory.dart';
part 'filter.dart';
part 'list_request.dart';
part 'list_response.dart';
part 'object_id.dart';
part 'response.dart';
part 'errors.dart';
part 'bloc/model_bloc.dart';
part 'bloc/model_event.dart';
part 'bloc/model_state.dart';

String generateObjectId() {
  final rand = math.Random();
  final bytes = List<int>.generate(12, (_) => rand.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

abstract class BaseModel{
  BaseModel();
  BaseModel.fromJson(Map<String, dynamic> data);
  Map<String, dynamic> toJson(){
    throw UnimplementedError();
  }
  @override
  String toString() {
    return toJson().toString();
  }
  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

}