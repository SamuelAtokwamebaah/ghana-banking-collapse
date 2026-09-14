# Changelog

This dataset is archived on Zenodo and citable by DOI. Published findings therefore
carry a version, and any correction to them is recorded here rather than made silently.

## Unreleased, since v1.1.0

**One interpretation was reworded to what the data shows. No figure or data changed.**

### Reworded

The charts page, README and FINDINGS described liquidity failure as the *symptom* and
related-party lending as the *cause*. The co-occurrence data does not show that.
Liquidity failure is cited in 15 of the 17 institutions with related-party exposure, and
in all 6 without it, so it does not separate the two groups; and the notice does not
record which came first.

The wording now says what the data does show. Liquidity failure is the failure
depositors saw. What sets institutions apart is related-party exposure together with
misreporting: 14 of 17, against 1 of 6. Chart 1 is retitled *21 of 23 could not pay
depositors. 17 of 23 had lent to related parties.*

The FINDINGS headline, *in 17 of 23 cases the money went to the owners*, now reads
*related parties*. The coded cause is related-party exposure, which the notice describes
as funds placed with companies connected to the owners, not only with the owners
themselves.

This surfaced while building the BI layer below, which compares each pair of causes
against the institutions that do not cite the first.

### Added

- A BI layer: a star schema as SQL views in `sql/bi/`, eight KPIs defined with their
  queries and caveats in `docs/kpi-definitions.md`, and an interactive dashboard in
  `dashboard/`, whose data `scripts/build_dashboard_data.py` builds from the views after
  13 reconciliation checks.

### Corrected

- The header comment in `sql/10_failure_causes.sql` gave the mean as 4.0 causes per
  institution. It is 4.39, 101 across 23. The query's results were unaffected.

## v1.1.0 — 30 August 2026

**A published finding was withdrawn. No data changed.**

### Withdrawn

Finding 2 previously stated that all twenty institutions with a stated insolvency date
had **breached a 180-day statutory deadline**, by a median of 5.2× and at worst 19.2×.
That characterisation was wrong and has been removed throughout.

Act 930 does contain 180-day periods, but neither runs from insolvency:

- **s.105(2)(b)** requires capital adequacy to be restored *"within one hundred and
  eighty days of making that order"* — the period runs from **an order of the Bank of
  Ghana**.
- **s.106(1)(b)** allows 90 days to rectify and 180 to restore under **an agreement with
  the institution's board** — the period runs from **that agreement**.

Both begin only after a supervisory act. No public document shows that either was made
in respect of these institutions, so on the available evidence no 180-day period ever
began, and a period that never started cannot be breached.

Independently, Act 930 received assent on **14 September 2016**. Four of the twenty state
an insolvency date preceding it (Sterling, March 2010; Crest, Dream and FirstTrust, 2015),
and two more are recorded as year-only "2016" and cannot be placed on either side of that
date. Those institutions were being measured against a statute that did not yet exist.

### What replaces it

The interval itself is unchanged and remains sourced to the Bank of Ghana's own notice:

| | |
|---|---|
| Institutions with a stated insolvency date | 20 of 23 |
| Shortest interval | 258 days |
| **Median interval** | **927.5 days, two and a half years** |
| Longest interval | 3,455 days |

The duty actually engaged is **s.123(1)**, which obliges the Bank of Ghana to revoke the
licence of an institution it determines to be insolvent. **Act 930 attaches no period to
that duty.** The finding is therefore not that a deadline was missed, but that no deadline
exists for the obligation that mattered.

### Consequential changes

- **Recommendation 1** reverses: from *enforce the deadline that already exists* to
  *attach a deadline to s.123(1)*. The first draft of this project proposed creating a
  statutory clock, and was right to.
- **Chart 3** retitled; its reference line now marks the median rather than a 180-day
  limit, and its table reports days rather than a multiple of a limit.
- `sql/12_supervisory_lag.sql` rewritten, with the reasoning in the file header and a
  column flagging rows whose stated insolvency predates Act 930.

### Data changes since v1.0.0

`data/savings_loans_verified.csv` is **unchanged**. Every figure behind the withdrawn
finding, and behind the interval that replaces it, is exactly as first archived.

`data/defunct_institutions.csv` still holds **418 rows**, unchanged in scope, but gained a
column after v1.0.0 was archived:

- A new **`resolution_mechanism`** column, separating *how* an institution was resolved
  from *who* the receiver was. Two different facts that the original schema conflated.
- Seven universal banks previously recorded "Consolidated into Consolidated Bank Ghana"
  in the `receiver` column. That was wrong twice over: a resolution mechanism is not a
  receiver, and CBG is a **bridge institution** under s.127(11), not a consolidation, as
  the Court of Appeal held in *Chancellor Oppong Kyekyeku Kohl v Consolidated Bank Ghana
  Ltd* [2022] 181 GMJ 694. See [`docs/universal-banks.md`](docs/universal-banks.md).

### Unaffected

Related-party exposure in 17 of 23 against the s.64(2) 25% cap; the s.123(1)
mandatory-revocation reading; the causes analysis; the sector reconciliation; and the
sourcing discipline throughout.

## v1.0.0 — 29 August 2026

First archived release. 418 institutions compiled from three Bank of Ghana revocation
notices, with a hand-verified analysis of why the 23 savings and loans companies failed.
