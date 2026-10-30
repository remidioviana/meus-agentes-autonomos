#!/usr/bin/env python3
"""Fail-closed integrity check for the PUBLIC Dubai200 migration registry.

No platform builds, agent executions, media or approval claims result from this.
Uses Python standard library only. Run from any working directory:
    python migration/check_200.py
"""
from __future__ import annotations
import csv
import hashlib
import json
from collections import Counter
from pathlib import Path

BASE = Path(__file__).resolve().parent
CATEGORIES = ("AE", "PE", "BU", "GV")
PORTFOLIOS = ("Societal", "Personal", "Business", "Governmental")
LEGACY_BLOB = "87660ee2ffb9647f236a3a52099d7ff7869a0440"
ORIGINAL_REPO = "remidioviana/dubai50-mobile-ai-agents"

def rows_from(path: Path):
    with path.open(newline="", encoding="utf-8") as inp:
        return list(csv.DictReader(inp))

def git_blob_sha(path: Path):
    payload = path.read_bytes()
    return hashlib.sha1(b"blob " + str(len(payload)).encode() + b"\0" + payload).hexdigest()

def validate(rows, legacy_rows, summary):
    if len(rows) != 200 or len(legacy_rows) != 200:
        raise ValueError("Exactly 200 records required in both files")
    ids = [row["id"] for row in rows]
    expected = [f"{prefix}-{index:02d}" for prefix in CATEGORIES for index in range(1, 51)]
    if ids != expected or [x["id"] for x in legacy_rows] != expected:
        raise ValueError("Stable AE/PE/BU/GV ID or ordering mismatch")
    if len(set(row["registered_name"] for row in rows)) != 200:
        raise ValueError("Duplicate registered display names")
    if Counter(row["portfolio"] for row in rows) != dict(zip(PORTFOLIOS, (50,)*4)):
        raise ValueError("Portfolio cardinality mismatch")
    for row, original in zip(rows, legacy_rows):
        for field in ("registered_name", "distinct_mission_hypothesis",
                      "proposed_outcome_not_measured", "critical_risk",
                      "android_source_file", "ios_source_file",
                      "societal_slug", "societal_android_flavor",
                      "societal_android_bundle"):
            if row[field] != original[field]:
                raise ValueError(f"{row['id']}: historic identity/mission/source changed: {field}")
        if row["source_origin_repository"] != ORIGINAL_REPO:
            raise ValueError("Unexpected source origin")
        if row["source_migration_state"] != "NOT_MIGRATED":
            raise ValueError("Unverified source migration promotion")
        if row["source_path_audit"] != "LEGACY_REPO_PATH_NOT_IN_DESTINATION":
            raise ValueError("Source path incorrectly reported as present")
        if row["release_verdict"] != "NO_GO":
            raise ValueError("Unapproved release promotion")
        for key in ("android_native_build", "ios_native_build", "android_device_install",
                    "ios_device_install", "deck_final_pdf", "video_final_render"):
            if row[key] != "NOT_VERIFIED":
                raise ValueError(f"{row['id']}: unverified delivery promoted: {key}")
        for key in ("security_review", "privacy_review", "accessibility_review",
                    "deck_claims_review", "video_claims_review"):
            if row[key] != "NOT_APPROVED":
                raise ValueError(f"{row['id']}: unapproved assessment promoted: {key}")
        if row["qualified_approval"] != "NOT_GRANTED":
            raise ValueError(f"{row['id']}: unsupported approval")
        if (row["deck_target_pages"], row["deck_target_aspect"],
                row["video_target_seconds"], row["deadline_dubai"]) != (
                "50", "16:9_LANDSCAPE", "60", "2026-12-20"):
            raise ValueError(f"{row['id']}: master production requirements changed")
        if row["individual_logic_test"] not in (
            "NOT_LINKED_TO_EXECUTED_EVIDENCE", "HISTORICAL_ISOLATED_EVIDENCE_NOT_RERUN"):
            raise ValueError(f"{row['id']}: unverified test evidence")
    if summary.get("total_agents") != 200 or summary.get("deliverable_target_total") != 600:
        raise ValueError("Summary totals incorrect")
    if summary.get("release_verdict") != "NO_GO":
        raise ValueError("Unsupported GO summary")
    if summary.get("deliverables_approved") != 0 or summary.get("qualified_approvals_verified") != 0:
        raise ValueError("Unverified approvals")
    for name in ("destination_native_android_sources_verified",
                 "destination_native_ios_sources_verified",
                 "destination_native_android_builds_verified",
                 "destination_native_ios_builds_verified",
                 "device_installations_verified", "real_agent_workflows_verified",
                 "final_decks_50page_verified", "final_videos_60sec_verified"):
        if summary.get(name) != 0:
            raise ValueError("Unsupported destination evidence: " + name)
    return True

def main():
    legacy = BASE / "legacy" / "Stage176_readiness_200.csv"
    if git_blob_sha(legacy) != LEGACY_BLOB:
        raise ValueError("Original GitHub blob altered or provenance incorrect")
    rows = rows_from(BASE / "readiness_200.csv")
    original = rows_from(legacy)
    summary = json.loads((BASE / "status_summary.json").read_text(encoding="utf-8"))
    validate(rows, original, summary)
    print("PASS: 200 stable IDs, 50/category, history retained, 600 NO_GO gates; native migration unverified")

if __name__ == "__main__":
    main()
