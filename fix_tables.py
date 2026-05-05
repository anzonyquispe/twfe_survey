#!/usr/bin/env python3
"""fix_tables.py — Convert raw Stata output to proper LaTeX tabular format.

Fixes the \\verbatiminput{} problem in twfe_survey PDFs.

Papers processed:
1. Bloom et al. (2012): 4 esttab CSVs (="value" format)
2. Handley & Limao (2017): 2 CSVs + 15 outreg2 .out files (tab-separated)
3. Anderson & Sallee (2011): 2 Stata log files (ASCII pipe-delimited tables)
"""

import os
import re
import csv as csvmod

# ===========================================================================
# PATHS
# ===========================================================================
BASE = "C:/Users/Usuario/Documents/GitHub/twfe_survey/latex"
BLOOM_DIR = os.path.join(BASE, "2010-2012", "Bloom et al. (2012)", "full")
HL_DIR = os.path.join(BASE, "2015-2019", "Handley and Limao (2017)", "full")
AS_DIR = os.path.join(BASE, "2010-2012", "Anderson and Sallee (2011)", "full")

# ===========================================================================
# UTILITIES
# ===========================================================================

def esc(s):
    """Escape LaTeX special characters. Preserves *** ** * significance markers."""
    if s is None:
        return ''
    s = str(s).strip()
    if not s:
        return ''

    # Extract trailing significance stars
    stars = ''
    for marker in ['***', '**', '*']:
        if s.endswith(marker) and len(s) > len(marker):
            pre = s[:-len(marker)]
            if pre and (pre[-1].isdigit() or pre[-1] == ')' or pre[-1] == ']'):
                stars = marker
                s = pre
                break

    # Escape specials (order matters)
    s = s.replace('\\', '\\textbackslash{}')
    s = s.replace('%', '\\%')
    s = s.replace('&', '\\&')
    s = s.replace('#', '\\#')
    s = s.replace('_', '\\_')
    # Don't escape $ { } if they look like they might be LaTeX already
    if '$' in s and '\\' not in s:
        s = s.replace('$', '\\$')
    s = s.replace('{', '\\{')
    s = s.replace('}', '\\}')

    return s + stars


def write_tex(path, content):
    """Write LaTeX content to file."""
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content + '\n')
    print(f"  -> {os.path.basename(path)}")


# ===========================================================================
# 1. BLOOM ET AL. — esttab CSV (="value" format)
# ===========================================================================

def convert_bloom_csv(inpath, outpath):
    """Convert Bloom's esttab CSV (="value" format) to LaTeX tabular."""
    with open(inpath, 'r', encoding='utf-8-sig') as f:
        raw = f.read()

    rows = []
    for line in raw.strip().split('\n'):
        line = line.strip()
        if not line:
            continue
        # Extract ="..." cells
        cells = re.findall(r'="([^"]*)"', line)
        if not cells:
            # Fallback: handle bare ="" as empty
            cells = []
            for part in line.split(','):
                part = part.strip()
                if part.startswith('="') and part.endswith('"'):
                    cells.append(part[2:-1])
                elif part == '=""':
                    cells.append('')
                else:
                    cells.append(part.strip('"'))
        rows.append(cells)

    if not rows:
        return

    nc = len(rows[0])
    colspec = 'l' + 'c' * (nc - 1)

    out = []
    # Wrap wide tables in adjustbox
    wide = nc > 6
    if wide:
        out.append('\\begin{adjustbox}{max width=\\textwidth}')
    out.append(f'\\begin{{tabular}}{{{colspec}}}')
    out.append('\\toprule')

    # Find header end (b/se row)
    header_end = 2  # default
    for i, row in enumerate(rows[:5]):
        if any('b/se' in c.lower() for c in row):
            header_end = i
            break

    # Header rows
    for i in range(header_end + 1):
        cells = [esc(c) for c in rows[i]]
        while len(cells) < nc:
            cells.append('')
        out.append(' & '.join(cells) + ' \\\\')
    out.append('\\midrule')

    # Data rows
    footer_added = False
    for i in range(header_end + 1, len(rows)):
        row = rows[i]
        first = row[0].strip() if row else ''

        if first.upper() in ['N', 'OBSERVATIONS', 'R-SQUARED'] and not footer_added:
            out.append('\\midrule')
            footer_added = True

        cells = [esc(c) for c in row]
        while len(cells) < nc:
            cells.append('')
        out.append(' & '.join(cells) + ' \\\\')

    out.append('\\bottomrule')
    out.append('\\end{tabular}')
    if wide:
        out.append('\\end{adjustbox}')

    write_tex(outpath, '\n'.join(out))


# ===========================================================================
# 2. HANDLEY & LIMAO — outreg2 .out (tab-separated)
# ===========================================================================

def convert_outreg2(inpath, outpath):
    """Convert outreg2 .out (tab-separated) to LaTeX tabular."""
    with open(inpath, 'r', encoding='utf-8-sig') as f:
        raw = f.read()

    raw_lines = raw.split('\n')
    rows = [line.rstrip('\r').split('\t') for line in raw_lines]

    # Remove trailing empty rows
    while rows and not any(c.strip() for c in rows[-1]):
        rows.pop()

    if not rows:
        return

    # Find VARIABLES row
    var_idx = None
    for i, row in enumerate(rows):
        if row and row[0].strip() == 'VARIABLES':
            var_idx = i
            break

    if var_idx is None:
        var_idx = 0

    # Determine number of columns
    nc = max(len(r) for r in rows if r)
    colspec = 'l' + 'c' * (nc - 1)

    out = []
    # Wrap wide tables in adjustbox
    wide = nc > 6
    if wide:
        out.append('\\begin{adjustbox}{max width=\\textwidth}')
    out.append(f'\\begin{{tabular}}{{{colspec}}}')
    out.append('\\toprule')

    # Header rows (0 to var_idx, inclusive)
    for i in range(var_idx + 1):
        cells = [esc(c.strip()) for c in rows[i]]
        while len(cells) < nc:
            cells.append('')
        out.append(' & '.join(cells) + ' \\\\')
    out.append('\\midrule')

    # Skip blank line after VARIABLES
    data_start = var_idx + 1
    if data_start < len(rows) and not any(c.strip() for c in rows[data_start]):
        data_start += 1

    # Data and footer rows
    footer_added = False
    notes = []
    done = False

    for i in range(data_start, len(rows)):
        if done:
            break
        row = rows[i]
        if not any(c.strip() for c in row):
            continue

        first = row[0].strip()

        # Detect note lines
        if first.startswith('***') or first.startswith('Robust') or first.startswith('Standard'):
            notes.append(first)
            # Collect remaining notes
            for j in range(i + 1, len(rows)):
                nf = rows[j][0].strip() if rows[j] else ''
                if nf.startswith('***') or nf.startswith('Robust') or nf.startswith('Standard'):
                    notes.append(nf)
                elif nf:
                    break
            done = True
            continue

        # Footer detection (statistics rows)
        lower_first = first.lower()
        is_footer = any(lower_first.startswith(x) for x in [
            'observations', 'r-squared', 'restriction', 'test ', 'unc coeff',
            'unc se', 'tariff coeff', 'tariff se', 'tc coeff', 'tc se',
            'f-stat', 'mfx'
        ])
        if is_footer and not footer_added:
            out.append('\\midrule')
            footer_added = True

        cells = [esc(c.strip()) for c in row]
        while len(cells) < nc:
            cells.append('')
        out.append(' & '.join(cells) + ' \\\\')

    out.append('\\bottomrule')

    # Add notes as footnotes
    for note in notes:
        out.append(f'\\multicolumn{{{nc}}}{{l}}{{\\footnotesize {esc(note)}}} \\\\')

    out.append('\\end{tabular}')
    if wide:
        out.append('\\end{adjustbox}')

    write_tex(outpath, '\n'.join(out))


# ===========================================================================
# 3. HANDLEY & LIMAO — CSV files (summary statistics)
# ===========================================================================

def convert_hl_table1_csv(inpath, outpath):
    """Convert Handley table1.csv (summary stats, quoted CSV) to LaTeX tabular."""
    with open(inpath, 'r', encoding='utf-8-sig') as f:
        raw = f.read()

    # Parse quoted CSV manually
    rows = []
    for line in raw.strip().split('\n'):
        line = line.strip()
        if not line:
            continue
        cells = []
        in_quote = False
        current = ''
        for ch in line:
            if ch == '"':
                in_quote = not in_quote
            elif ch == ',' and not in_quote:
                cells.append(current.strip().strip('"'))
                current = ''
            else:
                current += ch
        cells.append(current.strip().strip('"'))
        rows.append(cells)

    if not rows:
        return

    nc = len(rows[0])
    colspec = 'l' + 'c' * (nc - 1)

    out = []
    out.append(f'\\begin{{tabular}}{{{colspec}}}')
    out.append('\\toprule')

    # First 2 rows are header
    for i in range(min(2, len(rows))):
        cells = [esc(c) for c in rows[i]]
        while len(cells) < nc:
            cells.append('')
        out.append(' & '.join(cells) + ' \\\\')
    out.append('\\midrule')

    # Data rows
    footer_added = False
    for i in range(2, len(rows)):
        row = rows[i]
        first = row[0].strip() if row else ''

        if first.lower().startswith('observations') and not footer_added:
            out.append('\\midrule')
            footer_added = True

        # Note line (single cell spanning all columns)
        if first.startswith('t-stat') or (len(row) == 1 and first):
            if not footer_added:
                out.append('\\bottomrule')
            out.append(f'\\multicolumn{{{nc}}}{{l}}{{\\footnotesize {esc(first)}}} \\\\')
            continue

        cells = [esc(c) for c in row]
        while len(cells) < nc:
            cells.append('')
        out.append(' & '.join(cells) + ' \\\\')

    if not any('\\bottomrule' in l for l in out):
        out.append('\\bottomrule')
    out.append('\\end{tabular}')

    write_tex(outpath, '\n'.join(out))


def convert_hl_tableA1_csv(inpath, outpath):
    """Convert Handley tableA1.csv (detailed section stats, wide) to LaTeX.
    Uses landscape and scriptsize for the wide table.
    """
    with open(inpath, 'r', encoding='utf-8-sig') as f:
        reader = csvmod.reader(f)
        rows = list(reader)

    if not rows:
        return

    # Simplify headers for readability
    header_map = {
        'section': 'Section',
        'imp_share_05': 'Import Share',
        'unc_pre': 'Unc. Mean',
        'unc_pre_p50': 'Unc. p50',
        'unc_pre_sd': 'Unc. SD',
        'unc_pre_min': 'Unc. Min',
        'unc_pre_max': 'Unc. Max',
        'dif_ln_imp_5': '$\\Delta$ln(Imp) Mean',
        'dif_ln_imp_5_p50': '$\\Delta$ln(Imp) p50',
        'dif_ln_imp_5_sd': '$\\Delta$ln(Imp) SD',
        'dif_ln_imp_5_min': '$\\Delta$ln(Imp) Min',
        'dif_ln_imp_5_max': '$\\Delta$ln(Imp) Max',
        'nobs': 'N',
        'nobs_imp': 'N(Imp)',
    }

    nc = len(rows[0])
    colspec = 'l' + 'r' * (nc - 1)

    out = []
    out.append('{\\scriptsize')
    out.append(f'\\begin{{tabular}}{{{colspec}}}')
    out.append('\\toprule')

    # Header row
    headers = rows[0]
    cells = [header_map.get(h.strip(), esc(h.strip())) for h in headers]
    out.append(' & '.join(cells) + ' \\\\')
    out.append('\\midrule')

    # Data rows
    for i in range(1, len(rows)):
        row = rows[i]
        cells = []
        for j, c in enumerate(row):
            c = c.strip()
            if j == 0:
                cells.append(esc(c))
            else:
                try:
                    val = float(c)
                    if abs(val) >= 100:
                        cells.append(f'{val:.0f}')
                    elif abs(val) >= 1:
                        cells.append(f'{val:.2f}')
                    else:
                        cells.append(f'{val:.4f}')
                except (ValueError, TypeError):
                    cells.append(esc(c) if c else '')
        while len(cells) < nc:
            cells.append('')
        out.append(' & '.join(cells) + ' \\\\')

    out.append('\\bottomrule')
    out.append('\\end{tabular}')
    out.append('}')

    write_tex(outpath, '\n'.join(out))


# ===========================================================================
# 4. ANDERSON & SALLEE — Stata log files
# ===========================================================================

def detect_columns_from_header(header_line, pipe_pos):
    """Detect column names and their center positions from Stata table header.
    Returns list of (name, center_position) tuples.
    """
    col_part = header_line[pipe_pos + 1:]

    # Find runs of non-space characters (column names)
    cols = []
    i = 0
    while i < len(col_part):
        if col_part[i] != ' ':
            start = i
            while i < len(col_part) and col_part[i] != ' ':
                i += 1
            name = col_part[start:i]
            center = (start + i - 1) / 2.0
            cols.append((name, center))
        i += 1

    return cols


def is_pure_dash_border(line):
    """Check if line is a pure-dash border (no + or | characters)."""
    stripped = line.strip()
    return bool(re.match(r'^-{10,}$', stripped))


def is_separator_line(line):
    """Check if line is a table separator (contains + and -)."""
    stripped = line.strip()
    return '+' in stripped and '-' in stripped and re.match(r'^[-+]+$', stripped)


def extract_tables_from_log(raw_lines):
    """Extract ASCII table blocks from Stata log lines.

    Returns list of (title, table_lines) tuples.

    A valid table has this structure:
      ------...------       (top border: pure dashes)
      Header | Col1 Col2   (header lines with |)
      ------+------         (separator: dashes + plus)
      Data   | val1 val2   (data lines with |)
      ------...------       (bottom border: pure dashes)
    """
    tables = []
    current_title = ''
    i = 0

    while i < len(raw_lines):
        line = raw_lines[i]
        stripped = line.strip()

        # Track section titles from Stata comments
        if stripped.startswith('.') and '*' in stripped and 'TABLE' in stripped.upper():
            current_title = stripped.lstrip('. ').strip('* ').strip()
        elif stripped.startswith('*****') and 'TABLE' in stripped.upper():
            current_title = stripped.strip('* ').strip()

        # Look for potential table start: pure-dash border
        if is_pure_dash_border(line):
            # Look ahead: expect header lines (with |), then separator (with +)
            j = i + 1
            found_pipe = False
            found_separator = False
            sep_line_idx = None

            while j < len(raw_lines) and j < i + 10:
                jline = raw_lines[j]
                jstripped = jline.strip()

                if '|' in jstripped and not jstripped.startswith('-'):
                    found_pipe = True
                elif is_separator_line(jline):
                    found_separator = True
                    sep_line_idx = j
                    break
                elif is_pure_dash_border(jline):
                    # Another pure border before separator → not a table
                    break
                j += 1

            if found_pipe and found_separator and sep_line_idx is not None:
                # Valid table start. Now find bottom border (next pure-dash line)
                j = sep_line_idx + 1
                while j < len(raw_lines):
                    if is_pure_dash_border(raw_lines[j]):
                        # Found bottom border
                        table_block = [raw_lines[k] for k in range(i, j + 1)]
                        tables.append((current_title, table_block))
                        i = j + 1
                        break
                    j += 1
                else:
                    i += 1  # No bottom border found, skip
                continue

        i += 1

    return tables


def ascii_table_to_tabular(table_lines):
    """Convert a single Stata ASCII table block to LaTeX tabular.
    Input: list of lines including top/bottom borders.
    Returns: LaTeX tabular string, or None if parsing fails.
    """
    # Clean lines
    lines = [l.rstrip() for l in table_lines]

    if len(lines) < 4:
        return None

    # Find separator line (contains +)
    sep_idx = None
    for i, l in enumerate(lines):
        if is_separator_line(l) and i > 0:
            sep_idx = i
            break

    if sep_idx is None:
        return None

    # Find pipe position from separator line (position of +)
    pipe_pos = lines[sep_idx].find('+')
    if pipe_pos < 0:
        return None

    # Header lines (between top border and separator)
    header_lines = lines[1:sep_idx]
    # Data lines (between separator and bottom border, excluding both)
    data_lines = lines[sep_idx + 1:]
    if data_lines and is_pure_dash_border(data_lines[-1]):
        data_lines = data_lines[:-1]

    if not header_lines:
        return None

    # Get column names and center positions from last header line
    last_header = header_lines[-1]
    col_info = detect_columns_from_header(last_header, pipe_pos)

    if not col_info:
        return None

    col_names = [c[0] for c in col_info]
    col_centers = [c[1] for c in col_info]
    nc = len(col_names) + 1  # +1 for row label
    colspec = 'l' + 'r' * len(col_names)

    out = []
    out.append(f'\\begin{{tabular}}{{{colspec}}}')
    out.append('\\toprule')

    # Build header
    if len(header_lines) > 1:
        first_header = header_lines[0]
        p = first_header.find('|')
        if p >= 0:
            row_label = first_header[:p].strip()
            span_label = first_header[p+1:].strip()
            if span_label:
                out.append(f'{esc(row_label)} & \\multicolumn{{{len(col_names)}}}{{c}}{{{esc(span_label)}}} \\\\')

    # Column header row
    last_header_row_label = last_header[:pipe_pos].strip()
    header_cells = [esc(last_header_row_label)] + [esc(c) for c in col_names]
    out.append(' & '.join(header_cells) + ' \\\\')
    out.append('\\midrule')

    # Parse data rows using nearest-column matching
    has_data = False
    for dl in data_lines:
        p = dl.find('|')
        if p < 0:
            continue

        row_label = dl[:p].strip()
        value_part = dl[p + 1:]

        # Find all tokens in the value part
        tokens = []
        ti = 0
        while ti < len(value_part):
            if value_part[ti] != ' ':
                start = ti
                while ti < len(value_part) and value_part[ti] != ' ':
                    ti += 1
                token = value_part[start:ti]
                token_center = (start + ti - 1) / 2.0
                tokens.append((token, token_center))
            ti += 1

        # Assign each token to nearest column
        values = [''] * len(col_names)
        for token, token_center in tokens:
            min_dist = float('inf')
            best_col = 0
            for j, cc in enumerate(col_centers):
                dist = abs(token_center - cc)
                if dist < min_dist:
                    min_dist = dist
                    best_col = j
            values[best_col] = token

        # Build cells
        all_empty = all(v == '' for v in values)
        if row_label == '' and all_empty:
            continue  # Skip blank separator rows

        cells = [esc(row_label)] + [esc(v) for v in values]
        out.append(' & '.join(cells) + ' \\\\')
        has_data = True

    if not has_data:
        return None

    out.append('\\bottomrule')
    out.append('\\end{tabular}')

    return '\n'.join(out)


def convert_stata_log(inpath, outpath):
    """Convert Stata log with ASCII tables to clean LaTeX.
    Extracts pipe-delimited tables and converts to tabular.
    Skips figure-related sections.
    """
    with open(inpath, 'r', encoding='utf-8-sig') as f:
        raw_lines = f.readlines()

    raw_lines = [l.rstrip('\n').rstrip('\r') for l in raw_lines]

    # Extract table blocks
    table_blocks = extract_tables_from_log(raw_lines)

    # Convert each table block to LaTeX
    out_parts = []
    seen_titles = set()

    for title, lines in table_blocks:
        # Skip figure-related tables
        if 'FIGURE' in title.upper():
            continue

        tex = ascii_table_to_tabular(lines)
        if tex:
            # Add section title if new
            if title and title not in seen_titles:
                out_parts.append(
                    f'\\vspace{{1em}}\n'
                    f'\\noindent\\textbf{{{esc(title)}}}\n'
                    f'\\vspace{{0.5em}}'
                )
                seen_titles.add(title)
            out_parts.append(tex)

    if not out_parts:
        # Fallback: clean verbatim (remove command echoes and boilerplate)
        clean_lines = []
        for line in raw_lines:
            stripped = line.strip()
            if stripped.startswith('.') or stripped.startswith('>'):
                continue
            if any(stripped.startswith(x) for x in ['name:', 'log:', 'log type:', 'opened on:']):
                continue
            if stripped.startswith('(') and stripped.endswith(')'):
                continue
            if stripped.startswith('note:'):
                continue
            if stripped == '':
                continue
            clean_lines.append(line)
        content = '\n'.join(clean_lines)
        out_parts.append(
            f'\\begin{{verbatim}}\n{content}\n\\end{{verbatim}}'
        )

    write_tex(outpath, '\n\n'.join(out_parts))


# ===========================================================================
# MASTER .TEX UPDATES
# ===========================================================================

def update_master_tex(filepath, file_map):
    """Update master .tex: replace \\verbatiminput{X} with \\input{X_table}.
    file_map: dict mapping old filename -> new .tex basename (without .tex extension)
    """
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    for old_file, new_base in file_map.items():
        # Pattern: \begin{small}\n\verbatiminput{filename}\n\end{small}
        # Replace with: \input{new_base}
        pattern = r'\\begin\{small\}\s*\n\s*\\verbatiminput\{' + re.escape(old_file) + r'\}\s*\n\s*\\end\{small\}'
        replacement = f'\\\\input{{{new_base}}}'
        new_content = re.sub(pattern, replacement, content)

        if new_content == content:
            # Try simpler pattern (just the verbatiminput line)
            pattern2 = r'\\verbatiminput\{' + re.escape(old_file) + r'\}'
            replacement2 = f'\\\\input{{{new_base}}}'
            new_content = re.sub(pattern2, replacement2, content)

        content = new_content

    # Also remove the verbatim package if no more \verbatiminput
    if '\\verbatiminput' not in content:
        content = content.replace(',verbatim', '')
        content = content.replace('verbatim,', '')
        content = content.replace('\\usepackage{verbatim}\n', '')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"  Updated: {os.path.basename(filepath)}")


# ===========================================================================
# MAIN
# ===========================================================================

if __name__ == '__main__':
    print("=" * 60)
    print("FIXING TABLE FORMAT FOR LOTE 1 PAPERS")
    print("=" * 60)

    # ----- 1. BLOOM ET AL. (2012) -----
    print("\n--- Bloom et al. (2012): 4 esttab CSVs ---")
    bloom_files = {}
    for f in ['Table6', 'tablec2', 'TableA5', 'TableA6']:
        inp = os.path.join(BLOOM_DIR, f + '.csv')
        outp = os.path.join(BLOOM_DIR, f + '_table.tex')
        print(f"  {f}.csv", end='')
        convert_bloom_csv(inp, outp)
        bloom_files[f + '.csv'] = f + '_table'

    print("\n  Updating bloom_tables.tex...")
    update_master_tex(os.path.join(BLOOM_DIR, 'bloom_tables.tex'), bloom_files)

    # ----- 2. HANDLEY & LIMAO (2017) -----
    print("\n--- Handley & Limao (2017): 2 CSVs + 15 .out files ---")
    hl_files = {}

    # table1.csv (summary stats)
    print("  table1.csv", end='')
    convert_hl_table1_csv(
        os.path.join(HL_DIR, 'table1.csv'),
        os.path.join(HL_DIR, 'table1_table.tex')
    )
    hl_files['table1.csv'] = 'table1_table'

    # tableA1.csv (detailed section stats - wide table)
    print("  tableA1.csv", end='')
    convert_hl_tableA1_csv(
        os.path.join(HL_DIR, 'tableA1.csv'),
        os.path.join(HL_DIR, 'tableA1_table.tex')
    )
    hl_files['tableA1.csv'] = 'tableA1_table'

    # .out files (outreg2)
    out_files = [
        'table2', 'table3_panelA', 'table3_panelB', 'table4', 'table5', 'table6',
        'tableA2', 'tableA3_panelA', 'tableA3_panelB', 'tableA4', 'tableA5',
        'tableA6', 'tableA7', 'tableA8', 'tableA9'
    ]
    for f in out_files:
        inp = os.path.join(HL_DIR, f + '.out')
        outp = os.path.join(HL_DIR, f + '_table.tex')
        print(f"  {f}.out", end='')
        convert_outreg2(inp, outp)
        hl_files[f + '.out'] = f + '_table'

    print("\n  Updating handley_limao_tables.tex...")
    update_master_tex(os.path.join(HL_DIR, 'handley_limao_tables.tex'), hl_files)

    # ----- 3. ANDERSON & SALLEE (2011) -----
    print("\n--- Anderson & Sallee (2011): 2 Stata log files ---")
    as_files = {}

    print("  cafe_compliance_behavior.txt", end='')
    convert_stata_log(
        os.path.join(AS_DIR, 'cafe_compliance_behavior.txt'),
        os.path.join(AS_DIR, 'cafe_compliance_behavior_table.tex')
    )
    as_files['cafe_compliance_behavior.txt'] = 'cafe_compliance_behavior_table'

    print("  cafe_compliance_costs.txt", end='')
    convert_stata_log(
        os.path.join(AS_DIR, 'cafe_compliance_costs.txt'),
        os.path.join(AS_DIR, 'cafe_compliance_costs_table.tex')
    )
    as_files['cafe_compliance_costs.txt'] = 'cafe_compliance_costs_table'

    print("\n  Updating anderson_sallee_tables.tex...")
    update_master_tex(os.path.join(AS_DIR, 'anderson_sallee_tables.tex'), as_files)

    print("\n" + "=" * 60)
    print("TABLE CONVERSION COMPLETE")
    print("=" * 60)
    print("\nNext step: compile PDFs with pdflatex")
