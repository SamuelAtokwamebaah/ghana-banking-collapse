# KPI definitions

Eight headline figures for the 23 savings and loans companies and finance houses revoked on 16 August 2019. Each one is defined here with the query that produces it, its result, and the caveats that go with it.

All eight come from one view, `v_kpis` in [`sql/bi/10_kpis.sql`](../sql/bi/10_kpis.sql). The queries below compute each figure directly from the model described in [`bi-data-model.md`](bi-data-model.md), so a reader can check a figure without trusting the view. Run the model first:

```bash
python scripts/build_sqlite.py
sqlite3 sql/ghana.db < sql/bi/01_dimensions.sql
sqlite3 sql/ghana.db < sql/bi/02_facts.sql
sqlite3 sql/ghana.db < sql/bi/03_marts.sql
sqlite3 sql/ghana.db < sql/bi/10_kpis.sql
sqlite3 sql/ghana.db "SELECT kpi_order, headline, comparison FROM v_kpis"
```

Three rules apply to every KPI:

- **Counts are shown as counts.** "17 of 23", not "74%", wherever the denominator is small enough to matter, which is everywhere here.
- **"Cited" means the Bank of Ghana's notice states it.** A cause the notice does not state is not shown to be absent.
- **Nothing here is a statistical result.** With 23 institutions, and comparison groups of 6 or 7, these figures describe what the regulator said about these institutions. They do not estimate anything about savings and loans companies in general.

| # | KPI | Headline | Read against |
|---|---|---|---|
| 1 | Related-party exposure cited | 17 of 23 | 74% |
| 2 | Liquidity failure cited | 21 of 23 | 91%, the most cited cause |
| 3 | Misreporting, where related-party exposure is cited | 14 of 17 | 1 of 6 where it is not |
| 4 | Liquidity failure, where related-party exposure is cited | 15 of 17 | 6 of 6 where it is not |
| 5 | Average causes cited per institution | 4.4 | Finance houses 5.4, savings and loans 3.9 |
| 6 | Median days licensed while insolvent | 927.5 days | 791.5 days on the conservative date reading |
| 7 | Share of the deficit held by the five largest | 68% | of GHS 2,301.32m, across 21 institutions |
| 8 | Closures with itemised causes and financials | 23 of 418 | all closures, 2017 to 2019 |

---

## 1. Related-party exposure cited

**Definition.** Institutions for which the notice cites related-party exposure, out of all 23.

```sql
SELECT COUNT(*) AS cited,
       (SELECT COUNT(*) FROM dim_institution) AS institutions
FROM fact_cited_causes
WHERE cause_code = 'related_party_exposure';
```

**Result.** 17 of 23, 74%. Reproduces chart 1 and finding 1.

**Caveats.**
- The notice was written to justify revocations already decided. It is the regulator's account, not an independent finding.
- The six without it are not shown to have had no related-party lending, only that the notice does not cite it.

## 2. Liquidity failure cited

**Definition.** Institutions for which the notice cites liquidity failure, out of all 23.

```sql
SELECT COUNT(*) AS cited,
       (SELECT COUNT(*) FROM dim_institution) AS institutions
FROM fact_cited_causes
WHERE cause_code = 'liquidity_failure';
```

**Result.** 21 of 23, 91%, the most cited of the ten causes.

**Caveats.**
- Because it is cited for almost every institution, it appears alongside almost every other cause. A high co-occurrence count with liquidity failure says little on its own. See KPI 4.
- Express and First African are the two without it. Both have stated insolvency dates and deficits, so its absence from the notice does not mean they were liquid.

## 3. Misreporting, where related-party exposure is cited

**Definition.** Of the institutions citing related-party exposure, how many also cite misreporting. Read against the same rate among institutions that do not cite related-party exposure.

```sql
SELECT cited_both, cited_a, b_without_a, not_a
FROM v_cause_cooccurrence
WHERE cause_a = 'related_party_exposure'
  AND cause_b = 'misreporting';
```

**Result.** 14 of 17 (82%), against 1 of 6 (17%) where related-party exposure is not cited. Reproduces chart 2 and `11_cooccurrence.sql`.

**Caveats.**
- This is the pairing that separates the two groups, and it is the one README and FINDINGS lead with.
- Co-occurrence is not causation. The notice does not say one led to the other, and the order in which the two happened is not recorded.
- The comparison group is 6 institutions. One institution more or less moves its rate by 17 percentage points.

## 4. Liquidity failure, where related-party exposure is cited

**Definition.** Of the institutions citing related-party exposure, how many also cite liquidity failure. Read against the same rate among institutions that do not.

```sql
SELECT cited_both, cited_a, b_without_a, not_a
FROM v_cause_cooccurrence
WHERE cause_a = 'related_party_exposure'
  AND cause_b = 'liquidity_failure';
```

**Result.** 15 of 17 (88%), against 6 of 6 (100%) where related-party exposure is not cited.

**Caveats.**
- **This KPI is here because it does not support the obvious story.** The charts page reads liquidity failure as the symptom and related-party lending as the cause. The data is consistent with that reading, but it does not show it: liquidity failure is cited in every institution without related-party exposure, so the two groups do not differ on it.
- What the data does show is KPI 3. A reader who takes one figure from this dashboard to support the causal reading should take that one, with its caveats.

## 5. Average causes cited per institution

**Definition.** Cited causes divided by institutions, overall and by licence type.

```sql
SELECT t.licence_type,
       COUNT(f.cause_code)                                AS cited_causes,
       COUNT(DISTINCT i.institution_name)                 AS institutions,
       ROUND(COUNT(f.cause_code) * 1.0
             / COUNT(DISTINCT i.institution_name), 2)     AS average
FROM dim_institution i
JOIN dim_institution_type t   ON t.type_key = i.type_key
LEFT JOIN fact_cited_causes f ON f.institution_name = i.institution_name
GROUP BY t.licence_type
UNION ALL
SELECT 'All',
       (SELECT COUNT(*) FROM fact_cited_causes),
       (SELECT COUNT(*) FROM dim_institution),
       ROUND((SELECT COUNT(*) FROM fact_cited_causes) * 1.0
             / (SELECT COUNT(*) FROM dim_institution), 2);
```

**Result.** 101 cited causes across 23 institutions, 4.39, shown as 4.4. Finance houses 38 across 7, 5.43. Savings and loans 63 across 16, 3.94.

**Caveats.**
- A count of what the notice states, not a measure of how badly an institution failed. First Ghana has 2 cited causes and IFS 2; Dream has 7. The notice may simply say more about some institutions than others.
- Finance houses number 7. The gap between 5.4 and 3.9 is a description of these 7 and these 16.
- The comment at the top of `sql/10_failure_causes.sql` gave the average as 4.0 until it was corrected to 4.39. The query's results were never affected.

## 6. Median days licensed while insolvent

**Definition.** For institutions with a stated insolvency date, the median number of days from that date to revocation on 16 August 2019. The median of an even count is the mean of the middle two values.

```sql
WITH ranked AS (
    SELECT days_insolvent_upper AS upper_days,
           days_insolvent_floor AS floor_days,
           ROW_NUMBER() OVER (ORDER BY days_insolvent_upper) AS rn_upper,
           ROW_NUMBER() OVER (ORDER BY days_insolvent_floor) AS rn_floor,
           COUNT(*)     OVER ()                              AS n
    FROM fact_institution_snapshot
    WHERE days_insolvent_upper IS NOT NULL
)
SELECT MAX(n)                                                                         AS dated,
       AVG(CASE WHEN rn_upper IN ((n + 1) / 2, (n + 2) / 2) THEN upper_days END)      AS median_upper,
       AVG(CASE WHEN rn_floor IN ((n + 1) / 2, (n + 2) / 2) THEN floor_days END)      AS median_floor
FROM ranked;
```

**Result.** 20 of 23 dated. Median 927.5 days on the published reading, 791.5 on the conservative one. Reproduces chart 3 and `12_supervisory_lag.sql`.

**Caveats.**
- **Two readings, and the published one is the longer.** Where the notice gives only a year, the published figure reads it as 1 January; where it gives only a month, as the 1st. That is the earliest date the notice permits, so it gives the longest interval. Reading them as 31 December and the month's last day gives 791.5. The truth lies somewhere between, for each institution.
- **Not a breach of any deadline.** Act 930 attaches no period to the duty to revoke in s.123(1). An earlier version of this project described these intervals as breaches of a 180-day deadline, and that claim was withdrawn. See `12_supervisory_lag.sql`.
- **Not a warning-to-revocation measure.** The notice does not say when the Bank of Ghana first identified each problem.
- Commerz, First Ghana and GN have no stated insolvency date and are excluded, not estimated.
- Four of the 20 state an insolvency date before Act 930 received assent on 14 September 2016.

## 7. Share of the deficit held by the five largest

**Definition.** The combined net-worth deficit of the five institutions with the largest deficits, as a share of the total deficit across all institutions with one.

```sql
SELECT ROUND(SUM(CASE WHEN deficit_rank <= 5 THEN deficit_ghs_m END), 2) AS top_5_ghs_m,
       ROUND(SUM(deficit_ghs_m), 2)                                      AS total_ghs_m,
       COUNT(*)                                                          AS institutions,
       ROUND(SUM(CASE WHEN deficit_rank <= 5 THEN deficit_ghs_m END) * 100.0
             / SUM(deficit_ghs_m), 1)                                    AS top_5_share_pct
FROM fact_institution_snapshot
WHERE deficit_ghs_m IS NOT NULL;
```

**Result.** GHS 1,563.88m of GHS 2,301.32m, 68.0%, across 21 institutions. The five are First Allied, Dream, Unicredit, FirstTrust and CDH. Reproduces chart 4 and `13_deficit_concentration.sql`.

**Caveats.**
- Net worth is as published, and not all at one date. Nineteen of the 21 are as at May 2019; Accent's is February 2019 and Ideal's November 2018.
- ASN reported a positive net worth and Sterling none, so both are outside the 21.
- A net-worth deficit is not the cost of the resolution and is not comparable with depositor claims. See [`sourcing-deposits.md`](sourcing-deposits.md).

## 8. Closures with itemised causes and financials

**Definition.** Institutions in the model, out of every institution closed in the 2017 to 2019 clean-up.

```sql
SELECT (SELECT COUNT(*) FROM dim_institution)       AS in_model,
       (SELECT COUNT(*) FROM defunct_institutions)  AS all_closures;
```

**Result.** 23 of 418.

**Caveats.**
- **Every other KPI covers these 23 only.** The other 395, 347 microfinance companies, 39 microcredit companies and 9 universal banks, carry a status such as "Insolvent" but no itemised causes or financials in the notices this project uses.
- The 23 are not a sample of the 418. They are the institutions for which the Bank of Ghana published its reasons one by one, so nothing here should be read across to the microfinance companies or the banks.
