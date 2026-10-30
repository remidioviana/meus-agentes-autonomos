# Dubai 200 — video frame-integrity QA checkpoint (2026-10-30)

**Status: DRAFT QA HARDENING; NO_GO for every agent.** This branch is based on the existing public migration draft PR #1 at `19cd947fa27cf04e7492509c99158524637144ee`; it does not merge to `main`, run GitHub Actions, add old private repository files, or publish real user footage.

## Failure mode and code change

Previously a nominal 60-second container could pass technical QA even if video stream duration, audio stream duration and frame count were all unavailable. The revised `migration/media_qa.py`:
- invokes `ffprobe -count_frames` and requires `nb_read_frames`;
- requires measurable video and audio stream durations near 60 seconds;
- compares decoded frames against nominal average frame rate and declared frame count (if available);
- fails closed on missing/inconsistent measurements;
- retains the permanent `NO_GO_HUMAN_REVIEW_REQUIRED` verdict.

`migration/tests/test_media_qa.py` now includes regression cases for missing counted frames, deceptive single-frame video, missing video/audio duration, declared/decoded mismatch and actual ffprobe command arguments. `migration/MEDIA_PRODUCTION_HANDOFF.md` documents compatibility limits.

## Evidence executed on isolated local reconstruction

**Not a full GitHub checkout or execution of the newly committed versioned Python unittest file.** On Linux with Python 3.13.5 and FFmpeg/ffprobe 7.1.5, the modified `inspect_ffprobe` logic was reconstructed locally from the authored patch. Local assertions: **1 accepted synthetic 60s metadata fixture + 9 rejected malformed metadata fixtures**. A real locally rendered synthetic 640x360, 10fps, 60s black-frame video with 60s test-tone audio passed the structural function with 600 counted frames. A separate locally rendered one-second video with 60s audio and 60s container was **rejected** because its video stream duration was 1.00000s. Both media fixtures are disposable QA-only artifacts and **not** a demo, narration, soundtrack, licensed production footage, or finished deliverables.

The versioned test file contains additional tests but is **NOT_EXECUTED** in this run. No hosted CI, macOS/Xcode, Android SDK, devices, audio intelligibility check, visual inspection or final PDF/video output was executed.

## Reproduction on an authorized local checkout of this draft branch

```sh
python3 -m unittest discover -s migration/tests -p 'test_media_qa.py' -v
ffprobe -version
python3 migration/media_qa.py --agent AE-01 --pdf /path/to/real_50_page.pdf --video /path/to/real_60_second.mp4
```

Dependencies: Python 3.10+, `pypdf==5.9.0` for actual PDF files, and FFmpeg/ffprobe 7.1.5 as tested for the local video fixtures. No account or paid runner required. The tool's structural PASS is **not** an approved final package; real captures, editable source, independent 50-page visual review, exact 60-second editorial QA, narration, burnt-in captions, licensed original/Arabic instrumental music, privacy/IP clearance, reviewer signoff and submission eligibility remain blocked.

All 200 agents retain equal delivery priority and unchanged stable IDs. Readiness remains 0 qualified final apps, 0 final PDFs and 0 final videos; 600/600 release deliverables NO_GO. The main branch still contains the separate 15-minute synthetic simulator workflow.
