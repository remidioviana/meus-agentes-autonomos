"""Fail-closed provenance regression for BU-03 compiler handoff (stdlib only)."""
import importlib.util
from pathlib import Path
import shutil
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "verify_bu03_offline.py"
SPEC = importlib.util.spec_from_file_location("bu03_handoff", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)

class Bu03HandoffTests(unittest.TestCase):
    def test_repository_sources_match_expected_blobs(self):
        MODULE.verify_sources()

    def test_changed_source_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            for relative in MODULE.EXPECTED_BLOBS:
                src = MODULE.ROOT / MODULE.STAGE / relative
                dest = root / MODULE.STAGE / relative
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(src, dest)
            MODULE.verify_sources(root)
            modified = root / MODULE.STAGE / "tests/bu03/main.swift"
            modified.write_bytes(modified.read_bytes() + b"\n// tampered\n")
            with self.assertRaisesRegex(ValueError, "source changed"):
                MODULE.verify_sources(root)

    def test_missing_source_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            with self.assertRaises(FileNotFoundError):
                MODULE.verify_sources(Path(temp))

if __name__ == "__main__":
    unittest.main()
