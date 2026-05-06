"""
Convert Forman et al. (2012) Stata logs to LaTeX tables.
Tables 1-5: Summary stats, OLS main effects, heterogeneous effects, IV, additional outcomes.
"""
import re, os

outdir = os.path.dirname(os.path.abspath(__file__))

def stars(p):
    if p <= 0.01: return '***'
    if p <= 0.05: return '**'
    if p <= 0.10: return '*'
    return ''

def parse_regress(block, vars_of_interest):
    """Parse a regress/ivregress block for specific variables."""
    results = {}
    for var in vars_of_interest:
        # Handle abbreviated names (surv_deep~00, etc.)
        short = var[:10] + '~' + var[-2:] if len(var) > 12 else var
        patterns = [
            rf'{re.escape(var)}\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+[-.0-9e+]+\s+([0-9.]+)',
            rf'{re.escape(short)}\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+[-.0-9e+]+\s+([0-9.]+)',
        ]
        for pat in patterns:
            m = re.search(pat, block)
            if m:
                results[var] = (m.group(1), m.group(2), float(m.group(3)))
                break

    # N and R2
    n_m = re.search(r'Number of obs\s*=\s*([0-9,]+)', block)
    r2_m = re.search(r'R-squared\s*=\s*([0-9.]+)', block)
    n = n_m.group(1).replace(',', '') if n_m else ''
    r2 = r2_m.group(1) if r2_m else ''

    return results, n, r2

# =============================================================================
# TABLE 2: Main Effects OLS
# =============================================================================
logfile = os.path.join(outdir, "table2.log")
with open(logfile, "r") as f:
    log = f.read()

# Split by column markers (only output lines, not the .di command)
cols = re.split(r'\n--- Col \d+:.*?---\n', log)[1:]
col_labels = ["No controls", "With controls", "PC \\& shallow"]

key_vars = ['surv_deeppost00', 'surv_pcperemp00', 'surv_shalpost00', 'indivhomeinternet00_cty']
var_labels = {
    'surv_deeppost00': 'Advanced Internet',
    'surv_pcperemp00': 'PCs per employee',
    'surv_shalpost00': 'Basic Internet',
    'indivhomeinternet00_cty': 'Home Internet',
}

table2_results = []
for col_block in cols:
    res, n, r2 = parse_regress(col_block, key_vars)
    table2_results.append({'coefs': res, 'n': n, 'r2': r2})

ncols = len(table2_results)
tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{l" + "c"*ncols + "}")
tex.append("\\toprule")
tex.append(" & " + " & ".join(f"({i+1})" for i in range(ncols)) + " \\\\")
tex.append(" & " + " & ".join(col_labels[:ncols]) + " \\\\")
tex.append("\\midrule")

for var in key_vars:
    row_c = [var_labels.get(var, var)]
    row_s = [""]
    for col in table2_results:
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
tex.append("Controls & No & Yes & Yes \\\\")
row_n = ["Observations"] + [col['n'] for col in table2_results]
tex.append(" & ".join(row_n) + " \\\\")
row_r = ["$R^2$"] + [col['r2'] for col in table2_results]
tex.append(" & ".join(row_r) + " \\\\")

tex.append("\\bottomrule")
tex.append("\\multicolumn{" + str(ncols+1) + "}{l}{\\footnotesize DV: Wage growth 2000--2006. Robust SEs. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table2_full.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print(f"Table 2: {ncols} columns")

# =============================================================================
# TABLE 3: Heterogeneous Effects
# =============================================================================
logfile = os.path.join(outdir, "table3.log")
with open(logfile, "r") as f:
    log = f.read()

cols3 = re.split(r'\n--- Col \d+:.*?---\n', log)[1:]
col3_labels = ["Income", "Educ", "Industry", "Pop", "All inter.", "Combined", "All+Comb"]

key_vars3 = ['surv_deeppost00', 'inc_dum_surv_deeppost00', 'educ_dum_surv_deeppost00',
             'ind_dum_surv_deeppost00', 'pop_dum_surv_deeppost00',
             'educ_inc_ind_pop_dum_surv_deep00']
var_labels3 = {
    'surv_deeppost00': 'Advanced Internet',
    'inc_dum_surv_deeppost00': 'Adv. Int. $\\times$ High Income',
    'educ_dum_surv_deeppost00': 'Adv. Int. $\\times$ High Educ',
    'ind_dum_surv_deeppost00': 'Adv. Int. $\\times$ High Ind',
    'pop_dum_surv_deeppost00': 'Adv. Int. $\\times$ High Pop',
    'educ_inc_ind_pop_dum_surv_deep00': 'Adv. Int. $\\times$ All High',
}

table3_results = []
for col_block in cols3:
    res, n, r2 = parse_regress(col_block, key_vars3)
    table3_results.append({'coefs': res, 'n': n, 'r2': r2})

ncols3 = len(table3_results)
tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{l" + "c"*ncols3 + "}")
tex.append("\\toprule")
tex.append(" & " + " & ".join(f"({i+1})" for i in range(ncols3)) + " \\\\")
tex.append(" & " + " & ".join(col3_labels[:ncols3]) + " \\\\")
tex.append("\\midrule")

for var in key_vars3:
    row_c = [var_labels3.get(var, var)]
    row_s = [""]
    for col in table3_results:
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
row_n = ["Observations"] + [col['n'] for col in table3_results]
tex.append(" & ".join(row_n) + " \\\\")
row_r = ["$R^2$"] + [col['r2'] for col in table3_results]
tex.append(" & ".join(row_r) + " \\\\")

tex.append("\\bottomrule")
tex.append("\\multicolumn{" + str(ncols3+1) + "}{l}{\\footnotesize DV: Wage growth 2000--2006. Robust SEs. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table3_full.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print(f"Table 3: {ncols3} columns")

# =============================================================================
# TABLE 4: IV Regressions
# =============================================================================
logfile = os.path.join(outdir, "table4.log")
with open(logfile, "r") as f:
    log = f.read()

# Split by column markers (output lines only)
cols4_raw = re.split(r'\n--- (?:Col \d+|OLS baseline|Heterogeneous IV):.*?---\n', log)[1:]

# Key variables for IV
iv_vars = ['surv_deeppost00', 'educ_inc_ind_pop_dum_surv_deep00']
iv_var_labels = {
    'surv_deeppost00': 'Advanced Internet',
    'educ_inc_ind_pop_dum_surv_deep00': 'Adv. Int. $\\times$ All High',
}

# Parse: OLS baseline + 4 IV cols + interacted section
# The first block is OLS, then cols 1-4 are IV, then cols 5-8 are heterogeneous IV
table4_results = []
for col_block in cols4_raw:
    # For IV, parse second-stage (after "Instrumental variables" header)
    iv_section = col_block
    iv_m = re.search(r'Instrumental variables.*?\n-+\n(.*?)(?=-+\nInstrumented|\Z)', col_block, re.DOTALL)
    if iv_m:
        iv_section = iv_m.group(0)

    res, n, r2 = parse_regress(iv_section, iv_vars)
    if not res:
        res, n, r2 = parse_regress(col_block, iv_vars)
    table4_results.append({'coefs': res, 'n': n, 'r2': r2})

# Build table with first 5 cols (OLS + 4 IV)
ncols4 = min(5, len(table4_results))
col4_labels = ["OLS", "Prog. IV", "Bartik IV", "ARPANET", "All IVs"]

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{l" + "c"*ncols4 + "}")
tex.append("\\toprule")
tex.append(" & " + " & ".join(f"({i+1})" for i in range(ncols4)) + " \\\\")
tex.append(" & " + " & ".join(col4_labels[:ncols4]) + " \\\\")
tex.append("\\midrule")

for var in iv_vars[:1]:  # Just surv_deeppost00 for main IV table
    row_c = [iv_var_labels.get(var, var)]
    row_s = [""]
    for col in table4_results[:ncols4]:
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
tex.append("Method & OLS & LIML & LIML & GMM & LIML \\\\")
row_n = ["Observations"] + [col['n'] for col in table4_results[:ncols4]]
tex.append(" & ".join(row_n) + " \\\\")

tex.append("\\bottomrule")
tex.append("\\multicolumn{" + str(ncols4+1) + "}{l}{\\footnotesize DV: Wage growth. Robust SEs. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table4_full.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print(f"Table 4: {ncols4} columns")

# =============================================================================
# TABLE 5: Additional Outcomes
# =============================================================================
logfile = os.path.join(outdir, "table5.log")
with open(logfile, "r") as f:
    log = f.read()

cols5 = re.split(r'\n--- Col \d+:.*?---\n', log)[1:]
col5_labels = ["Emp growth", "Emp + allhigh", "Wage 99--05", "Wage 99--05 + allhigh"]

t5_vars = ['surv_deeppost00', 'educ_inc_ind_pop_dum_surv_deep00', 'educ_inc_ind_pop_dum_surv_deep05']
t5_var_labels = {
    'surv_deeppost00': 'Advanced Internet',
    'educ_inc_ind_pop_dum_surv_deep00': 'Adv. Int. $\\times$ All High',
    'educ_inc_ind_pop_dum_surv_deep05': 'Adv. Int. $\\times$ All High',
}

table5_results = []
for col_block in cols5:
    res, n, r2 = parse_regress(col_block, t5_vars)
    table5_results.append({'coefs': res, 'n': n, 'r2': r2})

ncols5 = len(table5_results)
tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{l" + "c"*ncols5 + "}")
tex.append("\\toprule")
tex.append(" & " + " & ".join(f"({i+1})" for i in range(ncols5)) + " \\\\")
tex.append(" & \\multicolumn{2}{c}{Employment 2000--06} & \\multicolumn{2}{c}{Wage 1999--05} \\\\")
tex.append("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}")
tex.append(" & " + " & ".join(col5_labels[:ncols5]) + " \\\\")
tex.append("\\midrule")

for var in t5_vars:
    row_c = [t5_var_labels.get(var, var)]
    row_s = [""]
    has_any = False
    for col in table5_results:
        if var in col['coefs']:
            c, s, p = col['coefs'][var]
            row_c.append(f"{c}{stars(p)}")
            row_s.append(f"({s})")
            has_any = True
        else:
            row_c.append("")
            row_s.append("")
    if has_any:
        tex.append(" & ".join(row_c) + " \\\\")
        tex.append(" & ".join(row_s) + " \\\\[0.3em]")

tex.append("\\midrule")
row_n = ["Observations"] + [col['n'] for col in table5_results]
tex.append(" & ".join(row_n) + " \\\\")
row_r = ["$R^2$"] + [col['r2'] for col in table5_results]
tex.append(" & ".join(row_r) + " \\\\")

tex.append("\\bottomrule")
tex.append("\\multicolumn{" + str(ncols5+1) + "}{l}{\\footnotesize Robust SEs. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "table5_full.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print(f"Table 5: {ncols5} columns")

# =============================================================================
# TABLE 1: Summary Statistics
# =============================================================================
logfile = os.path.join(outdir, "table1.log")
with open(logfile, "r") as f:
    log = f.read()

# Parse summarize output
summ_results = []
for m in re.finditer(
    r'(\w[\w~]+)\s*\|\s+([0-9,]+)\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+([-.0-9e+]+)',
    log
):
    summ_results.append({
        'var': m.group(1), 'n': m.group(2),
        'mean': m.group(3), 'sd': m.group(4),
        'min': m.group(5), 'max': m.group(6)
    })

if summ_results:
    tex = []
    tex.append("\\begin{adjustbox}{max width=\\textwidth}")
    tex.append("\\begin{tabular}{lccccc}")
    tex.append("\\toprule")
    tex.append("Variable & N & Mean & Std. Dev. & Min & Max \\\\")
    tex.append("\\midrule")
    for r in summ_results[:20]:
        # Escape ~ and _ for LaTeX
        varname = r['var'].replace('~', '\\textasciitilde ').replace('_', '\\_')
        tex.append(f"\\texttt{{{varname}}} & {r['n']} & {r['mean']} & {r['sd']} & {r['min']} & {r['max']} \\\\")
    tex.append("\\bottomrule")
    tex.append("\\end{tabular}")
    tex.append("\\end{adjustbox}")

    with open(os.path.join(outdir, "table1_full.tex"), "w") as f:
        f.write("\n".join(tex) + "\n")
    print(f"Table 1: {len(summ_results)} variables")

print("\n=== Forman LaTeX tables generated ===")
