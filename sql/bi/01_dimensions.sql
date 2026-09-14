-- BI layer, part 1 of 3: the dimensions.
--
-- The star schema is built entirely from views over the two tables that
-- sql/01_schema.sql creates. Nothing is copied and nothing new is recorded:
-- drop the views and the database is exactly what build_sqlite.py produced.
-- docs/bi-data-model.md explains the design and what was left out.
--
-- Run after the load, in order:
--
--   python scripts/build_sqlite.py
--   sqlite3 sql/ghana.db < sql/bi/01_dimensions.sql
--   sqlite3 sql/ghana.db < sql/bi/02_facts.sql
--   sqlite3 sql/ghana.db < sql/bi/03_marts.sql
--   sqlite3 sql/ghana.db < sql/bi/09_checks.sql

DROP VIEW IF EXISTS dim_institution_type;
DROP VIEW IF EXISTS dim_cause;
DROP VIEW IF EXISTS dim_institution;


-- The two licence types in the notice. This is the only grouping the data
-- supports: the notice gives no region, town or branch location, so there is
-- no geography dimension.
CREATE VIEW dim_institution_type AS
WITH t(type_key, licence_type, sort_order) AS (
    VALUES ('savings_and_loans', 'Savings and Loans', 1),
           ('finance_house',     'Finance House',     2)
)
SELECT type_key, licence_type, sort_order
FROM t;


-- The ten failure causes coded in savings_loans. The labels are the ones the
-- charts page already uses, so a cause reads the same in both places. The
-- sort order is the charts page's order, most cited first.
--
-- A cause is "cited" when the notice states it for that institution. A cause
-- that is not cited is not shown to be absent: the Bank of Ghana may simply
-- not have said so.
CREATE VIEW dim_cause AS
WITH c(cause_code, cause_label, description, sort_order) AS (
    VALUES
    ('liquidity_failure',              'Liquidity failure',
     'Could not meet depositors'' withdrawals.', 1),
    ('related_party_exposure',         'Related-party exposure',
     'Lending to, or funds placed with, parties connected to the institution or its owners.', 2),
    ('misreporting',                   'Misreporting / false records',
     'Misrepresented or misreported its true financial position to the Bank of Ghana.', 3),
    ('high_npl',                       'High non-performing loans',
     'A large share of the loan book not being repaid.', 4),
    ('governance_failure',             'Governance failure',
     'Weak corporate governance, such as the absence of a functioning board.', 5),
    ('unauthorised_structural_change', 'Unauthorised structural change',
     'Changed its name, head office, branches or structure without the Bank of Ghana''s prior approval.', 6),
    ('ignored_bog_recommendations',    'Ignored BoG findings',
     'Did not implement the Bank of Ghana''s on-site examination recommendations.', 7),
    ('failed_to_publish_accounts',     'Failed to publish accounts',
     'Did not publish its audited financial statements as the law requires.', 8),
    ('stopped_prudential_returns',     'Stopped prudential returns',
     'Stopped submitting prudential returns to the Bank of Ghana.', 9),
    ('ceased_ops_without_approval',    'Ceased ops without approval',
     'Ceased operations and closed its offices to the general public.', 10)
)
SELECT cause_code, cause_label, description, sort_order
FROM c;


-- One row per institution revoked on 16 August 2019: who it is, and the
-- descriptive attributes the notice gives. Money and intervals are measures
-- and live in fact_institution_snapshot instead.
--
-- The key is institution_name as published, already the primary key of
-- savings_loans. At 23 rows a surrogate integer would add a lookup and
-- nothing else.
--
-- short_name matches the names on the charts page. The CASE lists all 23, so
-- a renamed or added institution produces a NULL, which 09_checks.sql refuses.
--
-- Dates are kept exactly as published. The *_precision columns say how much
-- of each date the notice actually gives, because '2015' and '2015-01-28' are
-- different statements and must not be compared as if they were the same.
CREATE VIEW dim_institution AS
SELECT
    s.institution_name,
    CASE s.institution_name
        WHEN 'Accent Financial Services Ltd.'                   THEN 'Accent'
        WHEN 'Adom Savings and Loans Ltd.'                      THEN 'Adom'
        WHEN 'AllTime Finance Ltd.'                             THEN 'AllTime'
        WHEN 'Alpha Capital Savings and Loans Ltd.'             THEN 'Alpha Capital'
        WHEN 'ASN Financial Services Ltd.'                      THEN 'ASN'
        WHEN 'CDH Savings and Loans Ltd.'                       THEN 'CDH'
        WHEN 'Commerz Savings and Loans Ltd.'                   THEN 'Commerz'
        WHEN 'Crest Finance House Ltd.'                         THEN 'Crest'
        WHEN 'Dream Finance Company Ltd.'                       THEN 'Dream'
        WHEN 'Express Savings and Loans Company Ltd.'           THEN 'Express'
        WHEN 'First Allied Savings and Loans Co. Ltd.'          THEN 'First Allied'
        WHEN 'First African Savings & Loans Company Ltd.'       THEN 'First African'
        WHEN 'First Ghana Savings and Loans Co. Ltd.'           THEN 'First Ghana'
        WHEN 'FirstTrust Savings and Loans Ltd.'                THEN 'FirstTrust'
        WHEN 'Global Access Savings and Loans Company Ltd.'     THEN 'Global Access'
        WHEN 'GN Savings and Loans Ltd.'                        THEN 'GN'
        WHEN 'Ideal Finance Ltd.'                               THEN 'Ideal'
        WHEN 'IFS Financial Services Ltd.'                      THEN 'IFS'
        WHEN 'Legacy Capital Savings and Loans Ltd.'            THEN 'Legacy Capital'
        WHEN 'Midland Savings and Loans Company Ltd.'           THEN 'Midland'
        WHEN 'Sterling Financial Services Ltd.'                 THEN 'Sterling'
        WHEN 'Unicredit Savings and Loans Ltd.'                 THEN 'Unicredit'
        WHEN 'Women''s World Banking Savings and Loans Co. Ltd.' THEN 'Women''s World Banking'
    END                                                          AS short_name,
    t.type_key,
    s.licence_type,
    s.incorporated,
    CASE LENGTH(s.incorporated)    WHEN 4 THEN 'year' WHEN 7 THEN 'month' WHEN 10 THEN 'day' END AS incorporated_precision,
    s.licensed,
    CASE LENGTH(s.licensed)        WHEN 4 THEN 'year' WHEN 7 THEN 'month' WHEN 10 THEN 'day' END AS licensed_precision,
    s.insolvent_since,
    CASE LENGTH(s.insolvent_since) WHEN 4 THEN 'year' WHEN 7 THEN 'month' WHEN 10 THEN 'day' END AS insolvent_since_precision,
    s.branches,
    s.notes
FROM savings_loans AS s
LEFT JOIN dim_institution_type AS t ON t.licence_type = s.licence_type;


-- Expected:
--
--   dim_institution_type    2 rows
--   dim_cause              10 rows
--   dim_institution        23 rows, 16 Savings and Loans and 7 Finance House,
--                          every short_name and type_key filled in
