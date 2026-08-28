-- Q2. Do related-party lending and misreporting travel together?
--
-- Reproduces: chart 2 on the charts page, and finding 2 in FINDINGS.md.
--
-- The single most important query in this project. Either cause on its own is
-- a story about incompetence. Together they are a story about intent: money
-- moved to companies the owners controlled, and the books were kept so that it
-- did not show.

-- 2a. The full 2x2.
SELECT
    CASE WHEN related_party_exposure = 'Y'
         THEN 'related-party cited' ELSE 'not cited' END AS related_party,
    CASE WHEN misreporting = 'Y'
         THEN 'misreporting cited'  ELSE 'not cited' END AS misreporting,
    COUNT(*)                                             AS institutions,
    GROUP_CONCAT(institution_name, '; ')                 AS which
FROM savings_loans
GROUP BY related_party, misreporting
ORDER BY institutions DESC;

-- Expected:
--
--   related-party cited   misreporting cited    14
--   not cited             not cited              5
--   related-party cited   not cited              3
--   not cited             misreporting cited     1


-- 2b. The headline figure, stated as a conditional rate.
SELECT
    COUNT(*)                                                   AS related_party_cases,
    SUM(CASE WHEN misreporting = 'Y' THEN 1 ELSE 0 END)        AS also_misreported,
    ROUND(SUM(CASE WHEN misreporting = 'Y' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 0) || '%'                        AS rate
FROM savings_loans
WHERE related_party_exposure = 'Y';

-- Expected: 17 related-party cases, 14 of which also misreported — 82%.
--
-- Compare that with the base rate: misreporting is cited in 15 of all 23
-- institutions, i.e. 65%. So an institution that was lending to its own
-- affiliates was substantially more likely to be falsifying its records too.
--
-- With n = 23 this is a description of these institutions, not a statistical
-- claim about savings and loans companies in general. No significance test is
-- offered and none would be meaningful at this size.
