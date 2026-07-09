"""Extract Munshi & Rosenzweig Table 6 regression results from log and create LaTeX."""
import re, os

logfile = os.path.join(os.path.dirname(__file__), "run_munshi.log")
outfile = os.path.join(os.path.dirname(__file__), "table6_table.tex")

with open(logfile, "r") as f:
    log = f.read()

# Parse each column's results
columns = []
for m in re.finditer(r'--- Table 6, Column (\d+).*?---\n(.*?)(?=--- Table 6|===== TABLE 6 DONE)', log, re.DOTALL):
    col_num = int(m.group(1))
    block = m.group(2)

    # Extract variable coefficients
    coefs = {}
    # Match regression output lines: varname | coef se t p ci_low ci_high
    for line in block.split('\n'):
        line = line.strip()
        # Match lines like: pminc |   .0058604    .002627     2.23   0.026  ...
        match = re.match(r'(\w+)\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+([0-9.]+)', line)
        if match:
            var = match.group(1)
            coef = float(match.group(2))
            se = float(match.group(3))
            pval = float(match.group(5))
            coefs[var] = (coef, se, pval)

    # Extract N and R-squared
    n_match = re.search(r'Number of obs\s*=\s*([0-9,]+)', block)
    r2_match = re.search(r'R-squared\s*=\s*([0-9.]+)', block)
    n = n_match.group(1).replace(',', '') if n_match else ""
    r2 = r2_match.group(1) if r2_match else ""

    columns.append({'num': col_num, 'coefs': coefs, 'n': n, 'r2': r2})

# Build LaTeX table
vars_order = ['pminc', 'jpminc', 'cvsq', 'vpminc', 'vjpminc',
              'second', 'bank', 'hlthctr', 'bus', 'towndist']
var_labels = {
    'pminc': 'Permanent income',
    'jpminc': 'Jati perm. income',
    'cvsq': 'CV squared',
    'vpminc': 'Village perm. income',
    'vjpminc': 'Village $\\times$ jati perm. inc.',
    'second': 'Secondary school',
    'bank': 'Bank',
    'hlthctr': 'Health center',
    'bus': 'Bus stop',
    'towndist': 'Town distance',
}

ncols = len(columns)

def fmt_coef(coef, pval):
    stars = ''
    if pval <= 0.01: stars = '***'
    elif pval <= 0.05: stars = '**'
    elif pval <= 0.1: stars = '*'
    return f"{coef:.4f}{stars}"

def fmt_se(se):
    return f"({se:.4f})"

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{l" + "c" * ncols + "}")
tex.append("\\toprule")
tex.append(" & " + " & ".join(f"({c['num']})" for c in columns) + " \\\\")
tex.append("\\midrule")

for var in vars_order:
    label = var_labels.get(var, var)
    coef_row = [label]
    se_row = [""]
    for c in columns:
        if var in c['coefs']:
            coef, se, pval = c['coefs'][var]
            coef_row.append(fmt_coef(coef, pval))
            se_row.append(fmt_se(se))
        else:
            coef_row.append("")
            se_row.append("")
    tex.append(" & ".join(coef_row) + " \\\\")
    tex.append(" & ".join(se_row) + " \\\\")

tex.append("\\midrule")
n_row = ["Observations"] + [c['n'] for c in columns]
r2_row = ["R-squared"] + [c['r2'] for c in columns]
tex.append(" & ".join(n_row) + " \\\\")
tex.append(" & ".join(r2_row) + " \\\\")

# Add method row
methods = ['Bootstrap', 'Bootstrap', 'Bootstrap/FE', 'Two-way CL', 'Two-way CL', 'Two-way CL']
method_row = ["Method"] + methods[:ncols]
tex.append(" & ".join(method_row) + " \\\\")

tex.append("\\bottomrule")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(outfile, "w") as f:
    f.write("\n".join(tex) + "\n")

print(f"Written {outfile} with {ncols} columns")
