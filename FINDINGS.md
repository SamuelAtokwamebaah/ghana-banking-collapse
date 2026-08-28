# What Killed Ghana's Savings & Loans Companies

Analysis of the 23 savings and loans companies and finance houses whose licences the Bank of Ghana revoked on 16 August 2019. Every figure is from Annex 2 of [the BoG notice](https://www.bog.gov.gh/wp-content/uploads/2019/08/Revocation-of-Licenses-of-SDIs-16.8.19.pdf), hand-transcribed in `build_sl_verified.py`.

**Headline:** these institutions did not fail from bad luck or a difficult market. In 17 of 23 cases the money went to the owners.

---

## 1. Related-party lending is the dominant failure mode

| Stated cause | Institutions | Share |
|---|---|---|
| Liquidity failure — could not meet withdrawals | 21 | 91% |
| **Related-party exposure** | **17** | **74%** |
| Misreporting / false accounting records | 15 | 65% |
| High non-performing loans | 14 | 61% |
| Governance failure | 10 | 43% |
| Unauthorised structural change | 7 | 30% |
| Ignored BoG examination findings | 6 | 26% |
| Failed to publish audited accounts | 4 | 17% |
| Stopped submitting prudential returns | 4 | 17% |
| Ceased operations without approval | 3 | 13% |

Liquidity failure at 91% is the *symptom* — it is what a depositor experiences and what triggers the complaint to the regulator. The cause sits above it.

**Related-party exposure appears in 17 of 23. And 14 of those 17 also involved misreporting.** That co-occurrence is the finding. It is not two separate problems; it is one behaviour and its cover-up. Money moved to companies the owners controlled, and the accounts were then kept in a way that hid it.

The specifics are unambiguous:
- **GN Savings** placed **GHS 761.55m** with sister companies in the Groupe Nduom network, and transferred **USD 62.26m** of depositor funds to a US affiliate with no supporting documentation.
- **uniCredit** had **GHS 160.10m** non-performing with sister company uniSecurities — more than its entire net-worth deficit.
- **CDH** was exposed to affiliates at **319%** against a 25% regulatory limit.
- **Global Access** assumed a **GHS 2.91m** personal loan of its majority shareholder, booked it as equity, and concealed the liability in a suspense account.
- **First Allied** had eight related companies overdrawn by more than **GHS 100m**, and understated deposit liabilities to conceal years of losses.

## 2. The regulator knew, on average, two and a half years early

Comparing the date the BoG states each institution became insolvent against the 16 August 2019 revocation:

| | |
|---|---|
| Median time insolvent before revocation | **2.6 years** |
| Insolvent more than 2 years | **12 of 20** |
| Longest | **9.5 years** — Sterling Financial Services |

**Sterling is the case that should not exist.** It reported a capital adequacy ratio of **-1,469%** as at March 2010. It stopped submitting returns in May 2010 and folded its operations in 2011 without telling the Bank of Ghana. Its licence was revoked in **August 2019** — eight years after it ceased to exist and nine after the regulator had the numbers.

Every month of that lag is a month in which an insolvent institution could legally take deposits. This is the policy finding, and it is more important than any individual failure.

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

**One institution reported a positive net worth: ASN Financial Services**, at GHS 628,311. It was revoked anyway — CAR of -81%, insolvent since October 2016, and operating without a functioning board.

## 4. Capital adequacy ratios past the point of meaning

The regulatory minimum was +10%. Reported ratios included **-7,508%** (Dream Finance), **-6,873%** (Crest), and **-1,469%** (Sterling).

A CAR of -7,508% is not a capital shortfall. It is an institution whose liabilities exceed its assets by seventy-five times its required capital — a number that only accumulates over years without intervention. These figures are the supervisory lag in section 2, expressed as arithmetic.

---

## What this means

Three conclusions, in order of confidence:

1. **This was a governance failure before it was a financial one.** Undercapitalisation was the mechanism; related-party extraction was the cause. Minimum capital requirements — the main policy response — do not address the behaviour that emptied these institutions.
2. **Supervisory timing mattered more than supervisory standards.** The BoG identified insolvency correctly and early in most cases. The gap was between detection and action, and depositors funded that gap.
3. **The concentration suggests targeted supervision would have worked.** Five institutions account for two-thirds of the deficit. They were identifiable years in advance.

---

## Caveats

- **23 institutions is a small n.** These are descriptive findings, not statistical ones. No significance is claimed and none should be.
- **Causes are as stated by the regulator**, hand-coded from the notice. They reflect what BoG chose to publish, which may not be exhaustive and is written to justify a decision already taken.
- **"Insolvent since" dates are as stated in the notice**, sometimes as a month, sometimes only a year. Year-only dates were treated as January, which *understates* the lag if anything.
- **Per-institution deposit values are absent** from the public record — not on the Receiver's site, not in the BoG notices. Sector aggregates exist and are used below; the route to institution-level figures is set out in [Sourcing - Deposits and Depositors](docs/sourcing-deposits.md).

---

## The human scale

The figures above are balance-sheet deficits. The Receiver's own reporting gives the other side — what depositors were owed across **all** the resolved institutions (347 microfinance, 23 savings and loans and finance houses, 39 microcredit):

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

What the two together do establish: this was not a technical failure inside a small sector. Over a third of a million people had money they could not reach, and the state committed GHS 5 billion of public funds to make them whole — while, on the evidence in section 1, the money had in most cases gone to the owners.

---

## Optional extensions

The analysis above is complete and stands on its own. These would broaden it, not fix it.

- [x] ~~Chart the related-party / misreporting co-occurrence~~ — done, `charts.html`
- [x] ~~Timeline chart: insolvency to revocation~~ — done, `charts.html`
- [ ] Repeat this analysis for the 347 microfinance companies — but note the BoG notice gives **no** per-institution reasons for those, so it will be structural rather than causal
- [x] ~~Per-institution deposit figures~~ — **not pursued.** Not public, and an RTI request to BoG would very likely be refused under the supervisory-confidentiality exemptions. The analysis does not depend on them.

---

> [!NOTE]
> **Personal note for the write-up**
> **First Ghana Savings and Loans** — the institution whose Adabraka branch you managed — is one of only six of the 23 with **no** related-party lending in its stated causes, and one of the shortest cause lists in the dataset. It was established in **1956 as First Ghana Building Society**, under the Building Societies Ordinance of 1955, making it the oldest institution here and older than the country.
>
> It failed on capital, not on conduct. That distinction is invisible to a depositor at the counter, which is exactly the thing you can write about and no other analyst can.
