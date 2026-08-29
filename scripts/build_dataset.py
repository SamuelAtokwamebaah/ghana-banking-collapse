# -*- coding: utf-8 -*-
"""Build the Ghana banking-sector cleanup dataset from Bank of Ghana primary sources."""
import io, os, re, csv

HERE = os.path.dirname(os.path.abspath(__file__))
RAW  = os.path.join(HERE, "..", "data", "raw") + os.sep
OUT  = os.path.join(HERE, "..", "data") + os.sep
SRC  = RAW   # text extracted from the BoG PDFs with: pdftotext -layout <pdf> <txt>

if not os.path.isdir(OUT):
    os.makedirs(OUT)


def read(name):
    return io.open(SRC + name, encoding="utf-8", errors="replace").read()


mfi = read("bog-2019-05-31-microfinance-revocation.txt")
mc  = read("bog-2019-05-31-microcredit-revocation.txt")
sl  = read("bog-2019-08-16-savings-loans-revocation.txt")


rows = []


def add(name, category, status, date, receiver, act, source, resolution="Receivership"):
    name = re.sub(r"\s+", " ", name).strip().strip(".")
    if not name:
        return
    rows.append(dict(institution_name=name, category=category, status=status,
                     revocation_date=date, receiver=receiver,
                     resolution_mechanism=resolution, legal_basis=act,
                     source_document=source))


# ---------- 1. Microfinance: 192 insolvent + 155 ceased ----------
annex = mfi[mfi.index("ANNEX: LIST OF 347"):]
split_at = annex.index("MICROFINANCE COMPANIES - INSOLVENT AND CEASED")
part_a, part_b = annex[:split_at], annex[split_at:]

LINE = re.compile(r"^\s*(\d+)?\s*([A-Z0-9][A-Z0-9''\.\,\&\-\s/]*(?:MICROFINANCE|MICRO FINANCE)[A-Z0-9''\.\,\&\-\s/]*)$")


def harvest(block):
    out = []
    for raw_line in block.split("\n"):
        line = raw_line.rstrip()
        if not line.strip():
            continue
        if "ANNEX" in line or "S/No" in line or "NAME OF INSTITUTION" in line:
            continue
        if "COMPANIES -" in line or "CEASED" in line and "MICROFINANCE COMPANIES" in line:
            continue
        m = LINE.match(line)
        if m:
            nm = m.group(2).strip()
            if len(nm) > 6:
                out.append(nm)
    return out


mfi_insolvent = harvest(part_a)
mfi_ceased = harvest(part_b)

for n in mfi_insolvent:
    add(n, "Microfinance", "Insolvent", "2019-05-31", "Eric Nipah (PwC)",
        "Act 930 s.123(1)", "BoG Notice, 31 May 2019 (microfinance)")
for n in mfi_ceased:
    add(n, "Microfinance", "Insolvent and ceased operations", "2019-05-31", "Eric Nipah (PwC)",
        "Act 930 s.123(1)", "BoG Notice, 31 May 2019 (microfinance)")

# ---------- 2. Microcredit: 29 insolvent + 10 ceased ----------
mc_annex = mc[mc.index("ANNEX: LIST OF 39"):]
mc_split = mc_annex.index("MICROCREDIT COMPANIES - INSOLVENT AND CEASED")
MC_LINE = re.compile(r"^\s*(?:\d+\s+)?([A-Za-z0-9][A-Za-z0-9''\.\,\&\-\s/]*(?:Money Lend|Money Lenders)[A-Za-z0-9''\.\,\&\-\s/]*)$")


def harvest_mc(block):
    out = []
    for line in block.split("\n"):
        if not line.strip() or "ANNEX" in line or "S/No" in line:
            continue
        m = MC_LINE.match(line.rstrip())
        if m:
            nm = m.group(1).strip()
            if len(nm) > 6:
                out.append(nm)
    return out


mc_insolvent = harvest_mc(mc_annex[:mc_split])
mc_ceased = harvest_mc(mc_annex[mc_split:])

for n in mc_insolvent:
    add(n, "Microcredit / money lending", "Insolvent", "2019-05-31", "Not applicable (wound up via Registrar)",
        "Act 774 s.7", "BoG Notice, 31 May 2019 (microcredit)",
        resolution="Wound up via the Registrar of Companies")
for n in mc_ceased:
    add(n, "Microcredit / money lending", "Insolvent and ceased operations", "2019-05-31",
        "Not applicable (wound up via Registrar)", "Act 774 s.7", "BoG Notice, 31 May 2019 (microcredit)",
        resolution="Wound up via the Registrar of Companies")

# ---------- 3. Savings & loans / finance houses: 23 ----------
sl_annex = sl[sl.index("ANNEX 1"):sl.index("ANNEX 2")]
SL_LINE = re.compile(r"^\s*(\d{1,2})\s+(.+?)\s{2,}(Savings and Loans Company|Finance House)\s*$")
sl_rows = []
for line in sl_annex.split("\n"):
    m = SL_LINE.match(line.rstrip())
    if m:
        sl_rows.append((int(m.group(1)), m.group(2).strip(), m.group(3).strip()))
# entry 23 wraps onto two lines in the PDF
if not any(r[0] == 23 for r in sl_rows):
    sl_rows.append((23, "Women's World Banking Savings and Loans Co. Ltd.", "Savings and Loans Company"))

for _, nm, lic in sl_rows:
    add(nm, lic, "Insolvent", "2019-08-16", "Eric Nipah (PwC)", "Act 930 s.123(1)",
        "BoG Notice, 16 Aug 2019 (savings & loans / finance houses)")

# ---------- 4. Banks (from BoG press releases; see sources note) ----------
# The receiver and the resolution mechanism are two different facts and are
# recorded separately. An earlier version put "Consolidated into Consolidated
# Bank Ghana" in the receiver column for seven of these banks; that is not a
# receiver, and it misdescribes CBG, which is a bridge institution under
# Act 930 s.127(11) rather than a consolidation of the banks it served.
# See docs/universal-banks.md.
#
# Premium Bank and Heritage Bank are left blank: the source that corroborates
# the others does not cover them, and a guess is worse than a documented gap.
VERIFIED = ("BoG press releases 2017-2018; corroborated in "
            "Bediako, Agyei & Asabre, GIRJ 3rd edn Vol 1(1), Dec 2025")
UNVERIFIED = "BoG press releases 2019 - VERIFY against primary source"

BANKS = [
    ("UT Bank Ltd.", "2017-08-14", "PwC", "Purchase and assumption by GCB Bank", VERIFIED),
    ("Capital Bank Ltd.", "2017-08-14", "PwC", "Purchase and assumption by GCB Bank", VERIFIED),
    ("uniBank Ghana Ltd.", "2018-08-01", "Nii Amanor Dodoo (KPMG)", "Bridge institution: Consolidated Bank Ghana (Act 930 s.127(11))", VERIFIED),
    ("The Royal Bank Ltd.", "2018-08-01", "Nii Amanor Dodoo (KPMG)", "Bridge institution: Consolidated Bank Ghana (Act 930 s.127(11))", VERIFIED),
    ("Beige Bank Ltd.", "2018-08-01", "Nii Amanor Dodoo (KPMG)", "Bridge institution: Consolidated Bank Ghana (Act 930 s.127(11))", VERIFIED),
    ("Sovereign Bank Ltd.", "2018-08-01", "Nii Amanor Dodoo (KPMG)", "Bridge institution: Consolidated Bank Ghana (Act 930 s.127(11))", VERIFIED),
    ("Construction Bank Ltd.", "2018-08-01", "Nii Amanor Dodoo (KPMG)", "Bridge institution: Consolidated Bank Ghana (Act 930 s.127(11))", VERIFIED),
    ("Premium Bank Ltd.", "2019-01-04", "", "", UNVERIFIED),
    ("Heritage Bank Ltd.", "2019-01-04", "", "", UNVERIFIED),
]
for nm, dt, receiver, resolution, src in BANKS:
    rows.append(dict(institution_name=nm, category="Universal bank", status="Licence revoked",
                     revocation_date=dt, receiver=receiver, resolution_mechanism=resolution,
                     legal_basis="Act 930 s.123(1)", source_document=src))

# ---------- write master file ----------
cols = ["institution_name", "category", "status", "revocation_date", "receiver",
        "resolution_mechanism", "legal_basis", "source_document"]
with io.open(OUT + "defunct_institutions.csv", "w", encoding="utf-8", newline="") as f:
    w = csv.DictWriter(f, fieldnames=cols)
    w.writeheader()
    for r in rows:
        w.writerow(r)

# ---------- 5. Savings & loans financials from Annex 2 ----------
ann2 = sl[sl.index("ANNEX 2"):]
blocks = re.split(r"\n\s*(\d{1,2})\.\s+([A-Z][A-Z\s&''\.\,\-]{8,})\n", ann2)
fin = []
for i in range(1, len(blocks) - 1, 3):
    num, nm, body = blocks[i], blocks[i + 1].strip(), blocks[i + 2]
    body = body.replace("\ufffd", "")
    nw = re.search(r"[Nn]et\s*worth of (negative\s*)?GH[^\d]{0,4}([\d,]+\.?\d*)\s*(million|billion)", body)
    car = re.search(r"capital adequacy ratio of (negative\s*)?\(?-?([\d,]+\.?\d*)\)?\s*%", body)
    inc = re.search(r"incorporated[^.]{0,80}?(?:on|in)\s+((?:\d{1,2}(?:st|nd|rd|th)?\s+)?[A-Z][a-z]+,?\s+\d{4})", body)
    fin.append(dict(
        institution_name=nm.title().strip(),
        net_worth_ghs_million=("-" if nw and nw.group(1) else "") + (nw.group(2).replace(",", "") if nw else ""),
        net_worth_unit=(nw.group(3) if nw else ""),
        capital_adequacy_ratio_pct=("-" if car and car.group(1) else "") + (car.group(2).replace(",", "") if car else ""),
        incorporated=(inc.group(1) if inc else ""),
        related_party_issues="Y" if re.search(r"related part", body, re.I) else "",
        governance_failure="Y" if re.search(r"corporate governance|Board and (Senior )?Management oversight", body, re.I) else "",
        liquidity_failure="Y" if re.search(r"liquidit|withdraw", body, re.I) else "",
        misreporting="Y" if re.search(r"creative accounting|misreport|misrepresent|conceal", body, re.I) else "",
        high_npl="Y" if re.search(r"non-performing loan|high NPL|underwriting", body, re.I) else "",
    ))

fcols = ["institution_name", "net_worth_ghs_million", "net_worth_unit", "capital_adequacy_ratio_pct",
         "incorporated", "related_party_issues", "governance_failure", "liquidity_failure",
         "misreporting", "high_npl"]
with io.open(OUT + "savings_loans_financials.csv", "w", encoding="utf-8", newline="") as f:
    w = csv.DictWriter(f, fieldnames=fcols)
    w.writeheader()
    for r in fin:
        w.writerow(r)

print("MFI insolvent      :", len(mfi_insolvent), "(expected 192)")
print("MFI ceased         :", len(mfi_ceased), "(expected 155)")
print("Microcredit insolv :", len(mc_insolvent), "(expected 29)")
print("Microcredit ceased :", len(mc_ceased), "(expected 10)")
print("Savings & loans    :", len(sl_rows), "(expected 23)")
print("Banks              :", len(BANKS))
print("TOTAL ROWS         :", len(rows))
print("S&L financial rows :", len(fin), "(expected 23)")
print("  with net worth   :", sum(1 for r in fin if r["net_worth_ghs_million"]))
print("  with CAR         :", sum(1 for r in fin if r["capital_adequacy_ratio_pct"]))
