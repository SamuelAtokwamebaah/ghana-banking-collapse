-- Q3. How long did each institution stay licensed after the Bank of Ghana
--     says it became insolvent — and how does that compare with the deadline
--     the statute sets?
--
-- Reproduces: chart 3 on the charts page, and finding 3 in FINDINGS.md.
--
-- THE STATUTORY TEST
-- Banks and Specialised Deposit-Taking Institutions Act, 2016 (Act 930):
--   s.105(2)(b)  capital restoration plan within 45 days; capital adequacy
--                restored within 180 days
--   s.106(1)(b)  90 days to rectify, 180 days to restore
--   s.106(3)     on failure, the Bank of Ghana "shall, without having to wait
--                for the expiry of that period", place the institution into
--                official administration or revoke its licence
--
-- The wording is mandatory, not discretionary. 180 days is therefore not a
-- target; it is a limit. This query measures every institution against it.
--
-- NORMALISING THE DATE
-- The notice gives some insolvency dates as a month ('2017-03') and some as a
-- year only ('1997'). Year-only dates are read as 1 January, which makes the
-- lag as SHORT as the source permits — the conservative direction. Three
-- institutions have no stated date at all and are excluded rather than guessed.

WITH lag AS (
    SELECT
        institution_name,
        insolvent_since,
        CASE LENGTH(insolvent_since)
            WHEN 4 THEN insolvent_since || '-01-01'
            WHEN 7 THEN insolvent_since || '-01'
        END AS insolvent_date
    FROM savings_loans
    WHERE insolvent_since IS NOT NULL
),
measured AS (
    SELECT
        institution_name,
        insolvent_since,
        CAST(julianday('2019-08-16') - julianday(insolvent_date) AS INTEGER) AS days_licensed_while_insolvent
    FROM lag
)
SELECT
    institution_name,
    insolvent_since,
    days_licensed_while_insolvent                                AS days,
    ROUND(days_licensed_while_insolvent / 365.25, 1)             AS years,
    ROUND(days_licensed_while_insolvent / 180.0, 1) || 'x'       AS vs_statutory_limit,
    CASE WHEN days_licensed_while_insolvent > 180
         THEN 'BREACH' ELSE 'within limit' END                   AS s105_106
FROM measured
ORDER BY days DESC;

-- Expected: 20 rows, every one of them 'BREACH'. Sterling Financial Services
-- tops it at 3,455 days — insolvent from March 2010, licence revoked in 2019.
-- That is 19.2x the statutory maximum.


-- 3b. The summary, which is the finding.
WITH lag AS (
    SELECT
        CASE LENGTH(insolvent_since)
            WHEN 4 THEN insolvent_since || '-01-01'
            WHEN 7 THEN insolvent_since || '-01'
        END AS insolvent_date
    FROM savings_loans
    WHERE insolvent_since IS NOT NULL
),
measured AS (
    SELECT julianday('2019-08-16') - julianday(insolvent_date) AS days FROM lag
),
ranked AS (
    SELECT days,
           ROW_NUMBER() OVER (ORDER BY days) AS rn,
           COUNT(*)    OVER ()               AS n
    FROM measured
)
SELECT
    (SELECT COUNT(*) FROM savings_loans)                                  AS institutions_total,
    (SELECT COUNT(*) FROM measured)                                       AS with_stated_date,
    (SELECT COUNT(*) FROM measured WHERE days > 180)                      AS breached_180_days,
    (SELECT ROUND(MIN(days) / 180.0, 1) FROM measured) || 'x'             AS smallest_overrun,
    ROUND(AVG(days) / 180.0, 1) || 'x'                                    AS median_overrun,
    (SELECT ROUND(MAX(days) / 180.0, 1) FROM measured) || 'x'             AS largest_overrun
FROM ranked
WHERE rn IN ((n + 1) / 2, (n + 2) / 2);   -- median: middle value, or mean of the middle two

-- Expected: 23 institutions, 20 with a stated date, 20 breaches — 100%.
-- Median overrun 5.2x. Smallest 1.4x. Largest 19.2x.
--
-- Not one institution was resolved inside the period the statute allows, and
-- the closest was still 1.4 times over it. That is the difference
-- between "the regulator was slow", which is an opinion, and "every one of
-- them breached a limit written in the Act", which is arithmetic.
