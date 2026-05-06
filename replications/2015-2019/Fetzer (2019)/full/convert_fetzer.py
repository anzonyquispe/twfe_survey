"""
Convert Fetzer (2019) Stata log to LaTeX tables.
District-level analysis only (UKHLS data not included).
"""
import re, os

OUTDIR = os.path.dirname(os.path.abspath(__file__))
LOGFILE = os.path.join(OUTDIR, "run_fetzer_full.log")

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

def fmt(val, decimals=3):
    try:
        v = float(val)
        return f'{v:.{decimals}f}'
    except:
        return str(val)


# ── TABLE A1: Summary Statistics ─────────────────────────────────────────────

def make_table_a1():
    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Table A1: Summary Statistics (District Level)}')
    lines.append(r'\label{tab:fetzer_a1}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lcccc}')
    lines.append(r'\toprule')
    lines.append(r'Variable & Obs & Mean & Std.\ Dev. & Min & Max \\')
    lines.append(r'\midrule')

    # Parse summary statistics from log
    # Pattern: Variable |   Obs   Mean   Std.dev   Min   Max
    sum_pattern = re.compile(
        r'---\s+Summary:\s+(.+?)\s+(?:\(year==2011\)\s+)?---\n'
        r'\n\s+Variable \|.+?\n'
        r'-+\+-+\n'
        r'\s*\S+\s*\|\s+([0-9,]+)\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+([-.0-9e+]+)\s+([-.0-9e+]+)',
        re.DOTALL
    )

    labels = {
        'pct_votes_UKIP': 'Local election \\% for UKIP',
        'UKIPPct': 'EP \\% for UKIP',
        'QUAL_ALL_noq_sh': '\\% No qualifications (2001)',
        'RoutineOccAll_sh': '\\% Routine occupations (2001)',
        'GRetailAll_sh': '\\% in Retail (2001)',
        'DManufAll_sh': '\\% in Manufacturing (2001)',
        'totalimpact_finlosswapyr': 'Total austerity impact',
        'taxcredits_finlosswapyr': 'Tax credits impact',
        'childbenefit_finlosswapyr': 'Child benefit impact',
        'counciltaxbenefit_finlosswapyr': 'Council tax benefit impact',
        'disabilitylivingallow_finlosswap': 'Disability living allowance impact',
        'bedroom_tax_finlosswapyr': 'Bedroom tax impact',
    }

    for m in sum_pattern.finditer(log):
        varname = m.group(1).strip()
        obs = m.group(2).replace(',', '')
        mean = fmt(m.group(3), 3)
        sd = fmt(m.group(4), 3)
        mn = fmt(m.group(5), 3)
        mx = fmt(m.group(6), 3)
        label = labels.get(varname, varname)
        lines.append(f'{label} & {obs} & {mean} & {sd} & {mn} & {mx} \\\\')

    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} District-level summary statistics. Austerity variables measured as financial loss per working-age person per year (\pounds).}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'table_a1_summary.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Table A1: Summary Statistics")


# ── EVENT STUDY TABLE (Figure 4 data) ────────────────────────────────────────

def make_event_study_table():
    """Extract reghdfe event study coefficients for all 4 vulnerability measures."""

    variables = [
        ('QUAL_ALL_noq_sh', 'No qualifications'),
        ('RoutineOccAll_sh', 'Routine occupations'),
        ('GRetailAll_sh', 'Retail'),
        ('DManufAll_sh', 'Manufacturing'),
    ]

    # For each variable, extract the HDFE regression block
    sections = {}
    for vname, vlabel in variables:
        header = f'--- reghdfe: pct_votes_UKIP on {vname} x year ---'
        start = log.find(header)
        if start < 0:
            continue
        # Find the next section header or end
        next_header = log.find('--- reghdfe:', start + len(header))
        next_section = log.find('=====', start + len(header))
        end = len(log)
        if next_header > 0:
            end = min(end, next_header)
        if next_section > 0:
            end = min(end, next_section)
        sections[vname] = log[start:end]

    # Extract coefficients from each reghdfe block
    # The main table has abbreviated variable names like yyin_QUAL~_1
    # But we also have the lincom output with exact coefficients

    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Figure 4 Data: Event Study Coefficients (reghdfe)}')
    lines.append(r'\label{tab:fetzer_fig4}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lcccc}')
    lines.append(r'\toprule')
    lines.append(r' & No qualif. & Routine occ. & Retail & Manufacturing \\')
    lines.append(r' & (1) & (2) & (3) & (4) \\')
    lines.append(r'\midrule')

    # Extract from the main HDFE table for each variable
    # Years 1-10 (pre), 12-16 (post), with 11 as omitted
    year_labels = {1: '2000', 2: '2001', 3: '2002', 4: '2003', 5: '2004',
                   6: '2005', 7: '2006', 8: '2007', 9: '2008', 10: '2009',
                   12: '2012', 13: '2013', 14: '2014', 15: '2015', 16: '2016'}

    # Parse from lincom output: "Year X: coef (se)"
    for yr in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16]:
        if yr == 10:
            lines.append(r'\midrule')
            lines.append(r'\textit{Omitted: 2011} & & & & \\')
            lines.append(r'\midrule')

        row_c = [year_labels.get(yr, str(yr))]
        row_s = ['']
        for vname, vlabel in variables:
            block = sections.get(vname, '')
            # Parse from the HDFE regression table
            # Stata abbreviates variable names inconsistently, e.g.:
            #   yyin_QUAL~_1, yyin_QUAL_~7, yyin_QUAL~10
            # Use flexible pattern: yyin_ + anything + year digits (not followed by more digits)
            pat = re.compile(
                r'yyin_\S*?' + str(yr) + r'(?!\d)\s*\|\s+'
                r'([-.0-9e+]+)\s+([-.0-9e+]+)\s+[-.0-9e+]+\s+([0-9.]+)'
            )
            m = pat.search(block)
            if m:
                coef = float(m.group(1))
                se = float(m.group(2))
                pval = float(m.group(3))
                st = stars(str(pval))
                row_c.append(f'{coef:.4f}{st}')
                row_s.append(f'({se:.4f})')
            else:
                row_c.append('')
                row_s.append('')

        lines.append(' & '.join(row_c) + r' \\')
        lines.append(' & '.join(row_s) + r' \\')

    lines.append(r'\midrule')

    # Average post-treatment from lincom
    row_avg = ['Avg.\\ post-2013']
    row_avg_se = ['']
    for vname, vlabel in variables:
        block = sections.get(vname, '')
        m = re.search(r'Avg:\s+([-.0-9]+)\s+SE:\s+([-.0-9]+)', block)
        if m:
            avg = float(m.group(1))
            se = float(m.group(2))
            # Check significance
            t = abs(avg / se) if se != 0 else 0
            if t > 2.576: st = '***'
            elif t > 1.96: st = '**'
            elif t > 1.645: st = '*'
            else: st = ''
            row_avg.append(f'{avg:.4f}{st}')
            row_avg_se.append(f'({se:.4f})')
        else:
            row_avg.append('')
            row_avg_se.append('')
    lines.append(' & '.join(row_avg) + r' \\')
    lines.append(' & '.join(row_avg_se) + r' \\')

    lines.append(r'\midrule')

    # N and R2
    row_n = ['$N$']
    row_r2 = ['Within $R^2$']
    for vname, vlabel in variables:
        block = sections.get(vname, '')
        m = re.search(r'Number of obs\s*=\s*([0-9,]+)', block)
        row_n.append(m.group(1).replace(',', '') if m else '')
        m = re.search(r'Within R-sq\.\s*=\s*([0-9.]+)', block)
        row_r2.append(m.group(1) if m else '')
    lines.append(' & '.join(row_n) + r' \\')
    lines.append(' & '.join(row_r2) + r' \\')
    lines.append(r'\midrule')
    lines.append(r'District FE & Yes & Yes & Yes & Yes \\')
    lines.append(r'Region $\times$ Year FE & Yes & Yes & Yes & Yes \\')
    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} Dep.\ var.: UKIP local election vote share (proportion). Each column interacts the vulnerability measure with year dummies. Reghdfe with district and region$\times$year FE. SEs clustered at district level. Year 2011 omitted. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'table_fig4_eventstudy.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Event Study Table (Figure 4 data): 4 columns x 15 year coefficients")


# ── FIGURE 1 TABLE (UKIP vote shares by year) ────────────────────────────────

def make_figure1_table():
    """UKIP vote shares by year from OLS regression."""
    lines = []
    lines.append(r'\begin{table}[htbp]')
    lines.append(r'\centering')
    lines.append(r'\caption{Figure 1 Data: UKIP Vote Shares by Year}')
    lines.append(r'\label{tab:fetzer_fig1}')
    lines.append(r'\begin{adjustbox}{max width=\textwidth}')
    lines.append(r'\begin{tabular}{lcc}')
    lines.append(r'\toprule')
    lines.append(r'Year & Local elections & EP elections \\')
    lines.append(r'\midrule')

    # Parse local election coefficients
    local_block = log[log.find('--- pct_votes_UKIP by year ---'):log.find('--- UKIPPct by year ---')]
    ep_block = log[log.find('--- UKIPPct by year ---'):log.find('===== TABLE A1')]

    year_map_local = {
        1: 2000, 2: 2001, 3: 2002, 4: 2003, 5: 2004, 6: 2005, 7: 2006, 8: 2007,
        9: 2008, 10: 2009, 11: 2010, 12: 2011, 13: 2012, 14: 2013, 15: 2014, 16: 2015
    }
    year_map_ep = {1: 2004, 2: 2009, 3: 2014}

    # Parse "Year coef: X SE: Y" lines
    local_coefs = {}
    for m in re.finditer(r'Year coef:\s+([-.0-9]+)\s+SE:\s+([-.0-9]+)', local_block):
        idx = len(local_coefs) + 1
        local_coefs[idx] = (float(m.group(1)), float(m.group(2)))

    ep_coefs = {}
    for m in re.finditer(r'Year coef:\s+([-.0-9]+)\s+SE:\s+([-.0-9]+)', ep_block):
        idx = len(ep_coefs) + 1
        ep_coefs[idx] = (float(m.group(1)), float(m.group(2)))

    all_years = sorted(set(year_map_local.values()) | set(year_map_ep.values()))
    for yr in all_years:
        local_str = ''
        ep_str = ''
        local_se = ''
        ep_se = ''

        for k, v in year_map_local.items():
            if v == yr and k in local_coefs:
                c, s = local_coefs[k]
                local_str = f'{c:.2f}'
                local_se = f'({s:.2f})'

        for k, v in year_map_ep.items():
            if v == yr and k in ep_coefs:
                c, s = ep_coefs[k]
                ep_str = f'{c:.2f}'
                ep_se = f'({s:.2f})'

        lines.append(f'{yr} & {local_str} & {ep_str} \\\\')
        if local_se or ep_se:
            lines.append(f' & {local_se} & {ep_se} \\\\')

    lines.append(r'\midrule')
    lines.append(r'$N$ & 1,832 & 353 \\')
    lines.append(r'\bottomrule')
    lines.append(r'\end{tabular}')
    lines.append(r'\end{adjustbox}')
    lines.append(r'\parbox{\textwidth}{\footnotesize\textit{Notes:} Mean UKIP vote share by year. Local elections: year dummies weighted by seats contested. EP elections: year dummies weighted by seats contested.}')
    lines.append(r'\end{table}')

    with open(os.path.join(OUTDIR, 'table_fig1_ukip.tex'), 'w') as f:
        f.write('\n'.join(lines))
    print("Figure 1: UKIP vote shares by year")


if __name__ == '__main__':
    make_table_a1()
    make_event_study_table()
    make_figure1_table()
    print("\nAll Fetzer tables generated.")
