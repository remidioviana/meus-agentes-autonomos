#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
KOTLIN="$ROOT/Portfolio_50_Preserved/Android_50_App_Variants/app/src/main/java/ai/dubai/agents/LafzRightsExplainer.kt"
SWIFT="$ROOT/Portfolio_50_Preserved/iOS_50_Native_Targets/Shared/LafzRightsExplainer.swift"
FIXTURES="$ROOT/Stage151_ElevenNativeCandidates/tests/ae18"
command -v kotlinc >/dev/null
command -v swiftc >/dev/null
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
kotlinc "$KOTLIN" "$FIXTURES/main.kt" -include-runtime -d "$TMP/ae18.jar"
java -jar "$TMP/ae18.jar"
swiftc -parse-as-library "$SWIFT" "$FIXTURES/main.swift" -o "$TMP/ae18swift"
"$TMP/ae18swift"
