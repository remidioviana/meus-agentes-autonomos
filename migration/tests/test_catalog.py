"""Negative and positive independent registry integrity tests (no native-build claims)."""
import importlib.util
import json
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "check_200.py"
spec = importlib.util.spec_from_file_location("dubai200_catalog_checker", SCRIPT)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

class MigrationRegistryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.original = mod.rows_from(mod.BASE / "legacy" / "Stage176_readiness_200.csv")
        cls.rows = mod.rows_from(mod.BASE / "readiness_200.csv")
        cls.summary = json.loads((mod.BASE / "status_summary.json").read_text(encoding="utf-8"))

    def check_mutation(self, index, field, value):
        damaged = [dict(row) for row in self.rows]
        damaged[index][field] = value
        with self.assertRaises(ValueError):
            mod.validate(damaged, self.original, self.summary)

    def test_original_blob_exact(self):
        self.assertEqual(mod.git_blob_sha(mod.BASE / "legacy" / "Stage176_readiness_200.csv"), mod.LEGACY_BLOB)

    def test_200_stable_qualified_denials(self):
        self.assertTrue(mod.validate(self.rows, self.original, self.summary))

    def test_cross_portfolio_identity_drift_rejected(self):
        self.check_mutation(150, "id", "GV-99")

    def test_false_native_build_rejected(self):
        self.check_mutation(101, "android_native_build", "PASS")

    def test_false_source_migration_rejected(self):
        self.check_mutation(0, "source_migration_state", "MIGRATED")

    def test_false_video_rejected(self):
        self.check_mutation(199, "video_final_render", "PASS")

    def test_name_drift_rejected(self):
        self.check_mutation(50, "registered_name", "REMOVED")

    def test_renamed_original_slug_rejected(self):
        self.check_mutation(0, "societal_slug", "something_else")

    def test_false_approval_rejected(self):
        self.check_mutation(151, "qualified_approval", "APPROVED")

    def test_summary_false_go_rejected(self):
        state = dict(self.summary, release_verdict="GO")
        with self.assertRaises(ValueError):
            mod.validate(self.rows, self.original, state)

if __name__ == "__main__":
    unittest.main()
