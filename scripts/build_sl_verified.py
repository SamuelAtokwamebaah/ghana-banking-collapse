# -*- coding: utf-8 -*-
"""
Savings & loans / finance houses: hand-verified dataset.

Every field below was read directly from Annex 2 of the Bank of Ghana notice of
16 August 2019 and typed by hand. This file deliberately does NOT parse the PDF:
the keyword-matched first pass (build_dataset.py) mis-assigned failure causes and
dropped figures, so the 23 records are coded manually. There are only 23 - accuracy
beats automation at this size.

Conventions:
  net_worth_ghs_m   negative = deficit. ASN is POSITIVE (see notes).
  car_pct           regulatory minimum was +10% (13% for the reclassified GN).
  blank             the notice gave no figure. Never estimated.
  Y / blank         cause present in the notice's stated reasons.
"""
import io, csv, os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "data")

# name | licence | incorporated | licensed | insolvent_since | NW(m) | NW as at | CAR% | CAR as at | branches
CORE = [
 ("Accent Financial Services Ltd.",              "Finance House", "2012-11-21", "2013-06", "2017-03", -55.76, "2019-02", -144.30, "2019-02", ""),
 ("Adom Savings and Loans Ltd.",                 "Savings and Loans", "2010-01", "2016-08", "2018-08", -9.60, "2019-05", -126.23, "2019-05", ""),
 ("AllTime Finance Ltd.",                        "Finance House", "", "2017-07", "2018-08", -23.15, "2019-05", -47.41, "2019-05", ""),
 ("Alpha Capital Savings and Loans Ltd.",        "Savings and Loans", "", "2015-01", "2016-12", -11.51, "2019-05", -81.05, "2019-05", ""),
 ("ASN Financial Services Ltd.",                 "Savings and Loans", "", "2014-07-14", "2016-10", 0.628311, "2019-05", -81.39, "2019-05", ""),
 ("CDH Savings and Loans Ltd.",                  "Savings and Loans", "2000", "2016", "2018-09", -171.36, "2019-05", -35.90, "2019-05", ""),
 ("Commerz Savings and Loans Ltd.",              "Savings and Loans", "", "2016-12", "", -40.99, "2019-05", -126.15, "2019-05", ""),
 ("Crest Finance House Ltd.",                    "Finance House", "1997-09-02", "2007-06-05", "2015", -17.55, "2019-05", -6873.50, "2019-05", ""),
 ("Dream Finance Company Ltd.",                  "Finance House", "", "2013-10-25", "2015", -333.46, "2019-05", -7508.10, "2019-05", ""),
 ("Express Savings and Loans Company Ltd.",      "Savings and Loans", "", "2007-08-14", "2016", -119.83, "2019-05", -610.52, "2019-05", "18 (14 closed by May 2019)"),
 ("First Allied Savings and Loans Co. Ltd.",     "Savings and Loans", "", "1996-03-27", "2018-03", -661.84, "2019-05", -263.21, "2019-05", "27"),
 ("First African Savings & Loans Company Ltd.",  "Savings and Loans", "1993-11", "2009-10", "2017-08", -22.29, "2019-05", -90.15, "2019-05", ""),
 ("First Ghana Savings and Loans Co. Ltd.",      "Savings and Loans", "1956", "2015-03-08", "", -14.08, "2019-05", -54.47, "2019-05", ""),
 ("FirstTrust Savings and Loans Ltd.",           "Savings and Loans", "2007-10-11", "2015-01-28", "2015", -175.90, "2019-05", -132.96, "2019-05", ""),
 ("Global Access Savings and Loans Company Ltd.","Savings and Loans", "1998", "2009-06-15", "2016", -58.19, "2019-05", -195.06, "2019-05", ""),
 ("GN Savings and Loans Ltd.",                   "Finance House", "2006-05-08", "2019-01-04", "", -30.70, "2019-05", -61.20, "2019-05", "70 suspended"),
 ("Ideal Finance Ltd.",                          "Finance House", "2009", "2014-12-18", "2017", -117.50, "2018-11", -32.80, "2018-11", ""),
 ("IFS Financial Services Ltd.",                 "Savings and Loans", "2006-09-01", "2007-06-05", "2018-12", -2.29, "2019-05", -18.77, "2019-05", ""),
 ("Legacy Capital Savings and Loans Ltd.",       "Savings and Loans", "2013-10-30", "2016-08-12", "2018-08", -19.52, "2019-05", -16.96, "2019-05", ""),
 ("Midland Savings and Loans Company Ltd.",      "Finance House", "", "1996-10-21", "2017-01", -148.92, "2019-05", -311.91, "2019-05", ""),
 ("Sterling Financial Services Ltd.",            "Savings and Loans", "", "1997", "2010-03", None, "", -1469.39, "2010-03", ""),
 ("Unicredit Savings and Loans Ltd.",            "Savings and Loans", "1995-10", "1995-10", "2018-12", -221.32, "2019-05", -97.83, "2019-05", ""),
 ("Women's World Banking Savings and Loans Co. Ltd.", "Savings and Loans", "1982-05-31", "1996-10", "2017-10", -45.56, "2019-05", -46.62, "2019-05", ""),
]

# Hand-coded failure causes, read from each institution's stated reasons in Annex 2.
CAUSES = ["related_party_exposure", "governance_failure", "liquidity_failure", "misreporting",
          "high_npl", "ignored_bog_recommendations", "ceased_ops_without_approval",
          "unauthorised_structural_change", "failed_to_publish_accounts", "stopped_prudential_returns"]

FLAGS = {
 "Accent Financial Services Ltd.":                    "1110100000",
 "Adom Savings and Loans Ltd.":                       "1111100000",
 "AllTime Finance Ltd.":                              "1111001100",
 "Alpha Capital Savings and Loans Ltd.":              "0110011001",
 "ASN Financial Services Ltd.":                       "1110110000",
 "CDH Savings and Loans Ltd.":                        "1011100000",
 "Commerz Savings and Loans Ltd.":                    "0110100000",
 "Crest Finance House Ltd.":                          "1110100100",
 "Dream Finance Company Ltd.":                        "1111011100",
 "Express Savings and Loans Company Ltd.":            "1001000110",
 "First Allied Savings and Loans Co. Ltd.":           "1011100001",
 "First African Savings & Loans Company Ltd.":        "1001100000",
 "First Ghana Savings and Loans Co. Ltd.":            "0110000000",
 "FirstTrust Savings and Loans Ltd.":                 "1111010000",
 "Global Access Savings and Loans Company Ltd.":      "1011010010",
 "GN Savings and Loans Ltd.":                         "1011100110",
 "Ideal Finance Ltd.":                                "1011100011",
 "IFS Financial Services Ltd.":                       "0010100000",
 "Legacy Capital Savings and Loans Ltd.":             "1011100000",
 "Midland Savings and Loans Company Ltd.":            "1011000100",
 "Sterling Financial Services Ltd.":                  "0010100101",
 "Unicredit Savings and Loans Ltd.":                  "1011100000",
 "Women's World Banking Savings and Loans Co. Ltd.":  "0011010000",
}

NOTES = {
 "ASN Financial Services Ltd.": "Net worth POSITIVE at GHS 628,311.16 - the only institution of the 23 not reporting a deficit. Still revoked: CAR -81.39%, insolvent since Oct 2016, no functioning board.",
 "Sterling Financial Services Ltd.": "CAR is as at end-MARCH 2010, not 2019. Stopped submitting returns May 2010 and folded operations in 2011 without notifying BoG. Licence not revoked until Aug 2019 - a nine-year gap.",
 "GN Savings and Loans Ltd.": "Formerly First National Savings and Loans; universal banking licence Sep 2014 as GN Bank; reclassified to savings and loans 4 Jan 2019 after failing the GHS 400m minimum capital. GHS 761.55m placed with sister companies (Groupe Nduom). USD 62.26m, GBP 718,528 and EUR 4,200 of depositor funds transferred to a US affiliate without documentation.",
 "First Ghana Savings and Loans Co. Ltd.": "Established 1956 as First Ghana Building Society under the Building Societies Ordinance 1955 - the oldest institution in the dataset, predating independence. Notably few stated causes: no related-party lending, no misreporting, no fraud. A straightforward capital failure.",
 "First Allied Savings and Loans Co. Ltd.": "Largest net-worth deficit of the 23. NPLs at 88.89% of the loan portfolio. Deposit liabilities understated to conceal losses. Bank run began June 2018 at the Kumasi and Adabraka branches and spread to all 27.",
 "Ideal Finance Ltd.": "Figures are as at end-November 2018, not May 2019 - the institution stopped submitting returns after that date. Proposed merger with FirsTrust declined by BoG: both insolvent, merged entity assessed at CAR -78.32%.",
 "FirstTrust Savings and Loans Ltd.": "Formerly EZI Savings and Loans (licensed 2007), acquired by Ideal Financial Holdings 2014. Cash reserve ratio 0.07% against a 10% minimum.",
 "CDH Savings and Loans Ltd.": "Took over Ivory Finance Company (operating since 2000). Exposure to affiliates at 319% against a 25% regulatory limit.",
 "Unicredit Savings and Loans Ltd.": "Formerly Kantamanto Savings and Loans; acquired by Hoda Group 2006. Non-performing exposure of GHS 160.10m to sister company uniSecurities.",
 "Dream Finance Company Ltd.": "Changed name to El Finance Limited and relocated head office without BoG approval. Over-exposed to six related companies.",
 "Commerz Savings and Loans Ltd.": "Formerly Sterling Savings and Loans, part of Nordcom Africa Holdings. Distinct from Sterling Financial Services Ltd. (entry 21).",
 "Legacy Capital Savings and Loans Ltd.": "Operated as a microfinance institution from Oct 2013 before its savings and loans licence in Aug 2016.",
 "Midland Savings and Loans Company Ltd.": "Related-party exposure to Liberty Asset Management, Liberty DMI Microfinance and Griffin Financial Services.",
 "Global Access Savings and Loans Company Ltd.": "Began as a Western Union agent for ADB. Assumed a GHS 2.91m loan of the majority shareholder, injected it as equity, and concealed the liability in a suspense account.",
 "Express Savings and Loans Company Ltd.": "Closed 14 of its 18 branches by May 2019 without BoG approval. Cash reserve ratio 0.23% against a 10% minimum.",
 "Crest Finance House Ltd.": "Originally Apex Finance House (1997). Entire loan portfolio non-performing.",
}

if not os.path.isdir(OUT):
    os.makedirs(OUT)

cols = (["institution_name", "licence_type", "incorporated", "licensed", "insolvent_since",
         "net_worth_ghs_m", "net_worth_as_at", "car_pct", "car_as_at", "branches"]
        + CAUSES + ["cause_count", "notes"])

with io.open(os.path.join(OUT, "savings_loans_verified.csv"), "w", encoding="utf-8", newline="") as f:
    w = csv.writer(f)
    w.writerow(cols)
    for (name, lic, inc, licd, ins, nw, nwd, car, card, br) in CORE:
        bits = FLAGS[name]
        assert len(bits) == len(CAUSES), name
        flags = ["Y" if b == "1" else "" for b in bits]
        w.writerow([name, lic, inc, licd, ins,
                    "" if nw is None else nw, nwd, car, card, br]
                   + flags + [bits.count("1"), NOTES.get(name, "")])

print("wrote data/savings_loans_verified.csv:", len(CORE), "rows")
deficits = [r[5] for r in CORE if r[5] is not None and r[5] < 0]
print("institutions with a net-worth deficit:", len(deficits))
print("total deficit (GHS m): %.2f" % sum(deficits))
print("largest deficit: %.2f" % min(deficits))
for i, c in enumerate(CAUSES):
    print("  %-32s %d" % (c, sum(1 for v in FLAGS.values() if v[i] == "1")))
