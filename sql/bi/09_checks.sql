-- BI layer: guard rails.
--
-- Every row should read OK. A CHECK FAILED row means the model no longer
-- reconciles to the loaded tables, and every number built on it is suspect.

SELECT 'dim_institution_type' AS model_check,
       CASE WHEN (SELECT COUNT(*) FROM dim_institution_type) = 2
            THEN 'OK: 2 licence types'
            ELSE 'CHECK FAILED: expected 2 licence types' END AS result
UNION ALL
SELECT 'dim_cause',
       CASE WHEN (SELECT COUNT(*) FROM dim_cause) = 10
            THEN 'OK: 10 causes'
            ELSE 'CHECK FAILED: expected 10 causes' END
UNION ALL
SELECT 'dim_institution rows',
       CASE WHEN (SELECT COUNT(*) FROM dim_institution) = (SELECT COUNT(*) FROM savings_loans)
             AND (SELECT COUNT(*) FROM dim_institution) = 23
            THEN 'OK: 23 institutions'
            ELSE 'CHECK FAILED: dim_institution does not match the 23 loaded rows' END
UNION ALL
SELECT 'dim_institution keys',
       CASE WHEN (SELECT COUNT(*) FROM dim_institution WHERE short_name IS NULL OR type_key IS NULL) = 0
             AND (SELECT COUNT(DISTINCT short_name) FROM dim_institution) = 23
            THEN 'OK: every institution has a unique short name and a licence type'
            ELSE 'CHECK FAILED: an institution has no short name or licence type, or two share a short name' END
UNION ALL
SELECT 'fact_cited_causes rows',
       CASE WHEN (SELECT COUNT(*) FROM fact_cited_causes) = 101
            THEN 'OK: 101 cited causes'
            ELSE 'CHECK FAILED: expected 101 cited causes' END
UNION ALL
SELECT 'fact_cited_causes keys',
       CASE WHEN (SELECT COUNT(*) FROM fact_cited_causes f
                  LEFT JOIN dim_cause c ON c.cause_code = f.cause_code
                  WHERE c.cause_code IS NULL) = 0
            THEN 'OK: every cited cause is in dim_cause'
            ELSE 'CHECK FAILED: a cited cause is missing from dim_cause' END
UNION ALL
SELECT 'cause counts reconcile',
       CASE WHEN (SELECT COUNT(*) FROM fact_institution_snapshot f
                  JOIN savings_loans s ON s.institution_name = f.institution_name
                  WHERE f.cited_causes <> s.cause_count) = 0
            THEN 'OK: each institution''s cited causes equal its published cause_count'
            ELSE 'CHECK FAILED: cited causes differ from the published cause_count' END
UNION ALL
SELECT 'fact_institution_snapshot rows',
       CASE WHEN (SELECT COUNT(*) FROM fact_institution_snapshot) = 23
            THEN 'OK: 23 snapshots'
            ELSE 'CHECK FAILED: expected 23 snapshots' END
UNION ALL
SELECT 'deficits',
       CASE WHEN (SELECT COUNT(*) FROM fact_institution_snapshot WHERE deficit_ghs_m IS NOT NULL) = 21
             AND (SELECT ROUND(SUM(deficit_ghs_m), 2) FROM fact_institution_snapshot) = 2301.32
            THEN 'OK: 21 deficits totalling GHS 2,301.32m, as 13_deficit_concentration.sql'
            ELSE 'CHECK FAILED: deficits do not reconcile to GHS 2,301.32m across 21 institutions' END
UNION ALL
SELECT 'intervals',
       CASE WHEN (SELECT COUNT(*) FROM fact_institution_snapshot WHERE days_insolvent_upper IS NOT NULL) = 20
             AND (SELECT MIN(days_insolvent_upper) FROM fact_institution_snapshot) = 258
             AND (SELECT MAX(days_insolvent_upper) FROM fact_institution_snapshot) = 3455
             AND (SELECT COUNT(*) FROM fact_institution_snapshot
                  WHERE days_insolvent_floor > days_insolvent_upper) = 0
            THEN 'OK: 20 intervals, 258 to 3,455 days, as 12_supervisory_lag.sql'
            ELSE 'CHECK FAILED: intervals do not reconcile to 12_supervisory_lag.sql' END
UNION ALL
SELECT 'v_cause_cooccurrence',
       CASE WHEN (SELECT COUNT(*) FROM v_cause_cooccurrence) = 100
             AND (SELECT COUNT(*) FROM v_cause_cooccurrence
                  WHERE cause_a = cause_b AND cited_both <> cited_a) = 0
             AND (SELECT cited_both || '/' || cited_a || ' ' || b_without_a || '/' || not_a
                  FROM v_cause_cooccurrence
                  WHERE cause_a = 'related_party_exposure' AND cause_b = 'misreporting') = '14/17 1/6'
            THEN 'OK: 100 pairs; related-party with misreporting 14 of 17, against 1 of 6'
            ELSE 'CHECK FAILED: co-occurrence does not reconcile to 11_cooccurrence.sql' END
UNION ALL
SELECT 'v_cause_by_type',
       CASE WHEN (SELECT COUNT(*) FROM v_cause_by_type) = 20
             AND (SELECT SUM(cited) FROM v_cause_by_type) = 101
            THEN 'OK: 20 rows summing to 101 cited causes'
            ELSE 'CHECK FAILED: causes by type do not sum to 101' END
UNION ALL
SELECT 'v_lag_by_cause',
       CASE WHEN (SELECT COUNT(*) FROM v_lag_by_cause) = 20
             AND (SELECT COUNT(*) FROM (SELECT cause_code FROM v_lag_by_cause
                                        GROUP BY cause_code HAVING SUM(institutions) <> 20)) = 0
            THEN 'OK: 20 rows; each cause splits all 20 dated institutions'
            ELSE 'CHECK FAILED: a cause does not split the 20 dated institutions' END;

-- Expected: 13 rows, every one beginning OK.
