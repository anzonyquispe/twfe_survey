# Replication Skill — `selected30papers/`

This document is the runbook for the 30 papers selected for the TWFE panel-data
study. For each paper we record the four panel-data primitives used to
parametrize the regression:

- **G** — unit / group identifier
- **T** — time variable
- **D** — treatment variable
- **Y** — outcome variable

These map to the `twowayfeweights` call signature:

```
twowayfeweights Y G T D, type(feTR|fdTR) [weight() other_treatments() ...]
```

The folder layout is:

```
selected30papers/
├── dCDH_webappendix/      ← 19 papers whose exact table/figure is named in
│   │                        de Chaisemartin & D'Haultfœuille's web appendix
│   │                        (literatura/two_way_FE_webappendix.latex, §6)
│   └── <Paper>/
│       ├── run_twowayfe.do        ← standardized TWFE replication (entry point)
│       ├── check_vars.do          ← (optional) panel structure sanity check
│       ├── *_tables.tex|pdf       ← compiled output
│       └── full/                  ← extended replication of additional tables/figures
│           └── run_<paper>_full.do
└── extension/             ← 11 newer papers (mostly 2015-2019) not covered
    └── <Paper>/             by the dCDH web appendix; spec chosen by us
        └── ...                (see the "Extension papers" table below)
```

Conventions used across `run_twowayfe.do` files:

1. The header comment block declares **G / T / D / Y** explicitly.
2. Paths are configured via `global datadir`, `global outdir`, `global texdir`,
   built on top of two auto-detected globals `${twfe_root}` and
   `${papers_root}`. The detection block at the top of every dofile branches
   on `c(username)`:
   - `anzony.quisperojas` → `/Users/anzony.quisperojas/Documents/GitHub/{twfe_survey,papers_economic}`
   - `Usuario` (Damian) → `C:/Users/Usuario/Documents/GitHub/{twfe_survey,papers_economic}`
   - Any other user → script aborts with `exit 198`. Add your branch to the
     block (or override `$twfe_root`/`$papers_root` from the command line).
3. Required Stata packages: `twowayfeweights`, `reghdfe`, `ftools`, `estout`.
   Each script attempts `ssc install` if missing.
4. Outputs are written to `table_twowayfeweights.tex` (the dCDH decomposition)
   and a paper-specific `table*_replication.tex`.

---

## How to parametrize a dofile

Every `run_twowayfe.do` reduces to a block of the form:

```stata
local Y   = "<outcome>"
local G   = "<unit_id>"
local T   = "<time_var>"
local D   = "<treatment>"
local W   = "<weight_var>"      // optional
local CL  = "<cluster_var>"

xtreg `Y' `D' i.`T', fe i(`G') cluster(`CL')
twowayfeweights `Y' `G' `T' `D', type(feTR) [weight(`W')] summary_measures
```

When porting a paper that does not yet expose these as locals, look at the
**header comment** of `run_twowayfe.do` — the `(G, T, D, Y)` quadruple is
always stated there. The table below pre-computes that quadruple.

---

## Panel structure by paper

Legend:
- **Status**: `✅ clear` (clean panel, plug-and-play) · `⚠ partial` (works
  but with caveats: only a few tables, dropped FEs, etc.) · `❓ ambiguous`
  (no obvious TWFE; please confirm).
- **Design**: Bin (binary), Cont (continuous), Stagg (staggered),
  FD (first differences / two-period), Cross (cross-section).

### `dCDH_webappendix/` — papers with a spec named in the dCDH web appendix

The "Webappendix spec" column gives the exact table/figure listed in §6 of
`literatura/two_way_FE_webappendix.latex` (the de Chaisemartin & D'Haultfœuille
companion appendix). That is the target regression for the panel decomposition.

| # | Paper | G (unit) | T (time) | D (treatment) | Y (outcome) | Webappendix spec | Design | Status |
|---|---|---|---|---|---|---|---|---|
| 1 | Algan & Cahuc (2010) | `cty` | `period` (1935, 2000) | `trustgss` (inherited trust) | `gdpk_diffswd_good` (GDP/capita rel. Sweden) | Figure 4 | FD, Cont | ✅ clear |
| 2 | Zhang & Zhu (2011) | `id` (contributor) | `week` | `after`, `social_participation_after` | `logTotal` / `logAddition` / `logDeletion` | Tables 3 & 4, Cols 4–6 | Bin, Stagg | ✅ clear |
| 3 | Bagwell & Staiger (2011) | `country_num` | `HS2` industry | `Import` (volume) | `TariffFinal` (WTO bound rate) | Table 3, OLS cols | Cross, Cont | ❓ ambiguous — **two FEs are HS-industry × country, not time × unit**. Please confirm whether to treat HS2 as "T" or to drop this paper from the panel analysis. |
| 4 | Wang (2011) | `province` | `year` | `Post × Δ` (`Post1993 × log_mismatchpre`) | `F_it` (log floor space / utilities) | Table 5, Panel A | Cont, sharp | ✅ clear (treatment is interaction, not raw indicator) |
| 5 | Duranton & Turner (2011) | `MSA` | decade FD (1983-93, 1993-03) | `Δln(lane_km_IH)` | `Δln(VKT_IH)` | Table 5 | FD, Cont | ✅ clear (fdTR) |
| 6 | Moser & Voena (2012) | `class_id` (patent class) | `year` (1875–1939) | `treat` (compulsory license × post-1918) | `count_usa` (US patents) | Table 2 | Bin, Stagg | ✅ clear |
| 7 | Enikolopov et al. (2011) | `tik_id` (subregion) | `year` (1995, 1999) | `Watch_probit_` (NTV access prob.) | `Votes_SPS_` (vote share) | Table 3 | Cont, FD-like | ✅ clear |
| 8 | Forman et al. (2012) | `county` | `year` (1995, 2000) | `surv_deeppost00` | `wagediff` = Δlog weekly wage | Tables 2 & 4 | FD, Cont | ✅ clear |
| 9 | Acemoglu et al. (2011) | `id` (polity) | `year` (1700,1750,1800,…,1900) | `fpresence` (years of French presence) | `urbrate_jt` (urbanization rate) | Table 3 | Cont, Stagg | ✅ clear |
| 10 | Hornbeck (2012) | `county` | `year` (1910–1997) | `m1_2 × I(year>1930)` (erosion × post) | depvar varies by table (farm value, ag output, …) | Table 2 | Cont, sharp | ✅ clear |
| 11 | Aaronson et al. (2012) | `id` (CPS household) | `year` | `minwage` | `tot_inc` (and other consumption/income vars) | Tables 1, 2 & 5 | Cont | ⚠ partial — CPS rotating panel; treatment varies state×year. Confirm whether you want the CEX subsample (different `id` definition) — see "Questions" below. |
| 13 | Anderson (& Sallee, 2011) | `manufacturer` | `model_year` | binding CAFE indicator | compliance / fuel-economy metrics | Table 5, Col 2 | Cont | ❓ ambiguous — paper is RD-flavored using bunching; the available `cafe_compliance_*` dofiles run cross-sectional regressions. **Please specify which spec to treat as TWFE** (or mark as out of scope). |
| 15 | Baum-Snow & Lutz (2011) | `leaid` (school district) | `year` (1960, 1970, 1980, 1990) | `imp_post` = I(year ≥ desegregation yr) | `lnwpu` (ln white K-12 enrollment) | Tables 2–6 | Bin, Stagg | ✅ clear |
| 16 | Besley & Mueller (2012) | `region` (11 N. Ireland regions) | quarter (1984Q4–2009Q1) | `L1.wtotaldeaths` (lagged killings / SD) | `lnhouseprice` | Table 1, Cols 3 & 5–7 | Cont | ✅ clear |
| 17 | Bloom et al. (2012) | `company_code` (firm) | `sic` industry / interview | various IT-intensity vars | `ly` (ln output) | Table 2, Cols 6–8 | Cont, cross-section | ⚠ partial — base spec is `areg ly … , ab(sic)` with single absorbed FE. To impose TWFE you'd need to add `year` or `interview` as the second dimension. Confirm which is "T". |
| 21 | Dinkelman (2011) | `placecode0` | 2-period (1996, 2001) | `T` (electrification dummy) | `d_prop_emp_f` (Δ female employment rate) | Tables 4 & 5 (Cols 5–8), 8 (Cols 3–4), 9 (Col 2), 10 (Cols 2, 4, 6) | FD, Bin | ✅ clear (IV: `mean_grad_new`) |
| 24 | Faye & Niehaus (2012) | `pair_id` (donor × recipient) | `year` (1975–2003) | `i_elecex` (executive election year in recipient) | `oda` (aid commitments) | Table 3 (Cols 4 & 5), Tables 4 & 5 | Bin, Stagg | ✅ clear |
| 25 | Gentzkow et al. (2011) | `cnty90` (county) | `styr` (state × election year) | `numdailies` / `x_0` (Δ daily newspapers) | `prestout` (presidential turnout) | Tables 2 & 3 | Cont | ✅ clear |
| 27 | Simcoe (2012) | `techarea` (Col 1–2) or `wg` (Col 3) | `pubCohort` (submission year) | `st_stbafl1yr` (suit-share × S-track) | `ttlDur` (days to disposal) | Table 4, Cols 1–3 | Cont | ✅ clear (two alternative G's: techarea / wg) |

### `extension/` — papers not in the dCDH web appendix

These (mostly 2015-2019) post-date the dCDH web appendix. The "Spec used"
column reflects our chosen target regression (see also "Questions" below).

| # | Paper | G (unit) | T (time) | D (treatment) | Y (outcome) | Spec used | Design | Status |
|---|---|---|---|---|---|---|---|---|
| 34 | Dell (2015) | `id_mun` (municipality) | `elec_c` (election cycle) | `PANwin` (PAN narrow win) | drug homicides / `DummyDeaths` | Tables 1, 2B, 3B (panel-castable subset) | RD, Bin | ❓ ambiguous — main identification is **RD around close PAN elections, not TWFE**. Tables 1, 2B, 3B are replicated; Tables 4-7 require confidential drug-homicide data. Please confirm whether to keep or drop from the panel set. |
| 35 | Burgess et al. (2015) | `distnum` (district) | `year` (1963-2011) | `president` (coethnic of president) | `exp_dens_share` (road expenditure share) | Table 3 (main TWFE) | Bin, Switch | ✅ clear |
| 36 | Favara & Imbs (2015) | `county` | `year` | `Linter_bra` (lagged interstate branching dereg) | `Dl_hpi` (Δ log house price index) | Table 4 baseline | Bin, Stagg | ✅ clear (weight: `w1`) |
| 39 | Munshi & Rosenzweig (2016) | `village` | survey round (cross-section in most tables) | `pminc` / `jpminc` (income shocks) | `mig` (migration) | Table 6 (TBD) | Cont, mostly cross-section | ⚠ partial — Table 6 is the closest to TWFE; structural tables require Maple. Confirm if Table 6 is the target spec. |
| 42 | Suárez Serrato & Zidar (2016) | `fe_group` (state groupings) | `year` (decadal) | `d_keeprate` (Δ log net-of-tax rate) | `E` (Δ employment) | Table 2 (reduced-form) | Cont | ✅ clear (weight: `epop`) |
| 45 | Berman et al. (2017) | `cell` (0.5°×0.5° grid) | `it` (country × year) | `main_lprice_mines` (log price × mine) | `acled` (conflict indicator) | Table 2, Col 2 | Cont | ✅ clear (sample: `sd_mines==0`) |
| 46 | Handley & Limao (2017) | `hs6` × country | `year` | `unc_pre` (pre-period uncertainty) × Δtariff | `dif_ln_imp_5` (5-yr Δ log imports) | `panel_regs_replicate.do` (TBD) | Cont, long-diff | ⚠ partial — most specs are long-differences with `i.ctry_section` FE, not true TWFE. `panel_regs_replicate.do` is the closest TWFE spec (`reghdfe ln_imp …, absorb(hs6 yearXfix)`). Confirm which spec to use. |
| 49 | Donaldson (2018) | `distid` (district) | `year` | `RAIL` (railroad access dummy) | `ln_realincome` | Table 4, Col 1 | Bin, Stagg | ✅ clear |
| 54 | Antecol et al. (2018) | `pol_u` (university) | `pol_job_start` (hire year) | `gncs` (gender-neutral clock-stop policy) | `tenure_policy_school` (tenure at policy uni) | Table 2 (main) / Table 4, Col 5 | Bin, Stagg | ✅ clear |
| 55 | Fetzer (2019) | `id` (local authority district) | `ryr` (region × year) | `temp` = `post2010 × totalimpact_finlosswap` | `pct_votes_UKIP` | Table 2 (main TWFE) | Cont | ✅ clear |
| 56 | Kaur (2019) | `dist` (district) | `year` (1956–1987) | `amons80` (monsoon rainfall > p80) | `lwage` (log daily ag wage) | Table 3 (wage response) | Bin | ✅ clear (other treatment: `bmons20`, cluster: `regionyr`) |

---

## Readability

### Easy to read & interpret (recommended starting points)

These have clean two-period or balanced panels, binary or simple continuous
treatment, and a short header that maps directly to (G, T, D, Y):

1. **Donaldson (2018)** — textbook G=district, T=year, D=RAIL.
2. **Antecol et al. (2018)** — clean staggered binary policy adoption.
3. **Burgess et al. (2015)** — switching binary D, balanced district panel.
4. **Dinkelman (2011)** — 2-period FD, single binary D, IV available.
5. **Forman et al. (2012)** — 2-period FD, well-documented sample.
6. **Moser & Voena (2012)** — staggered binary treatment, large balanced panel.
7. **Baum-Snow & Lutz (2011)** — Census decades, binary post-desegregation.
8. **Faye & Niehaus (2012)** — pair × year panel, binary D=election year.
9. **Kaur (2019)** — district × year, binary rainfall shock.
10. **Fetzer (2019)** — district × region-year, continuous interaction D.

### Difficult to follow (need extra care)

These run, but require thought before plugging into a generic TWFE pipeline:

1. **Bagwell & Staiger (2011)** — *the two FEs are not unit × time*; treat
   either HS2 or country as G, but the other dimension is not "time" in any
   meaningful sense.
2. **Dell (2015)** — RD design at municipal close elections; only a subset
   of tables can be cast as TWFE, and the most interesting (drug-homicide)
   outcome is confidential.
3. **Anderson & Sallee (2011)** — paper is built around CAFE bunching; the
   replicated specs are cross-sectional, not TWFE.
4. **Bloom et al. (2012)** — base spec uses a single absorbed FE (`sic`);
   needs an arbitrary choice for the time dimension. UK data is restricted.
5. **Handley & Limao (2017)** — many long-difference specs (`dif_ln_imp_5`);
   the closest panel spec is in `panel_regs_replicate.do`. Heavy use of
   `i.section#i.country` interactions.
6. **Aaronson et al. (2012)** — CPS rotating panel; constructing `id` is
   non-trivial (see `cps_adapted.do` lines 109–116). CEX and SIPP subsamples
   need extra data.
7. **Munshi & Rosenzweig (2016)** — mixed reduced-form and structural; Maple
   needed for the structural tables; Table 6 is the only clean panel spec.
8. **Wang (2011)** — treatment is `Post × Δ_i` with `Δ_i` time-invariant; this
   is a "fuzzy" sharp design that requires the dCDH `feTR` interpretation.
9. **Enikolopov et al. (2011)** — fuzzy design (NTV access varies within
   `tik_id × year`); the regression uses a generated probability as D.
10. **Hornbeck (2012)** — full paper spec uses `state × year` FE; the TWFE
    decomposition requires dropping it to keep only `county + year` FE.

---

## Questions for the user (please clarify)

The following items I could not resolve from the dofiles alone. Please tell me
how you want each handled before I parametrize the corresponding scripts:

1. **Aaronson et al. (2012)** — three datasets are used (CPS, CEX, SIPP).
   Each has a different unit definition. Which should be the canonical
   panel? My default would be CPS (`id` constructed from `state+hhid+...`,
   T = `year`, D = `minwage`, Y = `tot_inc`).

2. **Anderson & Sallee (2011)** — there is no obvious TWFE spec in the
   replicated portion. Options: (a) drop from the 30 and replace, (b) treat
   `manufacturer × model_year` panel of CAFE compliance behavior as the
   panel, (c) keep only for the descriptive piece. Which?

3. **Bagwell & Staiger (2011)** — should we (a) treat HS2 as G and country
   as "time" (T), (b) the reverse, or (c) keep it as cross-section and
   exclude from the panel-data exercise?

4. **Bloom et al. (2012)** — the second FE is `sic` (industry); should we
   instead use `year` (when present) and re-estimate, or keep the
   `sic + interview` two-way FE specification as-is?

5. **Dell (2015)** — the paper is RD-identified. Do you want the panel
   replication to use Tables 2-3 (the only ones with a time dimension), or
   should we drop Dell from the TWFE-panel subset?

6. **Handley & Limao (2017)** — pick the canonical TWFE spec: (a) the
   long-difference spec in `table2_baseline_replicate.do`, or (b) the panel
   spec in `panel_regs_replicate.do` (which uses `reghdfe ln_imp …, absorb(hs6 yearXfix)`).

7. **Munshi & Rosenzweig (2016)** — confirm that Table 6 (`run_munshi_v2.do`)
   is the spec to parametrize; the structural tables are out of scope.

8. **Hornbeck (2012)** — the published spec uses `state × year` FE. The
   `twowayfeweights` decomposition assumes plain `county + year`. Should we
   report only the simplified spec or both?

9. **Wang (2011)** — D is the interaction `regime2 × log_mismatchpre`.
   Should `D_level` (the time-invariant Δ) be the variable passed to
   `twowayfeweights` for the `fdTR` natural-weight computation, or the
   interaction itself?

10. **Enikolopov et al. (2011)** — `Watch_probit_` is a generated regressor
    (probit of NTV access). Should we run `twowayfeweights` on this generated
    D, or on the raw underlying indicator `NTV`?

Once answered, I will:
- Add a parametrized `_panel_spec.do` snippet to each paper with the four
  locals (Y/G/T/D) so any future regression can be re-run by changing
  globals only.
- Patch the path globals so they resolve against `$workspace/data/...`
  instead of `C:/Users/Usuario/...`.

---

## Re-running a paper

From the repo root:

```bash
# webappendix papers:
cd "replications/selected30papers/dCDH_webappendix/<Paper>"
# extension papers:
cd "replications/selected30papers/extension/<Paper>"

stata -b do run_twowayfe.do
# outputs:
#   run_twowayfe.log
#   table_twowayfeweights.tex
#   <paper>_tables.tex
```

The `c(username)`-based path detection at the top of every dofile handles
the Mac/Windows split — no need to edit globals before running.

For papers without `run_twowayfe.do` (Aaronson, Anderson, Bloom, Handley,
Munshi), the entry point is `full/run_<paper>.do` or `full/run_all.do`.

---

## Source of truth

- Selection list: `/workspace/reports/selected_papers.xlsx`
- Original (unmodified) replications: `/workspace/replications/2010-2012/`
  and `/workspace/replications/2015-2019/`
- This folder (`selected30papers/`) is a **copy**, safe to edit without
  touching the originals.
