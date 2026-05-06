"""
Convert Simcoe (2012) Stata logs to LaTeX tables.
The logs use estout format which is already TeX-structured.
"""
import re, os

outdir = os.path.dirname(os.path.abspath(__file__))
tabdir = os.path.join(outdir, "tables")

def parse_estout(log_text):
    """Parse estout TeX-style output from a log file.
    Returns list of lines from the estout block."""
    # Find the estout block between the estout command and the next . command
    m = re.search(r'starlevels\(.*?\)\n\n(.*?)(?=\n\. )', log_text, re.DOTALL)
    if not m:
        # Try simpler approach: find block with & and \\
        lines = []
        for line in log_text.split('\n'):
            if '&' in line and '\\\\' in line:
                lines.append(line)
        return '\n'.join(lines)
    return m.group(1)

def estout_to_latex(estout_block, caption="", note=""):
    """Convert estout block to proper LaTeX tabular."""
    lines = [l.strip() for l in estout_block.strip().split('\n') if l.strip()]

    # Handle line continuations (lines ending with > at start)
    merged = []
    for line in lines:
        if line.startswith('>'):
            if merged:
                merged[-1] = merged[-1].rstrip('\\\\').rstrip() + ' ' + line[1:].strip()
            else:
                merged.append(line[1:].strip())
        else:
            merged.append(line)
    lines = merged

    if not lines:
        return ""

    # Count columns from first line
    first_line = lines[0]
    ncols = first_line.count('&')

    tex = []
    tex.append("\\begin{adjustbox}{max width=\\textwidth}")
    tex.append("\\begin{tabular}{l" + "c"*ncols + "}")
    tex.append("\\toprule")

    # Process lines
    in_stats = False
    for i, line in enumerate(lines):
        # Clean the line
        line = line.replace('\\\\', '').strip()
        parts = [p.strip() for p in line.split('&')]

        # Skip header row with b/se
        if any('b/se' in p for p in parts):
            continue

        # Check if this is a stats line (N, r2, df_m, N_g)
        if parts[0] in ('N', 'r2', 'df_m', 'N_g'):
            if not in_stats:
                tex.append("\\midrule")
                in_stats = True
            # Format label
            label_map = {'N': 'Observations', 'r2': '$R^2$', 'df_m': 'df model', 'N_g': 'Groups'}
            parts[0] = label_map.get(parts[0], parts[0])

        # Format coefficient/se rows
        row = " & ".join(parts) + " \\\\"
        tex.append(row)

    tex.append("\\bottomrule")
    if note:
        tex.append("\\multicolumn{" + str(ncols+1) + "}{l}{\\footnotesize " + note + "} \\\\")
    tex.append("\\end{tabular}")
    tex.append("\\end{adjustbox}")

    return "\n".join(tex)

# =============================================================================
# Table 4: Main Results (olsMainRegs.log)
# =============================================================================
logfile = os.path.join(tabdir, "olsMainRegs.log")
with open(logfile, "r") as f:
    log = f.read()

block = parse_estout(log)
col_headers = ["(1) OLS DiD", "(2) Matched", "(3) WG FE", "(5) Std Only RE"]

# Extract N, R2 from di commands
n_vals = re.findall(r'N:\s*(\d+)', log)
r2_vals = re.findall(r'R-square:\s+([0-9.]+)', log)

# Parse the estout table manually for better control
lines = [l.strip() for l in block.split('\n') if l.strip()]
merged = []
for line in lines:
    if line.startswith('>'):
        if merged:
            merged[-1] = merged[-1].rstrip() + ' ' + line[1:].strip()
        else:
            merged.append(line[1:].strip())
    else:
        merged.append(line)

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{lcccc}")
tex.append("\\toprule")
tex.append(" & " + " & ".join(col_headers) + " \\\\")
tex.append("\\midrule")

for line in merged:
    line_clean = line.replace('\\\\', '').strip()
    parts = [p.strip() for p in line_clean.split('&')]
    if any('b/se' in p for p in parts):
        continue
    # Format variable names
    var_labels = {
        'st_stbafl1yr': 'STB Affil. $\\times$ Std',
        'st_lwgipr': 'WG IPR $\\times$ Std',
        'st_othDum': 'Other org $\\times$ Std',
        'stbafl1yr': 'STB Affiliation',
        'lwgipr': 'WG IPR disclosures',
        'othDum': 'Other org dummy',
    }
    if parts[0] in var_labels:
        parts[0] = var_labels[parts[0]]
    stat_labels = {'N': 'Observations', 'r2': '$R^2$', 'df_m': 'df (model)', 'N_g': 'WG groups'}
    if parts[0] in stat_labels:
        if parts[0] == 'N':
            tex.append("\\midrule")
        parts[0] = stat_labels[parts[0]]
    row = " & ".join(parts) + " \\\\"
    tex.append(row)

tex.append("\\bottomrule")
tex.append("\\multicolumn{5}{l}{\\footnotesize Clustered SEs in parentheses. + p$<$0.10, * p$<$0.05, ** p$<$0.01, *** p$<$0.001} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table4_main.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print("Table 4 (Main): written")

# =============================================================================
# Table 5: Robustness STB (olsRobustSTB.log)
# =============================================================================
logfile = os.path.join(tabdir, "olsRobustSTB.log")
with open(logfile, "r") as f:
    log = f.read()

block = parse_estout(log)
lines = [l.strip() for l in block.split('\n') if l.strip()]

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{lcc}")
tex.append("\\toprule")
tex.append(" & (1) OLS Matched & (2) WG FE \\\\")
tex.append("\\midrule")

for line in lines:
    line_clean = line.replace('\\\\', '').strip()
    parts = [p.strip() for p in line_clean.split('&')]
    if any('b/se' in p for p in parts):
        continue
    var_labels = {
        'st_lwgipr': 'WG IPR $\\times$ Std',
        'st_othDum': 'Other org $\\times$ Std',
        'lwgipr': 'WG IPR disclosures',
        'othDum': 'Other org dummy',
        'st_stbEmail': 'STB Email $\\times$ Std',
        'stbEmail': 'STB Email activity',
        'strfc': 'Standards track',
        '_cons': 'Constant',
    }
    stat_labels = {'N': 'Observations', 'r2': '$R^2$', 'df_m': 'df (model)', 'N_g': 'WG groups'}
    if parts[0] in var_labels:
        parts[0] = var_labels[parts[0]]
    if parts[0] in stat_labels:
        if parts[0] == 'N':
            tex.append("\\midrule")
        parts[0] = stat_labels[parts[0]]
    row = " & ".join(parts) + " \\\\"
    tex.append(row)

tex.append("\\bottomrule")
tex.append("\\multicolumn{3}{l}{\\footnotesize Alt.\ STB measure (email activity). + p$<$0.10, * p$<$0.05, ** p$<$0.01, *** p$<$0.001} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table5_robust_stb.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print("Table 5 (Robust STB): written")

# =============================================================================
# Table 6: Robustness DV (olsRobustDV.log)
# =============================================================================
logfile = os.path.join(tabdir, "olsRobustDV.log")
with open(logfile, "r") as f:
    log = f.read()

block = parse_estout(log)
lines = [l.strip() for l in block.split('\n') if l.strip()]

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{lcccc}")
tex.append("\\toprule")
tex.append(" & \\multicolumn{2}{c}{DV: Age} & \\multicolumn{2}{c}{DV: ln(Duration)} \\\\")
tex.append("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}")
tex.append(" & (1) OLS & (2) FE & (3) OLS & (4) FE \\\\")
tex.append("\\midrule")

for line in lines:
    line_clean = line.replace('\\\\', '').strip()
    parts = [p.strip() for p in line_clean.split('&')]
    if any('b/se' in p for p in parts):
        continue
    var_labels = {
        'st_stbafl1yr': 'STB Affil. $\\times$ Std',
        'st_lwgipr': 'WG IPR $\\times$ Std',
        'st_othDum': 'Other org $\\times$ Std',
        'stbafl1yr': 'STB Affiliation',
        'lwgipr': 'WG IPR disclosures',
        'othDum': 'Other org dummy',
        'strfc': 'Standards track',
        '_cons': 'Constant',
    }
    stat_labels = {'N': 'Observations', 'r2': '$R^2$', 'df_m': 'df (model)', 'N_g': 'WG groups'}
    if parts[0] in var_labels:
        parts[0] = var_labels[parts[0]]
    if parts[0] in stat_labels:
        if parts[0] == 'N':
            tex.append("\\midrule")
        parts[0] = stat_labels[parts[0]]
    row = " & ".join(parts) + " \\\\"
    tex.append(row)

tex.append("\\bottomrule")
tex.append("\\multicolumn{5}{l}{\\footnotesize Alternative DVs. + p$<$0.10, * p$<$0.05, ** p$<$0.01, *** p$<$0.001} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table6_robust_dv.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print("Table 6 (Robust DV): written")

# =============================================================================
# Table 7: Interactions (olsInteractions.log)
# =============================================================================
logfile = os.path.join(tabdir, "olsInteractions.log")
with open(logfile, "r") as f:
    log = f.read()

block = parse_estout(log)
lines = [l.strip() for l in block.split('\n') if l.strip()]
# Handle continuations
merged = []
for line in lines:
    if line.startswith('>'):
        if merged:
            merged[-1] = merged[-1].rstrip() + ' ' + line[1:].strip()
        else:
            merged.append(line[1:].strip())
    else:
        merged.append(line)

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{lcccccc}")
tex.append("\\toprule")
tex.append(" & \\multicolumn{2}{c}{Org/Edu} & \\multicolumn{2}{c}{Tech Area} & \\multicolumn{2}{c}{Cohort} \\\\")
tex.append("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7}")
tex.append(" & (1) Std & (2) DiD & (3) Std & (4) DiD & (5) Std & (6) DiD \\\\")
tex.append("\\midrule")

for line in merged:
    line_clean = line.replace('\\\\', '').strip()
    parts = [p.strip() for p in line_clean.split('&')]
    if any('b/se' in p for p in parts):
        continue
    var_labels = {
        'st_stborg': 'STB $\\times$ Org $\\times$ Std',
        'st_stbedu': 'STB $\\times$ Edu $\\times$ Std',
        'stXarea_app': 'STB$\\times$Std: Applications',
        'stXarea_int': 'STB$\\times$Std: Internet',
        'stXarea_ops': 'STB$\\times$Std: Operations',
        'stXarea_rtg': 'STB$\\times$Std: Routing',
        'stXarea_sec': 'STB$\\times$Std: Security',
        'stXarea_tsv': 'STB$\\times$Std: Transport',
        'stStb_1993': 'STB$\\times$Std: 1993--94',
        'stStb_1995': 'STB$\\times$Std: 1995--96',
        'stStb_1997': 'STB$\\times$Std: 1997--98',
        'stStb_1999': 'STB$\\times$Std: 1999--00',
        'stStb_2001': 'STB$\\times$Std: 2001--02',
    }
    stat_labels = {'N': 'Observations', 'r2': '$R^2$', 'df_m': 'df (model)', 'N_g': 'WG groups'}
    if parts[0] in var_labels:
        parts[0] = var_labels[parts[0]]
    if parts[0] in stat_labels:
        if parts[0] == 'N':
            tex.append("\\midrule")
        parts[0] = stat_labels[parts[0]]
    row = " & ".join(parts) + " \\\\"
    tex.append(row)

tex.append("\\bottomrule")
tex.append("\\multicolumn{7}{l}{\\footnotesize Interactions with area/cohort/org type. + p$<$0.10, * p$<$0.05, ** p$<$0.01, *** p$<$0.001} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table7_interactions.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print("Table 7 (Interactions): written")

# =============================================================================
# Summary Stats from sumstats.log
# =============================================================================
logfile = os.path.join(tabdir, "sumstats.log")
with open(logfile, "r") as f:
    log = f.read()

# Extract balance test results
balance_sections = re.split(r'---\s*(Full|Matched)\s*Sample Balance\s*---', log)

for section_name, section_idx in [("Full", 1), ("Matched", 3)]:
    if section_idx + 1 >= len(balance_sections):
        continue
    block = balance_sections[section_idx + 1]
    results = []
    for line in block.split('\n'):
        m = re.match(r'\s*([-.0-9]+)\s+([-.0-9]+)\s+([-.0-9]+)\s+([-.0-9]+)\s+(\S+)', line)
        if m:
            results.append({
                'diff': m.group(1), 'mean_ns': m.group(2),
                'mean_st': m.group(3), 'pval': m.group(4),
                'var': m.group(5)
            })

    if results and section_name == "Matched":
        tex = []
        tex.append("\\begin{adjustbox}{max width=\\textwidth}")
        tex.append("\\begin{tabular}{lcccc}")
        tex.append("\\toprule")
        tex.append("Variable & Non-Std mean & Std mean & Difference & p-value \\\\")
        tex.append("\\midrule")
        for r in results[:15]:  # top 15
            pstr = r['pval']
            try:
                p = float(pstr)
                if p < 0.05:
                    pstr = f"\\textbf{{{pstr}}}"
            except:
                pass
            tex.append(f"{r['var']} & {r['mean_ns']} & {r['mean_st']} & {r['diff']} & {pstr} \\\\")
        tex.append("\\bottomrule")
        tex.append("\\multicolumn{5}{l}{\\footnotesize Matched sample balance (p99/p5 trimming).} \\\\")
        tex.append("\\end{tabular}")
        tex.append("\\end{adjustbox}")

        with open(os.path.join(outdir, "table3_balance.tex"), "w") as f:
            f.write("\n".join(tex) + "\n")
        print(f"Table 3 ({section_name} Balance): written")

print("\n=== Simcoe LaTeX tables generated ===")
