# SQL

The same findings as `FINDINGS.md`, expressed as queries you can run yourself.

Every query here reproduces a number that is already published elsewhere in this repository, and each file ends with its expected result as a comment. If a query returns something different from what its comment claims, one of the two is wrong and I want to know about it.

## Running it

Two commands, no dependencies beyond Python's standard library:

```bash
python scripts/build_sqlite.py
sqlite3 sql/ghana.db < sql/10_failure_causes.sql
```

`build_sqlite.py` loads both published CSVs into `sql/ghana.db`. That file is a build artefact and is not committed. The CSVs are the source of truth, and the database is only a second away from them.

If you have the sqlite3 shell (3.32 or later) you can skip Python entirely:

```bash
cd sql
sqlite3 ghana.db ".read 01_schema.sql" ".read 02_load.sql"
```

Or open `ghana.db` in DB Browser for SQLite, DBeaver, or anything else that speaks SQLite.

## The files

| File | Question | Reproduces |
|---|---|---|
| `01_schema.sql` | n/a | Two tables mirroring the two CSVs |
| `02_load.sql` | n/a | CSV import for the sqlite3 shell |
| `10_failure_causes.sql` | How often is each cause cited? | Chart 1, finding 1 |
| `11_cooccurrence.sql` | Do related-party lending and misreporting travel together? | Chart 2, finding 2 |
| `12_supervisory_lag.sql` | How long did each institution stay licensed while insolvent? | Chart 3, finding 3 |
| `13_deficit_concentration.sql` | How concentrated are the losses? | Chart 4, finding 4 |
| `14_sector_reconciliation.sql` | Does the dataset reconcile to the Bank of Ghana's stated totals? | The 418-row counts |

Run them in any order; only `01` and `02` have to come first.

## Two conventions worth knowing before you read the queries

**NULL means the regulator published no figure.** It never means zero. Three institutions have no stated insolvency date and are excluded from the supervisory-lag calculation rather than given a guessed one; two have no net-worth figure and are excluded from the deficit total. A documented blank is a finding about what the public record contains; a filled-in guess would end the project's credibility.

**Causes are stored one per column, `'Y'` or NULL.** That is the right shape for a hand-checked transcription, one column for each thing the notice might say, and the wrong shape for counting, so `10_failure_causes.sql` unpivots them with `UNION ALL` first. A NULL is not evidence that a cause was absent, only that the Bank of Ghana did not cite it.

## What this layer caught

Writing `12_supervisory_lag.sql` corrected a published number. With n = 20 the median is the mean of the 10th and 11th ordered values, 898 and 957 days, which is 927.5 days, or **5.2×** the 180-day statutory limit. The earlier figure of 5.3× had taken the upper of the two middle values instead of averaging them.

It changes nothing about the finding: still 20 breaches out of 20, still 19.2× at the worst. But it is the second time on this project that redoing the arithmetic a different way caught an error the first pass missed, which is the argument for doing it twice.

## Caveats

The caveats in the [main README](../README.md#caveats) apply in full. In particular: n = 23, these are descriptive findings rather than statistical ones, and the causes reflect what the Bank of Ghana chose to publish in a document written to justify a decision it had already taken.
