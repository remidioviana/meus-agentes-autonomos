#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
STAGE="$ROOT/Stage171_IndividualNativeAgents"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
for tool in kotlinc java swiftc; do command -v "$tool" >/dev/null || { echo "Missing $tool" >&2; exit 2; }; done
kotlinc "$STAGE/Android/app/src/main/java/ai/dubai/research/OfflineMission.kt" \
  "$STAGE/Android/app/src/main/java/ai/dubai/research/missions/QarainVisitsMission.kt" \
  "$STAGE/tests/bu03/main.kt" -include-runtime -d "$TMP/bu03.jar"
java -jar "$TMP/bu03.jar"
swiftc "$STAGE/iOS/Shared/OfflineMission.swift" \
  "$STAGE/iOS/Shared/Missions/QarainVisitsMission.swift" \
  "$STAGE/tests/bu03/main.swift" -o "$TMP/bu03-swift"
"$TMP/bu03-swift"
