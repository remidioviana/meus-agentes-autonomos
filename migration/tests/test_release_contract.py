"""Mutation tests for every frozen W1 release-evidence field in all four groups."""
import importlib.util
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "release_contract.py"
spec = importlib.util.spec_from_file_location("dubai200_release_contract", SCRIPT)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


def fixture():
    rows = []
    for prefix, category in mod.PORTFOLIOS.items():
        for n in range(1, 51):
            row = dict.fromkeys(mod.FIELDS, "synthetic-test-only")
            row.update(mod.UNVERIFIED)
            row.update(mod.SPEC)
            row["id"] = f"{prefix}-{n:02d}"
            row["portfolio"] = category
            rows.append(row)
    summary = dict(mod.SUMMARY_EXPECTED)
    summary["by_portfolio"] = dict.fromkeys(mod.PORTFOLIOS.values(), 50)
    return rows, summary


class ContractTests(unittest.TestCase):
    def test_200_row_fixture_is_not_a_real_delivery_claim(self):
        rows, summary = fixture()
        self.assertTrue(mod.verify_contract(rows, summary))

    def test_every_unverified_status_rejects_false_promotion_in_every_category(self):
        rows, summary = fixture()
        for idx in (0, 50, 100, 150):
            for field in mod.UNVERIFIED:
                with self.subTest(id=rows[idx]["id"], field=field):
                    damaged = [dict(r) for r in rows]
                    damaged[idx][field] = "PASS"
                    with self.assertRaisesRegex(ValueError, field):
                        mod.verify_contract(damaged, summary)

    def test_all_spec_and_provenance_fields_reject_mutation(self):
        rows, summary = fixture()
        for field in mod.SPEC:
            with self.subTest(field=field):
                damaged = [dict(r) for r in rows]
                damaged[199][field] = "changed"
                with self.assertRaisesRegex(ValueError, field):
                    mod.verify_contract(damaged, summary)

    def test_category_swaps_fail_even_when_totals_unchanged(self):
        rows, summary = fixture()
        rows[0]["portfolio"], rows[50]["portfolio"] = rows[50]["portfolio"], rows[0]["portfolio"]
        with self.assertRaisesRegex(ValueError, "portfolio"):
            mod.verify_contract(rows, summary)

    def test_missing_and_unknown_csv_columns_fail(self):
        rows, summary = fixture()
        del rows[0]["video_music_rights"]
        with self.assertRaisesRegex(ValueError, "schema drift"):
            mod.verify_contract(rows, summary)
        rows, summary = fixture()
        rows[0]["unexpected"] = "PASS"
        with self.assertRaisesRegex(ValueError, "schema drift"):
            mod.verify_contract(rows, summary)

    def test_all_summary_fields_reject_false_claims(self):
        rows, summary = fixture()
        for field in mod.SUMMARY_EXPECTED:
            with self.subTest(field=field):
                damaged = dict(summary)
                damaged[field] = True if isinstance(summary[field], int) else "changed"
                with self.assertRaisesRegex(ValueError, field):
                    mod.verify_contract(rows, damaged)

    def test_summary_category_and_type_fail(self):
        rows, summary = fixture()
        summary["by_portfolio"]["Governmental"] = 49
        with self.assertRaisesRegex(ValueError, "category totals"):
            mod.verify_contract(rows, summary)
        rows, summary = fixture()
        summary["total_agents"] = True  # bool is subclass of int; reject anyway
        with self.assertRaisesRegex(ValueError, "total_agents"):
            mod.verify_contract(rows, summary)


if __name__ == "__main__":
    unittest.main()
