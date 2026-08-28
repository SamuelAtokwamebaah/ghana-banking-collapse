-- Q5. Does the compiled dataset reconcile to the totals the Bank of Ghana
--     states in its own notices?
--
-- This is not an analysis query. It is the check that has to pass before any
-- of the others mean anything — the SQL equivalent of the assertions in
-- scripts/build_dataset.py. If a parse breaks, these counts stop matching and
-- the failure is visible instead of silent.
--
-- The notices state their own totals in the body text:
--   31 May 2019 (microfinance)  192 insolvent + 155 insolvent and ceased = 347
--   31 May 2019 (microcredit)    29 insolvent +  10 insolvent and ceased =  39
--   16 Aug 2019 (S&L / finance)  16 savings and loans + 7 finance houses =  23

SELECT
    category,
    status,
    COUNT(*) AS institutions
FROM defunct_institutions
GROUP BY category, status
ORDER BY institutions DESC;

-- Expected:
--
--   Microfinance                  Insolvent                          192
--   Microfinance                  Insolvent and ceased operations    155
--   Microcredit / money lending   Insolvent                           29
--   Savings and Loans Company     Insolvent                           16
--   Microcredit / money lending   Insolvent and ceased operations     10
--   Universal bank                Licence revoked                      9
--   Finance House                 Insolvent                            7
--                                                                    ---
--                                                                    418


-- 5b. The reconciliation, stated as a pass/fail rather than left to the reader.
SELECT
    source_document,
    COUNT(*) AS institutions,
    CASE source_document
        WHEN 'BoG Notice, 31 May 2019 (microfinance)'                     THEN CASE WHEN COUNT(*) = 347 THEN 'OK' ELSE 'MISMATCH' END
        WHEN 'BoG Notice, 31 May 2019 (microcredit)'                      THEN CASE WHEN COUNT(*) =  39 THEN 'OK' ELSE 'MISMATCH' END
        WHEN 'BoG Notice, 16 Aug 2019 (savings & loans / finance houses)' THEN CASE WHEN COUNT(*) =  23 THEN 'OK' ELSE 'MISMATCH' END
        ELSE 'not from a consolidated notice — verify separately'
    END AS reconciles
FROM defunct_institutions
GROUP BY source_document
ORDER BY institutions DESC;

-- The nine universal banks are the one block that does NOT reconcile to a
-- single notice: they are compiled from separate Bank of Ghana press releases
-- issued between 2017 and 2019, and are flagged as such in the data. Treat
-- that block as needing verification. The other 409 rows come straight from
-- the three archived notices in sources/.


-- 5c. The 23 in this project, set against the whole clean-up.
SELECT
    (SELECT COUNT(*) FROM defunct_institutions)                                    AS all_institutions_closed,
    (SELECT COUNT(*) FROM savings_loans)                                           AS analysed_in_detail,
    ROUND((SELECT COUNT(*) FROM savings_loans) * 100.0
          / (SELECT COUNT(*) FROM defunct_institutions), 1) || '%'                 AS share_of_closures;

-- Expected: 418 closed, 23 analysed in detail — 5.5%.
--
-- Why only 23: the 16 August 2019 notice is the only one of the three that
-- publishes per-institution financials and stated reasons. The other two name
-- the institutions and nothing more. So the deep analysis is possible for 23
-- and impossible for the remaining 395 — which is itself a finding about what
-- the public record contains.
