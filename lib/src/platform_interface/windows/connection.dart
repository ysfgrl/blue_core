import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import '../util/connection_status.dart';

// Top-level initialization is lazy, so the DLL is opened only on Windows.
final _networkLibrary = DynamicLibrary.open('iphlpapi.dll');

// Prefix of IP_ADAPTER_ADDRESSES through OperStatus. The first native union
// occupies eight bytes on both Windows x86 and x64.
final class _AdapterAddresses extends Struct {
  @Uint64()
  external int alignment;
  external Pointer<_AdapterAddresses> next;
  external Pointer<Utf8> adapterName;
  external Pointer<Void> unicast;
  external Pointer<Void> anycast;
  external Pointer<Void> multicast;
  external Pointer<Void> dnsServer;
  external Pointer<Utf16> dnsSuffix;
  external Pointer<Utf16> description;
  external Pointer<Utf16> friendlyName;
  @Array(8)
  external Array<Uint8> physicalAddress;
  @Uint32()
  external int physicalAddressLength;
  @Uint32()
  external int flags;
  @Uint32()
  external int mtu;
  @Uint32()
  external int ifType;
  @Int32()
  external int operStatus;
}

Future<List<String>> readWindowsConnectionStatus() async {
  if (!Platform.isWindows) {
    throw UnsupportedError('Windows connection status requires Windows');
  }
  final read = _networkLibrary.lookupFunction<
      Uint32 Function(Uint32, Uint32, Pointer<Void>, Pointer<_AdapterAddresses>,
          Pointer<Uint32>),
      int Function(int, int, Pointer<Void>, Pointer<_AdapterAddresses>,
          Pointer<Uint32>)>('GetAdaptersAddresses');
  final size = calloc<Uint32>()..value = 15 * 1024;
  Pointer<Uint8>? buffer;
  try {
    for (var attempt = 0; attempt < 3; attempt++) {
      final data = calloc<Uint8>(size.value);
      buffer = data;
      // AF_UNSPEC; skip anycast, multicast and DNS, retain unicast addresses.
      final result = read(0, 14, nullptr, data.cast(), size);
      if (result == 111) {
        calloc.free(data);
        buffer = null;
        continue;
      }
      if (result == 232) return ['none'];
      if (result != 0) throw StateError('GetAdaptersAddresses failed: $result');
      final types = <String>[];
      var adapter = data.cast<_AdapterAddresses>();
      while (adapter != nullptr) {
        final value = adapter.ref;
        if (value.operStatus == 1 &&
            value.unicast != nullptr &&
            value.ifType != 24) {
          types.add(switch (value.ifType) {
            6 || 144 => 'ethernet',
            71 => 'wifi',
            23 || 131 => 'vpn',
            243 || 244 => 'mobile',
            _ => 'other',
          });
        }
        adapter = value.next;
      }
      return normalizeConnectionStatus(types);
    }
    throw StateError('Network adapters changed repeatedly while reading.');
  } finally {
    if (buffer != null) calloc.free(buffer);
    calloc.free(size);
  }
}
