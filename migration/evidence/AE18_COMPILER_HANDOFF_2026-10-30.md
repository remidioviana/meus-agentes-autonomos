# AE-18 — isolated compiler evidence and handoff (2026-10-30)

**Release classification: NO_GO.** This note records **one Societal (AE-18) fictional, offline cue-detection engine**, not a functioning Android/iOS app or an AI inference system. Other AE/PE/BU/GV missions retain equal delivery priority. No private donor files were newly imported by this change; the four source/test files already existed on the public draft migration branch. Public disclosure/IP review of those earlier files remains **pending**.

## Actual independent local execution

The four exact source/test files were reconstructed from the public GitHub draft branch and verified with git hash-object before compilation:

| Public file | Git blob SHA |
| --- | --- |
| Portfolio_50_Preserved/Android_50_App_Variants/app/src/main/java/ai/dubai/agents/LafzRightsExplainer.kt | f7aac7dd56b1a47073c1e9ec292cb9e5a77473e0 |
| Portfolio_50_Preserved/iOS_50_Native_Targets/Shared/LafzRightsExplainer.swift | 8a1704ba942fc02f42d0af54fd6e968b7d0625c6 |
| Stage151_ElevenNativeCandidates/tests/ae18/main.kt | 3fffa7f3d7f42b978e247e94968c18586fec396c |
| Stage151_ElevenNativeCandidates/tests/ae18/main.swift | eb4f29a24e6aa6019d273e7dc52ebbf0289b3985 |

Toolchain: Python 3.13.5; Kotlin/JVM 1.9.0; OpenJDK 21.0.12; Swift 6.2.1 for x86_64-unknown-linux-gnu. All runs were offline, in an ephemeral cloud container, not on the user's computer. No GitHub Actions run was requested.

**Executed results:**
- Kotlin/JVM compilation and Java execution: AE-18 Kotlin: 20/20 assertions PASS.
- Swift/Linux compilation and execution: AE-18 Swift: 20/20 assertions PASS.
- Five new Python versioned unit tests executed: **5/5 PASS**. These reject missing, altered and symlinked source, and unavailable compiler, in addition to checking the exact source blobs.
- The two new public-authored Python files were independently read back from GitHub with exact blob hashes matching the locally executed files: verify_ae18_offline.py = 9d1433ecfa5349bdf105d82c5eda838f182af82b; test_verify_ae18_offline.py = 8406f1ab5d414228eb60d9961ca117215d4a5336.

## Reproduce from this draft PR checkout

No network is needed **after checkout**. Requires Python 3.10+, Bash-compatible shell, Kotlin compiler 1.9.0, JDK 21 and Swift compiler 6.2.1 on Linux. Toolchains must already be installed; download/setup costs and versions depend on environment.

~~~sh
python3 -m unittest discover -s migration/tests -p 'test_verify_ae18_offline.py' -v
python3 migration/verify_ae18_offline.py
~~~

The Python runner checks the four source Git blobs before running both compilers and validates their exact 20/20 summary strings. It uses a temporary build directory, 120-second timeout per subprocess and deletes generated binaries. A source change intentionally requires updating the expected hashes and rerunning all tests; no automatic promotion is allowed.

## Limitations and handoff

**Independently reproducible isolated compiler-test handoff: YES. Production-ready Android/iOS package: NO.** The engine handles fictional English notice wording only. It does not verify legal rights or deadlines, process real records, invoke AI models or services, store/submit user data, or provide an authorized real-world workflow. Kotlin/JVM is not an Android Gradle APK. Swift/Linux is not an iOS Xcode build. No device installation, security/privacy/accessibility review, outcome measurement, reviewer approval, authentic app footage, 50-page final deck or 60-second final video occurred.

To advance this mission, a future reviewer would need cleared publication rights, Android SDK/Gradle and emulator or real Android device, macOS/Xcode and an eligible iOS test device/signing arrangement, product UI integration, real workflow permissions, security/privacy/accessibility evidence and an independent review. Free Linux/JDK/Kotlin/Swift compilers suffice **only** for the isolated regression reproduced here. The canonical 200-row release registry and 600 final deliverable gates remain unchanged and **NO_GO**.
