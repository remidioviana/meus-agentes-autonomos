#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
command -v kotlinc >/dev/null || { echo 'Kotlin compiler missing' >&2; exit 2; }
command -v java >/dev/null || { echo 'Java runtime missing' >&2; exit 2; }
command -v swiftc >/dev/null || { echo 'Swift compiler missing' >&2; exit 2; }
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
kotlinc "$ROOT/bu04/kotlin/RasdAssets.kt" "$ROOT/bu04/tests/main.kt" -include-runtime -d "$TMP/rasd.jar"
java -jar "$TMP/rasd.jar"
swiftc "$ROOT/bu04/swift/RasdAssets.swift" "$ROOT/bu04/tests/main.swift" -o "$TMP/rasd-swift"
"$TMP/rasd-swift"
