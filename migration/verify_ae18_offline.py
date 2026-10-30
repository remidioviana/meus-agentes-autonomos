#!/usr/bin/env python3
"""Reproduce AE-18 isolated Kotlin/JVM + Swift/Linux fictional cue tests.

This is NOT Android/iOS compilation, device evidence, legal advice, AI inference,
or a release approval. No network, CI or user data are required.
"""
from __future__ import annotations

import hashlib
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
EXPECTED_BLOBS = {
    "Portfolio_50_Preserved/Android_50_App_Variants/app/src/main/java/ai/dubai/agents/LafzRightsExplainer.kt": "f7aac7dd56b1a47073c1e9ec292cb9e5a77473e0",
    "Portfolio_50_Preserved/iOS_50_Native_Targets/Shared/LafzRightsExplainer.swift": "8a1704ba942fc02f42d0af54fd6e968b7d0625c6",
    "Stage151_ElevenNativeCandidates/tests/ae18/main.kt": "3fffa7f3d7f42b978e247e94968c18586fec396c",
    "Stage151_ElevenNativeCandidates/tests/ae18/main.swift": "eb4f29a24e6aa6019d273e7dc52ebbf0289b3985",
}
KOTLIN = tuple(ROOT / name for name in EXPECTED_BLOBS if name.endswith(".kt"))
SWIFT = tuple(ROOT / name for name in EXPECTED_BLOBS if name.endswith(".swift"))


def git_blob(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode("ascii") + b"\0" + data).hexdigest()


def verify_sources(root: Path = ROOT) -> None:
    for relative, expected in EXPECTED_BLOBS.items():
        path = root / relative
        if path.is_symlink():
            raise ValueError(f"AE-18 symlink not accepted: {relative}")
        if git_blob(path.read_bytes()) != expected:
            raise ValueError(f"AE-18 source changed: {relative}")


def checked(args: list[str], cwd: Path, timeout: int = 120) -> str:
    result = subprocess.run(args, cwd=cwd, capture_output=True, text=True,
                            timeout=timeout, check=False)
    if result.returncode:
        raise RuntimeError(f"AE-18 command failed ({result.returncode}): {args[0]}\n"
                           f"{result.stdout}\n{result.stderr}")
    return result.stdout


def run(root: Path = ROOT) -> None:
    verify_sources(root)
    for tool in ("kotlinc", "java", "swiftc"):
        if shutil.which(tool) is None:
            raise RuntimeError(f"NOT EXECUTED: missing {tool}")
    kotlin = [str(root / p) for p in EXPECTED_BLOBS if p.endswith(".kt")]
    swift = [str(root / p) for p in EXPECTED_BLOBS if p.endswith(".swift")]
    with tempfile.TemporaryDirectory(prefix="ae18-offline-") as temp:
        jar = str(Path(temp) / "ae18.jar")
        exe = str(Path(temp) / "ae18-swift")
        checked(["kotlinc", *kotlin, "-include-runtime", "-d", jar], root)
        kotlin_out = checked(["java", "-jar", jar], root)
        checked(["swiftc", "-parse-as-library", *swift, "-o", exe], root)
        swift_out = checked([exe], root)
    for output, expected in ((kotlin_out, "AE-18 Kotlin: 20/20 assertions PASS"),
                             (swift_out, "AE-18 Swift: 20/20 assertions PASS")):
        if output.strip() != expected:
            raise RuntimeError(f"AE-18 unexpected test summary: {output!r}")
    print(kotlin_out.strip())
    print(swift_out.strip())
    print("PASS: 4 exact public-branch Git blobs; isolated Linux compilers only; NO_GO")


if __name__ == "__main__":
    try:
        run()
    except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        sys.exit(1)
