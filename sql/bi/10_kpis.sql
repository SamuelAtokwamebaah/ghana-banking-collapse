-- BI layer: the headline KPIs.
--
-- One row per KPI, in the order the dashboard shows them. Each is defined,
-- with its caveats, in docs/kpi-definitions.md. Run 01_dimensions.sql,
-- 02_facts.sql and 03_marts.sql first.
--
-- Columns:
--
--   kpi_order, kpi_code, kpi_label
--   numerator, denominator   the two counts or sums the KPI is made of
--   value                    the KPI as a number, unrounded beyond 4 places
--   headline                 the KPI as it is displayed, "17 of 23"
--   comparison               the figure it must be read against
--   note                     the one caveat that matters most
--
-- The headline and comparison are built here, not in the dashboard, so the
-- text on each card is the output of this query and nothing else.

DROP VIEW IF EXISTS v_kpis;

CREATE VIEW v_kpis AS
WITH
total AS (
    SELECT COUNT(*) AS n FROM dim_institution
),
cause AS (
    SELECT cause_code, COUNT(*) AS n
    FROM fact_cited_causes
    GROUP BY cause_code
),
pair AS (
    SELECT * FROM v_cause_cooccurrence
),
by_type AS (
    SELECT t.type_key, t.licence_type,
           COUNT(DISTINCT i.institution_name)                                    AS institutions,
           (SELECT COUNT(*) FROM fact_cited_causes f WHERE f.type_key = t.type_key) AS cited
    FROM dim_institution_type t
    JOIN dim_institution i ON i.type_key = t.type_key
    GROUP BY t.type_key, t.licence_type
),
-- Median of the stated insolvency intervals, on both date readings. Same
-- rule as 12_supervisory_lag.sql: the middle value, or the mean of the
-- middle two.
lag_upper AS (
    SELECT days_insolvent_upper AS d,
           ROW_NUMBER() OVER (ORDER BY days_insolvent_upper) AS rn,
           COUNT(*)     OVER ()                              AS n
    FROM fact_institution_snapshot
    WHERE days_insolvent_upper IS NOT NULL
),
lag_floor AS (
    SELECT days_insolvent_floor AS d,
           ROW_NUMBER() OVER (ORDER BY days_insolvent_floor) AS rn,
           COUNT(*)     OVER ()                              AS n
    FROM fact_institution_snapshot
    WHERE days_insolvent_floor IS NOT NULL
),
lag AS (
    SELECT
        (SELECT MAX(n) FROM lag_upper)                                                AS n,
        (SELECT AVG(d) FROM lag_upper WHERE rn IN ((n + 1) / 2, (n + 2) / 2))         AS median_upper,
        (SELECT AVG(d) FROM lag_floor WHERE rn IN ((n + 1) / 2, (n + 2) / 2))         AS median_floor
),
deficit AS (
    SELECT
        COUNT(*)                                                         AS n,
        ROUND(SUM(deficit_ghs_m), 2)                                     AS total,
        ROUND(SUM(CASE WHEN deficit_rank <= 5 THEN deficit_ghs_m END), 2) AS top5
    FROM fact_institution_snapshot
    WHERE deficit_ghs_m IS NOT NULL
),
closures AS (
    SELECT COUNT(*) AS n FROM defunct_institutions
),
kpi AS (
    SELECT
        1                                    AS kpi_order,
        'related_party_cited'                AS kpi_code,
        'Related-party exposure cited'       AS kpi_label,
        c.n                                  AS numerator,
        t.n                                  AS denominator,
        ROUND(c.n * 1.0 / t.n, 4)            AS value,
        c.n || ' of ' || t.n                 AS headline,
        CAST(ROUND(c.n * 100.0 / t.n) AS INTEGER) || '% of the institutions revoked on 16 August 2019' AS comparison,
        'Cited in the notice. A cause not cited is not shown absent.' AS note
    FROM cause c, total t
    WHERE c.cause_code = 'related_party_exposure'

    UNION ALL
    SELECT
        2, 'liquidity_cited', 'Liquidity failure cited',
        c.n, t.n, ROUND(c.n * 1.0 / t.n, 4),
        c.n || ' of ' || t.n,
        CAST(ROUND(c.n * 100.0 / t.n) AS INTEGER) || '%, the most cited of the ten causes',
        'Cited alongside almost every other cause, so on its own it tells one institution from another very little.'
    FROM cause c, total t
    WHERE c.cause_code = 'liquidity_failure'

    UNION ALL
    SELECT
        3, 'misreporting_given_related_party', 'Misreporting, where related-party exposure is cited',
        p.cited_both, p.cited_a, p.share_b_given_a,
        p.cited_both || ' of ' || p.cited_a,
        'against ' || p.b_without_a || ' of ' || p.not_a || ' where it is not',
        'Groups of ' || p.cited_a || ' and ' || p.not_a || '. A description of these institutions, not a statistical result.'
    FROM pair p
    WHERE p.cause_a = 'related_party_exposure' AND p.cause_b = 'misreporting'

    UNION ALL
    SELECT
        4, 'liquidity_given_related_party', 'Liquidity failure, where related-party exposure is cited',
        p.cited_both, p.cited_a, p.share_b_given_a,
        p.cited_both || ' of ' || p.cited_a,
        'against ' || p.b_without_a || ' of ' || p.not_a || ' where it is not',
        'Liquidity failure is cited at least as often without related-party exposure, so this pairing does not separate the two groups.'
    FROM pair p
    WHERE p.cause_a = 'related_party_exposure' AND p.cause_b = 'liquidity_failure'

    UNION ALL
    SELECT
        5, 'mean_cited_causes', 'Average causes cited per institution',
        (SELECT COUNT(*) FROM fact_cited_causes), t.n,
        ROUND((SELECT COUNT(*) FROM fact_cited_causes) * 1.0 / t.n, 4),
        printf('%.1f', (SELECT COUNT(*) FROM fact_cited_causes) * 1.0 / t.n),
        (SELECT 'Finance houses ' || printf('%.1f', cited * 1.0 / institutions) FROM by_type WHERE type_key = 'finance_house')
            || ', savings and loans '
            || (SELECT printf('%.1f', cited * 1.0 / institutions) FROM by_type WHERE type_key = 'savings_and_loans'),
        'A count of what the notice states for each institution, not a measure of severity.'
    FROM total t

    UNION ALL
    SELECT
        6, 'median_days_insolvent', 'Median days licensed while insolvent',
        l.n, t.n, ROUND(l.median_upper, 1),
        CASE WHEN l.median_upper = CAST(l.median_upper AS INTEGER)
             THEN printf('%,d', CAST(l.median_upper AS INTEGER))
             ELSE printf('%,d', CAST(l.median_upper AS INTEGER)) || substr(printf('%.1f', l.median_upper), -2)
        END || ' days',
        CASE WHEN l.median_floor = CAST(l.median_floor AS INTEGER)
             THEN printf('%,d', CAST(l.median_floor AS INTEGER))
             ELSE printf('%,d', CAST(l.median_floor AS INTEGER)) || substr(printf('%.1f', l.median_floor), -2)
        END || ' days on the conservative date reading',
        l.n || ' of ' || t.n || ' have a stated insolvency date. Year-only dates read as 1 January.'
    FROM lag l, total t

    UNION ALL
    SELECT
        7, 'top5_deficit_share', 'Share of the deficit held by the five largest',
        d.top5, d.total, ROUND(d.top5 / d.total, 4),
        CAST(ROUND(d.top5 * 100.0 / d.total) AS INTEGER) || '%',
        'of GHS ' || printf('%,d', CAST(d.total AS INTEGER)) || substr(printf('%.2f', d.total), -3)
            || 'm, across ' || d.n || ' institutions with a deficit',
        'Net worth is as published, mostly as at May 2019. ASN reported a positive net worth and Sterling none.'
    FROM deficit d

    UNION ALL
    SELECT
        8, 'scope', 'Closures with itemised causes and financials',
        t.n, k.n, ROUND(t.n * 1.0 / k.n, 4),
        t.n || ' of ' || k.n,
        'institutions closed in the 2017 to 2019 clean-up',
        'The other ' || (k.n - t.n) || ' carry a status, such as insolvent, but no itemised causes, so everything else here covers ' || t.n || ' institutions.'
    FROM total t, closures k
)
SELECT kpi_order, kpi_code, kpi_label, numerator, denominator, value, headline, comparison, note
FROM kpi;


-- Expected:
--
--   1  related_party_cited               17 of 23      74%
--   2  liquidity_cited                   21 of 23      91%
--   3  misreporting_given_related_party  14 of 17      against 1 of 6
--   4  liquidity_given_related_party     15 of 17      against 6 of 6
--   5  mean_cited_causes                 4.4           finance houses 5.4, savings and loans 3.9
--   6  median_days_insolvent             927.5 days    791.5 days on the conservative reading
--   7  top5_deficit_share                68%           of GHS 2,301.32m, across 21
--   8  scope                             23 of 418
