# Dubai 200 — Migration gate (public repository)

This public repository currently contains a **synthetic Python asyncio simulator**, not 200 functional native mobile AI agents. The earlier private repository has more research and native source but those are not automatically present or validated here.

**Migration branch / PR** stages source provenance and a fail-closed 200-row readiness registry before native code movement; no merge/release. Read [ADR-0001](ADR-0001.md) for the reviewed architecture, public-data boundary, native build gates and risk.

| Evidence level | Verified in destination |
| --- | ---: |
| Canonical AE/PE/BU/GV identities in imported source register | 200 |
| Native Kotlin source files imported / built | 0 / 0 |
| Native Swift source files imported / built | 0 / 0 |
| Android/iOS installation tests | 0 / 0 |
| Qualified final applications + decks + videos | 0 / 600 |

The registry keeps the private original paths **as external historic references**. All 200 rows explicitly say `source_migration_state=NOT_MIGRATED`. The only verified destination execution is the standalone Python simulation from `main` (200/200 synthetic jobs).

Check offline with `python migration/check_200.py` and `python -m unittest discover -s migration/tests -v`. No network, secret, personal data, government access, or external paid tool needed.
