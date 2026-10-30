#!/usr/bin/env bash
# PE-02 isolated offline compiler regression; does not prove Android/iOS app builds.
set -euo pipefail
for tool in kotlinc java swiftc; do
  command -v "$tool" >/dev/null || { echo "NOT EXECUTED: missing $tool" >&2; exit 2; }
done
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="$(cd "$HERE/../.." && pwd)"
TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT
kotlinc "$BASE/Android/app/src/main/java/ai/dubai/research/OfflineMission.kt" \
 "$BASE/Android/app/src/main/java/ai/dubai/research/missions/IthbatCancellationMission.kt" \
 "$HERE/main.kt" -include-runtime -d "$TEMP/pe02.jar"
java -jar "$TEMP/pe02.jar"
swiftc "$BASE/iOS/Shared/OfflineMission.swift" \
 "$BASE/iOS/Shared/Missions/IthbatCancellationMission.swift" \
 "$HERE/main.swift" -o "$TEMP/pe02"
"$TEMP/pe02"
