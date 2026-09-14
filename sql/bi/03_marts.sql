-- BI layer, part 3 of 3: the marts.
--
-- Aggregations over the facts, shaped for the questions the dashboard asks.
-- Each mart is reproducible from the facts by hand, and each says here what it
-- can and cannot show. Run 01_dimensions.sql and 02_facts.sql first.

DROP VIEW IF EXISTS v_cause_cooccurrence;
DROP VIEW IF EXISTS v_cause_by_type;
DROP VIEW IF EXISTS v_lag_by_cause;


-- Every ordered pair of causes, 10 x 10 = 100 rows, including the pairs no
-- institution shares, so the matrix has no silent gaps.
--
--   cited_a              institutions citing cause A
--   cited_both           of those, how many also cite cause B
--   share_b_given_a      cited_both / cited_a
--   not_a                institutions not citing A
--   b_without_a          of those, how many cite B
--   share_b_given_not_a  b_without_a / not_a, NULL where no institution is
--                        without A
--
-- The last three columns are the comparison that makes a co-occurrence count
-- mean anything. Liquidity failure is cited alongside related-party exposure
-- in 15 of 17 cases, which looks like a strong link until the other side
-- reads 6 of 6: liquidity failure is cited almost everywhere. Misreporting
-- does separate the two groups, 14 of 17 against 1 of 6.
--
-- On the diagonal A and B are the same cause, so cited_both = cited_a.
--
-- Co-occurrence is not causation, and with 17 and 6 institutions in the two
-- groups no difference here is a statistical result.
CREATE VIEW v_cause_cooccurrence AS
WITH total AS (
    SELECT COUNT(*) AS n FROM dim_institution
),
per_cause AS (
    SELECT cause_code, COUNT(*) AS n
    FROM fact_cited_causes
    GROUP BY cause_code
),
pair AS (
    SELECT a.cause_code AS cause_a, b.cause_code AS cause_b, COUNT(*) AS n
    FROM fact_cited_causes AS a
    JOIN fact_cited_causes AS b ON b.institution_name = a.institution_name
    GROUP BY a.cause_code, b.cause_code
),
grid AS (
    SELECT
        ca.cause_code                      AS cause_a,
        cb.cause_code                      AS cause_b,
        ca.sort_order                      AS sort_a,
        cb.sort_order                      AS sort_b,
        total.n                            AS institutions,
        COALESCE(pa.n, 0)                  AS cited_a,
        COALESCE(pb.n, 0)                  AS cited_b,
        COALESCE(pair.n, 0)                AS cited_both
    FROM dim_cause AS ca
    CROSS JOIN dim_cause AS cb
    CROSS JOIN total
    LEFT JOIN per_cause AS pa   ON pa.cause_code = ca.cause_code
    LEFT JOIN per_cause AS pb   ON pb.cause_code = cb.cause_code
    LEFT JOIN pair              ON pair.cause_a = ca.cause_code AND pair.cause_b = cb.cause_code
)
SELECT
    cause_a,
    cause_b,
    sort_a,
    sort_b,
    institutions,
    cited_a,
    cited_both,
    CASE WHEN cited_a > 0
         THEN ROUND(cited_both * 1.0 / cited_a, 4) END                        AS share_b_given_a,
    institutions - cited_a                                                     AS not_a,
    cited_b - cited_both                                                       AS b_without_a,
    CASE WHEN institutions - cited_a > 0
         THEN ROUND((cited_b - cited_both) * 1.0 / (institutions - cited_a), 4) END AS share_b_given_not_a
FROM grid;


-- Each cause by licence type, 10 x 2 = 20 rows, zeros included.
--
-- There are 16 savings and loans companies and 7 finance houses. A difference
-- of one or two institutions in a group of 7 moves the share by 14 to 29
-- percentage points, so read the counts, not the percentages.
CREATE VIEW v_cause_by_type AS
WITH type_size AS (
    SELECT type_key, COUNT(*) AS n
    FROM dim_institution
    GROUP BY type_key
),
cited AS (
    SELECT cause_code, type_key, COUNT(*) AS n
    FROM fact_cited_causes
    GROUP BY cause_code, type_key
)
SELECT
    c.cause_code,
    c.sort_order                                            AS cause_sort,
    t.type_key,
    t.licence_type,
    t.sort_order                                            AS type_sort,
    COALESCE(k.n, 0)                                        AS cited,
    COALESCE(z.n, 0)                                        AS institutions_of_type,
    CASE WHEN z.n > 0 THEN ROUND(COALESCE(k.n, 0) * 1.0 / z.n, 4) END AS share
FROM dim_cause AS c
CROSS JOIN dim_institution_type AS t
LEFT JOIN type_size AS z ON z.type_key = t.type_key
LEFT JOIN cited     AS k ON k.cause_code = c.cause_code AND k.type_key = t.type_key;


-- Days licensed while insolvent, split by whether each cause is cited.
-- 10 causes x {cited, not cited} = 20 rows.
--
-- EXPLORATORY. Only the 20 institutions with a stated insolvency date are
-- included. For most causes one side of the split holds a handful of
-- institutions, and liquidity failure's "not cited" side holds two, so a
-- median here describes those few and nothing wider. n is reported on every
-- row for that reason.
--
-- This is not a warning-to-revocation measure. The notice gives no date on
-- which the Bank of Ghana first identified a problem, so the only interval
-- the record supports is stated insolvency to revocation, as in
-- 12_supervisory_lag.sql. Medians are given on both date readings; see
-- fact_institution_snapshot for the difference.
CREATE VIEW v_lag_by_cause AS
WITH dated AS (
    SELECT institution_name, days_insolvent_upper AS upper_days, days_insolvent_floor AS floor_days
    FROM fact_institution_snapshot
    WHERE days_insolvent_upper IS NOT NULL
),
split AS (
    SELECT
        c.cause_code,
        CASE WHEN f.institution_name IS NOT NULL THEN 'cited' ELSE 'not cited' END AS cause_status,
        d.institution_name,
        d.upper_days,
        d.floor_days
    FROM dim_cause AS c
    CROSS JOIN dated AS d
    LEFT JOIN fact_cited_causes AS f
           ON f.cause_code = c.cause_code AND f.institution_name = d.institution_name
),
ranked AS (
    SELECT
        cause_code,
        cause_status,
        upper_days,
        floor_days,
        ROW_NUMBER() OVER (PARTITION BY cause_code, cause_status ORDER BY upper_days) AS rn_upper,
        ROW_NUMBER() OVER (PARTITION BY cause_code, cause_status ORDER BY floor_days) AS rn_floor,
        COUNT(*)     OVER (PARTITION BY cause_code, cause_status)                     AS n
    FROM split
),
-- Median: the middle value, or the mean of the middle two. Same rule as
-- 12_supervisory_lag.sql, applied to each group.
median_upper AS (
    SELECT cause_code, cause_status, AVG(upper_days) AS m
    FROM ranked
    WHERE rn_upper IN ((n + 1) / 2, (n + 2) / 2)
    GROUP BY cause_code, cause_status
),
median_floor AS (
    SELECT cause_code, cause_status, AVG(floor_days) AS m
    FROM ranked
    WHERE rn_floor IN ((n + 1) / 2, (n + 2) / 2)
    GROUP BY cause_code, cause_status
),
agg AS (
    SELECT cause_code, cause_status, COUNT(*) AS n,
           MIN(upper_days) AS shortest_upper, MAX(upper_days) AS longest_upper
    FROM split
    GROUP BY cause_code, cause_status
),
frame AS (
    SELECT c.cause_code, c.sort_order, s.cause_status, s.status_sort
    FROM dim_cause AS c
    CROSS JOIN (SELECT 'cited' AS cause_status, 1 AS status_sort
                UNION ALL
                SELECT 'not cited', 2) AS s
)
SELECT
    fr.cause_code,
    fr.sort_order                    AS cause_sort,
    fr.cause_status,
    fr.status_sort,
    COALESCE(a.n, 0)                 AS institutions,
    ROUND(mu.m, 1)                   AS median_days_upper,
    ROUND(mf.m, 1)                   AS median_days_floor,
    a.shortest_upper                 AS shortest_days_upper,
    a.longest_upper                  AS longest_days_upper
FROM frame AS fr
LEFT JOIN agg          AS a  ON a.cause_code  = fr.cause_code AND a.cause_status  = fr.cause_status
LEFT JOIN median_upper AS mu ON mu.cause_code = fr.cause_code AND mu.cause_status = fr.cause_status
LEFT JOIN median_floor AS mf ON mf.cause_code = fr.cause_code AND mf.cause_status = fr.cause_status;


-- Expected, for the pairs the project's argument rests on:
--
--   v_cause_cooccurrence
--     related_party_exposure -> misreporting        14 of 17, against 1 of 6
--     related_party_exposure -> liquidity_failure   15 of 17, against 6 of 6
--
--   v_cause_by_type
--     related_party_exposure    Savings and Loans 10 of 16, Finance House 7 of 7
--
--   v_lag_by_cause
--     ignored_bog_recommendations      cited n = 6,  median 1,186 days;
--                                      not cited n = 14, median 639 days
--     unauthorised_structural_change   cited n = 6,  median 1,505.5 days;
--                                      not cited n = 14, median 714.5 days
--                                      (7 institutions cite it, but GN has no
--                                      stated insolvency date)
--     every cause's two rows sum to 20 institutions
