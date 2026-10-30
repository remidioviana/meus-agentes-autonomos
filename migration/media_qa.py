#!/usr/bin/env python3
"""Offline, fail-closed technical QA for one Dubai 200 media pair.

No automatic GO: narration, captions, rights, screenshots, and claim accuracy
require human verification even if the PDF/video structure passes.

Usage:
  python migration/media_qa.py --agent AE-01 --pdf /path/deck.pdf --video /path/video.mp4

Requires pypdf (pip install pypdf==5.9.0) for PDFs and ffprobe (FFmpeg) for video.
No network, credentials, uploads, paid CI, or government data are used.
"""
from __future__ import annotations

import argparse
import json
import math
import re
import subprocess
import sys
from fractions import Fraction
from pathlib import Path

AGENT_RE = re.compile(r"^(AE|PE|BU|GV)-(0[1-9]|[1-4][0-9]|50)$")
TARGET_ASPECT = 16 / 9
MANUAL_GATES = [
    "English editorial accuracy, evidence-backed claims and independent reviewer approval",
    "Original design, source/editable assets, typography, contrast and accessibility",
    "Real mobile-app footage and accurate mission-specific product identity",
    "Natural English narration, audible mix and verified burnt-in English captions",
    "Original or legally licensed Arabic instrumental music and retained license evidence",
    "Frame-by-frame video QA and PDF visual/page-by-page review",
    "Official competition rules, permissions and eligibility independently checked",
]


def inspect_pdf_reader(reader):
    """Validate every page, not merely the first page reported by pdfinfo."""
    if reader.is_encrypted:
        raise ValueError("Encrypted PDF cannot be independently reviewed")
    count = len(reader.pages)
    if count != 50:
        raise ValueError(f"Expected exactly 50 PDF pages; found {count}")
    for i, page in enumerate(reader.pages, 1):
        # A 16:9 MediaBox can conceal a portrait CropBox or /Rotate=90.
        # Validate the visible page geometry after the PDF viewer applies rotation.
        box = getattr(page, "cropbox", None) or page.mediabox
        width = float(box.right) - float(box.left)
        height = float(box.top) - float(box.bottom)
        rotation = int(getattr(page, "rotation", 0) or 0) % 360
        if rotation not in (0, 90, 180, 270):
            raise ValueError(f"PDF page {i}: unsupported rotation {rotation}")
        if rotation in (90, 270):
            width, height = height, width
        if (not math.isfinite(width) or not math.isfinite(height)
                or width <= 0 or height <= 0 or width <= height):
            raise ValueError(f"PDF page {i}: invalid visible landscape dimensions")
        if abs(width / height - TARGET_ASPECT) > 0.005:
            raise ValueError(f"PDF page {i}: visible aspect {width/height:.5f}, not 16:9")
    return {"pages": count, "aspect": "16:9_LANDSCAPE", "all_pages_checked": True}


def inspect_pdf(path):
    try:
        from pypdf import PdfReader
    except ImportError as exc:
        raise RuntimeError("pypdf is required; install pypdf==5.9.0") from exc
    return inspect_pdf_reader(PdfReader(str(path), strict=True))


def _duration(value, name):
    try:
        result = float(value)
    except (ValueError, TypeError):
        raise ValueError(f"{name}: no measurable duration") from None
    if not (0 < result < 86400):
        raise ValueError(f"{name}: invalid duration {result}")
    return result


def inspect_ffprobe(data):
    streams = data.get("streams") or []
    videos = [s for s in streams if s.get("codec_type") == "video" and s.get("disposition", {}).get("attached_pic") != 1]
    audios = [s for s in streams if s.get("codec_type") == "audio"]
    if len(videos) != 1 or not audios:
        raise ValueError("Exactly one primary video stream and at least one audio stream required")
    video = videos[0]
    if int(video.get("width", 0)) < 640 or int(video.get("height", 0)) < 360:
        raise ValueError("Video dimensions below 640x360 minimum technical QA")
    try:
        fps = float(Fraction(video.get("avg_frame_rate", "0/1")))
    except (ZeroDivisionError, ValueError):
        fps = 0
    if fps <= 0 or fps > 240:
        raise ValueError("Missing or invalid video frame rate")
    tolerance = min(0.05, 1.0 / fps + 0.001)
    container_duration = _duration((data.get("format") or {}).get("duration"), "Container")
    if abs(container_duration - 60.0) > tolerance:
        raise ValueError(f"Container duration {container_duration:.5f}s differs from 60s")
    # A 60-second container can hide a one-frame video or truncated audio.
    # Require measured stream durations and frames actually counted by ffprobe.
    if video.get("duration") in (None, "N/A"):
        raise ValueError("Video stream duration unavailable; cannot verify 60 seconds")
    video_duration = _duration(video["duration"], "Video stream")
    if abs(video_duration - 60.0) > tolerance:
        raise ValueError(f"Video stream duration {video_duration:.5f}s differs from 60s")
    raw_frames = video.get("nb_read_frames")
    if raw_frames in (None, "N/A"):
        raise ValueError("Decoded frame count unavailable; rerun ffprobe with -count_frames")
    try:
        counted_frames = int(raw_frames)
    except (ValueError, TypeError):
        raise ValueError("Invalid decoded frame count") from None
    if counted_frames <= 0 or abs(counted_frames / fps - 60.0) > tolerance:
        raise ValueError("Decoded frame count does not correspond to 60 seconds")
    if video.get("nb_frames") not in (None, "N/A"):
        try:
            declared_frames = int(video["nb_frames"])
        except (ValueError, TypeError):
            raise ValueError("Invalid declared frame count") from None
        if declared_frames != counted_frames:
            raise ValueError("Declared and decoded frame counts disagree")
    for a in audios:
        if a.get("duration") in (None, "N/A"):
            raise ValueError("Audio stream duration unavailable; cannot verify 60 seconds")
        if abs(_duration(a["duration"], "Audio stream") - 60.0) > 0.1:
            raise ValueError("Audio stream duration differs from 60 seconds")
    return {"container_seconds": container_duration, "video_seconds": video_duration,
            "fps": fps, "decoded_frames": counted_frames,
            "width": int(video["width"]), "height": int(video["height"]),
            "audio_streams": len(audios), "duration_tolerance_seconds": tolerance}


def inspect_video(path):
    try:
        proc = subprocess.run(
            ["ffprobe", "-v", "error", "-count_frames", "-show_format", "-show_streams", "-of", "json", str(path)],
            capture_output=True, text=True, timeout=30, check=False,
        )
    except FileNotFoundError as exc:
        raise RuntimeError("ffprobe missing; install FFmpeg") from exc
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError("ffprobe timed out") from exc
    if proc.returncode != 0:
        raise RuntimeError("ffprobe failed: " + proc.stderr[:400])
    return inspect_ffprobe(json.loads(proc.stdout))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--agent", required=True)
    parser.add_argument("--pdf", type=Path)
    parser.add_argument("--video", type=Path)
    args = parser.parse_args(argv)
    if not AGENT_RE.fullmatch(args.agent):
        parser.error("--agent must be AE/PE/BU/GV-01..50")
    if not args.pdf and not args.video:
        parser.error("Provide at least --pdf or --video")
    checks = {}
    errors = {}
    for kind, path, inspect in (("pdf", args.pdf, inspect_pdf), ("video", args.video, inspect_video)):
        if path is None:
            checks[kind] = {"status": "NOT_PROVIDED"}
        elif not path.is_file():
            errors[kind] = f"File not found: {path}"
        else:
            try:
                checks[kind] = {"status": "TECHNICAL_PASS", **inspect(path)}
            except (ValueError, RuntimeError, OSError, KeyError, TypeError) as exc:
                errors[kind] = str(exc)
    report = {
        "agent": args.agent, "technical_status": "FAIL" if errors else "PASS_PARTIAL" if not (args.pdf and args.video) else "PASS",
        "release_verdict": "NO_GO_HUMAN_REVIEW_REQUIRED", "checks": checks,
        "errors": errors, "unverified_manual_gates": MANUAL_GATES,
        "disclaimer": "Technical container/page checks are not product, media, rights or competition approval.",
    }
    print(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
