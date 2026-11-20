#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")/.."
flutter_bin="${FLUTTER_BIN:-/Volumes/macos/flutter/bin}"
"$flutter_bin/dart" run pigeon --input ' pigeon/messages.dart'
# Normalize whitespace emitted by the generator without changing its code.
python3 - <<'PY'
from pathlib import Path

for name in [
    'lib/src/platform_interface/blue_core_messages.g.dart',
    'android/src/main/kotlin/com/ysfgrl/blue_core/Messages.g.kt',
    'ios/blue_core/Sources/blue_core/Messages.g.swift',
]:
    path = Path(name)
    path.write_text('\n'.join(line.rstrip() for line in path.read_text().splitlines()).rstrip() + '\n')
PY
# Both Apple platforms use the same generated protocol and event channel.
cp ios/blue_core/Sources/blue_core/Messages.g.swift \
  macos/blue_core/Sources/blue_core/Messages.g.swift
