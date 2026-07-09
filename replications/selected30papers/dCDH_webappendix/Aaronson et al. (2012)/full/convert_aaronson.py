"""Extract Aaronson et al. CPS regression results from logs and create LaTeX tables."""
import re, os

outdir = os.path.dirname(__file__)

# =============================================================================
# Table 1 (CPS columns) - Fixed-effects regressions
# =============================================================================
logfile = os.path.join(outdir, "cps_table1.log")
with open(logfile, "r") as f:
    log = f.read()

# Find all xtreg results
regressions = []
for m in re.finditer(
    r'xtreg tot_inc minwage.*?if (.*?), fe cluster.*?\n'
    r'(.*?)'
    r'(?=\. xtreg|\. log close|\. \*)',
    log, re.DOTALL
):
    condition = m.group(1).strip()
    block = m.group(2)

    # Extract minwage coefficient
    mw_match = re.search(r'minwage\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+([0-9.]+)', block)
    if mw_match:
        coef = mw_match.group(1)
        se = mw_match.group(2)
        t = mw_match.group(3)
        p = float(mw_match.group(4))

    n_match = re.search(r'Number of obs\s*=\s*([0-9,]+)', block)
    n = n_match.group(1) if n_match else ""

    r2_match = re.search(r'Within\s*=\s*([0-9.]+)', block)
    r2 = r2_match.group(1) if r2_match else ""

    groups_match = re.search(r'Number of groups\s*=\s*([0-9,]+)', block)
    groups = groups_match.group(1) if groups_match else ""

    regressions.append({
        'condition': condition,
        'coef': coef, 'se': se, 'p': p,
        'n': n, 'r2': r2, 'groups': groups
    })

# Build Table 1 LaTeX
tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{l" + "c" * len(regressions) + "}")
tex.append("\\toprule")
tex.append(" & " + " & ".join(f"({i+1})" for i in range(len(regressions))) + " \\\\")

# Add condition labels
labels = []
for r in regressions:
    cond = r['condition']
    if 'firstsharemw==0' in cond and '120300' not in cond:
        labels.append('$S=0$')
    elif 'firstsharemw>0' in cond and '120300' not in cond:
        labels.append('$S>0$')
    elif 'firstsharemw>=0.2' in cond and '120300' not in cond:
        labels.append('$S\\geq 0.2$')
    elif 'firstsharemw_120300==0' in cond:
        labels.append('$S_{120}=0$')
    elif 'firstsharemw_120300>0' in cond:
        labels.append('$S_{120}>0$')
    elif 'firstsharemw_120300>=0.2' in cond:
        labels.append('$S_{120}\\geq 0.2$')
    else:
        labels.append(cond[:15])
tex.append(" & " + " & ".join(labels) + " \\\\")
tex.append("\\midrule")

# Coefficient row
def stars(p):
    if p <= 0.01: return '***'
    if p <= 0.05: return '**'
    if p <= 0.1: return '*'
    return ''

coef_row = ["Log min. wage"] + [f"{r['coef']}{stars(r['p'])}" for r in regressions]
tex.append(" & ".join(coef_row) + " \\\\")

se_row = [""] + [f"({r['se']})" for r in regressions]
tex.append(" & ".join(se_row) + " \\\\")

tex.append("\\midrule")
n_row = ["Observations"] + [r['n'] for r in regressions]
tex.append(" & ".join(n_row) + " \\\\")

groups_row = ["Households"] + [r['groups'] for r in regressions]
tex.append(" & ".join(groups_row) + " \\\\")

r2_row = ["Within $R^2$"] + [r['r2'] for r in regressions]
tex.append(" & ".join(r2_row) + " \\\\")

tex.append("\\bottomrule")
tex.append("\\multicolumn{" + str(len(regressions)+1) + "}{l}{\\footnotesize Fixed effects regressions. Clustered SEs in parentheses.} \\\\")
tex.append("\\multicolumn{" + str(len(regressions)+1) + "}{l}{\\footnotesize *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "cps_table1_table.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print(f"Written cps_table1_table.tex with {len(regressions)} columns")

# =============================================================================
# Table A1 - Summary Statistics
# =============================================================================
logfile = os.path.join(outdir, "cps_tableA1.log")
with open(logfile, "r") as f:
    log = f.read()

# Extract summary statistics blocks
blocks = []
for m in re.finditer(r'su tot_inc.*?if (.*?) \[w=hhwgt\].*?\n.*?\n(.*?)\n\n', log, re.DOTALL):
    cond = m.group(1).strip()
    block = m.group(2)
    stats = {}
    for line in block.split('\n'):
        vm = re.match(r'\s*(\w+)\s*\|\s*([0-9,]+)\s+[0-9e.+]+\s+([0-9.]+)\s+([0-9.]+)', line)
        if vm:
            var = vm.group(1)
            n = vm.group(2)
            mean = vm.group(3)
            sd = vm.group(4)
            stats[var] = (n, mean, sd)
    blocks.append({'cond': cond, 'stats': stats})

tex = []
tex.append("\\begin{tabular}{lcccc}")
tex.append("\\toprule")
tex.append(" & \\multicolumn{2}{c}{$S=0$} & \\multicolumn{2}{c}{$S\\geq 0.2$} \\\\")
tex.append("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}")
tex.append(" & Mean & Std. Dev. & Mean & Std. Dev. \\\\")
tex.append("\\midrule")

var_labels_a1 = {
    'tot_inc': 'Total income (annual)',
    'firstsharemw': 'Share min. wage',
    'agehead': 'Age of head',
    'adults': 'Number of adults',
    'kids': 'Number of kids',
}

for var in ['tot_inc', 'firstsharemw', 'agehead', 'adults', 'kids']:
    row = [var_labels_a1.get(var, var)]
    for b in blocks:
        if var in b['stats']:
            _, mean, sd = b['stats'][var]
            row.extend([mean, sd])
        else:
            row.extend(['', ''])
    tex.append(" & ".join(row) + " \\\\")

tex.append("\\midrule")
n_vals = []
for b in blocks:
    if 'tot_inc' in b['stats']:
        n_vals.append(b['stats']['tot_inc'][0])
    else:
        n_vals.append('')
tex.append("Observations & " + " & & ".join(n_vals) + " & \\\\")

tex.append("\\bottomrule")
tex.append("\\end{tabular}")

with open(os.path.join(outdir, "cps_tableA1_table.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print(f"Written cps_tableA1_table.tex")

# =============================================================================
# Table A3 - Employment, Hours, Wages regressions
# =============================================================================
logfile = os.path.join(outdir, "cps_tableA3.log")
with open(logfile, "r") as f:
    log = f.read()

# Collapse Stata continuation lines ("> " at start of line)
log = re.sub(r'\r?\n> ', ' ', log)

# Parse all xtreg regressions from A3
a3_regs = []
for m in re.finditer(
    r'\. xtreg (\w+) minwage.*?if (.*?),\s*fe\s+cluster.*?\n'
    r'(.*?)'
    r'(?=\. xtreg|\. log close|\. \*|\. gen |\. replace )',
    log, re.DOTALL
):
    depvar = m.group(1)
    condition = m.group(2).strip()
    block = m.group(3)

    mw_match = re.search(r'minwage\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+([0-9.]+)', block)
    if mw_match:
        coef = mw_match.group(1)
        se = mw_match.group(2)
        p = float(mw_match.group(4))
    else:
        continue

    n_match = re.search(r'Number of obs\s*=\s*([0-9,]+)', block)
    n = n_match.group(1) if n_match else ""

    a3_regs.append({
        'depvar': depvar, 'condition': condition,
        'coef': coef, 'se': se, 'p': p, 'n': n
    })

# Organize: rows = dep vars, columns = subsamples (S=0, S>0, S>=0.2)
dep_vars = ['tot_emp', 'emp1', 'emp2', 'tot_hrs', 'hrs1', 'hrs2', 'tot_wage', 'wage1', 'wage2']
dep_labels = {
    'tot_emp': 'Total employment',
    'emp1': 'Employment (member 1)',
    'emp2': 'Employment (member 2)',
    'tot_hrs': 'Total hours',
    'hrs1': 'Hours (member 1)',
    'hrs2': 'Hours (member 2)',
    'tot_wage': 'Total wage',
    'wage1': 'Wage (member 1)',
    'wage2': 'Wage (member 2)',
}

def get_subsample(cond):
    if 'firstsharemw==0' in cond:
        return 0
    elif 'firstsharemw>0' in cond and '0.2' not in cond:
        return 1
    elif 'firstsharemw>=0.2' in cond:
        return 2
    return -1

# Build lookup: (depvar, subsample_idx) -> reg dict
a3_lookup = {}
for r in a3_regs:
    idx = get_subsample(r['condition'])
    if idx >= 0:
        a3_lookup[(r['depvar'], idx)] = r

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{lccc}")
tex.append("\\toprule")
tex.append(" & (1) $S=0$ & (2) $S>0$ & (3) $S\\geq 0.2$ \\\\")
tex.append("\\midrule")

# Panel A: Employment
tex.append("\\multicolumn{4}{l}{\\textit{Panel A: Employment}} \\\\[0.3em]")
for dv in ['tot_emp', 'emp1', 'emp2']:
    coefs = []
    ses = []
    for si in range(3):
        r = a3_lookup.get((dv, si))
        if r:
            coefs.append(f"{r['coef']}{stars(r['p'])}")
            ses.append(f"({r['se']})")
        else:
            coefs.append("")
            ses.append("")
    tex.append(f"{dep_labels[dv]} & " + " & ".join(coefs) + " \\\\")
    tex.append(" & " + " & ".join(ses) + " \\\\[0.3em]")

# Panel B: Hours
tex.append("\\multicolumn{4}{l}{\\textit{Panel B: Hours}} \\\\[0.3em]")
for dv in ['tot_hrs', 'hrs1', 'hrs2']:
    coefs = []
    ses = []
    for si in range(3):
        r = a3_lookup.get((dv, si))
        if r:
            coefs.append(f"{r['coef']}{stars(r['p'])}")
            ses.append(f"({r['se']})")
        else:
            coefs.append("")
            ses.append("")
    tex.append(f"{dep_labels[dv]} & " + " & ".join(coefs) + " \\\\")
    tex.append(" & " + " & ".join(ses) + " \\\\[0.3em]")

# Panel C: Wages
tex.append("\\multicolumn{4}{l}{\\textit{Panel C: Wages}} \\\\[0.3em]")
for dv in ['tot_wage', 'wage1', 'wage2']:
    coefs = []
    ses = []
    for si in range(3):
        r = a3_lookup.get((dv, si))
        if r:
            coefs.append(f"{r['coef']}{stars(r['p'])}")
            ses.append(f"({r['se']})")
        else:
            coefs.append("")
            ses.append("")
    tex.append(f"{dep_labels[dv]} & " + " & ".join(coefs) + " \\\\")
    tex.append(" & " + " & ".join(ses) + " \\\\[0.3em]")

tex.append("\\bottomrule")
tex.append("\\multicolumn{4}{l}{\\footnotesize Fixed effects regressions with year dummies and controls (adults, kids).} \\\\")
tex.append("\\multicolumn{4}{l}{\\footnotesize Clustered SEs in parentheses. *** p$<$0.01, ** p$<$0.05, * p$<$0.1} \\\\")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(os.path.join(outdir, "cps_tableA3_table.tex"), "w") as f:
    f.write("\n".join(tex) + "\n")
print(f"Written cps_tableA3_table.tex with {len(a3_regs)} regressions")
