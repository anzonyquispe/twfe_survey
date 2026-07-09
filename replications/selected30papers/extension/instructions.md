---
name: Extension-paper replication targets
description: Which exact table to replicate for each of the 11 extension papers (those not covered by the dCDH web appendix), plus the current state of each folder after the prune
type: project
---

# `extension/` — replication targets

The 11 papers in this folder are **not** named in the dCDH web appendix
(`literatura/two_way_FE_webappendix.latex` §6). The target table for each one
was specified by the user. This file is the source of truth for what each
folder is supposed to replicate; the `dCDH_webappendix/` folder is governed by
the web appendix itself.

## Target table by paper

| # | Paper | Target table(s) | Current dofile state | Action needed |
|---|---|---|---|---|
| 1 | Antecol et al. (2018) | **Main Table 1** | `run_twowayfe.do` estimates Table 2 / Table 4 Col 5 | **Retarget** Step 2 to Table 1 |
| 2 | Berman et al. (2017) | **Main Table 2** | `run_twowayfe.do` estimates Table 2, Col 2 | ✅ on target |
| 3 | Burgess et al. (2015) | **Main Tables 1 and 2** | `run_twowayfe.do` does Table 1 only | **Add** a step for Table 2 |
| 4 | Dell (2015) | **No replication** — main result is RD-identified. The authors do a similar panel-style analysis in Appendix Tables A-15 to A-24, but we are not replicating those either. | Folder is empty placeholder | — |
| 5 | Donaldson (2018) | **Main Table 3** | `run_twowayfe.do` estimates Table 4, Col 1 | **Retarget** to Table 3 |
| 6 | Favara and Imbs (2015) | **Main Table 2** | `run_twowayfe.do` estimates Table 4, Col 1 | **Retarget** to Table 2 |
| 7 | Fetzer (2019) | **Main Table 1** | `run_twowayfe.do` estimates Table 1, Panel A Col 1 | ✅ on target |
| 8 | Handley and Limao (2017) | **Main Table 3** | `full/regs_twn_chn_compare_replicate.do` builds Panel A; `full/regs_EU_chn_compare_replicate.do` builds Panel B | Wrap both inside a top-level `run_twowayfe.do` |
| 9 | Kaur (2019) | **Main Table 1** | `run_twowayfe.do` estimates Table 1, Col 1 (WB data) | ✅ on target |
| 10 | Munshi and Rosenzweig (2016) | **Main Table 8** | `full/run_table8a.do` runs Table 8a (Panel A). Confirm whether Panel B (`table8b.dta`) is also wanted. | Add `run_table8b.do` if Panel B is required |
| 11 | Suárez Serrato and Zidar (2016) | **Main Table 4** | `run_twowayfe.do` estimates Table 4, Panel A Col 1 | ✅ on target |

## Why these tables

For each paper the user identified the table that the broader TWFE survey
should reproduce. Where the existing dofile aimed at a different table (Antecol,
Donaldson, Favara), the regression specification will need to be rewritten on
top of the same data; the panel structure and clustering can be kept since
they apply across all tables of the paper.

Dell is excluded because the paper's identifying variation is a regression
discontinuity around close mayoral elections, not a two-way fixed-effects
panel. The author does report panel-style results in Appendix Tables A-15 to
A-24, but those are not part of our replication set either.

## Folder layout after the prune

Each paper folder under `extension/` now contains only the files relevant to
its target table (plus required `check_vars.do` and supporting ado/data
files):

```
extension/
├── instructions.md                    ← this file
├── Antecol et al. (2018)/
│   └── run_twowayfe.do                ← header flags Table 1 as target
├── Berman et al. (2017)/
│   ├── run_twowayfe.do                ← Table 2 ✓
│   ├── table2_replication.tex
│   └── …
├── Burgess et al. (2015)/
│   ├── run_twowayfe.do                ← Table 1 done; header flags Table 2 to add
│   ├── table1_replication.tex
│   └── …
├── Dell (2015)/                       ← empty (no replication)
├── Donaldson (2018)/
│   ├── check_vars.do
│   └── run_twowayfe.do                ← header flags Table 3 as target
├── Favara and Imbs (2015)/
│   └── run_twowayfe.do                ← header flags Table 2 as target
├── Fetzer (2019)/
│   ├── check_vars.do
│   ├── run_twowayfe.do                ← Table 1 ✓
│   └── table1_replication.tex
├── Handley and Limao (2017)/
│   ├── check_vars.do
│   └── full/
│       ├── regs_twn_chn_compare_replicate.do   ← Table 3, Panel A
│       ├── regs_EU_chn_compare_replicate.do    ← Table 3, Panel B
│       ├── replication_maindata2.dta
│       ├── replication_maindata3.dta
│       ├── table3_panelA.out
│       └── table3_panelB.out
├── Kaur (2019)/
│   ├── check_vars.do
│   ├── run_twowayfe.do                ← Table 1 ✓
│   └── table1_replication.tex
├── Munshi and Rosenzweig (2016)/
│   ├── check_vars.do
│   └── full/
│       ├── run_table8a.do             ← Table 8, Panel A
│       ├── cgmwildboot.ado
│       ├── install_*.do
│       ├── convert_munshi.py
│       └── table8a_table.tex
└── Suárez Serrato and Zidar (2016)/
    ├── run_twowayfe.do                ← Table 4 ✓
    └── table4_replication.tex
```

## Open items

- **Antecol / Donaldson / Favara**: rewrite the regression block of
  `run_twowayfe.do` to estimate the new target table. The path globals,
  `check_vars.do`, and the user-detection block can all be reused.
- **Burgess**: add a Step 2b that replicates Table 2 alongside the existing
  Table 1 code.
- **Handley and Limao**: create a `run_twowayfe.do` at the paper-folder level
  that calls both `regs_twn_chn_compare_replicate.do` (Panel A) and
  `regs_EU_chn_compare_replicate.do` (Panel B), then runs `twowayfeweights`
  on the panel underlying Table 3.
- **Munshi and Rosenzweig**: confirm whether Table 8 means Panel A only or
  Panels A+B. If A+B, add `run_table8b.do` analogous to `run_table8a.do`.
