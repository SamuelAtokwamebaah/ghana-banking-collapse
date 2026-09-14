"""Build the data the interactive dashboard reads, from the BI views in sql/bi/.

Standard library only, like everything else in this repo. Run it from anywhere:

    python scripts/build_dashboard_data.py          writes dashboard/data.json
    python scripts/build_dashboard_data.py --db     also writes sql/ghana.db,
                                                    with every BI view in it

It loads both published CSVs into an in-memory SQLite database, runs the
views in order, and refuses to write anything unless every row of
sql/bi/09_checks.sql reads OK.

The dashboard computes no figures of its own. Every count, share, median and
headline in data.json is a column of a view, selected here unchanged, so each
number on the page can be reproduced by running the same view by hand. The
one piece of text not from the views is the court-status note on GN, which
records litigation after the 2019 notice and is quoted from the epilogue in
FINDINGS.md.

Output is byte-stable: the same CSVs always produce the same file.
"""

import json
import os
import sqlite3
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DATA = os.path.join(ROOT, "data")
SQL = os.path.join(ROOT, "sql")
BI = os.path.join(SQL, "bi")
OUT = os.path.join(ROOT, "dashboard", "data.json")
DB = os.path.join(SQL, "ghana.db")

sys.path.insert(0, HERE)
from build_sqlite import load  # noqa: E402  same loader, so the tables are identical

VIEW_FILES = ["01_dimensions.sql", "02_facts.sql", "03_marts.sql", "10_kpis.sql"]

# Litigation after the notice. Not data from the notice, so it is kept out of
# the SQL views and shown on the dashboard as a note beside the figures.
ANNOTATIONS = {
    "GN Savings and Loans Ltd.": {
        "as_at": "August 2026",
        "text": (
            "In May 2026 the Court of Appeal ordered the Bank of Ghana to restore "
            "this licence. The Supreme Court stayed that judgment in July 2026, "
            "pending the appeal, so the licence has not been restored. The figures "
            "and causes here are as the Bank of Ghana stated them in 2019, and this "
            "project takes no position on the litigation."
        ),
        "source": "FINDINGS.md#epilogue-where-things-stand-in-2026",
    },
}


def read_sql(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def build(conn):
    """Load the CSVs and create every BI view. Returns the check results."""
    conn.executescript(read_sql(os.path.join(SQL, "01_schema.sql")))
    n_sl = load(conn, "savings_loans", os.path.join(DATA, "savings_loans_verified.csv"))
    n_all = load(conn, "defunct_institutions", os.path.join(DATA, "defunct_institutions.csv"))
    assert n_sl == 23, "expected 23 savings and loans rows, got %d" % n_sl
    assert n_all == 418, "expected 418 institutions, got %d" % n_all

    for name in VIEW_FILES:
        conn.executescript(read_sql(os.path.join(BI, name)))
    conn.commit()
    return conn.execute(read_sql(os.path.join(BI, "09_checks.sql"))).fetchall()


def rows(conn, query):
    cur = conn.execute(query)
    names = [d[0] for d in cur.description]
    return [dict(zip(names, r)) for r in cur.fetchall()]


def collect(conn):
    causes = rows(conn, """
        SELECT c.cause_code, c.cause_label, c.description, c.sort_order,
               COUNT(f.institution_name) AS cited
        FROM dim_cause c
        LEFT JOIN fact_cited_causes f ON f.cause_code = c.cause_code
        GROUP BY c.cause_code, c.cause_label, c.description, c.sort_order
        ORDER BY c.sort_order
    """)

    types = rows(conn, """
        SELECT t.type_key, t.licence_type, t.sort_order,
               COUNT(i.institution_name) AS institutions
        FROM dim_institution_type t
        LEFT JOIN dim_institution i ON i.type_key = t.type_key
        GROUP BY t.type_key, t.licence_type, t.sort_order
        ORDER BY t.sort_order
    """)

    institutions = rows(conn, """
        SELECT i.institution_name, i.short_name, i.type_key, i.licence_type,
               i.incorporated, i.incorporated_precision,
               i.licensed, i.licensed_precision,
               i.insolvent_since, i.insolvent_since_precision,
               i.branches, i.notes,
               s.revocation_date,
               s.net_worth_ghs_m, s.net_worth_as_at,
               s.deficit_ghs_m, s.deficit_rank,
               s.car_pct, s.car_as_at,
               s.cited_causes,
               s.insolvent_date_upper, s.days_insolvent_upper,
               s.insolvent_date_floor, s.days_insolvent_floor
        FROM dim_institution i
        JOIN fact_institution_snapshot s ON s.institution_name = i.institution_name
        ORDER BY i.short_name COLLATE NOCASE
    """)
    cited = {}
    for r in rows(conn, """
        SELECT f.institution_name, f.cause_code
        FROM fact_cited_causes f
        JOIN dim_cause c ON c.cause_code = f.cause_code
        ORDER BY f.institution_name, c.sort_order
    """):
        cited.setdefault(r["institution_name"], []).append(r["cause_code"])
    for inst in institutions:
        inst["causes"] = cited.get(inst["institution_name"], [])
        inst["annotation"] = ANNOTATIONS.get(inst["institution_name"])

    cooccurrence = rows(conn, """
        SELECT cause_a, cause_b, institutions, cited_a, cited_both, share_b_given_a,
               not_a, b_without_a, share_b_given_not_a
        FROM v_cause_cooccurrence
        ORDER BY sort_a, sort_b
    """)

    by_type = rows(conn, """
        SELECT cause_code, type_key, cited, institutions_of_type, share
        FROM v_cause_by_type
        ORDER BY cause_sort, type_sort
    """)

    lag_by_cause = rows(conn, """
        SELECT cause_code, cause_status, institutions,
               median_days_upper, median_days_floor,
               shortest_days_upper, longest_days_upper
        FROM v_lag_by_cause
        ORDER BY cause_sort, status_sort
    """)

    kpis = rows(conn, """
        SELECT kpi_order, kpi_code, kpi_label, numerator, denominator, value,
               headline, comparison, note
        FROM v_kpis
        ORDER BY kpi_order
    """)

    return {
        "about": {
            "generated_by": "scripts/build_dashboard_data.py",
            "sources": ["data/savings_loans_verified.csv", "data/defunct_institutions.csv"],
            "views": ["sql/bi/" + name for name in VIEW_FILES],
            "notice": "Bank of Ghana, revocation of licences of 23 savings and loans "
                      "companies and finance houses, 16 August 2019, Annex 2",
            "revocation_date": "2019-08-16",
        },
        "kpis": kpis,
        "causes": causes,
        "types": types,
        "institutions": institutions,
        "cooccurrence": cooccurrence,
        "by_type": by_type,
        "lag_by_cause": lag_by_cause,
    }


def verify(data):
    """The dashboard lists institutions by filtering on their cited causes.
    Confirm that filter gives the same counts as the SQL, pair by pair, so a
    list on the page can never disagree with the number above it."""
    insts = data["institutions"]
    for pair in data["cooccurrence"]:
        a, b = pair["cause_a"], pair["cause_b"]
        with_a = [i for i in insts if a in i["causes"]]
        both = [i for i in with_a if b in i["causes"]]
        without_a_b = [i for i in insts if a not in i["causes"] and b in i["causes"]]
        assert len(with_a) == pair["cited_a"], (a, b, "cited_a")
        assert len(both) == pair["cited_both"], (a, b, "cited_both")
        assert len(without_a_b) == pair["b_without_a"], (a, b, "b_without_a")
    for row in data["lag_by_cause"]:
        group = [i for i in insts
                 if i["days_insolvent_upper"] is not None
                 and (row["cause_code"] in i["causes"]) == (row["cause_status"] == "cited")]
        assert len(group) == row["institutions"], (row["cause_code"], row["cause_status"])
    for row in data["by_type"]:
        n = sum(1 for i in insts if i["type_key"] == row["type_key"] and row["cause_code"] in i["causes"])
        assert n == row["cited"], (row["cause_code"], row["type_key"])


def main():
    write_db = "--db" in sys.argv[1:]

    conn = sqlite3.connect(":memory:")
    checks = build(conn)
    failed = [c for c in checks if not c[1].startswith("OK")]
    for name, result in checks:
        print("  %-32s %s" % (name, result))
    if failed:
        sys.exit("\nRefusing to write: %d check(s) failed." % len(failed))

    data = collect(conn)
    verify(data)
    conn.close()

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    text = json.dumps(data, indent=1, ensure_ascii=False) + "\n"
    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(text)
    print("\nWrote %s" % os.path.relpath(OUT, ROOT))
    for k in data["kpis"]:
        print("  %d  %-58s %s, %s" % (k["kpi_order"], k["kpi_label"], k["headline"], k["comparison"]))

    if write_db:
        tmp = DB + ".building"
        if os.path.exists(tmp):
            os.remove(tmp)
        disk = sqlite3.connect(tmp)
        build(disk)
        disk.close()
        os.replace(tmp, DB)
        print("\nWrote %s, with the BI views" % os.path.relpath(DB, ROOT))


if __name__ == "__main__":
    main()
