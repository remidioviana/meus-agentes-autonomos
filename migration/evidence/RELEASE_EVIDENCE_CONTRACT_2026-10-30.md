# 2026-10-30 — W1 fail-closed 200-agent evidence contract

## Problem reproduced
The previous `migration/check_200.py` checked native builds and some approvals, but omitted several independent release-evidence fields. Editing `video_music_rights`, `video_render_qa`, `deck_editable_source`, `permitted_real_workflow`, the required English/caption specification, or `source_origin_reference` could pass those original checks without any supporting evidence. A swap of two portfolio labels could preserve the 50/category totals while mismatching stable IDs.

## Bounded change
- New public-authored `migration/release_contract.py`: exact 44-column W1 schema, all 19 independent unverified release-evidence states, 10 frozen media/identity/provenance values, AE/PE/BU/GV ID-to-portfolio consistency, and all 21 required summary values plus 50/category totals. No private donor source or credentials added.
- `migration/check_200.py` now invokes this contract before the existing legacy blob/mission/provenance checks. Existing stable IDs, names, missions, legacy register, and 200 rows are unchanged.
- New `migration/tests/test_release_contract.py` uses explicitly synthetic 200-row fixtures. It mutates every one of the 19 status fields in all four categories (76 negative cases), all 10 specification/provenance fields, all 21 summary fields, category swaps, malformed schema, and wrong numeric types. No positive result implies app or media completion.

## Actually executed and independently checked
- Python **3.13.5**, offline local workspace: `python3 -m unittest discover -s migration/tests -p 'test_release_contract.py' -v` => **7/7 tests PASS**, elapsed **0.088 s**. Test methods contain 76 status-field negative subcases and additional malformed-metadata subcases.
- Confirmed that the exact executed local Python files match the public draft branch Git blob SHAs: `release_contract.py` **36a7bc9f08e6eb319b1a1286230e93a81f9f4e24**; `test_release_contract.py` **fbfefe221c5b73799aaecd34f895bb233315c20b**.
- Independent JavaScript CSV parser read the **actual public draft branch** `migration/readiness_200.csv` (200 rows, 44 columns), the preserved legacy 200-row CSV (blob `87660ee2ffb9647f236a3a52099d7ff7869a0440`), and `status_summary.json`: **8,027/8,027 assertions PASS** for stable IDs, category labels, 19 evidence fields, 10 master spec/provenance fields, 9 preserved identity/mission/source fields, and summary totals. This is a separate audit, **not execution of `check_200.py` against the full checkout**.
- No CI run was triggered; no Android/iOS build, device install, live agent workflow, final 50-page deck, final 60-second video, rights clearance, reviewer approval, or real outcome was established.

## Reproduce with no paid services
On a clean checkout of this **draft branch** with Python >=3.10:

```bash
python3 -m unittest discover -s migration/tests -p 'test_release_contract.py' -v
python3 migration/check_200.py
python3 -m unittest discover -s migration/tests -v
```

Only the first command was executed locally against the exact versioned test and module bytes in this checkpoint. The second and third commands are proposed independent full-checkout handoff steps, **not reported as passes**. No cloud account, device, SDK, network, government access or license is needed to run these offline checks after cloning. Capacity measured only for synthetic fixtures; full-checkout throughput not measured.

## Important guardrails
This W1 contract intentionally keeps **all 600 app/deck/video approvals NO_GO**. Future genuine evidence must be linked and reviewed, then the frozen contract deliberately amended with a positive/negative tested evidence-validation path; changing a CSV label alone is not authorization. Four historical cross-category domain engine pairs are source-only, not four native apps. Independent publication/IP clearance of inherited public PR #1 contents is still outstanding. No merge, deployment, spend or workflow activation.
