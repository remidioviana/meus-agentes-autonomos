# BU-04 — RASD Assets | Public-authored offline prototype

**Stable identity:** BU-04 / Business / RASD Assets. The mission in the 200-row migration register is: **"Convert authorized readings to reviewable exception assignments"**. The measurable hypothesis is time from verified defect to owned action; the critical risk is **unsafe auto-triage**. This is an original, standalone implementation written for the public repository, not a copy of donor source.

## What it does (and does not)

Kotlin and Swift versions independently validate a batch of *synthetic* temperature (C) and vibration (mm/s) readings against explicitly supplied review rules. Inputs require a source-authorization **attestation** (not real authorization), a nonempty evidence identifier, a bounded timestamp, a valid unit, and a unique rule per asset/metric. Finite values and a 100-item batch limit are enforced. Readings beyond supplied thresholds generate deterministic, sorted findings with a **suggested human reviewer**. The output has four states: `INVALID_INPUT`, `BLOCKED`, `REVIEW_REQUIRED`, and `NO_EXCEPTION` (with language-specific enum spelling). No task is assigned, no equipment is controlled, and no safety decision is made. All-or-nothing output prevents partial findings after a blocked/invalid batch.

**Important:** The status `NO_EXCEPTION` means only that supplied readings did not exceed the supplied thresholds. It does not establish that an asset is safe. The code does not validate device identity, measurement calibration, threshold provenance, actual consent, operational authorizations, or physical hazards. It uses no network, files, credentials, or live data.

## Reproduce (free, offline)

Linux with Bash, Kotlin/JVM 1.9.0, JDK 21, Swift 6.2.1:

```bash
bash bu04/tests/run_offline.sh
```

Or individually:

```bash
kotlinc bu04/kotlin/RasdAssets.kt bu04/tests/main.kt -include-runtime -d /tmp/rasd.jar
java -jar /tmp/rasd.jar
swiftc bu04/swift/RasdAssets.swift bu04/tests/main.swift -o /tmp/rasd-swift
/tmp/rasd-swift
```

The script uses a temporary directory and cleans it on exit. It does not use CI, services, accounts, or billable runners.

## Actual evidence — 2026-10-30

- Kotlin/JVM 1.9.0, OpenJDK 21.0.12.1: **28/28 named behavior checks PASS**.
- Swift/Linux 6.2.1: **28/28 named behavior checks PASS**.
- Coverage includes boundaries, deterministic ordering, invalid units and values, duplicate evidence, missing rules, unauthorized source, stale/future timestamps, maximum batch, clock overflow, and suggested reviewer.
- This is an isolated **domain engine**, not a native Android APK or iOS app, not an AI model, not a user workflow or approved system.

## Handoff and release blockers

- **Ready:** source and offline compiler/test reproduction on a suitable Linux host. No cost or account required. Capacity benchmark **not measured**.
- **Not ready:** Android SDK/Gradle application and APK; Xcode/macOS app and IPA; UI and screen reader/RTL localization; secure device-source attestation; threshold governance and authorization; human approval/persistence; real sensor workflows; device installations; independent security/privacy/accessibility review; outcome measurement; final 50-page English 16:9 PDF; final 60-second English video with authentic mobile footage, captions, narration, and music rights.
- The editable deck and video **preproduction plan** is in `bu04/media/PREPRODUCTION.md`. It is **not** final media.
- No private source/assets, customer records, government material, secrets, or copyrighted music are used.
- **Release: NO_GO**. Do not merge or deploy until required evidence and independent reviewers exist.
