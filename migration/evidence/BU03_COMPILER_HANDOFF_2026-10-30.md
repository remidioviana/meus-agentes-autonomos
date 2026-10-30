# BU-03 QARAIN Visits — isolated dual-compiler evidence (2026-10-30)

**Verdict: OFFLINE DOMAIN-ENGINE TEST PASS ONLY; APP/RELEASE NO_GO.** This evidence concerns one Business agent's fictional-data decision logic, not an Android APK, iOS application, installed device, AI autonomy, live service, customer acceptance, or governmental endorsement. All 200 agents retain equal delivery priority.

## Reproduction (no CI, network or paid services)

On a checkout of draft PR #1, from the repository root:

```sh
python3 migration/verify_bu03_offline.py
python3 -m unittest discover -s migration/tests -p 'test_verify_bu03_offline.py' -v
```

The first command **fails closed** if any of the seven pinned Git blobs differ or if bash, kotlinc, java or swiftc is unavailable. It compiles the exact destination branch source/test files using Kotlin/JVM and Swift/Foundation and requires both independent 11/11 test summaries. It does not auto-start GitHub Actions.

## Executed local evidence

- Platform: Linux x86_64, Python 3.13.5, Kotlin/JVM compiler 1.9.0, OpenJDK 21.0.12, Swift 6.2.1.
- Seven inputs independently reconstructed from the PUBLIC draft PR #1 branch, with local Git blob SHA-1 **exactly matching** the GitHub blobs. Source hashes are pinned in `migration/verify_bu03_offline.py`.
- `bash Stage171_IndividualNativeAgents/tests/bu03/run_offline.sh`: Kotlin 11/11 PASS; Swift 11/11 PASS, both exit 0.
- `python migration/verify_bu03_offline.py`: PASS (seven hashes + both compilers).
- `python -m unittest discover -s migration/tests -p 'test_verify_bu03_offline.py' -v`: three tests PASS, including tampered and missing input rejection.
- The two new Python files were separately read back from GitHub and matched their local Git blob hashes.
- No hosted CI was launched. This is local execution against byte-identical source, **not** a full destination checkout, Android Gradle, macOS Xcode, or real-device test.

## User infrastructure handoff

The pinned verifier is immediately usable for **offline regression reproduction** on a machine with Python 3.10+, bash, JDK 21, Kotlin compiler 1.9, and Swift compiler 6.2.1; temporary build outputs are cleaned by the runner. A Linux machine is sufficient for this narrow compiler exercise; no accounts, SDK purchases or network access are required after obtaining the checkout. The command does **not** produce APK/IPA, installable app artifacts, screenshots, editable deck assets or a video. It is not a production-ready mobile/media handoff.

## Blocking conditions

- PUBLIC PR #1 already contains historical private-repository-derived files; no further donor files were copied in this checkpoint. Independent IP, privacy and disclosure approval is **not established**. Removing a file from a public branch cannot guarantee erasure of previously published Git history.
- `migration/readiness_200.csv` remains conservative: 0 qualified native app builds, 0 device installs, 0 final decks and 0 final videos. BU-03 isolated compiler results must not be promoted to full app delivery.
- The official Create AI Agents page requires original solutions not copied from existing repositories. Eligibility of donor-derived code is unresolved: https://www.dubaichambers.com/en/web/dubai-chamber-of-digital-economy/create-ai-agents
- Main's 15-minute scheduled synthetic simulator is unrelated to this evidence and may consume GitHub Actions quota. No workflow change or merge was made.
