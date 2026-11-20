

import 'package:blue_core/src/model/blue_model.dart';
import 'src/platform_interface/blue_core.dart';

export 'src/upgrader/blue_upgrader.dart';

export 'src/notify/blue_notify.dart';
export 'src/connectivity/blue_connectivity.dart';

export 'src/toast/bloc/toast_bloc.dart';
export 'src/toast/blue_toast.dart';


export 'src/list/blue_list.dart';
export 'src/dialog/blue_dialog.dart';

export 'src/model/blue_model.dart';

export 'src/repository/repository.dart';

export 'src/request/blue_request.dart';

export 'src/upload/upload_bloc.dart';
export 'src/list/bloc/list_bloc.dart';

export 'src/form/form_bool.dart';
export 'src/form/form_bool_check.dart';
export 'src/form/form_dropdown_repo.dart';
export 'src/form/form_dropdown.dart';
export 'src/form/form_file.dart';
export 'src/form/form_list.dart';
export 'src/form/form_list_repo.dart';
export 'src/form/form_number.dart';
export 'src/form/form_text.dart';
export 'src/form/form_select.dart';
export 'src/form/form_json.dart';
export 'src/form/form_static.dart';
export 'src/form/form_username.dart';

export 'src/json_editor/blue_json_editor.dart';

export 'src/chart/blue_chart.dart';
export 'package:community_material_icon/community_material_icon.dart';
export 'package:form_builder_validators/form_builder_validators.dart';
export 'package:flutter_form_builder/flutter_form_builder.dart';
export 'package:form_builder_file_picker/form_builder_file_picker.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:equatable/equatable.dart';
export 'package:dio/dio.dart';
export 'package:file_picker/file_picker.dart';
export 'package:json_annotation/json_annotation.dart';
export 'package:url_launcher/url_launcher.dart';


class BlueCore {

  static Future<List<String>> getConnectionStaus() =>
      BlueCoreImpl.getConnectionStaus();

  static Stream<List<String>> onConnectionStatus() =>
      BlueCoreImpl.onConnectionStatus();

  static DeviceInfo get deviceInfo => BlueCoreImpl.getCurrentDeviceInfo();
  static PackageInfo get packageInfo => BlueCoreImpl.getCurrentPackageInfo();

  static Future<void> init() async{
    await BlueCoreImpl.init();
  }
}
