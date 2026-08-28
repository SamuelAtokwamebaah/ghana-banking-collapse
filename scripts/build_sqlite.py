"""Load the published CSVs into a SQLite database for the queries in sql/.

Standard library only, like everything else in this repo. Run it from anywhere:

    python scripts/build_sqlite.py

It writes sql/ghana.db, replacing any previous copy, then verifies the row
counts. The database is a build artefact and is not committed — the CSVs are
the source of truth and this file is reproducible from them in a second.

The sqlite3 shell can do the same job via sql/02_load.sql. This exists because
that route needs sqlite3 3.32+ installed separately, and this one does not.
"""

import csv
import os
import sqlite3

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DATA = os.path.join(ROOT, "data")
SQL = os.path.join(ROOT, "sql")
DB = os.path.join(SQL, "ghana.db")

# Columns that must be stored as numbers rather than text, so that the
# analysis queries can compare and aggregate them.
REAL_COLS = {"net_worth_ghs_m", "car_pct"}
INT_COLS = {"cause_count"}


def typed(column, value):
    """Convert one CSV cell. Blank means the regulator published no figure."""
    if value == "":
        return None
    if column in REAL_COLS:
        return float(value)
    if column in INT_COLS:
        return int(value)
    return value


def load(conn, table, csv_path):
    with open(csv_path, newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        columns = reader.fieldnames
        rows = [
            tuple(typed(c, row[c]) for c in columns)
            for row in reader
        ]
    placeholders = ",".join("?" * len(columns))
    conn.executemany(
        "INSERT INTO %s (%s) VALUES (%s)" % (table, ",".join(columns), placeholders),
        rows,
    )
    return len(rows)


def main():
    if os.path.exists(DB):
        os.remove(DB)

    conn = sqlite3.connect(DB)
    with open(os.path.join(SQL, "01_schema.sql"), encoding="utf-8") as fh:
        conn.executescript(fh.read())

    n_sl = load(conn, "savings_loans",
                os.path.join(DATA, "savings_loans_verified.csv"))
    n_all = load(conn, "defunct_institutions",
                 os.path.join(DATA, "defunct_institutions.csv"))
    conn.commit()

    # Same guard rails as build_dataset.py. A silent partial load would make
    # every number downstream wrong, so fail loudly instead.
    assert n_sl == 23, "expected 23 savings and loans rows, got %d" % n_sl
    assert n_all == 418, "expected 418 institutions, got %d" % n_all

    print("Wrote %s" % os.path.relpath(DB, ROOT))
    print("  savings_loans         %3d rows" % n_sl)
    print("  defunct_institutions  %3d rows" % n_all)
    print()
    print("Run a query:  sqlite3 sql/ghana.db < sql/10_failure_causes.sql")
    conn.close()


if __name__ == "__main__":
    main()
