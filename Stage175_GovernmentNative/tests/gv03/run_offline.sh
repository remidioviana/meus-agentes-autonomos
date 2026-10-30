#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
STAGE="$ROOT/Stage175_GovernmentNative"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
command -v kotlinc >/dev/null || { echo 'kotlinc required' >&2; exit 2; }
command -v swiftc >/dev/null || { echo 'swiftc required' >&2; exit 2; }
kotlinc "$STAGE/Android/src/main/kotlin/ai/dubai/gov/ReviewContract.kt" \
 "$STAGE/Android/src/main/kotlin/ai/dubai/gov/missions/Gv03_TasneefRecordsReview.kt" \
 "$STAGE/tests/gv03/main.kt" -include-runtime -d "$TMP/gv03.jar"
java -jar "$TMP/gv03.jar"
swiftc "$STAGE/iOS/Sources/ReviewContract.swift" \
 "$STAGE/iOS/Sources/Missions/Gv03_TasneefRecordsReview.swift" \
 "$STAGE/tests/gv03/main.swift" -o "$TMP/gv03-swift"
"$TMP/gv03-swift"
echo 'GV-03: 22 Kotlin + 22 Swift test vectors and 2 fixtures each; no native app build or device proof.'
