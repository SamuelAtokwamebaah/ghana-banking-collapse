# What Killed Ghana's Savings & Loans Companies

Analysis of the 23 savings and loans companies and finance houses whose licences the Bank of Ghana revoked on 16 August 2019. Every figure is from Annex 2 of [the BoG notice](https://www.bog.gov.gh/wp-content/uploads/2019/08/Revocation-of-Licenses-of-SDIs-16.8.19.pdf), hand-transcribed in `build_sl_verified.py`.

**Headline:** these institutions did not fail from bad luck or a difficult market. In 17 of 23 cases the money went to the owners.

---

---

## 1. Related-party lending is the dominant failure mode

| Stated cause | Institutions | Share |
|---|---|---|
| Liquidity failure, could not meet withdrawals | 21 | 91% |
| **Related-party exposure** | **17** | **74%** |
| Misreporting / false accounting records | 15 | 65% |
| High non-performing loans | 14 | 61% |
| Governance failure | 10 | 43% |
| Unauthorised structural change | 7 | 30% |
| Ignored BoG examination findings | 6 | 26% |
| Failed to publish audited accounts | 4 | 17% |
| Stopped submitting prudential returns | 4 | 17% |
| Ceased operations without approval | 3 | 13% |

Liquidity failure at 91% is the *symptom*. It is what a depositor experiences and what triggers the complaint to the regulator. The cause sits above it.

**Related-party exposure appears in 17 of 23. And 14 of those 17 also involved misreporting.** That co-occurrence is the finding. On the regulator's account these are not two separate problems: the notice describes funds placed with companies connected to the institutions' owners, and accounts that did not reflect them.

The specifics are unambiguous:
- **uniCredit** had **GHS 160.10m** non-performing with sister company uniSecurities, more than its entire net-worth deficit.
- **CDH** was exposed to affiliates at **319%** against a 25% regulatory limit.
- **Global Access** assumed a **GHS 2.91m** personal loan of its majority shareholder, booked it as equity, and concealed the liability in a suspense account.
- **First Allied** had eight related companies overdrawn by more than **GHS 100m**, and understated deposit liabilities to conceal years of losses.

---

## 2. Insolvent institutions kept their licences for a median of two and a half years

The Bank of Ghana states, in its own notice, the date each institution became insolvent. Measuring those dates against the revocation on 16 August 2019:

| | |
|---|---|
| Institutions with a stated insolvency date | 20 of 23 |
| Shortest interval | **258 days** |
| **Median interval** | **927.5 days, two and a half years** |
| Longest interval | **3,455 days, nine and a half years** |

Every one of those days is a day an institution the regulator had determined to be insolvent could lawfully accept new deposits.

**Sterling is the case that should not exist.** It reported a capital adequacy ratio of **-1,469%** as at March 2010. It stopped submitting prudential returns in May 2010 and folded its operations in 2011 without telling the Bank of Ghana. Its licence was revoked in **August 2019**, nine and a half years after the regulator had the numbers in front of it.

### What the law required, and what it did not

> [!IMPORTANT]
> **An earlier version of this analysis described these intervals as breaches of a "180-day statutory deadline". That was wrong, and the claim has been withdrawn.** The arithmetic was never in question; the legal label on it was. The correction is recorded here rather than quietly removed, because the reasoning matters more than the headline it cost.

Act 930 does contain 180-day periods, but **neither of them runs from insolvency**:

- **s.105(2)(b)** requires capital adequacy to be restored *"within one hundred and eighty days of making that order"*. The clock runs from **an order of the Bank of Ghana**.
- **s.106(1)(b)** gives 90 days to rectify and 180 to restore under **an agreement with the institution's board**. The clock runs from **that agreement**.

Both periods begin only after a supervisory act. No public document shows that either an order or an agreement was made in respect of these twenty institutions. On the available evidence **no 180-day period ever began**, and a period that never started cannot be breached.

There is a second, independent reason the old framing failed. Act 930 received assent on **14 September 2016**. Sterling's stated insolvency is March 2010; Crest, Dream and FirstTrust are 2015. **Four of the twenty were being measured against a statute that did not yet exist**, and two more, Express and Global Access, are recorded as "2016" with no month and cannot be placed on either side of the assent date.

**The duty that was actually engaged is section 123(1)**, which requires the Bank of Ghana to revoke a licence where it determines that an institution is insolvent or likely to become insolvent within sixty days. That duty plainly applied: the Bank states the insolvency dates itself. Section 106(3) reinforces the direction of travel, obliging the Bank to act *"without having to wait for the expiry of that period"*, and the verb throughout is **shall**, not *may*.

But **Act 930 attaches no deadline to the s.123(1) duty.** There is no period within which a determination of insolvency must be followed by revocation.

That absence is the finding. It is not that the Bank of Ghana missed a deadline written in the Act; it is that **the Act sets no deadline for the one duty that mattered here**, and institutions the regulator had already judged insolvent held deposit-taking licences for a median of two and a half years while none ran.

## 3. The losses are concentrated, not spread

| | |
|---|---|
| Institutions with a net-worth deficit | 21 of 23 |
| Total deficit | **GHS 2.30 billion** |
| Top 5 institutions' share | **68%** (GHS 1.56bn) |
| Median institution | GHS 45.6m |

| Institution | Net worth (GHS m) | CAR |
|---|---:|---:|
| First Allied Savings and Loans | -661.84 | -263% |
| Dream Finance | -333.46 | -7,508% |
| uniCredit | -221.32 | -98% |
| FirsTrust Savings and Loans | -175.90 | -133% |
| CDH Savings and Loans | -171.36 | -36% |

The distribution matters for policy. A sector where losses are evenly spread suggests a bad market; one where 68% sits in five institutions suggests specific firms behaving specifically badly. This is the latter.

**One institution reported a positive net worth: ASN Financial Services**, at GHS 628,311. It was revoked anyway, CAR of -81%, insolvent since October 2016, and operating without a functioning board.

---

## 4. Capital adequacy ratios past the point of meaning

The regulatory minimum was +10%. Reported ratios included **-7,508%** (Dream Finance), **-6,873%** (Crest), and **-1,469%** (Sterling).

A CAR of -7,508% is not a capital shortfall. It is an institution whose liabilities exceed its assets by seventy-five times its required capital, a number that only accumulates over years without intervention. These figures are the supervisory lag in section 2, expressed as arithmetic.

---

## The human scale

The figures above are balance-sheet deficits. The Receiver's own reporting gives the other side, what depositors were owed across **all** the resolved institutions (347 microfinance, 23 savings and loans and finance houses, 39 microcredit):

| | |
|---|---|
| Depositor claims received | **over 360,000** |
| Value of claims | **~GHS 6.4 billion** |
| Validated claims | ~GHS 5.4 billion |
| Share paid | ~96% (GHS 2.13bn cash, remainder in bonds) |
| Public money committed | **GHS 5 billion** |

> [!WARNING]
> **These are not comparable to the GHS 2.30bn above**
> The GHS 2.30bn is the net-worth deficit of the **23 savings and loans companies only**. The GHS 6.4bn is depositor claims across **all 409 resolved institutions**. Different denominators, different measures. Never put them in the same sentence without saying so.

What the two together do establish: this was not a technical failure inside a small sector. Over a third of a million people had money they could not reach, and the state committed GHS 5 billion of public funds to make them whole, while, on the evidence in section 1, the money had in most cases gone to the owners.

---

## What this means

Three conclusions, in order of confidence:

1. **This was a governance failure before it was a financial one.** Undercapitalisation was the mechanism; related-party lending, on the regulator’s stated reasons, was the cause. Minimum capital requirements, the main policy response, do not address the behaviour those notices describe.
2. **Detection worked; consequence did not follow.** The Bank of Ghana identified insolvency correctly and early in most cases, and section 123(1) obliged it to revoke. It did revoke, on average two and a half years later. Act 930 sets no period within which that must happen, so the delay breached nothing. The gap was between detection and consequence, and depositors funded it.
3. **The concentration suggests targeted supervision would have worked.** Five institutions account for two-thirds of the deficit. They were identifiable years in advance.

What follows from these is set out in **Recommendations** below.

---

## Recommendations

Every recommendation below is tied to a specific finding above. The starting point is uncomfortable and important:

> [!IMPORTANT]
> **The rules were mostly already there.** Act 930 s.64(2) capped related-party exposure at 25% of net own funds; CDH was at **319%**, Legacy Capital at **200%**. Sections 28(1) and 29(2) set minimum net worth and capital adequacy, every one of these institutions breached them, some for years. The Bank of Ghana's own on-site examinations identified the problems and made recommendations; six institutions simply ignored them.
>
> This was not a gap in regulation. It was a gap between detection and consequence. Recommendations that propose new rules miss the point.

### 1. Attach a deadline to section 123(1), and publish the clock

**Finding:** institutions the Bank of Ghana had determined to be insolvent held deposit-taking licences for a median of 927.5 days, two and a half years, and in one case nine and a half years.

This recommendation has been through two reversals, and both are worth recording. The first draft proposed creating a statutory clock. The second withdrew it, on the belief that sections 104 to 106 already supplied one. **Checking those sections properly showed that they do not**: their 180-day periods run from a Bank of Ghana order or from an agreement with the institution's board, not from insolvency, and no public document shows that either was ever made here. The duty actually engaged is section 123(1), and **Act 930 attaches no period to it at all.**

So the first draft was right. There is a gap in the statute, not merely in its application.

**Recommend:**
- **Set a statutory period in section 123(1).** Once the Bank of Ghana determines that an institution is insolvent, revocation or official administration should follow within a defined number of days. Any period would be an improvement on the present position, which is none.
- **Publish the clock.** For every institution under corrective action, the date a determination was made and the date any period expires, disclosed to the market. A deadline nobody outside the supervisor can see is not a deadline; it is a discretion.
- **Require a written, published justification for every extension**, time-limited and countersigned at board level within the Bank of Ghana. Forbearance is sometimes correct, and the systemic risk of resolving many institutions at once is real. But it should be a recorded decision with a name attached, not a silence.
- **Report annually on the interval** between determination of insolvency and resolution, with its distribution. On the evidence here the median would have read two and a half years.

### 2. Treat a missing return as the trigger the Act already makes it

**Finding:** four institutions had stopped submitting prudential returns. Sterling stopped in **May 2010** and kept its licence until 2019. Ideal Finance stopped in November 2018; Alpha Capital in September 2017.

Again, the power exists. Section 107(1)(e) makes failure to cooperate with the Bank of Ghana or its examiners, *"including through concealment or failure to submit for inspection any of the books, documents or records"*, a ground for appointing an official administrator. Non-submission of returns is the plainest possible instance, and it is the cheapest signal in supervision: it requires no model and no examination, only noticing an absence.

**Recommend:** make it automatic rather than discretionary. A defined number of consecutive missed returns triggers a formal notice, then a supervisory visit, then a presumption that section 107 grounds are met. An institution should not be able to go silent for nine years and keep its licence.

### 3. Make the related-party limit enforceable, not just written

**Finding:** related-party exposure in **17 of 23**, at multiples of the statutory cap. The notice records related-party exposure of GHS 160.10m from uniCredit to uniSecurities; eight related companies at First Allied overdrawn by more than GHS 100m; and, at Global Access, a GHS 2.91m loan contracted by the majority shareholder that was injected as equity, with the liability, in the Bank of Ghana's words, “concealed as a suspense account”.

The limit existed. What was missing was visibility, supervisors could not see the affiliate structures in time, because the institutions themselves defined and reported them.

**Recommend:**
- **Beneficial-ownership disclosure** for every affiliate and connected party, filed and updated, not self-declared at examination time
- **Automated exposure reporting** against the 25% limit, computed from filed data rather than from the institution's own assertion
- **Consequences that reach individuals.** Post-2019 reform has moved here already: the Fit and Proper Persons regime now allows the Bank to disqualify directors and key management associated with defaulted related-party facilities. That is the right instrument, the open question is how often it is used.

### 4. Independently verify what stressed institutions report

**Finding:** misreporting in **15 of 23**, and the gap between reported and adjusted figures was enormous. Ideal Finance reported a capital adequacy ratio of **0.52%**; the Bank of Ghana's adjustment put it at **-52.18%**. FirsTrust reported shareholders' funds of -GHS 99.46m; adjusted, -GHS 174.10m. Of First Allied the notice states that reported deposit liabilities were “grossly understated … to conceal losses over the years”.

Supervision that relies on self-reported numbers from institutions with an incentive to misreport will always be late.

**Recommend:** risk-triggered independent verification: once an institution trips defined stress indicators, its returns are verified by an independent party at its own cost, not accepted at face value. Pair it with **auditor accountability**: Women's World Banking's external auditors did flag material going-concern uncertainty. Most did not, on institutions in far worse condition. That difference should carry consequences.

### 5. Concentrate supervision where the money is

**Finding:** five institutions account for **68%** of the GHS 2.30bn deficit, and they were identifiable years ahead.

Uniform supervisory attention across 400+ institutions guarantees that the largest exposures get proportionally the least scrutiny.

**Recommend:** explicitly tiered supervision, examination frequency and depth scaled to deposit base and risk score, with the largest and most connected institutions on a continuous rather than periodic cycle.

### 6. Keep the cost off the taxpayer next time

**Finding:** the state committed **GHS 5 billion** to pay depositors of institutions whose stated reasons for failure cite related-party exposure in 17 of 23 cases.

The **Ghana Deposit Protection Corporation**, established under Act 931 and operational from 2019, is the structural answer and it now exists. That is genuine progress.

**Recommend:** the open questions are whether coverage limits are adequate against actual deposit sizes, whether premiums are risk-weighted so that badly-run institutions pay more, and whether the fund is large enough to absorb a concentrated failure without recourse to public money. Those are answerable with data the Corporation holds.

---

## What has already been done

Honesty requires noting the reforms that followed the clean-up, so none of the above is presented as a novel insight:

| Reform | Status |
|---|---|
| Corporate Governance Directive | Issued 2018, board duties, key management criteria, tenure limits |
| Fit and Proper Persons Directive | 2019, shareholder and director assessment; disqualification powers |
| Minimum capital raised to GHS 400m | December 2018 |
| Ghana Deposit Protection Corporation | Operational 2019 under Act 931 |
| Capital Requirement, Risk Management, and further directives | 15+ issued since 2018 |
| Large Exposures Directive | September 2025 |

**The gap that remains is on the supervisor's side of the line.** Nearly all of the above governs how an institution should be run. Very little governs how quickly the supervisor must act once it has concluded that one has failed. Section 123(1) obliges the Bank of Ghana to revoke the licence of an institution it determines to be insolvent, but fixes no period in which to do it, and the 180-day periods in sections 105 and 106 run from supervisory acts that no public document records here. What is missing is a deadline on the duty that was actually engaged, and any disclosure of the interval when it runs long.

> [!NOTE]
> **Verified against Act 930 itself, August 2026.** An earlier draft recommended creating a statutory intervention clock; reading sections 104–106 showed one already existed, which changed the finding in section 2 from *"the regulator was slow"* to *"every institution breached a deadline written in the statute."* The directive table above reflects sources gathered in August 2026, check [bog.gov.gh](https://www.bog.gov.gh/) for anything issued since.

---

## Epilogue: where things stand in 2026

*As of August 2026.*

Nearly seven years after the revocations, the receivership of the 23 institutions is still running. **Eric Nana Nipah**, a director of PwC Ghana, remains the appointed Receiver, and the official receivership site at [ghreceiverships.com](https://www.ghreceiverships.com/) continues to carry active notices, demands to borrowers of the resolved institutions to settle outstanding loans, and public auctions of assets, the most recent dated February 2026. No final consolidated receivership report has been published.

On **21 May 2026** the Court of Appeal ordered the Bank of Ghana to restore the licence of **GN Savings and Loans**, one of the 23 institutions in this dataset. The three-member panel overturned an earlier High Court decision that had upheld the revocation, ruled the 2019 revocation **"unfair and unreasonable"**, and directed the Receiver to hand the company's assets and control back to its shareholders.

The Bank of Ghana appealed to the Supreme Court, which on **14 July 2026** stayed the Court of Appeal's judgment in full pending determination of that appeal. The licence has therefore not been restored, and the position established in 2019 stands for now. The final outcome is pending as of August 2026.

> [!IMPORTANT]
> **What this means for this analysis.** The dataset records the reasons the Bank of Ghana stated at the time of revocation, as published in its notice of 16 August 2019. That document is unchanged, and nothing in the analysis above has been revised in light of the litigation. What has changed is that the legal status of one of the 23 revocations is now contested, and depending on how the Supreme Court rules, the final count of institutions whose licences were validly revoked could differ from the 23 recorded here. This project takes no position on the litigation.

Sources: [Citi Newsroom, Court of Appeal orders BoG to restore GN Bank licence and assets](https://www.citinewsroom.com/2026/05/court-of-appeal-orders-bog-to-restore-gn-bank-licence-assets/), May 2026 · [Citi Newsroom, Supreme Court halts reinstatement of GN Savings licence](https://www.citinewsroom.com/2026/07/supreme-court-halts-reinstatement-of-gn-savings-licence/), July 2026 · [Office of the Receiver](https://www.ghreceiverships.com/), notices to February 2026.

---

## Notice

This project analyses documents published by the Bank of Ghana and other public sources. **It reports what those documents state. It does not independently allege wrongdoing by any institution or any individual.**

- **Every factual claim about a named institution comes from the Bank of Ghana's published notices**, which are archived in [`sources/`](sources/) so that any reader can check the original wording for themselves.
- **The failure causes are the Bank of Ghana's assessment, not the author's.** They are coded from the reasons the Bank stated, in documents written to justify decisions it had already taken, and they may not be exhaustive. Where an institution is not coded for a cause, that is not evidence the cause was absent, only that the Bank did not cite it.
- **Some matters remain before the courts.** In May 2026 the Court of Appeal ordered the licence of GN Savings and Loans restored; the Supreme Court stayed that order in July 2026 and the appeal is undetermined. See the [Epilogue](#epilogue-where-things-stand-in-2026). This project takes no position on that or any other proceeding, and nothing here should be read as commenting on their merits.
- **Where individual institutions are used as examples**, this analysis draws on institutions whose revocations are not currently before the courts. The dataset itself is complete: it records every institution named in the Bank of Ghana's notice, including any whose status is contested.
- **The author worked on the receivership of these institutions.** This analysis uses only publicly published documents. No information obtained during that engagement has been used, and none of it appears here.
- Nothing in this repository is legal, financial or investment advice.

**Corrections are welcome and will be made.** If you believe anything here misstates a published document, misattributes a figure, or is out of date, please [open an issue](https://github.com/SamuelAtokwamebaah/ghana-banking-collapse/issues) or contact me. Corrections will be applied and recorded in the commit history, which is public.

---

## Caveats

- **23 institutions is a small n.** These are descriptive findings, not statistical ones. No significance is claimed and none should be.
- **The legal status of one of the 23 revocations is contested.** In May 2026 the Court of Appeal ordered GN Savings and Loans’ licence restored; the Supreme Court stayed that order in July 2026 and the appeal is undetermined as of August 2026. This dataset records what the Bank of Ghana stated in 2019 and is unrevised, but the final count could differ. See the [Epilogue](#epilogue-where-things-stand-in-2026).
- **Causes are as stated by the regulator**, hand-coded from the notice. They reflect what BoG chose to publish, which may not be exhaustive and is written to justify a decision already taken.
- **"Insolvent since" dates are as stated in the notice**, sometimes as a month, sometimes only a year. Year-only dates were treated as January, which *understates* the lag if anything.
- **Per-institution deposit values are absent** from the public record, not on the Receiver's site, not in the BoG notices. Sector aggregates exist and are used below; the route to institution-level figures is set out in [Sourcing - Deposits and Depositors](docs/sourcing-deposits.md).

---

## Optional extensions

The analysis above is complete and stands on its own. These would broaden it, not fix it.

- [x] ~~Chart the related-party / misreporting co-occurrence~~, done, `charts.html`
- [x] ~~Timeline chart: insolvency to revocation~~, done, `charts.html`
- [ ] Repeat this analysis for the 347 microfinance companies, but note the BoG notice gives **no** per-institution reasons for those, so it will be structural rather than causal
- [x] ~~Per-institution deposit figures~~, **not pursued.** Not public, and an RTI request to BoG would very likely be refused under the supervisory-confidentiality exemptions. The analysis does not depend on them.

---

> [!NOTE]
> **The oldest institution on the list**
> First Ghana Savings and Loans is one of only six of the 23 with **no** related-party lending in its stated causes, and it carries one of the shortest cause lists in the dataset. It was established in **1956 as First Ghana Building Society** under the Building Societies Ordinance of 1955, which makes it older than the country.
>
> It failed on capital, not on conduct. That is a real distinction, and it is invisible to a depositor standing at the counter.
