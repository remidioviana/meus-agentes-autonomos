"""Fail-closed W1 readiness contract; validates *unverified* evidence states.

This is intentionally a frozen NO_GO snapshot. To promote any field later,
reviewers must replace the corresponding gate with an evidence-backed rule and
add positive/negative tests; merely editing CSV status text is not evidence.
No private data, network calls, or third-party dependencies.
"""

FIELDS = (
    "id", "portfolio", "registered_name", "societal_slug",
    "societal_android_flavor", "societal_android_bundle",
    "distinct_mission_hypothesis", "proposed_outcome_not_measured",
    "critical_risk", "android_source_file", "ios_source_file",
    "source_path_audit", "individual_logic_test", "android_native_build",
    "ios_native_build", "android_device_install", "ios_device_install",
    "security_review", "privacy_review", "accessibility_review",
    "permitted_real_workflow", "independent_outcome_validation",
    "qualified_approval", "deck_editable_source", "deck_final_pdf",
    "deck_render_qa", "deck_claims_review", "video_editable_source",
    "video_final_render", "video_render_qa", "video_music_rights",
    "video_claims_review", "deck_target_pages", "deck_target_aspect",
    "deck_target_language", "video_target_seconds", "video_target_language",
    "video_target_burnt_in_captions", "deadline_dubai", "release_verdict",
    "source_origin_repository", "source_origin_reference",
    "source_migration_state", "domain_engine_source_status",
)

UNVERIFIED = {
    "android_native_build": "NOT_VERIFIED",
    "ios_native_build": "NOT_VERIFIED",
    "android_device_install": "NOT_VERIFIED",
    "ios_device_install": "NOT_VERIFIED",
    "security_review": "NOT_APPROVED",
    "privacy_review": "NOT_APPROVED",
    "accessibility_review": "NOT_APPROVED",
    "permitted_real_workflow": "NOT_AUTHORIZED_OR_VERIFIED",
    "independent_outcome_validation": "NOT_MEASURED",
    "qualified_approval": "NOT_GRANTED",
    "deck_editable_source": "NOT_VERIFIED",
    "deck_final_pdf": "NOT_VERIFIED",
    "deck_render_qa": "NOT_VERIFIED",
    "deck_claims_review": "NOT_APPROVED",
    "video_editable_source": "NOT_VERIFIED",
    "video_final_render": "NOT_VERIFIED",
    "video_render_qa": "NOT_VERIFIED",
    "video_music_rights": "NOT_VERIFIED",
    "video_claims_review": "NOT_APPROVED",
}

SPEC = {
    "deck_target_pages": "50",
    "deck_target_aspect": "16:9_LANDSCAPE",
    "deck_target_language": "English",
    "video_target_seconds": "60",
    "video_target_language": "English",
    "video_target_burnt_in_captions": "REQUIRED",
    "deadline_dubai": "2026-12-20",
    "release_verdict": "NO_GO",
    "source_origin_repository": "remidioviana/dubai50-mobile-ai-agents",
    "source_origin_reference": "stage176/dubai200-evidence-gated-delivery-register",
}

PORTFOLIOS = {"AE": "Societal", "PE": "Personal", "BU": "Business", "GV": "Governmental"}

SUMMARY_EXPECTED = {
    "source_repository": "remidioviana/dubai50-mobile-ai-agents",
    "source_ref": "stage176/dubai200-evidence-gated-delivery-register",
    "source_readiness_git_blob": "87660ee2ffb9647f236a3a52099d7ff7869a0440",
    "destination_repository": "remidioviana/meus-agentes-autonomos",
    "total_agents": 200,
    "source_catalog_rows_preserved": 200,
    "destination_native_android_sources_verified": 0,
    "destination_native_ios_sources_verified": 0,
    "destination_native_android_builds_verified": 0,
    "destination_native_ios_builds_verified": 0,
    "device_installations_verified": 0,
    "real_agent_workflows_verified": 0,
    "qualified_approvals_verified": 0,
    "final_decks_50page_verified": 0,
    "final_videos_60sec_verified": 0,
    "deliverables_approved": 0,
    "deliverable_target_total": 600,
    "isolated_domain_engine_source_pairs_migrated": 4,
    "isolated_domain_engine_pairs_compiled_in_destination": 0,
    "deadline": "2026-12-20",
    "release_verdict": "NO_GO",
}


def verify_contract(rows, summary):
    """Raise ValueError on unsupported evidence, schema drift or category mismatch."""
    if len(rows) != 200:
        raise ValueError("Readiness contract requires exactly 200 rows")
    required = set(FIELDS)
    for index, row in enumerate(rows):
        agent_id = f"row {index + 1}"
        if set(row) != required:
            missing, extra = sorted(required - set(row)), sorted(set(row) - required)
            raise ValueError(f"{agent_id}: schema drift missing={missing} extra={extra}")
        agent_id = row["id"]
        prefix = agent_id[:2]
        if row["portfolio"] != PORTFOLIOS.get(prefix):
            raise ValueError(f"{agent_id}: portfolio does not match stable ID")
        for field, expected in {**UNVERIFIED, **SPEC}.items():
            if row[field] != expected:
                raise ValueError(f"{agent_id}: unsupported {field}={row[field]!r}")
    if not isinstance(summary, dict):
        raise ValueError("Summary must be a JSON object")
    for field, expected in SUMMARY_EXPECTED.items():
        actual = summary.get(field)
        if type(actual) is not type(expected) or actual != expected:
            raise ValueError(f"Summary {field}: expected {expected!r}, got {actual!r}")
    expected_categories = dict.fromkeys(PORTFOLIOS.values(), 50)
    if summary.get("by_portfolio") != expected_categories:
        raise ValueError("Summary category totals must remain 50 each")
    return True
