# PE-04 — TAWAZUN Chores: original consent-gated offline domain slice

**Identity:** PE-04 / Personal / TAWAZUN Chores. Matches the 200-row register in draft PR #1: “Facilitate consensual recurring-task negotiation with editable assignments.” No legacy private code or assets were copied into this branch.

## Executable behavior (not a mobile app)

The Kotlin and Swift implementations deterministically draft task-to-participant proposals within declared per-person time capacities. Each listed participant must opt in; tasks must have explicit eligible people. The algorithm considers longer chores first, then assigns to the eligible person with the lowest current capacity utilization, breaking ties by stable ID. This is a **greedy heuristic**, not an optimization guarantee, equity certification, employment decision, or consent to any real-world assignment.

Invalid IDs, duplicated participants/chores, unknown/duplicated eligible people, out-of-bounds counts, missing opt-in, and invalid capacities/durations are rejected. If a task cannot fit, the engine returns REVIEW_REQUIRED **with no partial proposals**. All successful proposals are DRAFT_REQUIRES_CONFIRMATION; every response requires human review and reports no external action.

The ASCII-only IDs are technical identifiers, **not names**; real participant names and Arabic-language UI are not implemented. Inputs are fictional and remain in memory. No network, file write, persistence, account, government service, or automated task assignment exists.

## Reproduce on Linux (zero external services)

Requirements: Bash, JDK 21, Kotlin/JVM 1.9.0, Swift 6.2.1. Both languages compile standalone; no Gradle, Android SDK, macOS, Apple account or device is required for **these domain tests**.

```bash
set -euo pipefail
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
kotlinc pe04/kotlin/TawazunChores.kt pe04/tests/main.kt -include-runtime -d "$tmp/pe04.jar"
java -jar "$tmp/pe04.jar"
swiftc pe04/swift/TawazunChores.swift pe04/tests/main.swift -o "$tmp/pe04-swift"
"$tmp/pe04-swift"
```

## Evidence, 2026-10-30

- The exact **four Git blob SHAs** of the public branch matched the files compiled in the isolated local environment.
- Kotlin/JVM 1.9.0 + JDK 21: **16/16 behavior vectors PASS**.
- Swift 6.2.1 on Linux: **16/16 behavior vectors PASS**.
- Both tests check human-review-required and no-external-action invariants on every vector.
- This verifies a bounded *domain algorithm only*. No Android APK, iOS IPA, device installation, accessibility audit, security approval, external workflow, user outcome or independent review was produced.
- `main` is unchanged. Do not merge without privacy/IP review, app integration, installation evidence, human consent UX, qualified reviews and release gates.

## Production handoff

**Ready:** offline reproduction of domain tests with the commands above. **Not ready:** Android/iOS application build, user-facing deployment, pitch PDF or video render.

For a mobile app: integrate a clear opt-in/revocation and manual-confirmation UI; local persistence only after explicit privacy design; support Arabic display names separately from ASCII IDs; add accessibility and RTL tests; build and install Android with Android SDK/Gradle; build and install iOS using macOS/Xcode; collect redacted device evidence. The project cannot claim a working native app from these compilers alone.

Other 199 agents remain independently tracked and equally prioritized. Release status **NO_GO**.
