# Dubai 200 — media production technical QA handoff

**Status: QA harness ready for independent testing; no final media package ready.** Applies equally to all 200 AE/PE/BU/GV missions. Internal target 2026-12-20. No completed decks, videos, genuine app screenshots, cleared music, narration, rights approvals or contest submissions are implied.

## Master production contract (user-defined, not asserted as contest limits)

For each mission: an English **exactly 50-page, landscape 16:9 PDF** (final format must not be PPT/PPTX), plus editable design source; an **exactly 60-second** English narrated video with subtle burnt-in English captions, real app footage and original/licensed Arabic instrumental music. Individual technical, legal, visual, audio and claims reviews are mandatory.

## Offline QA commands

Requires Python 3.10+, free open-source `pypdf==5.9.0` and FFmpeg `ffprobe` (tested locally with FFmpeg 7.1.5). No cloud account, external network, government data, API key or paid runner required for these checks.

```sh
python -m pip install pypdf==5.9.0
ffprobe -version
python migration/media_qa.py --agent AE-01 --pdf output/AE-01/deck.pdf --video output/AE-01/video.mp4 > output/AE-01/technical_qa.json
python -m unittest discover -s migration/tests -p 'test_media_qa.py' -v
```

The checker validates all 50 PDF pages' **visible CropBox geometry after page rotation** (not merely MediaBox), including 16:9 landscape, and video container AND measured video/audio stream durations near 60 seconds, decoded frame count via `ffprobe -count_frames` (required, not optional), declared-versus-decoded frame agreement when declared, measurable frame rate, minimum technical dimensions and audio stream presence. An unavailable stream duration or decoded frame count now fails closed. This can reject some valid containers whose metadata is incomplete; remux or transcode a review copy and retain provenance rather than waiving the gate. Missing or malformed inputs fail closed. Its JSON result **always** says `release_verdict=NO_GO_HUMAN_REVIEW_REQUIRED`, even after technical PASS. It cannot verify English speech, burnt-in captions, non-silent audio, copyright/license, product truth, accessibility, design excellence, official contest eligibility or real device footage.

**Suggested editable package per agent:** `sources/AE-01/deck/`, `sources/AE-01/video/`, script, captions, narration, licensed-music provenance, genuine capture manifest with native build SHA/device/session, PDF, MP4, `technical_qa.json`, and signed manual review. Keep private source footage, resident data, audio and restricted assets out of public GitHub until disclosure rights are cleared. Check storage/LFS constraints before upload.

## Production capacity / assistance

Target volume: **10,000 PDF pages** and **12,000 seconds (200 minutes) of video**, alongside **400 platform builds and installations**. Unverified resources include Android SDK/JDK/Gradle, macOS/Xcode, test devices, editing/rendering capacity, accessible audio/caption workflows, storage, music rights and human reviewers. Free local alternatives may include FFmpeg, Blender, Inkscape and Python/ReportLab, subject to suitability and rights.

**User handoff:** a machine/editor with FFmpeg, Python/pypdf and genuine app capture can run this structural checker now. A final per-agent render handoff must wait for verified product footage, cleared source assets and accurate script; this QA tool is not a rendered deck or video.
PDF rotation/CropBox regression evidence: [PDF_VISIBLE_GEOMETRY_2026-10-30.md](evidence/PDF_VISIBLE_GEOMETRY_2026-10-30.md). The 25 unit tests and three synthetic 50-page fixture checks were executed locally; they do not establish finished media readiness.
