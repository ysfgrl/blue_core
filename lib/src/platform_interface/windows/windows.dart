import '../blue_core_messages.g.dart';

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

Future<PackageInfoMessage> readWindowsPackageInfo(
    {String? executablePath}) async {
  if (!Platform.isWindows) {
    throw UnsupportedError('Windows version resources require Windows');
  }
  final path = executablePath ?? Platform.resolvedExecutable;
  // Some Dart versions return a UNC path without its leading backslashes.
  final executable =
  path.startsWith(r'UNC\') ? path.replaceFirst(r'UNC\', r'\\') : path;
  return WindowsVersionReader().read(executable);
}

/// Uses the Windows version.dll API without a Flutter plugin or platform channel.
class WindowsVersionReader {
  WindowsVersionReader() : _library = DynamicLibrary.open('version.dll');

  final DynamicLibrary _library;

  PackageInfoMessage read(String executable) {
    final getSize = _library.lookupFunction<
        Uint32 Function(Pointer<Utf16>, Pointer<Uint32>),
        int Function(
            Pointer<Utf16>, Pointer<Uint32>)>('GetFileVersionInfoSizeW');
    final getInfo = _library.lookupFunction<
        Int32 Function(Pointer<Utf16>, Uint32, Uint32, Pointer<Void>),
        int Function(Pointer<Utf16>, int, int, Pointer<Void>)>(
      'GetFileVersionInfoW',
    );
    final queryValue = _library.lookupFunction<
        Int32 Function(Pointer<Void>, Pointer<Utf16>, Pointer<Pointer<Void>>,
            Pointer<Uint32>),
        int Function(Pointer<Void>, Pointer<Utf16>, Pointer<Pointer<Void>>,
            Pointer<Uint32>)>(
      'VerQueryValueW',
    );

    final filename = executable.toNativeUtf16();
    Pointer<Uint8>? buffer;
    try {
      final size = getSize(filename, nullptr);
      if (size == 0) {
        throw StateError('No Windows version resource found: $executable');
      }
      final data = calloc<Uint8>(size);
      buffer = data;
      if (getInfo(filename, 0, size, data.cast()) == 0) {
        throw StateError(
            'Unable to read Windows version resource: $executable');
      }

      (Pointer<Void>, int)? query(String name) {
        final block = name.toNativeUtf16();
        final value = calloc<Pointer<Void>>();
        final length = calloc<Uint32>();
        try {
          if (queryValue(data.cast(), block, value, length) == 0 ||
              value.value == nullptr ||
              length.value == 0) {
            return null;
          }
          return (value.value, length.value);
        } finally {
          calloc.free(block);
          calloc.free(value);
          calloc.free(length);
        }
      }

      final translations = <String>[];
      final translation = query(r'\VarFileInfo\Translation');
      if (translation != null) {
        final values = translation.$1.cast<Uint16>();
        for (var index = 0; index + 3 < translation.$2; index += 4) {
          final language = values[index ~/ 2].toRadixString(16).padLeft(4, '0');
          final codePage =
          values[index ~/ 2 + 1].toRadixString(16).padLeft(4, '0');
          translations.add('$language$codePage');
        }
      }
      // Flutter's standard Runner.rc uses English with code page 1252.
      if (!translations.contains('040904e4')) {
        translations.add('040904e4');
      }

      final fields = <String, String>{};
      for (final field in [
        'ProductName',
        'FileDescription',
        'InternalName',
        'ProductVersion',
        'FileVersion',
      ]) {
        for (final translation in translations) {
          final resource = query('\\StringFileInfo\\$translation\\$field');
          if (resource == null) {
            continue;
          }
          final pointer = resource.$1.cast<Uint16>();
          final count =
          pointer[resource.$2 - 1] == 0 ? resource.$2 - 1 : resource.$2;
          final text = pointer.cast<Utf16>().toDartString(length: count);
          if (text.isNotEmpty) {
            fields[field] = text;
            break;
          }
        }
      }

      String? fixedVersion;
      final fixed = query(r'\');
      if (fixed != null && fixed.$2 >= 52) {
        final numbers = fixed.$1.cast<Uint32>();
        if (numbers[0] == 0xfeef04bd) {
          // VS_FIXEDFILEINFO: dwProductVersionMS and dwProductVersionLS.
          final high = numbers[4];
          final low = numbers[5];
          fixedVersion = '${high >> 16}.${high & 0xffff}.'
              '${low >> 16}.${low & 0xffff}';
        }
      }
      final name = executable
          .split(RegExp(r'[\\/]'))
          .last
          .replaceFirst(RegExp(r'\.exe$', caseSensitive: false), '');
      return decodeWindowsPackageInfo(
        fields,
        executableName: name,
        fixedVersion: fixedVersion,
      );
    } finally {
      calloc.free(filename);
      if (buffer != null) {
        calloc.free(buffer);
      }
    }
  }
}



final class _OsVersionInfo extends Struct {
  @Uint32()
  external int size;
  @Uint32()
  external int major;
  @Uint32()
  external int minor;
  @Uint32()
  external int build;
  @Uint32()
  external int platform;
  @Array(128)
  external Array<Uint16> servicePack;
}

Future<DeviceInfoMessage> readWindowsDeviceInfo() async {
  if (!Platform.isWindows) {
    throw UnsupportedError('Windows device info requires Windows');
  }
  return DeviceInfoMessage(
    platform: 'windows',
    type: 'desktop',
    name: Platform.localHostname,
    model: _readModel(),
    version: _readOsVersion(),
  );
}

String _readOsVersion() {
  final getVersion = DynamicLibrary.open('ntdll.dll').lookupFunction<
      Int32 Function(Pointer<_OsVersionInfo>),
      int Function(Pointer<_OsVersionInfo>)>('RtlGetVersion');
  final info = calloc<_OsVersionInfo>();
  try {
    info.ref.size = sizeOf<_OsVersionInfo>();
    if (getVersion(info) != 0) {
      return Platform.operatingSystemVersion;
    }
    return '${info.ref.major}.${info.ref.minor}.${info.ref.build}';
  } finally {
    calloc.free(info);
  }
}

String _readModel() {
  final readValue = DynamicLibrary.open('advapi32.dll').lookupFunction<
      Int32 Function(IntPtr, Pointer<Utf16>, Pointer<Utf16>, Uint32,
          Pointer<Uint32>, Pointer<Void>, Pointer<Uint32>),
      int Function(int, Pointer<Utf16>, Pointer<Utf16>, int, Pointer<Uint32>,
          Pointer<Void>, Pointer<Uint32>)>('RegGetValueW');
  final key = r'HARDWARE\DESCRIPTION\System\BIOS'.toNativeUtf16();
  final value = 'SystemProductName'.toNativeUtf16();
  final size = calloc<Uint32>();
  Pointer<Uint8>? buffer;
  try {
    // HKEY_LOCAL_MACHINE (a sign-extended predefined handle), REG_SZ only.
    const machine = -2147483646;
    const stringValue = 0x00000002;
    if (readValue(machine, key, value, stringValue, nullptr, nullptr, size) !=
        0 ||
        size.value < 2) {
      return '';
    }
    final data = calloc<Uint8>(size.value);
    buffer = data;
    if (readValue(
        machine, key, value, stringValue, nullptr, data.cast(), size) !=
        0) {
      return '';
    }
    return data.cast<Utf16>().toDartString().trim();
  } finally {
    calloc.free(key);
    calloc.free(value);
    calloc.free(size);
    if (buffer != null) {
      calloc.free(buffer);
    }
  }
}

/// Converts Windows VERSIONINFO strings into application metadata.
PackageInfoMessage decodeWindowsPackageInfo(
    Map<String, String> fields, {
      required String executableName,
      String? fixedVersion,
    }) {
  String first(List<String?> candidates) =>
      candidates.firstWhere(
            (value) => value != null && value.isNotEmpty,
        orElse: () => '',
      ) ??
          '';

  final versionText = first([
    fields['ProductVersion'],
    fields['FileVersion'],
    fixedVersion,
  ]);
  if (versionText.isEmpty) {
    throw const FormatException(
        'Windows executable has no version information');
  }
  final parts = versionText.split('+');
  var version = parts.first;
  var buildNumber = parts.length > 1 ? parts.sublist(1).join('+') : '';
  // Windows numeric version resources use major.minor.patch.build.
  if (RegExp(r'^\d+\.\d+\.\d+\.\d+$').hasMatch(version)) {
    final numbers = version.split('.');
    version = numbers.take(3).join('.');
    if (buildNumber.isEmpty) {
      buildNumber = numbers.last;
    }
  } else if (buildNumber.isEmpty && fixedVersion != null) {
    buildNumber = fixedVersion.split('.').last;
  }

  return PackageInfoMessage(
    appName: first([
      fields['ProductName'],
      fields['FileDescription'],
      executableName,
    ]),
    packageName: first([fields['InternalName'], executableName]),
    version: version,
    buildNumber: buildNumber,
  );
}
