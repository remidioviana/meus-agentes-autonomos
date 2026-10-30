#!/usr/bin/env python3
"""BU-03: reproduce isolated Kotlin/JVM and Swift/Foundation tests, fail closed.

Run from any directory: python migration/verify_bu03_offline.py
No network, CI, Android SDK, Xcode, device, customer data, or approvals involved.
"""
from __future__ import annotations
import hashlib
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
STAGE = "Stage171_IndividualNativeAgents/"
EXPECTED_BLOBS = {
    "Android/app/src/main/java/ai/dubai/research/OfflineMission.kt": "6b9edab954fa5ced31293dae7ccf1d4ef6673df5",
    "Android/app/src/main/java/ai/dubai/research/missions/QarainVisitsMission.kt": "685b1908b976d420ac65a268269fb6d48f19d54c",
    "iOS/Shared/OfflineMission.swift": "20af93345639f60abe06420b9670c78162990a24",
    "iOS/Shared/Missions/QarainVisitsMission.swift": "d3f923e5a600521eb6a59f888ff99c855a8d8ad8",
    "tests/bu03/main.kt": "c7816c23e0254416371e260f5b50bf0551cc95d1",
    "tests/bu03/main.swift": "86be1b7b00a9806e8d2289e6443ad0fedb288e22",
    "tests/bu03/run_offline.sh": "697c6db286cbfad2c9c12532fc86c325421a6fde",
}

def git_blob(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode("ascii") + b"\0" + data).hexdigest()

def verify_sources(root: Path = ROOT) -> None:
    for relative, expected in EXPECTED_BLOBS.items():
        path = root / STAGE / relative
        actual = git_blob(path.read_bytes())
        if actual != expected:
            raise ValueError(f"BU-03 evidence invalid: source changed: {relative}: {actual}")

def run(root: Path = ROOT) -> None:
    verify_sources(root)
    for tool in ("bash", "kotlinc", "java", "swiftc"):
        if shutil.which(tool) is None:
            raise RuntimeError(f"NOT EXECUTED: {tool} unavailable")
    script = root / STAGE / "tests/bu03/run_offline.sh"
    result = subprocess.run(["bash", str(script)], cwd=root, capture_output=True,
                            text=True, timeout=180, check=False)
    if result.returncode != 0:
        raise RuntimeError(f"BU-03 compiler regression FAILED ({result.returncode}):\n{result.stdout}\n{result.stderr}")
    for expected in ("BU-03 Kotlin isolated fictional vectors: 11/11 PASS",
                     "BU-03 Swift isolated fictional vectors: 11/11 PASS"):
        if result.stdout.count(expected) != 1:
            raise RuntimeError(f"BU-03 test summary missing or duplicated: {expected}")
    print(result.stdout.strip())
    print("PASS: 7 exact Git blobs and two isolated compiler executions; NO native app/build approval")

if __name__ == "__main__":
    try:
        run()
    except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
