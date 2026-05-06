"""
Convert Antecol et al. (2018) Stata logs to LaTeX tables.
Tables 2-9 + Figures referenced.
"""
import re, os

outdir = os.path.dirname(os.path.abspath(__file__))

def stars(p):
    if p <= 0.01: return '***'
    if p <= 0.05: return '**'
    if p <= 0.1: return '*'
    return ''

def parse_lincom(log_text):
    """Parse all lincom (1) results from Stata log."""
    results = []
    for m in re.finditer(
        r'\s+\(1\)\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+[-.0-9e+]+\s+([0-9.]+)',
        log_text
    ):
        coef = m.group(1)
        se = m.group(2)
        p = float(m.group(3))
        results.append((coef, se, p))
    return results

def parse_reg_nobs(log_text):
    """Parse number of observations from regression output."""
    nobs = []
    for m in re.finditer(r'Number of obs\s*=\s*([0-9,]+)', log_text):
        nobs.append(m.group(1).replace(',', ''))
    return nobs

# =============================================================================
# TABLE 2: Main Results
# =============================================================================
with open(os.path.join(outdir, "table2.log"), "r") as f:
    log = f.read()

lc = parse_lincom(log)
nobs = parse_reg_nobs(log)

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{lcccc}")
tex.append("\\toprule")
tex.append(" & \\multicolumn{2}{c}{FOCS} & \\multicolumn{2}{c}{GNCS} \\\\")
tex.append("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}")
tex.append(" & Men & Women & Men & Women \\\\")
tex.append("\\midrule")

if len(lc) >= 16:
    # 4+ years: focs-men(0), focs-women(1), gncs-men(2), gncs-women(3)
    tex.append("\\multicolumn{5}{l}{\\textit{Panel A: Years 4+ of policy}} \\\\[0.3em]")
    tex.append(f"Effect & {lc[0][0]}{stars(lc[0][2])} & {lc[1][0]}{stars(lc[1][2])} & {lc[2][0]}{stars(lc[2][2])} & {lc[3][0]}{stars(lc[3][2])} \\\\")
    tex.append(f" & ({lc[0][1]}) & ({lc[1][1]}) & ({lc[2][1]}) & ({lc[3][1]}) \\\\[0.5em]")

    # Differences
    tex.append(f"GNCS$-$FOCS & {lc[4][0]}{stars(lc[4][2])} & {lc[5][0]}{stars(lc[5][2])} & & \\\\")
    tex.append(f" & ({lc[4][1]}) & ({lc[5][1]}) & & \\\\")
    tex.append(f"Male$-$Female & \\multicolumn{{2}}{{c}}{{{lc[6][0]}{stars(lc[6][2])}}} & \\multicolumn{{2}}{{c}}{{{lc[7][0]}{stars(lc[7][2])}}} \\\\")
    tex.append(f" & \\multicolumn{{2}}{{c}}{{({lc[6][1]})}} & \\multicolumn{{2}}{{c}}{{({lc[7][1]})}} \\\\[0.5em]")

    # 0-3 years
    tex.append("\\midrule")
    tex.append("\\multicolumn{5}{l}{\\textit{Panel B: Years 0--3 of policy}} \\\\[0.3em]")
    tex.append(f"Effect & {lc[8][0]}{stars(lc[8][2])} & {lc[9][0]}{stars(lc[9][2])} & {lc[10][0]}{stars(lc[10][2])} & {lc[11][0]}{stars(lc[11][2])} \\\\")
    tex.append(f" & ({lc[8][1]}) & ({lc[9][1]}) & ({lc[10][1]}) & ({lc[11][1]}) \\\\[0.5em]")
    tex.append(f"GNCS$-$FOCS & {lc[12][0]}{stars(lc[12][2])} & {lc[13][0]}{stars(lc[13][2])} & & \\\\")
    tex.append(f" & ({lc[12][1]}) & ({lc[13][1]}) & & \\\\")
    tex.append(f"Male$-$Female & \\multicolumn{{2}}{{c}}{{{lc[14][0]}{stars(lc[14][2])}}} & \\multicolumn{{2}}{{c}}{{{lc[15][0]}{stars(lc[15][2])}}} \\\\")
    tex.append(f" & \\multicolumn{{2}}{{c}}{{({lc[14][1]})}} & \\multicolumn{{2}}{{c}}{{({lc[15][1]})}} \\\\")

tex.append("\\midrule")
if nobs:
    tex.append(f"Observations & \\multicolumn{{4}}{{c}}{{{nobs[0]}}} \\\\")
tex.append("\\bottomrule")
tex.append("\\multicolumn{5}{l}{\\footnotesize Clustered SEs at university level. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table2_full.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print(f"Table 2: {len(lc)} lincom results")

# =============================================================================
# TABLE 3: Event Study
# =============================================================================
with open(os.path.join(outdir, "table3.log"), "r") as f:
    log = f.read()

lc3 = parse_lincom(log)

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{lcccc}")
tex.append("\\toprule")
tex.append(" & \\multicolumn{2}{c}{FOCS} & \\multicolumn{2}{c}{GNCS} \\\\")
tex.append("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}")
tex.append(" & Men & Women & Men & Women \\\\")
tex.append("\\midrule")

if len(lc3) >= 16:
    tex.append("\\multicolumn{5}{l}{\\textit{Panel A: 4+ years (relative to $t-1$)}} \\\\[0.3em]")
    tex.append(f"Effect & {lc3[0][0]}{stars(lc3[0][2])} & {lc3[1][0]}{stars(lc3[1][2])} & {lc3[2][0]}{stars(lc3[2][2])} & {lc3[3][0]}{stars(lc3[3][2])} \\\\")
    tex.append(f" & ({lc3[0][1]}) & ({lc3[1][1]}) & ({lc3[2][1]}) & ({lc3[3][1]}) \\\\[0.5em]")

    tex.append("\\multicolumn{5}{l}{\\textit{Panel B: 0--3 years (relative to $t-1$)}} \\\\[0.3em]")
    tex.append(f"Effect & {lc3[8][0]}{stars(lc3[8][2])} & {lc3[9][0]}{stars(lc3[9][2])} & {lc3[10][0]}{stars(lc3[10][2])} & {lc3[11][0]}{stars(lc3[11][2])} \\\\")
    tex.append(f" & ({lc3[8][1]}) & ({lc3[9][1]}) & ({lc3[10][1]}) & ({lc3[11][1]}) \\\\[0.5em]")

if len(lc3) >= 22:
    tex.append("\\multicolumn{5}{l}{\\textit{Panel C: Pre-policy (relative to $t-1$)}} \\\\[0.3em]")
    tex.append(f"$t-3$ (Men / Women) & {lc3[16][0]}{stars(lc3[16][2])} & {lc3[17][0]}{stars(lc3[17][2])} & & \\\\")
    tex.append(f" & ({lc3[16][1]}) & ({lc3[17][1]}) & & \\\\")
    tex.append(f"$t-2$ (Men / Women) & {lc3[18][0]}{stars(lc3[18][2])} & {lc3[19][0]}{stars(lc3[19][2])} & & \\\\")
    tex.append(f" & ({lc3[18][1]}) & ({lc3[19][1]}) & & \\\\")

tex.append("\\bottomrule")
tex.append("\\multicolumn{5}{l}{\\footnotesize Relative to $t-1$. Clustered SEs. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table3_full.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print(f"Table 3: {len(lc3)} lincom results")

# =============================================================================
# TABLE 4: Alternative Specifications
# =============================================================================
with open(os.path.join(outdir, "table4.log"), "r") as f:
    log = f.read()

# Split by depvar sections (each has a regression + 6 lincoms)
sections = re.split(r'---\s*Col\s*\d+:', log)
if len(sections) <= 1:
    sections = re.split(r'---\s*Col', log)

# Parse all lincoms from the entire file, grouped by 6
all_lc4 = parse_lincom(log)
n_specs = len(all_lc4) // 6
print(f"Table 4: {len(all_lc4)} lincoms = {n_specs} specifications")

col_labels = ["Baseline", "No ctrl", "Expanded", "Rank$\\times$g", "No f.int", "Endog"]

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{l" + "c"*min(6, n_specs) + "}")
tex.append("\\toprule")
tex.append(" & " + " & ".join(f"({i+1})" for i in range(min(6, n_specs))) + " \\\\")
if n_specs > 0:
    tex.append(" & " + " & ".join(col_labels[:min(6, n_specs)]) + " \\\\")
tex.append("\\midrule")

# Order: focs-men(0), focs-women(1), gncs-men(2), gncs-women(3), -f_focs(4), -f_gncs(5)
row_defs = [
    ("FOCS: Men", 0),
    ("FOCS: Women", 1),
    ("GNCS: Men", 2),
    ("GNCS: Women", 3),
    ("Gender gap (FOCS)", 4),
    ("Gender gap (GNCS)", 5),
]

for label, offset in row_defs:
    row_c = [label]
    row_s = [""]
    for s in range(min(6, n_specs)):
        idx = s * 6 + offset
        if idx < len(all_lc4):
            row_c.append(f"{all_lc4[idx][0]}{stars(all_lc4[idx][2])}")
            row_s.append(f"({all_lc4[idx][1]})")
        else:
            row_c.append("")
            row_s.append("")
    tex.append(" & ".join(row_c) + " \\\\")
    tex.append(" & ".join(row_s) + " \\\\[0.3em]")

tex.append("\\bottomrule")
tex.append("\\multicolumn{" + str(min(6, n_specs)+1) + "}{l}{\\footnotesize Dep. var.: tenure at policy univ. Clustered SEs. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table4_full.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")

# =============================================================================
# TABLE 5: Other Outcomes
# =============================================================================
with open(os.path.join(outdir, "table5.log"), "r") as f:
    log = f.read()

all_lc5 = parse_lincom(log)
n_dep5 = len(all_lc5) // 6
print(f"Table 5: {len(all_lc5)} lincoms = {n_dep5} outcomes")

dep_labels5 = [
    "Ten. any.", "Time pol.", "Leave early", "Late move",
    "Time tenure", "Jobs assoc.",
    "Down", "Up"
]

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{l" + "c"*min(8, n_dep5) + "}")
tex.append("\\toprule")
tex.append(" & " + " & ".join(f"({i+1})" for i in range(min(8, n_dep5))) + " \\\\")
tex.append(" & " + " & ".join(dep_labels5[:min(8, n_dep5)]) + " \\\\")
tex.append("\\midrule")

for label, offset in row_defs[:4]:  # focs-m, focs-w, gncs-m, gncs-w
    row_c = [label]
    row_s = [""]
    for d in range(min(8, n_dep5)):
        idx = d * 6 + offset
        if idx < len(all_lc5):
            row_c.append(f"{all_lc5[idx][0]}{stars(all_lc5[idx][2])}")
            row_s.append(f"({all_lc5[idx][1]})")
        else:
            row_c.append("")
            row_s.append("")
    tex.append(" & ".join(row_c) + " \\\\")
    tex.append(" & ".join(row_s) + " \\\\[0.3em]")

tex.append("\\bottomrule")
tex.append("\\multicolumn{" + str(min(8, n_dep5)+1) + "}{l}{\\footnotesize Clustered SEs. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table5_full.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")

# =============================================================================
# TABLE 6: Publications
# =============================================================================
with open(os.path.join(outdir, "table6.log"), "r") as f:
    log = f.read()

all_lc6 = parse_lincom(log)
n_pub = len(all_lc6) // 6
print(f"Table 6: {len(all_lc6)} lincoms = {n_pub} publication outcomes")

pub_labels = ["Top3", "Top5", "Top7", "Top9", "Oth3", "Oth5", "Oth7", "Oth9"]

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{l" + "c"*min(8, n_pub) + "}")
tex.append("\\toprule")
tex.append(" & " + " & ".join(f"({i+1})" for i in range(min(8, n_pub))) + " \\\\")
tex.append(" & " + " & ".join(pub_labels[:min(8, n_pub)]) + " \\\\")
tex.append("\\midrule")

for label, offset in row_defs[:4]:
    row_c = [label]
    row_s = [""]
    for d in range(min(8, n_pub)):
        idx = d * 6 + offset
        if idx < len(all_lc6):
            row_c.append(f"{all_lc6[idx][0]}{stars(all_lc6[idx][2])}")
            row_s.append(f"({all_lc6[idx][1]})")
        else:
            row_c.append("")
            row_s.append("")
    tex.append(" & ".join(row_c) + " \\\\")
    tex.append(" & ".join(row_s) + " \\\\[0.3em]")

tex.append("\\bottomrule")
tex.append("\\multicolumn{" + str(min(8, n_pub)+1) + "}{l}{\\footnotesize Clustered SEs. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table6_full.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")

# =============================================================================
# TABLE 7: Fertility (t-tests)
# =============================================================================
with open(os.path.join(outdir, "table7.log"), "r") as f:
    log = f.read()

# Parse ttest blocks by finding diff lines
ttests = []
for m in re.finditer(
    r'Ha:.*?Pr\(\|T\|\s*>\s*\|t\|\)\s*=\s*([0-9.]+)',
    log, re.DOTALL
):
    p = float(m.group(1))
    ttests.append(p)

# Parse means: group 0 and group 1
means = []
for m in re.finditer(
    r'^\s*(0|1)\s*\|\s*(\d+)\s+([-.0-9.]+)\s+([-.0-9.]+)',
    log, re.MULTILINE
):
    group = int(m.group(1))
    n = m.group(2)
    mean = m.group(3)
    se = m.group(4)
    means.append((group, n, mean, se))

# Parse diffs
diffs = []
for m in re.finditer(r'^\s*diff\s*\|\s+([-.0-9.]+)\s+([-.0-9.]+)', log, re.MULTILINE):
    diffs.append((m.group(1), m.group(2)))

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{lccc}")
tex.append("\\toprule")
tex.append(" & GNCS (Men) & GNCS (Women) & FOCS (Women) \\\\")
tex.append("\\midrule")

depvar_labels = ['Any birth pre-tenure', 'All births pre-tenure', 'Has children', 'Number of children']

for i, label in enumerate(depvar_labels):
    idx = i * 3  # 3 ttests per depvar
    row = [label]
    for j in range(3):
        didx = idx + j
        if didx < len(diffs) and didx < len(ttests):
            d = diffs[didx]
            p = ttests[didx]
            row.append(f"{d[0]}{stars(p)}")
        else:
            row.append("")
    tex.append(" & ".join(row) + " \\\\")
    # SE row
    se_row = [""]
    for j in range(3):
        didx = idx + j
        if didx < len(diffs):
            se_row.append(f"({diffs[didx][1]})")
        else:
            se_row.append("")
    tex.append(" & ".join(se_row) + " \\\\[0.3em]")

tex.append("\\bottomrule")
tex.append("\\multicolumn{4}{l}{\\footnotesize Difference in means (no policy $-$ policy). *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table7_full.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print(f"Table 7: {len(diffs)} t-test differences")

# =============================================================================
# TABLE 8: Balance
# =============================================================================
with open(os.path.join(outdir, "table8.log"), "r") as f:
    log = f.read()

all_lc8 = parse_lincom(log)
n_bal = len(all_lc8) // 6
print(f"Table 8: {len(all_lc8)} lincoms = {n_bal} balance outcomes")

bal_labels = ["PhD rank", "Post-doc", "Top pubs yr 1", "Other pubs yr 1"]

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{l" + "c"*min(4, n_bal) + "}")
tex.append("\\toprule")
tex.append(" & " + " & ".join(bal_labels[:min(4, n_bal)]) + " \\\\")
tex.append("\\midrule")

for label, offset in row_defs[:4]:
    row_c = [label]
    row_s = [""]
    for d in range(min(4, n_bal)):
        idx = d * 6 + offset
        if idx < len(all_lc8):
            row_c.append(f"{all_lc8[idx][0]}{stars(all_lc8[idx][2])}")
            row_s.append(f"({all_lc8[idx][1]})")
        else:
            row_c.append("")
            row_s.append("")
    tex.append(" & ".join(row_c) + " \\\\")
    tex.append(" & ".join(row_s) + " \\\\[0.3em]")

tex.append("\\bottomrule")
tex.append("\\multicolumn{" + str(min(4, n_bal)+1) + "}{l}{\\footnotesize Clustered SEs. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table8_full.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")

print("\n=== All Antecol LaTeX tables generated ===")
