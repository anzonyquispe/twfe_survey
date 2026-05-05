"""Convert Dell (2015) table1.out (outsheet tab-separated) to LaTeX tabular."""
import os

infile = os.path.join(os.path.dirname(__file__), "table1.out")
outfile = os.path.join(os.path.dirname(__file__), "table1_table.tex")

with open(infile, "r") as f:
    lines = f.readlines()

# Parse header
header = lines[0].strip().split("\t")
# header: rowtitle, outcol1..outcol7
ncols = len(header) - 1  # exclude rowtitle

# Column headers for the paper
col_headers = [
    "PAN Win", "PAN Loss", "t-stat",
    "Coeff.", "t-stat",
    "Coeff.", "t-stat"
]

tex = []
tex.append("\\begin{adjustbox}{max width=\\textwidth}")
tex.append("\\begin{tabular}{l" + "c" * ncols + "}")
tex.append("\\toprule")
tex.append(" & \\multicolumn{3}{c}{Difference in Means}")
tex.append(" & \\multicolumn{2}{c}{Local Linear (mun.)}")
tex.append(" & \\multicolumn{2}{c}{Local Linear (neighbor)} \\\\")
tex.append("\\cmidrule(lr){2-4} \\cmidrule(lr){5-6} \\cmidrule(lr){7-8}")
tex.append(" & " + " & ".join(col_headers) + " \\\\")
tex.append("\\midrule")

# Group labels
groups = {
    6: "\\textit{Political characteristics}",
    12: "\\textit{Demographic characteristics}",
    15: "\\textit{Economic characteristics}",
    22: "\\textit{Road network characteristics}",
    25: "\\textit{Geographic characteristics}",
}

for i, line in enumerate(lines[1:], start=1):
    line = line.strip()
    if not line:
        continue
    parts = line.split("\t")
    rowtitle = parts[0].strip()
    if not rowtitle:
        continue

    # Row index in the original data (indexnum offset)
    row_idx = i + 4  # outsheet starts from indexnum=5

    # Add group headers
    if row_idx in groups:
        if row_idx > 6:
            tex.append("\\addlinespace")
        tex.append(groups[row_idx] + " & " + " & " * (ncols - 1) + " \\\\")

    # Clean values
    vals = []
    for j in range(1, ncols + 1):
        v = parts[j].strip() if j < len(parts) else ""
        # Remove leading apostrophe from outsheet
        v = v.lstrip("'")
        vals.append(v)

    # Escape special chars in rowtitle
    rowtitle = rowtitle.replace("\\%", "\\%")  # already escaped
    rowtitle = rowtitle.replace("$", "\\$") if "\\$" not in rowtitle else rowtitle
    rowtitle = rowtitle.replace("_", "\\_")

    tex.append(rowtitle + " & " + " & ".join(vals) + " \\\\")

tex.append("\\bottomrule")
tex.append("\\end{tabular}")
tex.append("\\end{adjustbox}")

with open(outfile, "w") as f:
    f.write("\n".join(tex) + "\n")

print(f"Written {outfile}")
