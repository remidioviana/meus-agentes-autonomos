# Dubai 200 — visible PDF geometry QA, 2026-10-30

**Scope:** Public-authored technical QA only. No private donor source imported; no real agent, deck, video, app build or approval delivered. This evidence belongs to draft PR #3 and is not merged into main.

## Defect demonstrated before patch

The original `migration/media_qa.py` verified only each page's `MediaBox` dimensions. A PDF with exactly 50 pages and a 960x540 MediaBox on every page was accepted even when page 50 had `/Rotate=90` (rendered portrait) or a 540x540 `CropBox` (square visible crop). Both malformed fixtures returned a structural PASS before this change.

## Correction

The checker now validates the effective visible dimensions using the page's `CropBox` (falling back to `MediaBox`) after applying `/Rotate` (0/90/180/270). It rejects non-right-angle rotations, non-finite dimensions, portrait orientation and non-16:9 visible page aspect on **every** page. Rotation by 180 degrees remains valid; a portrait source page rotated 90 degrees into visible 16:9 landscape is valid. This checks geometry only, not design or content.

## Executed evidence (local, exact GitHub blobs)

- Environment: Linux x86_64, Python **3.13.5**, pypdf **5.9.0**, ReportLab **4.4.9**, FFmpeg/ffprobe **7.1.5**.
- Retrieved and reconstructed the pre-change **exact public GitHub blobs**: `migration/media_qa.py` Git blob `0c67a870b54c61a91c3adebbee7ae965e57e8c2a`; `migration/tests/test_media_qa.py` Git blob `af3114baf3397faea5cd71a9ca301a6fe3010582`. Confirmed with `git hash-object` before executing.
- Ran **20/20 pre-change versioned unittest cases PASS**, then added five regression cases and ran **25/25 PASS**.
- Created disposable, synthetic 50-page PDFs with ReportLab/pypdf: ordinary 960x540 landscape, page 50 rotated 90 degrees, page 50 cropped to 540x540. The old checker accepted all three; the corrected checker accepted only the valid one.
- Ran the actual CLI on all three: valid fixture `PASS_PARTIAL` (PDF only), rotated and cropped fixtures `FAIL`; every result retained `NO_GO_HUMAN_REVIEW_REQUIRED`.
- Rendered page 50 with Poppler: valid 600x338 px, rotated 338x600 px, and cropped 600x600 px when using `pdftoppm -cropbox`. These are synthetic QA fixtures, **not** pitch decks.
- The two patched files were committed to this PUBLIC draft branch; connector-reported Git blob SHAs matched the locally tested files exactly: source `7ad28fe7b593c47e0345619de1176b12812e32f7`; tests `b1df29dd59bf5c9662a7d7f1f3642e6562424fe2`.
- No GitHub Actions run was triggered, no billable CI started, no branch merged and no private code copied.

## Reproduction

On a checkout of draft PR #3:

```sh
python3 -m unittest discover -s migration/tests -p 'test_media_qa.py' -v
python3 migration/media_qa.py --agent AE-01 --pdf /path/to/actual_50_page_deck.pdf
```

Unit tests use Python standard library only. Real PDF QA requires `pypdf==5.9.0`. Disposable integration fixtures used ReportLab 4.4.9 and pypdf 5.9.0; no fixtures or media are committed. No external account, network service or paid runner is needed after checkout.

## Remaining gates

All 200 agents retain their stable IDs and equal delivery priority. **0/200 apps, 0/200 final 50-page PDFs, 0/200 final 60-second videos approved; NO_GO.** PDF page design, actual product screenshots, editorial accuracy, accessible contrast, real video capture, English narration/captions, Arabic music rights, privacy/IP clearance, device testing and independent human approval remain unverified. This structural QA tool is an independently runnable test handoff, **not** a production-ready deck/video package.
