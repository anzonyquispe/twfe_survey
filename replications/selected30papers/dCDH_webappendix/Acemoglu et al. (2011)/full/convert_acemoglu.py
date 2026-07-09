"""
Convert Acemoglu et al. (2011) Stata logs to LaTeX tables.
Tables 2-6: Summary stats, panel FE, robustness, agriculture/industry, IV.
"""
import re, os

outdir = os.path.dirname(os.path.abspath(__file__))

def stars(p):
    if p <= 0.01: return '***'
    if p <= 0.05: return '**'
    if p <= 0.10: return '*'
    return ''

# =============================================================================
# TABLE 3: Panel FE results (from table3.log)
# =============================================================================
logfile = os.path.join(outdir, "table3.log")
with open(logfile, "r") as f:
    log = f.read()

# Parse xtreg results: coefficient rows for fpresence interaction terms
cols = []
for m in re.finditer(
    r'Table 3, Column (\d+).*?\n'
    r'(.*?)'
    r'(?=---\s*Table 3|log close)',
    log, re.DOTALL
):
    col_num = m.group(1)
    block = m.group(2)

    coefs = {}
    for var in ['fpresence1750', 'fpresence1800', 'fpresence1850', 'fpresence1875', 'fpresence1900']:
        # Match abbreviated or full variable names
        short = var.replace('fpresence', 'fpresen~')
        pattern = rf'(?:{re.escape(var)}|{re.escape(short)})\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+[-.0-9e+]+\s+([0-9.]+)'
        vm = re.search(pattern, block)
        if vm:
            coefs[var] = (vm.group(1), vm.group(2), float(vm.group(3)))

    nobs = re.search(r'Number of obs\s*=\s*([0-9,]+)', block)
    ngroups = re.search(r'Number of groups\s*=\s*([0-9,]+)', block)
    pjoint = re.search(r'Prob > F\s*=\s*([0-9.]+)\s*$', block, re.MULTILINE)
    # Get the p-value from the test command
    ptest = re.search(r'Prob > F\s*=\s*([0-9.]+)\s*\n\s*\n\. local test', block)

    cols.append({
        'num': col_num,
        'coefs': coefs,
        'nobs': nobs.group(1) if nobs else '',
        'ngroups': ngroups.group(1) if ngroups else '',
    })

# Build Table 3 LaTeX
col_titles = ["W.Elbe, wgt", "W.Elbe, unwgt", "All, wgt", "All, unwgt"]
ncols = len(cols)

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{l" + "c"*ncols + "}")
tex.append("\\toprule")
tex.append(" & " + " & ".join(f"({i+1})" for i in range(ncols)) + " \\\\")
tex.append(" & " + " & ".join(col_titles[:ncols]) + " \\\\")
tex.append("\\midrule")

for var, label in [
    ('fpresence1750', 'French presence $\\times$ 1750'),
    ('fpresence1800', 'French presence $\\times$ 1800'),
    ('fpresence1850', 'French presence $\\times$ 1850'),
    ('fpresence1875', 'French presence $\\times$ 1875'),
    ('fpresence1900', 'French presence $\\times$ 1900'),
]:
    row_c = [label]
    row_s = [""]
    for col in cols:
        if var in col['coefs']:
            c, s, p = col['coefs'][var]
            row_c.append(f"{c}{stars(p)}")
            row_s.append(f"({s})")
        else:
            row_c.append("")
            row_s.append("")
    tex.append(" & ".join(row_c) + " \\\\")
    tex.append(" & ".join(row_s) + " \\\\[0.3em]")

tex.append("\\midrule")
row_n = ["Observations"] + [col['nobs'] for col in cols]
tex.append(" & ".join(row_n) + " \\\\")
row_g = ["States"] + [col['ngroups'] for col in cols]
tex.append(" & ".join(row_g) + " \\\\")

tex.append("\\bottomrule")
tex.append("\\multicolumn{" + str(ncols+1) + "}{l}{\\footnotesize Panel FE with clustered SEs. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table3_full.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print(f"Table 3: {ncols} columns")

# =============================================================================
# TABLE 4: Robustness (from table4.log) - first 7 columns (xtreg)
# =============================================================================
logfile = os.path.join(outdir, "table4.log")
with open(logfile, "r") as f:
    log = f.read()

cols4 = []
# Parse each column header
for m in re.finditer(
    r'Table 4, Column (\d+):?\s*(.*?)\s*---\s*\n'
    r'(.*?)'
    r'(?=---\s*Table 4|log close)',
    log, re.DOTALL
):
    col_num = m.group(1)
    col_label = m.group(2).strip()
    block = m.group(3)

    coefs = {}
    for var in ['fpresence1750', 'fpresence1800', 'fpresence1850', 'fpresence1875', 'fpresence1900']:
        short = var.replace('fpresence', 'fpresen~')
        pattern = rf'(?:{re.escape(var)}|{re.escape(short)})\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+[-.0-9e+]+\s+([0-9.]+)'
        vm = re.search(pattern, block)
        if vm:
            coefs[var] = (vm.group(1), vm.group(2), float(vm.group(3)))

    nobs = re.search(r'Number of obs\s*=\s*([0-9,]+)', block)

    cols4.append({
        'num': col_num,
        'label': col_label,
        'coefs': coefs,
        'nobs': nobs.group(1) if nobs else '',
    })

# If parsing by headers failed, try a simpler approach
if len(cols4) == 0:
    # Split by the "---" markers
    sections = re.split(r'--- Table 4, Column (\d+):', log)
    for i in range(1, len(sections), 2):
        col_num = sections[i]
        block = sections[i+1] if i+1 < len(sections) else ""
        label_m = re.match(r'\s*(.*?)\s*---', block)
        label = label_m.group(1) if label_m else ""

        coefs = {}
        for var in ['fpresence1750', 'fpresence1800', 'fpresence1850', 'fpresence1875', 'fpresence1900']:
            short = var.replace('fpresence', 'fpresen~')
            pattern = rf'(?:{re.escape(var)}|{re.escape(short)})\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+[-.0-9e+]+\s+([0-9.]+)'
            vm = re.search(pattern, block)
            if vm:
                coefs[var] = (vm.group(1), vm.group(2), float(vm.group(3)))

        nobs = re.search(r'Number of obs\s*=\s*([0-9,]+)', block)
        cols4.append({
            'num': col_num,
            'label': label,
            'coefs': coefs,
            'nobs': nobs.group(1) if nobs else '',
        })

col4_titles = ["Excl Berl.", "Protest.", "Latit.", "Longit.", "Dist Par.", "Territ.", "Init Urb.", "GMM"]

ncols4 = min(len(cols4), 8)
tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{l" + "c"*ncols4 + "}")
tex.append("\\toprule")
tex.append(" & " + " & ".join(f"({i+1})" for i in range(ncols4)) + " \\\\")
tex.append(" & " + " & ".join(col4_titles[:ncols4]) + " \\\\")
tex.append("\\midrule")

for var, label in [
    ('fpresence1750', 'F.pres. $\\times$ 1750'),
    ('fpresence1800', 'F.pres. $\\times$ 1800'),
    ('fpresence1850', 'F.pres. $\\times$ 1850'),
    ('fpresence1875', 'F.pres. $\\times$ 1875'),
    ('fpresence1900', 'F.pres. $\\times$ 1900'),
]:
    row_c = [label]
    row_s = [""]
    for col in cols4[:ncols4]:
        if var in col['coefs']:
            c, s, p = col['coefs'][var]
            row_c.append(f"{c}{stars(p)}")
            row_s.append(f"({s})")
        else:
            row_c.append("")
            row_s.append("")
    tex.append(" & ".join(row_c) + " \\\\")
    tex.append(" & ".join(row_s) + " \\\\[0.3em]")

tex.append("\\midrule")
row_n = ["Observations"] + [col['nobs'] for col in cols4[:ncols4]]
tex.append(" & ".join(row_n) + " \\\\")

tex.append("\\bottomrule")
tex.append("\\multicolumn{" + str(ncols4+1) + "}{l}{\\footnotesize Cols 1--7: Panel FE. Col 8: Arellano-Bond GMM. Clustered SEs. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table4_full.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print(f"Table 4: {ncols4} columns")

# =============================================================================
# TABLE 5: Agriculture/Industry (from table5.log if exists)
# =============================================================================
t5_file = os.path.join(outdir, "table5.log")
if os.path.exists(t5_file):
    with open(t5_file, "r") as f:
        log = f.read()

    # Parse all reg results for fpresence
    t5_results = []
    for m in re.finditer(
        r'Table 5, Col (\d+), year (\d+).*?\n'
        r'(.*?)'
        r'(?=---\s*Table 5|log close)',
        log, re.DOTALL
    ):
        col = m.group(1)
        year = m.group(2)
        block = m.group(3)

        fp_match = re.search(r'fpresence\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+[-.0-9e+]+\s+([0-9.]+)', block)
        nobs = re.search(r'Number of obs\s*=\s*([0-9,]+)', block)

        if fp_match:
            t5_results.append({
                'col': col, 'year': year,
                'coef': fp_match.group(1), 'se': fp_match.group(2),
                'p': float(fp_match.group(3)),
                'n': nobs.group(1) if nobs else ''
            })

    # Build a summary table: rows=years, cols=specifications
    years_t5 = sorted(set(r['year'] for r in t5_results))
    col_groups = sorted(set(r['col'] for r in t5_results))

    t5_labels = {
        '1': 'Agric, W.Elbe wgt', '2': 'Agric, W.Elbe unwgt', '3': 'Agric, All wgt',
        '4': 'Ind, W.Elbe wgt', '5': 'Ind, W.Elbe unwgt', '6': 'Ind, All wgt',
    }

    tex = []
    tex.append("\\begin{adjustbox}{max width=\\textwidth}")
    tex.append("\\begin{tabular}{l" + "c"*len(col_groups) + "}")
    tex.append("\\toprule")
    tex.append(" & " + " & ".join(f"({c})" for c in col_groups) + " \\\\")
    tex.append(" & " + " & ".join(t5_labels.get(c, c) for c in col_groups) + " \\\\")
    tex.append("\\midrule")

    for yr in years_t5:
        row_c = [yr]
        row_s = [""]
        for cg in col_groups:
            r = next((x for x in t5_results if x['year'] == yr and x['col'] == cg), None)
            if r:
                row_c.append(f"{r['coef']}{stars(r['p'])}")
                row_s.append(f"({r['se']})")
            else:
                row_c.append("")
                row_s.append("")
        tex.append(" & ".join(row_c) + " \\\\")
        tex.append(" & ".join(row_s) + " \\\\[0.3em]")

    tex.append("\\bottomrule")
    tex.append("\\multicolumn{" + str(len(col_groups)+1) + "}{l}{\\footnotesize Cross-sectional OLS. Clustered SEs. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
    tex.append("\\end{tabular}")
    tex.append("\\end{adjustbox}")

    with open(os.path.join(outdir, "table5_full.tex"), "w") as f:
        f.write("\n".join(tex) + "\n")
    print(f"Table 5: {len(t5_results)} regressions across {len(years_t5)} years x {len(col_groups)} cols")
else:
    print("Table 5 log not yet available")

# =============================================================================
# TABLE 6: IV (from table6.log if exists)
# =============================================================================
t6_file = os.path.join(outdir, "table6.log")
if os.path.exists(t6_file):
    with open(t6_file, "r") as f:
        log = f.read()

    # Parse IV results: yearsref coefficient
    t6_results = []
    for m in re.finditer(
        r'Table 6, Column (\d+).*?\n'
        r'(.*?)'
        r'(?=---\s*Table 6|log close)',
        log, re.DOTALL
    ):
        col = m.group(1)
        block = m.group(2)

        yr_match = re.search(r'yearsref\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+[-.0-9e+]+\s+([0-9.]+)', block)
        fp_match = re.search(r'fpresenceXpostXtrend\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+[-.0-9e+]+\s+([0-9.]+)', block)
        if yr_match:
            t6_results.append({
                'col': col, 'var': 'yearsref',
                'coef': yr_match.group(1), 'se': yr_match.group(2),
                'p': float(yr_match.group(3)),
            })
        if fp_match:
            t6_results.append({
                'col': col, 'var': 'fpXpXt',
                'coef': fp_match.group(1), 'se': fp_match.group(2),
                'p': float(fp_match.group(3)),
            })

    tex = []
    tex.append("\\begin{adjustbox}{max width=\\textwidth}")
    tex.append("\\begin{tabular}{lcccc}")
    tex.append("\\toprule")
    tex.append(" & (1) W.Elbe wgt & (2) Overid & (3) W.Elbe unwgt & (4) All wgt \\\\")
    tex.append("\\midrule")

    # Show yearsref results per column
    for c in ['1', '2', '3', '4']:
        r = next((x for x in t6_results if x['col']==c and x['var']=='yearsref'), None)
        if r:
            tex.append(f"Years reform & {r['coef']}{stars(r['p'])} \\\\")
            tex.append(f" & ({r['se']}) \\\\")

    tex.append("\\bottomrule")
    tex.append("\\end{tabular}")
    tex.append("\\end{adjustbox}")

    with open(os.path.join(outdir, "table6_full.tex"), "w") as f:
        f.write("\n".join(tex) + "\n")
    print(f"Table 6: {len(t6_results)} IV results")
else:
    print("Table 6 log not yet available")

print("\n=== Acemoglu LaTeX tables generated ===")
