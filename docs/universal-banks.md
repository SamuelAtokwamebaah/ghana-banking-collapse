# The nine universal banks

Nine of the 418 rows in `defunct_institutions.csv` are universal banks. They are the weakest block in the dataset, and this note sets out exactly why, what has since been corroborated, and what has not.

## Why they are weaker than the other 409

The other 409 rows come from three Bank of Ghana notices that are archived in [`sources/`](../sources/), each of which lists its institutions and states its own totals. The banks have no equivalent single document. They were closed across three separate events — August 2017, August 2018 and January 2019 — and recorded here from Bank of Ghana press releases.

They are therefore excluded from the reconciliation check in `sql/14_sector_reconciliation.sql`, which tests the other three blocks against the totals the Bank states in its own notices.

## A correction, made August 2026

**Seven rows previously recorded "Consolidated into Consolidated Bank Ghana" in the `receiver` column. That was wrong twice over**, and it has been corrected.

It was wrong first because a resolution mechanism is not a receiver. Those are two different facts and the file now records them in two columns.

It was wrong second, and more importantly, because it misdescribes what happened. Consolidated Bank Ghana Ltd (CBG) is a **bridge institution** under Act 930 s.127(11) — an institution established for a temporary period to resolve institutions in distress. It acquired *selected* assets and liabilities under a purchase and assumption agreement. It did not consolidate, merge with, amalgamate or take over the banks whose customers it served.

The Court of Appeal decided this directly in **_Chancellor Oppong Kyekyeku Kohl v Consolidated Bank Ghana Ltd_ [2022] 181 GMJ 694**, holding that the receiver, not CBG, was the proper defendant for a liability of a resolved bank that fell outside the transferred set. The appellant's fixed deposit had been placed with one of the affected banks; the court held the receiver was the party to sue.

The corrected values, with their statutory basis:

| Institution | Revoked | Receiver | Resolution mechanism |
|---|---|---|---|
| UT Bank, Capital Bank | 14 Aug 2017 | PwC | Purchase and assumption by GCB Bank |
| uniBank, The Royal Bank, Beige Bank, Sovereign Bank, Construction Bank | 1 Aug 2018 | Nii Amanor Dodoo (KPMG) | Bridge institution: Consolidated Bank Ghana, Act 930 s.127(11) |
| Premium Bank, Heritage Bank | 4 Jan 2019 | *not recorded* | *not recorded* |

Revocation in each case rests on Act 930 s.123(1), which requires the Bank of Ghana to revoke where it determines an institution is insolvent or likely to become insolvent within sixty days. The appointment of a receiver follows automatically under s.123(2).

> [!NOTE]
> **The error is instructive, which is why it is documented rather than quietly fixed.** "Consolidated Bank Ghana" sounds like a consolidation of the banks it resolved, and that reading is common. It is also the misconception the Court of Appeal had to correct. A dataset that repeated it was passing on a legal error about a bank that is still trading.

## What is now corroborated, and what is not

**Seven of the nine** — UT, Capital, uniBank, Royal, Beige, Sovereign and Construction — are corroborated by a peer-reviewed source that cites the Bank of Ghana press releases directly:

> Ebenezer Adjei Bediako, Kwadwo Bioh Agyei and Michael Kwame Asabre, "The Banking Sector Clean–Up in Ghana, and the Legal Effects of the Appointments of a Receiver and Consolidated Bank Ghana Ltd as a Bridge Institution: An Analysis of the Case of Chancellor Oppong Kyekyeku Kohl v. Consolidated Bank of Ghana Ltd", *Ghana Insolvency and Restructuring Journal* (GIRJ), 3rd edn Vol. 1 (No. 1), December 2025. © Chartered Institute of Restructuring and Insolvency Practitioners Ghana (CIRIP).

**Premium Bank and Heritage Bank are not covered by it.** Their receiver and resolution mechanism are left blank, and their `source_document` still reads `VERIFY against primary source`. A blank is a documented gap; a plausible guess would be an undocumented error. That rule is applied throughout this project.

> [!NOTE]
> **The paper itself is not archived in `sources/`.** It carries an explicit copyright notice, and redistributing it is not ours to do. The three Bank of Ghana notices in `sources/` are public regulatory notices, which is a different case. The citation above is enough to find it.

## Context this adds to the main finding

The analysis in [FINDINGS.md](../FINDINGS.md) covers the 23 savings and loans companies and finance houses, where the Bank of Ghana cites related-party exposure in 17 of 23.

The GIRJ paper records that the Bank's stated reasons for the five banks closed on 1 August 2018 also cite dealings with shareholders and connected parties, alongside capital that was found to be impaired, overstated or sourced from borrowed or affiliated funds. The specific figures are set out in that paper and in the press releases it cites; they are not reproduced here, and no institution or individual named in this dataset is the subject of any allegation made by this project.

The point worth recording is narrow and it is about scope rather than blame: **the pattern this project documents in the savings and loans tier was not confined to it.** Whether the bank tier would code the same way under the same method is an open question, and answering it would need the press releases read and coded with the same discipline applied to the 23 — which has not been done here.

## Standing caution

Litigation arising from the clean-up is not finished. Proceedings involving directors and shareholders of several institutions, and the matter noted in the [Epilogue](../README.md#epilogue-where-things-stand-in-2026), remain live or recently decided. This project reports what published documents state, takes no position on any proceeding, and welcomes correction.
