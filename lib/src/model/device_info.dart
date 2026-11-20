part of 'blue_model.dart';


class DeviceInfo extends BaseModel{
  late String platform;
  late String type;
  late String name;
  late String model;
  late String version;

  DeviceInfo();
  factory DeviceInfo.init(){
    return DeviceInfo()
      ..platform = defaultTargetPlatform.name
      ..type = "Undefined"
      ..name = "Undefined"
      ..model ="Undefined"
      ..version = "Undefined";
  }
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo()
      ..platform = json['platform'] as String
      ..type = json['type'] as String
      ..name = json['name'] as String
      ..model = json['model'] as String
      ..version = json['version'] as String;
  }
  @override
  Map<String, dynamic> toJson() => {
    'platform': platform,
    'type': type,
    'name': name,
    'model': model,
    'version': version,
  };
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceInfo && other.version == version;
  }

  @override
  int get hashCode => version.hashCode;

  bool get isAndroid{
    return TargetPlatform.android.name == platform;
  }

}