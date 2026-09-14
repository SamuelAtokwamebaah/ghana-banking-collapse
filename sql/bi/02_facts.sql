-- BI layer, part 2 of 3: the facts.
--
-- Two fact tables at two different grains, sharing the dimensions in
-- 01_dimensions.sql. Run that file first.

DROP VIEW IF EXISTS fact_cited_causes;
DROP VIEW IF EXISTS fact_institution_snapshot;


-- Grain: one row per institution per cause the Bank of Ghana cites for it.
--
-- This is the unpivot 10_failure_causes.sql performs, kept as a view so that
-- every count of causes, pairs of causes and causes by licence type comes
-- from the same 101 rows. A cause that is not cited has no row. That is a
-- statement about what the notice says, not about what the institution did.
CREATE VIEW fact_cited_causes AS
WITH cited AS (
    SELECT institution_name, 'liquidity_failure'              AS cause_code FROM savings_loans WHERE liquidity_failure              = 'Y'
    UNION ALL
    SELECT institution_name, 'related_party_exposure'                       FROM savings_loans WHERE related_party_exposure         = 'Y'
    UNION ALL
    SELECT institution_name, 'misreporting'                                 FROM savings_loans WHERE misreporting                   = 'Y'
    UNION ALL
    SELECT institution_name, 'high_npl'                                     FROM savings_loans WHERE high_npl                       = 'Y'
    UNION ALL
    SELECT institution_name, 'governance_failure'                           FROM savings_loans WHERE governance_failure             = 'Y'
    UNION ALL
    SELECT institution_name, 'unauthorised_structural_change'               FROM savings_loans WHERE unauthorised_structural_change = 'Y'
    UNION ALL
    SELECT institution_name, 'ignored_bog_recommendations'                  FROM savings_loans WHERE ignored_bog_recommendations    = 'Y'
    UNION ALL
    SELECT institution_name, 'failed_to_publish_accounts'                   FROM savings_loans WHERE failed_to_publish_accounts     = 'Y'
    UNION ALL
    SELECT institution_name, 'stopped_prudential_returns'                   FROM savings_loans WHERE stopped_prudential_returns     = 'Y'
    UNION ALL
    SELECT institution_name, 'ceased_ops_without_approval'                  FROM savings_loans WHERE ceased_ops_without_approval    = 'Y'
)
SELECT
    c.institution_name,
    c.cause_code,
    i.type_key,
    1 AS cited
FROM cited AS c
JOIN dim_institution AS i ON i.institution_name = c.institution_name;


-- Grain: one row per institution, as at the revocation of 16 August 2019.
--
-- Net worth, capital adequacy and their as-at dates are as published. The
-- as-at dates differ: Ideal's figures are end-November 2018, Accent's are
-- February 2019, and Sterling's capital adequacy ratio is March 2010.
--
-- deficit_ghs_m flips the sign so a loss reads as a positive number, as in
-- 13_deficit_concentration.sql. It is NULL for ASN, whose published net worth
-- is positive, and for Sterling, which has no net-worth figure, so 21
-- institutions carry a deficit.
--
-- days_insolvent_upper and days_insolvent_floor are the interval between the
-- stated insolvency date and revocation, on the two readings of a partial
-- date that 12_supervisory_lag.sql sets out:
--
--   upper   year-only as 1 January, month-only as the 1st. The earliest date
--           the notice permits, so the longest interval. These are the
--           published figures.
--   floor   year-only as 31 December, month-only as the last day of the
--           month. The latest date the notice permits, so the shortest.
--
-- Both are NULL for the three institutions with no stated insolvency date.
CREATE VIEW fact_institution_snapshot AS
WITH dated AS (
    SELECT
        institution_name,
        CASE LENGTH(insolvent_since)
            WHEN 4  THEN insolvent_since || '-01-01'
            WHEN 7  THEN insolvent_since || '-01'
            WHEN 10 THEN insolvent_since
        END AS insolvent_date_upper,
        CASE LENGTH(insolvent_since)
            WHEN 4  THEN insolvent_since || '-12-31'
            WHEN 7  THEN date(insolvent_since || '-01', '+1 month', '-1 day')
            WHEN 10 THEN insolvent_since
        END AS insolvent_date_floor
    FROM savings_loans
),
counted AS (
    SELECT institution_name, COUNT(*) AS cited_causes
    FROM fact_cited_causes
    GROUP BY institution_name
)
SELECT
    s.institution_name,
    i.type_key,
    '2019-08-16'                                                             AS revocation_date,
    s.net_worth_ghs_m,
    s.net_worth_as_at,
    CASE WHEN s.net_worth_ghs_m < 0 THEN ROUND(-s.net_worth_ghs_m, 2) END   AS deficit_ghs_m,
    CASE WHEN s.net_worth_ghs_m < 0
         THEN ROW_NUMBER() OVER (ORDER BY CASE WHEN s.net_worth_ghs_m < 0
                                               THEN -s.net_worth_ghs_m END DESC)
    END                                                                      AS deficit_rank,
    s.car_pct,
    s.car_as_at,
    COALESCE(k.cited_causes, 0)                                              AS cited_causes,
    d.insolvent_date_upper,
    d.insolvent_date_floor,
    CAST(julianday('2019-08-16') - julianday(d.insolvent_date_upper) AS INTEGER) AS days_insolvent_upper,
    CAST(julianday('2019-08-16') - julianday(d.insolvent_date_floor) AS INTEGER) AS days_insolvent_floor
FROM savings_loans AS s
JOIN dim_institution AS i ON i.institution_name = s.institution_name
JOIN dated           AS d ON d.institution_name = s.institution_name
LEFT JOIN counted    AS k ON k.institution_name = s.institution_name;


-- Expected:
--
--   fact_cited_causes          101 rows, 38 for finance houses and 63 for
--                              savings and loans
--   fact_institution_snapshot   23 rows; 21 with a deficit, totalling
--                              GHS 2,301.32m, First Allied ranked 1 at 661.84;
--                              20 with an interval, Sterling longest at 3,455
--                              days on the upper reading
