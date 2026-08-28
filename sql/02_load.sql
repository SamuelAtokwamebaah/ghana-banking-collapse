-- Load both CSVs using the sqlite3 command-line shell.
--
--   cd sql
--   sqlite3 ghana.db ".read 01_schema.sql" ".read 02_load.sql"
--
-- Requires sqlite3 3.32 or later for `.import --skip`. If you do not have the
-- shell, or have an older one, use the Python loader instead — it needs
-- nothing beyond the standard library and produces an identical database:
--
--   python scripts/build_sqlite.py

.mode csv

.import --skip 1 ../data/savings_loans_verified.csv savings_loans
.import --skip 1 ../data/defunct_institutions.csv defunct_institutions

-- The CSV importer writes empty cells as empty strings. Convert them to NULL
-- so "the regulator published no figure" is distinguishable from zero, and so
-- the analysis queries below behave the same on both loading routes.
UPDATE savings_loans SET
    incorporated                   = NULLIF(incorporated, ''),
    licensed                       = NULLIF(licensed, ''),
    insolvent_since                = NULLIF(insolvent_since, ''),
    net_worth_ghs_m                = NULLIF(net_worth_ghs_m, ''),
    net_worth_as_at                = NULLIF(net_worth_as_at, ''),
    car_pct                        = NULLIF(car_pct, ''),
    car_as_at                      = NULLIF(car_as_at, ''),
    branches                       = NULLIF(branches, ''),
    related_party_exposure         = NULLIF(related_party_exposure, ''),
    governance_failure             = NULLIF(governance_failure, ''),
    liquidity_failure              = NULLIF(liquidity_failure, ''),
    misreporting                   = NULLIF(misreporting, ''),
    high_npl                       = NULLIF(high_npl, ''),
    ignored_bog_recommendations    = NULLIF(ignored_bog_recommendations, ''),
    ceased_ops_without_approval    = NULLIF(ceased_ops_without_approval, ''),
    unauthorised_structural_change = NULLIF(unauthorised_structural_change, ''),
    failed_to_publish_accounts     = NULLIF(failed_to_publish_accounts, ''),
    stopped_prudential_returns     = NULLIF(stopped_prudential_returns, ''),
    notes                          = NULLIF(notes, '');

-- Guard rails. If either count is wrong the load silently failed, and every
-- number downstream would be wrong with it.
SELECT CASE WHEN COUNT(*) = 23  THEN 'savings_loans OK: 23 rows'
            ELSE 'LOAD FAILED — expected 23, got ' || COUNT(*) END FROM savings_loans;

SELECT CASE WHEN COUNT(*) = 418 THEN 'defunct_institutions OK: 418 rows'
            ELSE 'LOAD FAILED — expected 418, got ' || COUNT(*) END FROM defunct_institutions;
