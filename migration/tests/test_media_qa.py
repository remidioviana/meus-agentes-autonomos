"""Offline unit tests for media structure validation; no final artifacts implied."""
import importlib.util
import io
import json
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from unittest.mock import patch

FILE = Path(__file__).resolve().parents[1] / "media_qa.py"
spec = importlib.util.spec_from_file_location("dubai200_media_qa", FILE)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


class Box:
    left, bottom, right, top = 0, 0, 960, 540


class Page:
    mediabox = Box()


class Reader:
    is_encrypted = False
    pages = [Page() for _ in range(50)]


def video(duration="60.0", fps="30/1", frames="1800", audio=True):
    streams = [{"codec_type": "video", "width": 1920, "height": 1080,
                "avg_frame_rate": fps, "duration": duration, "nb_frames": frames}]
    if audio:
        streams.append({"codec_type": "audio", "duration": duration})
    return {"format": {"duration": duration}, "streams": streams}


class MediaQATests(unittest.TestCase):
    def test_pdf_50_pages_landscape(self):
        self.assertEqual(mod.inspect_pdf_reader(Reader())["pages"], 50)

    def test_pdf_wrong_page_count_rejected(self):
        reader = Reader()
        reader.pages = reader.pages[:49]
        with self.assertRaises(ValueError):
            mod.inspect_pdf_reader(reader)

    def test_pdf_wrong_aspect_any_page_rejected(self):
        reader = Reader()
        wrong = Page()
        wrong.mediabox = type("Box", (), {"left": 0, "bottom": 0, "right": 1000, "top": 540})()
        reader.pages = reader.pages.copy()
        reader.pages[49] = wrong
        with self.assertRaisesRegex(ValueError, "page 50"):
            mod.inspect_pdf_reader(reader)

    def test_pdf_encrypted_rejected(self):
        reader = Reader()
        reader.is_encrypted = True
        with self.assertRaises(ValueError):
            mod.inspect_pdf_reader(reader)

    def test_video_exact_60_with_audio(self):
        self.assertEqual(mod.inspect_ffprobe(video())["audio_streams"], 1)

    def test_video_59_seconds_rejected(self):
        with self.assertRaises(ValueError):
            mod.inspect_ffprobe(video(duration="59.0", frames="1770"))

    def test_video_missing_audio_rejected(self):
        with self.assertRaises(ValueError):
            mod.inspect_ffprobe(video(audio=False))

    def test_video_frame_count_mismatch_rejected(self):
        with self.assertRaises(ValueError):
            mod.inspect_ffprobe(video(frames="1700"))

    def test_video_invalid_fps_rejected(self):
        with self.assertRaises(ValueError):
            mod.inspect_ffprobe(video(fps="0/0"))

    def test_video_tiny_dimensions_rejected(self):
        bad = video()
        bad["streams"][0]["width"] = 200
        with self.assertRaises(ValueError):
            mod.inspect_ffprobe(bad)

    def test_missing_media_fail_closed(self):
        out = io.StringIO()
        with redirect_stdout(out):
            result = mod.main(["--agent", "GV-50", "--pdf", "/not/here.pdf"])
        self.assertEqual(result, 1)
        payload = json.loads(out.getvalue())
        self.assertEqual(payload["release_verdict"], "NO_GO_HUMAN_REVIEW_REQUIRED")
        self.assertEqual(payload["technical_status"], "FAIL")

    def test_valid_id_format(self):
        for identifier in ("AE-01", "PE-50", "BU-29", "GV-10"):
            self.assertIsNotNone(mod.AGENT_RE.fullmatch(identifier))
        for identifier in ("AE-00", "PE-51", "XX-01", "GV-1"):
            self.assertIsNone(mod.AGENT_RE.fullmatch(identifier))

    def test_partial_pass_never_go(self):
        with tempfile.TemporaryDirectory() as tmp:
            pdf = Path(tmp) / "sample.pdf"
            pdf.write_bytes(b"not real PDF")
            with patch.object(mod, "inspect_pdf", return_value={"pages": 50}):
                out = io.StringIO()
                with redirect_stdout(out):
                    result = mod.main(["--agent", "AE-01", "--pdf", str(pdf)])
                payload = json.loads(out.getvalue())
                self.assertEqual(result, 0)
                self.assertEqual(payload["technical_status"], "PASS_PARTIAL")
                self.assertEqual(payload["release_verdict"], "NO_GO_HUMAN_REVIEW_REQUIRED")


if __name__ == "__main__":
    unittest.main()
