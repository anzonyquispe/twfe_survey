"""
Convert Enikolopov et al. (2011) Stata log to LaTeX tables.
Tables: 1 (Correlates), 2 (1999 vote), 3 (Panel FE), 4 (Placebo 95),
        5 (Placebo 03), 6 (First stage), 7 (Reported vote), 8 (Intended vote),
        A4 (Individual placebo 1995)
"""
import re, os

OUTDIR = os.path.dirname(os.path.abspath(__file__))
LOGFILE = os.path.join(OUTDIR, "run_enikolopov_full.log")

with open(LOGFILE, 'r') as f:
    log = f.read()

# ── helpers ──────────────────────────────────────────────────────────────────

def esc(s):
    return s.replace('_', r'\_').replace('~', r'\textasciitilde{}').replace('%', r'\%').replace('&', r'\&')

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
    """Generate possible Stata abbreviated names for a variable."""
    shorts = [varname]
    if len(varname) > 12:
        for prefix_len in range(6, 11):
            for suffix_len in range(2, 6):
                shorts.append(varname[:prefix_len] + '~' + varname[-suffix_len:])
    return shorts

def parse_coef(block, varname):
    """Extract coefficient, SE, p-value from a regression block."""
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
    if m: return m.group(1)
    m = re.search(r'Pseudo R2\s*=\s*([0-9.]+)', block)
    if m: return m.group(1)
    return ''

def parse_marginal(block, varname):
    """Extract marginal effect (dy/dx) from margins output."""
    idx = block.rfind('dy/dx')
    if idx < 0:
        return None, None, None
    sub = block[idx:]
    for v in get_abbreviated_names(varname):
        pat = re.escape(v) + r'\s*\|\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+[-.0-9e+]+\s+([0-9.]+)'
        m = re.search(pat, sub)
        if m:
            return m.group(1), m.group(2), m.group(3)
    return None, None, None

def find_next_section(text, pos):
    """Find the next '--- ... ---' section header after pos."""
    pat = re.compile(r'\n(--- .+? ---)\n')
    m = pat.search(text, pos)
    return m.start() if m else len(text)

def get_section(text, header):
    """Extract text from header to next section header."""
    start = text.find(header)
    if start < 0:
        return ''
    end = find_next_section(text, start + len(header))
    return text[start:end]

def fmt_coef(coef, se, pval):
    """Format coefficient with stars and SE in parentheses."""
    if coef is None:
        return '', ''
    try:
        c = float(coef)
        s = float(se)
        st = stars(pval)
        if abs(c) < 0.001 and c != 0:
            return f'{c:.2e}{st}', f'({s:.2e})'
        elif abs(c) < 1:
            return f'{c:.4f}{st}', f'({s:.4f})'
        else:
            return f'{c:.3f}{st}', f'({s:.3f})'
    except:
        return str(coef), f'({se})'

def get_table_block(start_marker, end_marker=None):
    """Get log block between two ===== markers."""
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


# ── TABLE 1: Correlates of NTV ──────────────────────────────────────────────

def make_table1():
    block = get_table_block('===== TABLE 1: Correlates of NTV =====',
                            '===== TABLE 2:')

    col_labels = ['--- Col 1: Vote 95 only ---',
                  '--- Col 2: Pop+wage linear ---',
                  '--- Col 3: Pop+wage polynomials ---',
                  '--- Col 4: Polynomials + vote95 ---',
                  '--- Col 5: Full controls ---',
                  '--- Col 6: With NTV1997 ---']

    key_vars = [
        ('NTV1997', 'NTV1997'),
        ('Votes_KPRF_1995', 'KPRF 1995'),
        ('Votes_LDPR_1995', 'LDPR 1995'),
        ('Votes_NDR_1995', 'NDR 1995'),
        ('Votes_Yabloko_1995', 'Yabloko 1995'),
        ('Votes_DVR_1995', 'DVR 1995'),
        ('Turnout1995', 'Turnout 1995'),
        ('population98_1', 'Population'),
        ('Gorod', 'City dummy'),
    ]

    sections = {h: get_section(block, h) for h in col_labels}

    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Table 1: Correlates of NTV Coverage}')
    lines.append(r'\label{tab:enik_table1}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lcccccc}')
    lines.append(r'\toprule')
    lines.append(r' & (1) & (2) & (3) & (4) & (5) & (6) \\')
    lines.append(r'\midrule')

    for vname, vlabel in key_vars:
        row_c = [esc(vlabel)]
        row_s = ['']
        for h in col_labels:
            c, se, p = parse_coef(sections[h], vname)
            cf, sf = fmt_coef(c, se, p)
            row_c.append(cf)
            row_s.append(sf)
        lines.append(' & '.join(row_c) + r' \\')
        lines.append(' & '.join(row_s) + r' \\')

    lines.append(r'\midrule')
    row_n = ['$N$'] + [parse_nobs(sections[h]) for h in col_labels]
    row_r2 = ['$R^2$'] + [parse_r2(sections[h]) for h in col_labels]
    lines.append(' & '.join(row_n) + r' \\')
    lines.append(' & '.join(row_r2) + r' \\')

    lines.append(r'\midrule')
    lines.append(r'Region FE & Yes & Yes & Yes & Yes & Yes & Yes \\')
    lines.append(r'1995 vote shares & Yes & No & No & Yes & Yes & Yes \\')
    lines.append(r'Socioeconomic & No & Yes & Yes & Yes & Yes & Yes \\')
    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} Dep.\ var.: NTV1999. All regressions include region FE. SEs clustered at region level. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'table1_correlates.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Table 1: Correlates of NTV - 6 columns")


# ── TABLE 2: NTV on 1999 Vote Shares ────────────────────────────────────────

def make_table2():
    block = get_table_block('===== TABLE 2: NTV on 1999 Vote Shares =====',
                            '===== TABLE 4:')

    parties = ['Votes_Edinstvo_1999', 'Votes_OVR_1999', 'Votes_SPS_1999',
               'Votes_Yabloko_1999', 'Votes_KPRF_1999', 'Votes_LDPR_1999', 'Turnout1999']
    party_labels = ['Unity', 'OVR', 'SPS', 'Yabloko', 'KPRF', 'LDPR', 'Turnout']

    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Table 2: Effect of NTV on 1999 Vote Shares}')
    lines.append(r'\label{tab:enik_table2}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lccccccc}')
    lines.append(r'\toprule')
    lines.append(r' & ' + ' & '.join(party_labels) + r' \\')
    lines.append(r'\midrule')

    for panel, suffix, panel_label in [
        ('A', 'without vote95', 'Panel A: Without 1995 vote controls'),
        ('B', 'with vote95', 'Panel B: With 1995 vote controls')
    ]:
        lines.append(r'\multicolumn{8}{l}{\textit{' + panel_label + r'}} \\')
        row_c = ['Watch\\_probit']
        row_s = ['']
        row_n = ['$N$']
        row_r2 = ['$R^2$']
        for p in parties:
            sec = get_section(block, f'--- {p} {suffix} ---')
            c, se, pv = parse_coef(sec, 'Watch_probit')
            cf, sf = fmt_coef(c, se, pv)
            row_c.append(cf)
            row_s.append(sf)
            row_n.append(parse_nobs(sec))
            row_r2.append(parse_r2(sec))
        lines.append(' & '.join(row_c) + r' \\')
        lines.append(' & '.join(row_s) + r' \\')
        lines.append(' & '.join(row_n) + r' \\')
        lines.append(' & '.join(row_r2) + r' \\')
        if panel == 'A':
            lines.append(r'\midrule')

    lines.append(r'\midrule')
    lines.append(r'Region FE & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\')
    lines.append(r'Socioeconomic & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\')
    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} Watch\_probit is predicted NTV viewership. All regressions include region FE, population/wage polynomials, city dummy, medical controls. Robust SEs clustered at region. Regions 5, 6 excluded. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'table2_vote1999.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Table 2: 1999 Vote Shares - 7 parties x 2 panels")


# ── TABLE 3: Panel Fixed Effects ────────────────────────────────────────────

def make_table3():
    block = get_table_block('===== TABLE 3: Panel Fixed Effects =====',
                            '===== AGGREGATE RESULTS COMPLETE =====')

    parties = ['Votes_SPS_', 'Votes_Yabloko_', 'Votes_KPRF_', 'Votes_LDPR_', 'Turnout']
    party_labels = ['SPS', 'Yabloko', 'KPRF', 'LDPR', 'Turnout']

    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Table 3: Panel Fixed Effects (1995--1999)}')
    lines.append(r'\label{tab:enik_table3}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lccccc}')
    lines.append(r'\toprule')
    lines.append(r' & ' + ' & '.join(party_labels) + r' \\')
    lines.append(r'\midrule')

    row_c = ['Watch\\_probit']
    row_s = ['']
    row_n = ['$N$']
    row_r2 = ['$R^2$ (within)']
    for p in parties:
        sec = get_section(block, f'--- Panel FE: {p} ---')
        c, se, pv = parse_coef(sec, 'Watch_probit_')
        cf, sf = fmt_coef(c, se, pv)
        row_c.append(cf)
        row_s.append(sf)
        row_n.append(parse_nobs(sec))
        m = re.search(r'within\s*=\s*([0-9.]+)', sec)
        row_r2.append(m.group(1) if m else '')

    lines.append(' & '.join(row_c) + r' \\')
    lines.append(' & '.join(row_s) + r' \\')
    lines.append(' & '.join(row_n) + r' \\')
    lines.append(' & '.join(row_r2) + r' \\')

    lines.append(r'\midrule')
    lines.append(r'District FE & Yes & Yes & Yes & Yes & Yes \\')
    lines.append(r'Year FE & Yes & Yes & Yes & Yes & Yes \\')
    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} Panel of 1995--1999 elections. Watch\_probit\_ = NTV viewership $\times$ 1999. District and year FE. SEs clustered at district. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'table3_panel.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Table 3: Panel FE - 5 columns")


# ── TABLE 6: First Stage ────────────────────────────────────────────────────

def make_table6():
    block = get_table_block('===== TABLE 6: First Stage =====',
                            '===== TABLE 7:')

    col_labels = ['--- OLS first stage ---',
                  '--- Probit first stage ---',
                  '--- OLS with intended vote ---',
                  '--- Probit with intended vote ---']
    sections = {h: get_section(block, h) for h in col_labels}

    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Table 6: First Stage --- Signal Strength on NTV Viewership}')
    lines.append(r'\label{tab:enik_table6}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lcccc}')
    lines.append(r'\toprule')
    lines.append(r' & OLS & Probit & OLS & Probit \\')
    lines.append(r' & (1) & (2) & (3) & (4) \\')
    lines.append(r'\midrule')

    key_var = 'tvmaxtveloss5050powerA'
    row_c = ['Signal strength']
    row_s = ['']
    row_n = ['$N$']
    row_r2 = ['$R^2$/Pseudo $R^2$']
    for h in col_labels:
        c, se, pv = parse_coef(sections[h], key_var)
        cf, sf = fmt_coef(c, se, pv)
        row_c.append(cf)
        row_s.append(sf)
        row_n.append(parse_nobs(sections[h]))
        row_r2.append(parse_r2(sections[h]))

    lines.append(' & '.join(row_c) + r' \\')
    lines.append(' & '.join(row_s) + r' \\')
    lines.append(' & '.join(row_n) + r' \\')
    lines.append(' & '.join(row_r2) + r' \\')

    lines.append(r'\midrule')
    lines.append(r'Intended vote controls & No & No & Yes & Yes \\')
    lines.append(r'Sociodemographic & Yes & Yes & Yes & Yes \\')
    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} Dep.\ var.: Watches NTV 1999. Signal strength is terrain-adjusted NTV signal. Robust SEs. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'table6_firststage.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Table 6: First Stage - 4 columns")


# ── TABLE 7: Reported Vote ──────────────────────────────────────────────────

def make_table7():
    block = get_table_block('===== TABLE 7: Reported Vote =====',
                            '===== TABLE 8: Intended Vote =====')

    parties = ['Unity', 'OVR', 'SPS', 'Yabloko', 'KPRF', 'Zhir', 'reported']
    party_labels = ['Unity', 'OVR', 'SPS', 'Yabloko', 'KPRF', 'Zhirinovsky', 'Reported']

    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Table 7: Effect on Reported Voting (Marginal Effects)}')
    lines.append(r'\label{tab:enik_table7}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lccccccc}')
    lines.append(r'\toprule')
    lines.append(r' & ' + ' & '.join(party_labels) + r' \\')
    lines.append(r'\midrule')

    for method, method_label in [('Biprobit', 'Panel A: Bivariate probit'), ('Probit', 'Panel B: Probit')]:
        lines.append(r'\multicolumn{8}{l}{\textit{' + method_label + r'}} \\')
        row_c = ['Watches NTV']
        row_s = ['']
        row_n = ['$N$']
        for p in parties:
            sec = get_section(block, f'--- {method}: vote_{p} ---')
            c, se, pv = parse_marginal(sec, 'Watches_NTV_1999')
            cf, sf = fmt_coef(c, se, pv)
            row_c.append(cf)
            row_s.append(sf)
            row_n.append(parse_nobs(sec))
        lines.append(' & '.join(row_c) + r' \\')
        lines.append(' & '.join(row_s) + r' \\')
        lines.append(' & '.join(row_n) + r' \\')
        if method == 'Biprobit':
            lines.append(r'\midrule')

    lines.append(r'\midrule')
    lines.append(r'Controls & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\')
    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} Marginal effects. Panel A: recursive bivariate probit (signal strength as instrument). Panel B: single-equation probit. SEs clustered at district. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'table7_reported.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Table 7: Reported Vote - 7 parties x 2 panels")


# ── TABLE 8: Intended Vote ──────────────────────────────────────────────────

def make_table8():
    block = get_table_block('===== TABLE 8: Intended Vote =====',
                            '===== TABLE 8 cont:')

    parties = ['Unity', 'OVR', 'SPS', 'Yabloko', 'KPRF', 'Zhir', 'vote']
    party_labels = ['Unity', 'OVR', 'SPS', 'Yabloko', 'KPRF', 'Zhirinovsky', 'Any Vote']

    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Table 8: Effect on Intended Voting (Biprobit Marginal Effects)}')
    lines.append(r'\label{tab:enik_table8}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lccccccc}')
    lines.append(r'\toprule')
    lines.append(r' & ' + ' & '.join(party_labels) + r' \\')
    lines.append(r'\midrule')

    row_c = ['Watches NTV']
    row_s = ['']
    row_n = ['$N$']
    for p in parties:
        sec = get_section(block, f'--- Biprobit intention: int_{p} ---')
        c, se, pv = parse_marginal(sec, 'Watches_NTV_1999')
        cf, sf = fmt_coef(c, se, pv)
        row_c.append(cf)
        row_s.append(sf)
        row_n.append(parse_nobs(sec))

    lines.append(' & '.join(row_c) + r' \\')
    lines.append(' & '.join(row_s) + r' \\')
    lines.append(' & '.join(row_n) + r' \\')

    lines.append(r'\midrule')
    lines.append(r'Controls & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\')
    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} Marginal effects from recursive bivariate probit. Signal strength instruments for NTV viewership. SEs clustered at district. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'table8_intended.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Table 8: Intended Vote - 7 columns")


# ── TABLE A4: Individual Placebo 1995 ───────────────────────────────────────

def make_tableA4():
    block = get_table_block('===== TABLE A4: Individual Placebo 1995 =====',
                            '===== ALL TABLES COMPLETE =====')

    parties = ['DVR', 'Yabloko', 'KPRF', 'LDPR', 'NDR', 'reported']
    party_labels = ['DVR', 'Yabloko', 'KPRF', 'LDPR', 'NDR', 'Reported']

    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Table A4: Individual Placebo --- 1995 Election (Probit Marginal Effects)}')
    lines.append(r'\label{tab:enik_tableA4}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lcccccc}')
    lines.append(r'\toprule')
    lines.append(r' & ' + ' & '.join(party_labels) + r' \\')
    lines.append(r'\midrule')

    row_c = ['Watch\\_probit']
    row_s = ['']
    row_n = ['$N$']
    for p in parties:
        sec = get_section(block, f'--- Placebo 1995: Voted_{p}_1995 ---')
        c, se, pv = parse_marginal(sec, 'Watch_probit')
        cf, sf = fmt_coef(c, se, pv)
        row_c.append(cf)
        row_s.append(sf)
        row_n.append(parse_nobs(sec))

    lines.append(' & '.join(row_c) + r' \\')
    lines.append(' & '.join(row_s) + r' \\')
    lines.append(' & '.join(row_n) + r' \\')

    lines.append(r'\midrule')
    lines.append(r'Controls & Yes & Yes & Yes & Yes & Yes & Yes \\')
    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} Placebo using 1995 outcomes. Probit marginal effects. SEs clustered at district. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'tableA4_placebo_indiv.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Table A4: Individual Placebo 1995 - 6 columns")


# ── Run all ──────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    make_table1()
    make_table2()
    make_table3()
    make_table6()
    make_table7()
    make_table8()
    make_tableA4()
    print("\nAll Enikolopov tables generated.")
