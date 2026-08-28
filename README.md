# Ghana's Banking Sector Collapse, 2017–2019

Every financial institution closed in Ghana's banking-sector clean-up, compiled from Bank of Ghana primary sources — and an analysis of *why* the 23 savings and loans companies failed.

**418 institutions. GHS 2.30 billion in net-worth deficits. Over 360,000 depositors.**

📊 **[Interactive charts](https://SamuelAtokwamebaah.github.io/ghana-banking-collapse/)** · 📄 **[Full findings](FINDINGS.md)**

---

## The finding

The Bank of Ghana revoked 23 savings and loans and finance house licences on 16 August 2019, publishing its reasons for each. Coding those reasons shows the failures were not accidents of a hard market:

- **Related-party lending appears in 17 of 23 institutions** — and 14 of those 17 also involved misreporting or false accounting records. That co-occurrence is the story: money moved to companies the owners controlled, and the books were kept so it did not show.
- **Every institution breached the statutory deadline — all twenty of them.** Act 930 s.105–106 require capital adequacy to be restored within **180 days**, after which the Bank of Ghana *shall* resolve the institution. Median overrun: **5.3×**. Worst: Sterling Financial Services, which reported a capital adequacy ratio of **-1,469% in March 2010**, stopped filing returns two months later, folded in 2011 — and kept its licence until **2019**. That is **19.2×** the statutory maximum.
- **Losses are concentrated, not spread.** Five institutions account for **68%** of the GHS 2.30bn deficit. They were identifiable years in advance.

Liquidity failure — being unable to pay depositors — is cited in 21 of 23 cases. It is the symptom. Related-party extraction is the cause.

### What follows from it

The uncomfortable part is that **the rules already existed**. Act 930 s.64(2) capped related-party exposure at 25% of net own funds — CDH ran at 319%. Sections 104–106 set a 180-day statutory clock for resolving a failing institution, in mandatory terms — and it was missed in **every single case**. On-site examinations identified the problems; six institutions ignored the recommendations with no consequence.

This was a gap between detection and consequence, not a gap in regulation. [FINDINGS.md](FINDINGS.md) sets out six recommendations that follow from it — led not by writing new rules but by **publishing the clock and requiring a justification for every extension** — alongside a table of the reforms Ghana has already implemented since 2018.

> [!NOTE]
> **This is what verification is for.** The first draft recommended creating a statutory intervention deadline. Reading Act 930 showed one already existed, which turned a soft observation — *the regulator was slow* — into a hard, checkable finding: **20 of 20 institutions breached a limit written in the statute, by a median of 5.3×.**

Read the full analysis in **[FINDINGS.md](FINDINGS.md)**.

---

## What's in here

```
data/
  defunct_institutions.csv     418 institutions: category, status, revocation date, receiver, legal basis
  savings_loans_verified.csv    23 savings & loans: financials, dates, 10 coded failure causes, notes
  chartdata.json                shaped for the charts page
  raw/                          text extracted from the BoG PDFs
sources/                        the three Bank of Ghana notices, as published
scripts/
  build_dataset.py              parses the notices -> defunct_institutions.csv
  build_sl_verified.py          the 23 savings & loans, transcribed by hand
docs/sourcing-deposits.md       where deposit and depositor figures do and don't exist
index.html                      the charts, self-contained
```

### `defunct_institutions.csv` — 418 rows

| Category | Count |
|---|---:|
| Microfinance — insolvent | 192 |
| Microfinance — insolvent and ceased operations | 155 |
| Microcredit / money lending | 39 |
| Savings and loans companies | 16 |
| Finance houses | 7 |
| Universal banks | 9 |

Every count reconciles exactly to the totals the Bank of Ghana states in its own notices (192, 155, 29, 10, 23). `build_dataset.py` asserts these on every run — if a parse breaks, the counts stop matching.

> [!NOTE]
> The nine universal banks come from Bank of Ghana press releases rather than a single consolidated notice, and are flagged as such in the `source_document` column. Treat that block as needing verification; the other 409 rows come straight from the three archived notices.

### `savings_loans_verified.csv` — 23 rows

Transcribed **by hand** from Annex 2 of the 16 August 2019 notice. Net worth, capital adequacy ratio, incorporation and licensing dates, date first assessed insolvent, branch counts where stated, ten failure-cause flags, and per-institution notes.

The hand pass exists because an earlier keyword-parsed version got it wrong: it mis-assigned causes, dropped two institutions' figures, and truncated every net-worth number by a digit. At n=23, reading beats parsing. `scripts/build_dataset.py` still produces the automated version so the difference is visible.

---

## Reproducing it

No dependencies beyond Python 3 — standard library only.

```bash
git clone https://github.com/SamuelAtokwamebaah/ghana-banking-collapse.git
cd ghana-banking-collapse/scripts
python build_sl_verified.py    # the 23, hand-verified
python build_dataset.py        # all 418, parsed from the notices
```

To regenerate `data/raw/` from the PDFs in `sources/` (requires `poppler-utils`):

```bash
pdftotext -layout sources/bog-2019-08-16-savings-loans-revocation.pdf \
                 data/raw/bog-2019-08-16-savings-loans-revocation.txt
```

Open `index.html` in any browser for the charts — no server, no internet, no build step.

---

## Method notes

**Failure causes are coded from the regulator's stated reasons**, not inferred. Each of the ten flags is set only where the Bank of Ghana's own text cites it for that institution.

**Blank means blank.** Where a notice gives no figure, the cell is empty — never estimated. Two institutions have no net-worth figure and one reported a *positive* net worth (ASN Financial Services, GHS 628,311) and was revoked anyway.

**The charts use one hue throughout.** None of them needs categorical colour: identity comes from position and direct labels, which makes the whole set colourblind-safe by construction. Contrast was computed against both light and dark surfaces rather than eyeballed. Every chart has a table view.

---

## Caveats

- **n = 23.** These are descriptive findings, not statistical ones. No significance is claimed.
- **Causes reflect what the regulator chose to publish**, in a document written to justify a decision already taken. They may not be exhaustive.
- **"Insolvent since" dates** are sometimes given as a month, sometimes only a year. Year-only dates were read as January, which understates the supervisory lag if anything.
- **Per-institution deposit values and depositor counts are not public** — not in the notices, not on the receiver's site. Sector aggregates are used instead, and [docs/sourcing-deposits.md](docs/sourcing-deposits.md) sets out what exists and where.

---

## Sources

All three primary documents are archived in [`sources/`](sources/).

- Bank of Ghana — [Revocation of licences of insolvent savings and loans companies and finance houses](https://www.bog.gov.gh/wp-content/uploads/2019/08/Revocation-of-Licenses-of-SDIs-16.8.19.pdf), 16 August 2019
- Bank of Ghana — [Revocation of licences of insolvent microfinance companies](https://www.bog.gov.gh/wp-content/uploads/2024/05/NOTICE-OF-REVOCATION-OF-LICENCES-OF-INSOLVENT-MICROFINANCE-COMPANIES-AND-APPOINTMENT-OF-RECEIVER.pdf), 31 May 2019
- Bank of Ghana — [Revocation of licences of insolvent microcredit companies](https://www.bog.gov.gh/wp-content/uploads/2019/07/NOTICE-OF-REVOCATION-OF-LICENCES-OF-INSOLVENT-MICROCREDIT-COMPANIES.pdf), 31 May 2019
- Receiver — [Update on full payments to validated depositors](https://www.ghreceiverships.com/update-on-full-payments-to-depositors-whose-claims-have-been-validated-in-the-resolution-process/), 2 March 2020

---

## Licence

Code and analysis: [MIT](LICENSE). Compiled dataset: CC BY 4.0. The underlying facts are drawn from Bank of Ghana public notices, which remain the Bank's own publications.

## Author

**Samuel Ato Kwame Baah** — Accra, Ghana.
[LinkedIn](https://linkedin.com/in/samuelatokwamebaah)

Built after four and a half years working the receivership that resolved these institutions — including as acting branch manager of one of them.
