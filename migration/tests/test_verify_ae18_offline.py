"""Fail-closed AE-18 source and execution prerequisites (synthetic fixtures only)."""
import importlib.util
from pathlib import Path
import shutil
import tempfile
import unittest
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[1] / "verify_ae18_offline.py"
SPEC = importlib.util.spec_from_file_location("ae18_handoff", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class Ae18HandoffTests(unittest.TestCase):
    def test_public_source_blobs_match(self):
        MODULE.verify_sources()

    def test_tampered_source_fails_closed(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for relative in MODULE.EXPECTED_BLOBS:
                dest = root / relative
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(MODULE.ROOT / relative, dest)
            MODULE.verify_sources(root)
            path = root / next(iter(MODULE.EXPECTED_BLOBS))
            path.write_bytes(path.read_bytes() + b"\n// unexpected edit\n")
            with self.assertRaisesRegex(ValueError, "source changed"):
                MODULE.verify_sources(root)

    def test_missing_source_fails_closed(self):
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaises(FileNotFoundError):
                MODULE.verify_sources(Path(tmp))

    def test_symlink_source_fails_closed(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for relative in MODULE.EXPECTED_BLOBS:
                dest = root / relative
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(MODULE.ROOT / relative, dest)
            path = root / next(iter(MODULE.EXPECTED_BLOBS))
            real = root / "outside.kt"
            shutil.copyfile(path, real)
            path.unlink()
            path.symlink_to(real)
            with self.assertRaisesRegex(ValueError, "symlink"):
                MODULE.verify_sources(root)

    def test_missing_compiler_fails_closed(self):
        with patch.object(MODULE.shutil, "which", return_value=None):
            with self.assertRaisesRegex(RuntimeError, "NOT EXECUTED"):
                MODULE.run()


if __name__ == "__main__":
    unittest.main()
