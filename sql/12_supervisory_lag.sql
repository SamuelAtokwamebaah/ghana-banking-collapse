-- Q3. How long did each institution stay licensed after the Bank of Ghana
--     says it became insolvent?
--
-- Reproduces: chart 3 on the charts page, and finding 2 in FINDINGS.md.
--
-- WHAT THIS MEASURES, AND WHAT IT DOES NOT
-- This query measures one interval: the date the Bank of Ghana states an
-- institution became insolvent, against 16 August 2019, when it revoked the
-- licence. That interval is a fact about the public record.
--
-- It is NOT a measure of any statutory deadline, and an earlier version of this
-- project wrongly described it as one. The correction is set out here because
-- the error is instructive.
--
-- WHY 180 DAYS IS NOT THE BENCHMARK
-- Act 930 does contain 180-day periods, but neither runs from insolvency:
--
--   s.105(2)(b)  capital adequacy restored "within one hundred and eighty days
--                of making that order" -- the clock runs from a Bank of Ghana
--                ORDER
--   s.106(1)(b)  90 days to rectify and 180 to restore, under an agreement with
--                the institution's board -- the clock runs from that AGREEMENT
--
-- Both periods begin only after a supervisory act. No public document shows
-- that either was made in respect of these institutions, so on the available
-- evidence no 180-day period ever started, and a period that never started
-- cannot be breached. Insolvency is not the trigger either section names.
--
-- A SECOND REASON THE OLD FRAMING FAILED
-- Act 930 received assent on 14 September 2016. Sterling's stated insolvency is
-- March 2010; Crest, Dream and FirstTrust are 2015. Those four cannot be
-- measured against a statute that did not yet exist. Two more, Express and
-- Global Access, are recorded as '2016' with no month, and cannot be placed on
-- either side of the assent date.
--
-- WHAT THE ACT DOES OBLIGE
-- s.123(1) requires the Bank of Ghana to revoke a licence where it determines
-- the institution is insolvent or likely to become insolvent within 60 days.
-- That duty was plainly engaged. The Act attaches no deadline to it, which is
-- the more interesting finding: the intervals below are not evidence of a
-- breached deadline, they are evidence that no deadline exists.
--
-- NORMALISING THE DATE
-- The notice gives some insolvency dates as a month ('2017-03') and some as a
-- year only ('2015'). Year-only dates are read as 1 January, which makes the
-- interval as SHORT as the source permits, the conservative direction. Three
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
        insolvent_date,
        CAST(julianday('2019-08-16') - julianday(insolvent_date) AS INTEGER) AS days_licensed_while_insolvent
    FROM lag
)
SELECT
    institution_name,
    insolvent_since,
    days_licensed_while_insolvent                                AS days,
    ROUND(days_licensed_while_insolvent / 365.25, 1)             AS years,
    -- Flags rows whose stated insolvency predates Act 930 entirely. Kept as a
    -- column rather than a filter: the interval is still a fact, it simply
    -- cannot be read against this statute.
    -- Order matters: a year-only '2016' normalises to 1 January and would
    -- otherwise be mislabelled as certainly pre-Act, when in truth it cannot be
    -- placed on either side of the 14 September 2016 assent.
    CASE WHEN insolvent_since = '2016' THEN 'year only, straddles assent'
         WHEN insolvent_date < '2016-09-14' THEN 'pre-Act 930'
         ELSE '' END                                             AS act_930_applicable
FROM measured
ORDER BY days DESC;

-- Expected: 20 rows. Sterling Financial Services tops it at 3,455 days, or 9.5
-- years, insolvent from March 2010 and revoked in 2019. Four rows are flagged
-- 'pre-Act 930' and two more as year-only 2016.


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
    SELECT insolvent_date,
           julianday('2019-08-16') - julianday(insolvent_date) AS days
    FROM lag
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
    (SELECT MIN(days) FROM measured)                                      AS shortest_days,
    ROUND(AVG(days), 1)                                                   AS median_days,
    ROUND(AVG(days) / 365.25, 1)                                          AS median_years,
    (SELECT MAX(days) FROM measured)                                      AS longest_days,
    (SELECT COUNT(*) FROM measured WHERE insolvent_date < '2016-01-01')   AS stated_before_act_930,
    (SELECT COUNT(*) FROM measured WHERE insolvent_date = '2016-01-01')   AS year_only_2016
FROM ranked
WHERE rn IN ((n + 1) / 2, (n + 2) / 2);   -- median: middle value, or mean of the middle two

-- Expected: 23 institutions, 20 with a stated date. Shortest 258 days,
-- median 927.5 days (2.5 years), longest 3,455 days. Four of the twenty state
-- an insolvency date preceding Act 930 altogether.
--
-- The honest statement of the finding: the Bank of Ghana left institutions it
-- had itself determined to be insolvent holding deposit-taking licences for a
-- median of two and a half years. That is sourced and it is serious. What
-- cannot be said is that a statutory deadline was breached, because Act 930
-- attaches no deadline to the duty that was actually engaged.
