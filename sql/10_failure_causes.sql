-- Q1. How often does the Bank of Ghana cite each failure cause?
--
-- Reproduces: chart 1 on the charts page, and finding 1 in FINDINGS.md.
--
-- The ten causes are stored one per column, which is right for a hand-checked
-- transcription — one column per thing the notice might say — but wrong for
-- counting. Unpivot them into one row per (institution, cause) first.
--
-- Institutions typically failed for several reasons at once, so these do not
-- sum to 23. The mean is 4.0 causes each.

WITH cited AS (
    SELECT institution_name, 'liquidity_failure'              AS cause FROM savings_loans WHERE liquidity_failure              = 'Y'
    UNION ALL
    SELECT institution_name, 'related_party_exposure'                  FROM savings_loans WHERE related_party_exposure         = 'Y'
    UNION ALL
    SELECT institution_name, 'misreporting'                            FROM savings_loans WHERE misreporting                   = 'Y'
    UNION ALL
    SELECT institution_name, 'high_npl'                                FROM savings_loans WHERE high_npl                       = 'Y'
    UNION ALL
    SELECT institution_name, 'governance_failure'                      FROM savings_loans WHERE governance_failure             = 'Y'
    UNION ALL
    SELECT institution_name, 'unauthorised_structural_change'          FROM savings_loans WHERE unauthorised_structural_change = 'Y'
    UNION ALL
    SELECT institution_name, 'ignored_bog_recommendations'             FROM savings_loans WHERE ignored_bog_recommendations    = 'Y'
    UNION ALL
    SELECT institution_name, 'stopped_prudential_returns'              FROM savings_loans WHERE stopped_prudential_returns     = 'Y'
    UNION ALL
    SELECT institution_name, 'failed_to_publish_accounts'              FROM savings_loans WHERE failed_to_publish_accounts     = 'Y'
    UNION ALL
    SELECT institution_name, 'ceased_ops_without_approval'             FROM savings_loans WHERE ceased_ops_without_approval    = 'Y'
)
SELECT
    cause,
    COUNT(*)                                  AS institutions,
    ROUND(COUNT(*) * 100.0 / 23, 0) || '%'    AS share_of_23
FROM cited
GROUP BY cause
ORDER BY institutions DESC, cause;

-- Expected result:
--
--   liquidity_failure                21   91%
--   related_party_exposure           17   74%
--   misreporting                     15   65%
--   high_npl                         14   61%
--   governance_failure               10   43%
--   unauthorised_structural_change    7   30%
--   ignored_bog_recommendations       6   26%
--   failed_to_publish_accounts        4   17%
--   stopped_prudential_returns        4   17%
--   ceased_ops_without_approval       3   13%
--
-- Read it in that order and the argument makes itself. Liquidity failure —
-- being unable to pay depositors — is the most cited, but it is what the
-- public sees at the end. Related-party exposure is what caused it.
