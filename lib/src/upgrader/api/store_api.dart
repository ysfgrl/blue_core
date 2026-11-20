part of '../blue_upgrader.dart';




mixin StoreApi {

  Future<PackageInfo?> get(String packageId, {String country = 'US', String locale = 'en'}){
    throw UnimplementedError("StoreApi.get");
  }
  static StoreApi? get api{
    switch(defaultTargetPlatform){
      case TargetPlatform.android:
        return PlayStoreApi();
      case TargetPlatform.fuchsia:
      // TODO: Handle this case.
        throw UnimplementedError();
      case TargetPlatform.iOS:
        return AppStoreApi();
      case TargetPlatform.linux:
      // TODO: Handle this case.
        throw UnimplementedError();
      case TargetPlatform.macOS:
        return AppStoreApi();
      case TargetPlatform.windows:
      // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
