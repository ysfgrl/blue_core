part of 'blue_model.dart';
class PackageInfo extends BaseModel{
  late String appName;
  late String packageName;
  late String version;
  late String buildNumber;
  late String? description;
  late String? releaseNotes;
  late String? storeUrl;

  PackageInfo();

  factory PackageInfo.init(){
      return PackageInfo()
      ..appName = "Undefined"
      ..packageName = "Undefined"
      ..version = "Undefined"
      ..buildNumber = "Undefined"
      ..description = "Undefined"
      ..releaseNotes = "Undefined"
      ..storeUrl = "Undefined";
}

  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    return PackageInfo()
      ..appName = json['appName'] as String
      ..packageName = json['packageName'] as String
      ..version = json['version'] as String
      ..buildNumber = json['buildNumber'] as String
      ..description = json['description'] as String?
      ..releaseNotes = json['releaseNotes'] as String?
      ..storeUrl = json['storeUrl'] as String?;
  }
  @override
  Map<String, dynamic> toJson() => {
    'appName': appName,
    'packageName': packageName,
    'version': version,
    'buildNumber': buildNumber,
    'description': description,
    'releaseNotes': releaseNotes,
    'storeUrl': storeUrl
  };
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PackageInfo && other.version == version;
  }

  @override
  int get hashCode => version.hashCode;

}