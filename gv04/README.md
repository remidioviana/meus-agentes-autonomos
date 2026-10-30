# GV-04 — TAMAASUK Schemas: public-authored offline domain prototype

**Identity:** GV-04 / Governmental / TAMAASUK Schemas. Stable mission from the 200-row register in draft PR #1: compare a **synthetic** pair of government API schemas with versioned field mapping and consent boundaries. No private donor code, confidential material, government endpoints, official logos, data, or credentials were copied.

## What actually runs

Kotlin and Swift independently compare **schema metadata only**, not records or citizen data. Inputs declare departments, version numbers, field names/types/requiredness/classification, explicit field mappings, approved scope names and a synthetic consent flag. Outputs enumerate version mismatches, unknown fields, missing required targets, type mismatches, classification downgrades, requiredness mismatches and missing scope/consent. Invalid inputs fail closed. Even a clean comparison returns `REVIEW_REQUIRED`, **never approved**. All outputs have `humanReviewRequired=true` and `dataTransferred=false`.

This is a deterministic offline review aid. The consent flag is **not verified legal consent**; approvedScopes is **not** a real permission system. No network, persistence, government access, schema import, data transfer, LLM inference, automatic integration, deployment or real policy decision occurs. The classification model is deliberately simplified; expert security/privacy review is required before any production use.

## Reproduce exactly (Linux, no paid services)

Dependencies actually tested: Kotlin/JVM 1.9.0, OpenJDK 21.0.12, Swift 6.2.1, Bash. Python/Android SDK/Gradle/Xcode not required for these **isolated** tests.

```bash
set -euo pipefail
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
kotlinc gv04/kotlin/TamaasukSchemas.kt gv04/tests/main.kt -include-runtime -d "$tmp/gv04.jar"
java -jar "$tmp/gv04.jar"
swiftc -parse-as-library gv04/swift/TamaasukSchemas.swift gv04/tests/main.swift -o "$tmp/gv04swift"
"$tmp/gv04swift"
```

## Executed evidence — 2026-10-30

- **Kotlin:** 16 named behavior cases / 48 assertions PASS on Linux.
- **Swift:** same 16 cases / 48 assertions PASS on Linux. Initial Swift invocation without `-parse-as-library` failed at compilation; corrected command above passed.
- The **four Git blob hashes** of the committed public files were checked against the exact four locally executed files:
  - Kotlin engine: `d7b458a549713757ec695d00e500a11245d82109`
  - Swift engine: `6d5ad9604a624e37fbaaa420213f9d47858ab65a`
  - Kotlin tests: `f977d6a925d68486d96bdab106174630f5f1e301`
  - Swift tests: `69b5d0227e31a0d664092e593c8821629c1b2b6b`
- No GitHub Actions or device tests were triggered. There is no app build or release certification.

## Production handoff and missing gates

**Available now:** reproducible isolated Kotlin/Swift domain-code test package with editable source. A Linux machine with the toolchain above suffices; capacity for mass parallel compilation is not benchmarked. Open-source toolchains can be used without paid cloud runners.

**Not available:** Android APK/AAB, iOS app/IPA, simulator/device installation, native UI, authentic government schema data, lawful access approvals, real consent capture/revocation, RTL/accessibility, threat model, privacy/security approval, independently measured impact, final 50-page PDF, or final 60-second video. iOS native app work needs macOS/Xcode and Apple signing if distribution is required; Android needs SDK/Gradle and a device/emulator. Neither is assumed available.

The media file `gv04/media/PREPRODUCTION.md` is an editable storyboard and page-by-page editorial plan, **not** a finished PDF or video. No official government endorsement or award eligibility is claimed.

All 200 agents retain equal priority. The existing 200-row register is **not changed** by this branch, because isolated test results must not be promoted to Android/iOS build or approval status. **NO_GO**. Review IP/provenance and privacy before merge.
