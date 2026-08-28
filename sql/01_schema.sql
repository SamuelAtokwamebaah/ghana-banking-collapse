-- Ghana banking sector collapse — schema
--
-- Two tables, mirroring the two published CSVs exactly. Nothing is derived
-- here: every column corresponds to a column in the source file, and every
-- source file is transcribed from a Bank of Ghana notice.
--
-- Blank cells in the CSVs mean the regulator published no figure. They load
-- as NULL, never as zero — the difference matters, because three institutions
-- have no stated insolvency date and two have no net-worth figure.

DROP TABLE IF EXISTS savings_loans;
DROP TABLE IF EXISTS defunct_institutions;

-- The 23 savings and loans companies and finance houses whose licences were
-- revoked on 16 August 2019. Hand-transcribed from Annex 2 of the notice.
CREATE TABLE savings_loans (
    institution_name                TEXT    NOT NULL PRIMARY KEY,
    licence_type                    TEXT    NOT NULL,   -- 'Savings and Loans' | 'Finance House'
    incorporated                    TEXT,               -- ISO date, or NULL where not stated
    licensed                        TEXT,
    insolvent_since                 TEXT,               -- 'YYYY' or 'YYYY-MM'; NULL where not stated
    net_worth_ghs_m                 REAL,               -- negative = deficit
    net_worth_as_at                 TEXT,
    car_pct                         REAL,               -- capital adequacy ratio, per cent
    car_as_at                       TEXT,
    -- Stored as published, not as a number: the notice qualifies some counts
    -- ('18 (14 closed by May 2019)', '70 suspended'). Only three institutions
    -- have a branch figure at all. Parsing it to an integer would discard the
    -- qualifier, which is the informative half.
    branches                        TEXT,

    -- Failure causes, coded from the regulator's own stated reasons.
    -- 'Y' where the notice cites it for that institution; NULL where it does not.
    -- A NULL is not evidence of absence — only that the Bank did not say so.
    related_party_exposure          TEXT,
    governance_failure              TEXT,
    liquidity_failure               TEXT,
    misreporting                    TEXT,
    high_npl                        TEXT,
    ignored_bog_recommendations     TEXT,
    ceased_ops_without_approval     TEXT,
    unauthorised_structural_change  TEXT,
    failed_to_publish_accounts      TEXT,
    stopped_prudential_returns      TEXT,

    cause_count                     INTEGER,
    notes                           TEXT
);

-- All 418 institutions closed in the clean-up, across the three notices
-- plus the nine universal banks.
CREATE TABLE defunct_institutions (
    institution_name    TEXT NOT NULL,
    category            TEXT NOT NULL,
    status              TEXT,
    revocation_date     TEXT,
    receiver            TEXT,
    legal_basis         TEXT,
    source_document     TEXT
);

CREATE INDEX idx_defunct_category ON defunct_institutions (category);
