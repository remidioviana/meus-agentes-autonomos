#!/usr/bin/env python3
"""W1 provenance check. Does NOT compile sources or approve native apps."""
from pathlib import Path
from collections import Counter
import csv
import hashlib

ROOT = Path(__file__).resolve().parent.parent
RECORDS = ROOT / "migration/waves/W1_source_provenance.csv"

def verify():
    with RECORDS.open(newline="", encoding="utf-8") as stream:
        rows = list(csv.DictReader(stream))
    if len(rows) != 21:
        raise ValueError(f"Expected 21 exact historical files, found {len(rows)}")
    expected = {"ENGINE_KOTLIN": 4, "ENGINE_SWIFT": 4,
                "CONTRACT_KOTLIN": 2, "CONTRACT_SWIFT": 2,
                "TEST_KOTLIN": 3, "TEST_SWIFT": 3, "TEST_RUNNER": 3}
    if Counter(row["artifact_kind"] for row in rows) != expected:
        raise ValueError("Portfolio source/test composition mismatch")
    for mission in ("AE-18", "PE-02", "BU-03", "GV-03"):
        kinds = {row["artifact_kind"] for row in rows if row["mission_id"] == mission}
        if not {"ENGINE_KOTLIN", "ENGINE_SWIFT"}.issubset(kinds):
            raise ValueError("Missing cross-platform engine for " + mission)
    visited = set()
    for row in rows:
        path = Path(row["destination_path"])
        if path.is_absolute() or ".." in path.parts or path in visited:
            raise ValueError("Unsafe/duplicate manifest path " + str(path))
        visited.add(path)
        if (row["origin_repository"] != "remidioviana/dubai50-mobile-ai-agents" or
            row["origin_ref"] != "stage176/dubai200-evidence-gated-delivery-register" or
            row["verification_scope"] != "BYTE_EXACT_SOURCE_NOT_RETESTED"):
            raise ValueError("Source lineage or evidence scope changed")
        data = (ROOT / path).read_bytes()
        gitsha = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
        if gitsha != row["origin_git_blob"]:
            raise ValueError("Git blob mismatch: " + str(path))
    # The readiness register and W1 source-provenance manifest must agree.
    with (ROOT / "migration/readiness_200.csv").open(newline="", encoding="utf-8") as fh:
        readiness = list(csv.DictReader(fh))
    if len(readiness) != 200:
        raise ValueError("Readiness register cardinality drift")
    migrated = {r["id"] for r in readiness if r["domain_engine_source_status"] != "NOT_MIGRATED"}
    if migrated != {"AE-18", "PE-02", "BU-03", "GV-03"}:
        raise ValueError("Readiness flags do not match W1 proof")
    for row in readiness:
        if row["release_verdict"] != "NO_GO":
            raise ValueError("Unapproved W1 source promotion")
        if row["id"] in migrated and row["individual_logic_test"] != "HISTORICAL_ISOLATED_EVIDENCE_NOT_RERUN":
            raise ValueError("No native/check-out tests were rerun")
    for filename in ("main.kt", "main.swift", "run_offline.sh"):
        if not (ROOT / "Stage171_IndividualNativeAgents/tests/bu03" / filename).is_file():
            raise ValueError("Missing newly authored BU-03 test file: " + filename)
    print("PASS W1: 21 SHA-exact original source/test artifacts + 3 BU-03 test files; no native-build claim")
    return True

if __name__ == "__main__":
    verify()
