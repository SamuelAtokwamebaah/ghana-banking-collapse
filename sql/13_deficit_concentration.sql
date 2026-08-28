-- Q4. How concentrated are the losses?
--
-- Reproduces: chart 4 on the charts page, and finding 4 in FINDINGS.md.
--
-- Net worth is stored as published: negative means a deficit. This query
-- flips the sign so the figures read as losses, which is how they are
-- discussed everywhere else in the project.
--
-- Two institutions have no net-worth figure in the notice and are excluded.
-- One — ASN Financial Services — reported a POSITIVE net worth of
-- GHS 628,311 and had its licence revoked anyway, so it is not a deficit and
-- does not belong in a total of deficits. That leaves 21.

WITH deficits AS (
    SELECT
        institution_name,
        licence_type,
        -net_worth_ghs_m AS deficit_ghs_m
    FROM savings_loans
    WHERE net_worth_ghs_m IS NOT NULL
      AND net_worth_ghs_m < 0
),
ranked AS (
    SELECT
        institution_name,
        licence_type,
        deficit_ghs_m,
        ROW_NUMBER() OVER (ORDER BY deficit_ghs_m DESC)                 AS rank,
        SUM(deficit_ghs_m) OVER (ORDER BY deficit_ghs_m DESC)           AS running_total,
        SUM(deficit_ghs_m) OVER ()                                      AS grand_total
    FROM deficits
)
SELECT
    rank,
    institution_name,
    licence_type,
    ROUND(deficit_ghs_m, 2)                                       AS deficit_ghs_m,
    ROUND(deficit_ghs_m * 100.0 / grand_total, 1) || '%'          AS share,
    ROUND(running_total * 100.0 / grand_total, 1) || '%'          AS cumulative_share
FROM ranked
ORDER BY rank;

-- Expected: 21 rows totalling GHS 2,301.32m. The cumulative share passes 68%
-- at rank 5 and 50% at rank 3.


-- 4b. The concentration, stated directly.
WITH deficits AS (
    SELECT -net_worth_ghs_m AS deficit_ghs_m
    FROM savings_loans
    WHERE net_worth_ghs_m IS NOT NULL AND net_worth_ghs_m < 0
),
ranked AS (
    SELECT deficit_ghs_m, ROW_NUMBER() OVER (ORDER BY deficit_ghs_m DESC) AS rank
    FROM deficits
)
SELECT
    COUNT(*)                                                                       AS institutions_with_deficit,
    ROUND(SUM(deficit_ghs_m), 2)                                                   AS total_deficit_ghs_m,
    ROUND(SUM(CASE WHEN rank <= 5 THEN deficit_ghs_m ELSE 0 END), 2)               AS top_5_ghs_m,
    ROUND(SUM(CASE WHEN rank <= 5 THEN deficit_ghs_m ELSE 0 END)
          * 100.0 / SUM(deficit_ghs_m), 0) || '%'                                  AS top_5_share
FROM ranked;

-- Expected: 21 institutions, GHS 2,301.32m total, five of them accounting for
-- roughly 68% of it.
--
-- Why it matters: supervisory attention spread evenly across 400+ institutions
-- guarantees that the largest exposures get proportionally the least scrutiny.
-- These five were identifiable years ahead — see 12_supervisory_lag.sql.
