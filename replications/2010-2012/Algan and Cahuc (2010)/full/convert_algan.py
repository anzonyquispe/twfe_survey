"""
Convert Algan & Cahuc (2010) Stata log to LaTeX tables.
Micro: Tables I, III, IV, VIII, XIII
Macro: Tables V, VI, VII
"""
import re, os

OUTDIR = os.path.dirname(os.path.abspath(__file__))
LOGFILE = os.path.join(OUTDIR, "run_algan_full.log")

with open(LOGFILE, 'r') as f:
    log = f.read()

def stars(pval):
    try:
        p = float(pval)
    except:
        return ''
    if p < 0.01: return '***'
    if p < 0.05: return '**'
    if p < 0.10: return '*'
    return ''

def get_abbreviated_names(varname):
    shorts = [varname]
    if len(varname) > 12:
        for pl in range(6, 13):
            for sl in range(1, 6):
                shorts.append(varname[:pl] + '~' + varname[-sl:])
    return shorts

def parse_coef(block, varname):
    for v in get_abbreviated_names(varname):
        pat = re.escape(v) + r'\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+[-.0-9e+]+\s+([0-9.]+)'
        m = re.search(pat, block)
        if m:
            return m.group(1), m.group(2), m.group(3)
    return None, None, None

def parse_nobs(block):
    m = re.search(r'Number of obs\s*=\s*([0-9,]+)', block)
    return m.group(1).replace(',', '') if m else ''

def parse_r2(block):
    m = re.search(r'R-squared\s*=\s*([0-9.]+)', block)
    return m.group(1) if m else ''

def find_next_section(text, pos):
    """Find next section header that's an output line (not a .di command echo)."""
    pat = re.compile(r'\n(--- [^"]+? ---)\n')
    idx = pos
    while True:
        m = pat.search(text, idx)
        if not m:
            return len(text)
        # Check the line before: if it contains '.di' it's likely the output line
        # The output line won't have quotes around it
        line = m.group(1)
        if '"' not in line:
            return m.start()
        idx = m.end()

def get_section(text, header):
    # Find the OUTPUT line (not the .di command line which has quotes)
    # Search for \nHEADER\n pattern to skip command echo
    search = '\n' + header + '\n'
    start = text.find(search)
    if start < 0:
        # Fallback: try without \n anchors
        start = text.find(header)
    if start < 0:
        return ''
    start += 1  # skip the leading \n
    end = find_next_section(text, start + len(header))
    # Also check for ===== markers
    eq = text.find('=====', start + len(header))
    if eq >= 0 and eq < end:
        end = eq
    return text[start:end]

def get_table_block(start_marker, end_marker=None):
    s = log.find(start_marker)
    if s < 0:
        return ''
    if end_marker:
        e = log.find(end_marker, s + len(start_marker))
        if e < 0:
            e = len(log)
    else:
        e = len(log)
    return log[s:e]

def fmt_coef(coef, se, pval):
    if coef is None:
        return '', ''
    try:
        c = float(coef)
        s = float(se)
        st = stars(pval)
        if abs(c) >= 100:
            return f'{c:.1f}{st}', f'({s:.1f})'
        elif abs(c) >= 1:
            return f'{c:.3f}{st}', f'({s:.3f})'
        else:
            return f'{c:.4f}{st}', f'({s:.4f})'
    except:
        return str(coef), f'({se})'


# ── TABLE III: Trust Correlation ─────────────────────────────────────────────

def make_table3():
    block = get_table_block('===== TABLE III: Trust Correlation =====',
                            '===== TABLE IV:')
    cols = ['--- Col 1: Cohort 2000 ---',
            '--- Col 2: Cohort 1935 ---',
            '--- Col 3: 4th generation 2000 ---']
    sections = {h: get_section(block, h) for h in cols}

    key_var = 'trustwvs2000'
    controls = [('age', 'Age'), ('men', 'Male'), ('ageedu', 'Age $\\times$ Education'),
                ('incomegood', 'Income good'), ('catho', 'Catholic'), ('pro', 'Protestant'),
                ('unemployed', 'Unemployed'), ('employed', 'Employed')]

    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Table III: Correlation Between Inherited and Home Country Trust}')
    lines.append(r'\label{tab:algan_table3}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lccc}')
    lines.append(r'\toprule')
    lines.append(r' & Cohort 2000 & Cohort 1935 & 4th Gen 2000 \\')
    lines.append(r' & (1) & (2) & (3) \\')
    lines.append(r'\midrule')

    # Trust variable
    row_c = ['Trust (home country)']
    row_s = ['']
    for h in cols:
        c, se, p = parse_coef(sections[h], key_var)
        cf, sf = fmt_coef(c, se, p)
        row_c.append(cf)
        row_s.append(sf)
    lines.append(' & '.join(row_c) + r' \\')
    lines.append(' & '.join(row_s) + r' \\')

    lines.append(r'\midrule')
    row_n = ['$N$'] + [parse_nobs(sections[h]) for h in cols]
    row_r2 = ['$R^2$'] + [parse_r2(sections[h]) for h in cols]
    lines.append(' & '.join(row_n) + r' \\')
    lines.append(' & '.join(row_r2) + r' \\')
    lines.append(r'\midrule')
    lines.append(r'Individual controls & Yes & Yes & Yes \\')
    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} Dep.\ var.: individual trust (0/1). Trust (home country) from WVS 2000. SEs clustered at ethnicity level. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'table3_trust_corr.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Table III: Trust Correlation - 3 columns")


# ── TABLE V: Cross-country ──────────────────────────────────────────────────

def make_table5():
    block = get_table_block('===== TABLE V: Cross-country =====',
                            '===== TABLE VI:')
    cols = ['--- Col 1: Trust only ---',
            '--- Col 2: + lagged GDP ---',
            '--- Col 3: + polity ---',
            '--- Col 4: Excl. Africa ---']
    sections = {h: get_section(block, h) for h in cols}

    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Table V: Cross-Country Trust and Growth (1935--2000)}')
    lines.append(r'\label{tab:algan_table5}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lcccc}')
    lines.append(r'\toprule')
    lines.append(r' & (1) & (2) & (3) & (4) \\')
    lines.append(r'\midrule')

    for vname, vlabel in [('trustgss', 'Inherited trust'),
                          ('gdpk_diffswd_good_1', 'Lagged GDP diff.'),
                          ('polity2diff', 'Polity diff.')]:
        row_c = [vlabel]
        row_s = ['']
        for h in cols:
            c, se, p = parse_coef(sections[h], vname)
            cf, sf = fmt_coef(c, se, p)
            row_c.append(cf)
            row_s.append(sf)
        lines.append(' & '.join(row_c) + r' \\')
        lines.append(' & '.join(row_s) + r' \\')

    lines.append(r'\midrule')
    row_n = ['$N$'] + [parse_nobs(sections[h]) for h in cols]
    row_r2 = ['$R^2$'] + [parse_r2(sections[h]) for h in cols]
    lines.append(' & '.join(row_n) + r' \\')
    lines.append(' & '.join(row_r2) + r' \\')
    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} Dep.\ var.: GDP per capita difference from Sweden. Inherited trust from GSS. No constant. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'table5_crosscountry.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Table V: Cross-country - 4 columns")


# ── TABLE VI: Within estimates ───────────────────────────────────────────────

def make_table6():
    block = get_table_block('===== TABLE VI: Within estimates =====',
                            '===== TABLE VII:')
    cols = ['--- Col 1: Country FE ---',
            '--- Col 2: + lagged GDP ---',
            '--- Col 3: Excl. Africa ---',
            '--- Col 4: + polity ---',
            '--- Col 5: Smoothed ---']
    sections = {h: get_section(block, h) for h in cols}

    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Table VI: Within-Country Estimates of Trust on Growth}')
    lines.append(r'\label{tab:algan_table6}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lccccc}')
    lines.append(r'\toprule')
    lines.append(r' & (1) & (2) & (3) & (4) & (5) \\')
    lines.append(r'\midrule')

    for vname, vlabel in [('trustgss', 'Inherited trust'),
                          ('gdpk_diffswd_good_1', 'Lagged GDP diff.'),
                          ('polity2diff', 'Polity diff.')]:
        row_c = [vlabel]
        row_s = ['']
        for h in cols:
            c, se, p = parse_coef(sections[h], vname)
            cf, sf = fmt_coef(c, se, p)
            row_c.append(cf)
            row_s.append(sf)
        lines.append(' & '.join(row_c) + r' \\')
        lines.append(' & '.join(row_s) + r' \\')

    lines.append(r'\midrule')
    row_n = ['$N$'] + [parse_nobs(sections[h]) for h in cols]
    row_r2 = ['$R^2$'] + [parse_r2(sections[h]) for h in cols]
    lines.append(' & '.join(row_n) + r' \\')
    lines.append(' & '.join(row_r2) + r' \\')
    lines.append(r'\midrule')
    lines.append(r'Country FE & Yes & Yes & Yes & Yes & Yes \\')
    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} Dep.\ var.: GDP per capita difference from Sweden. Country FE included. No constant. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'table6_within.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Table VI: Within estimates - 5 columns")


# ── TABLE VII: 50-year lag ──────────────────────────────────────────────────

def make_table7():
    block = get_table_block('===== TABLE VII: 50-year lag =====',
                            '===== TABLE IX')
    if not block:
        block = get_table_block('===== TABLE VII: 50-year lag =====',
                                '===== TABLE XI')
    if not block:
        block = get_table_block('===== TABLE VII: 50-year lag =====')

    cols = ['--- Col 1: Cross-section ---',
            '--- Col 2: Country FE ---',
            '--- Col 3: Full controls ---']
    sections = {h: get_section(block, h) for h in cols}

    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Table VII: 50-Year Lag Trust on Growth}')
    lines.append(r'\label{tab:algan_table7}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lccc}')
    lines.append(r'\toprule')
    lines.append(r' & Cross-section & Country FE & Full \\')
    lines.append(r' & (1) & (2) & (3) \\')
    lines.append(r'\midrule')

    for vname, vlabel in [('trustgss50yearslag', '50-year lag trust')]:
        row_c = [vlabel]
        row_s = ['']
        for h in cols:
            c, se, p = parse_coef(sections[h], vname)
            cf, sf = fmt_coef(c, se, p)
            row_c.append(cf)
            row_s.append(sf)
        lines.append(' & '.join(row_c) + r' \\')
        lines.append(' & '.join(row_s) + r' \\')

    lines.append(r'\midrule')
    row_n = ['$N$'] + [parse_nobs(sections[h]) for h in cols]
    row_r2 = ['$R^2$'] + [parse_r2(sections[h]) for h in cols]
    lines.append(' & '.join(row_n) + r' \\')
    lines.append(' & '.join(row_r2) + r' \\')
    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} 50-year lagged inherited trust. No constant. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'table7_lag50.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Table VII: 50-year lag - 3 columns")


if __name__ == '__main__':
    make_table3()
    make_table5()
    make_table6()
    make_table7()
    print("\nAll Algan tables generated.")
