

part of 'repository.dart';

mixin class KeyValueStore<VType> {
  const KeyValueStore();
  Future<VType?> get() {
    throw UnimplementedError();
  }
  Future<void> set(VType value) {
    throw UnimplementedError();
  }
  Future<void> del() {
    throw UnimplementedError();
  }
}
