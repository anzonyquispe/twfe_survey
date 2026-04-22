# TWFE Survey — Negative Weights in AER Papers

Systematic replication of AER papers to document the prevalence of negative weights in two-way fixed effects (TWFE) regressions, following the methodology of de Chaisemartin & D'Haultfoeuille (2020).

## Objective

Apply the `twowayfeweights` diagnostic (Stata/R) to published AER papers that use TWFE specifications with staggered adoption or heterogeneous treatment effects designs. The goal is to quantify how many published results are affected by negative weighting of treatment effects, as documented in the web appendix (Table 1) of de Chaisemartin & D'Haultfoeuille (2020).

## Two Waves of Replication

### Wave 1 — AER 2010-2012 (COMPLETED)

33 candidate papers evaluated from AER volumes 2010-2012:

- **10 fully replicated**: TWFE specification identified, `twowayfeweights` (feTR/fdTR) applied, LaTeX tables generated
- **17 with data available**: replication packages downloaded but TWFE analysis not yet run
- **6 without data**: restricted or proprietary data (code only)

### Wave 2 — AER 2015-2019 (IN PROGRESS)

26 papers from Table 1 of the de Chaisemartin & D'Haultfoeuille web appendix:

- **23 replication packages downloaded**: data and code available, replication not yet started
- **3 not downloaded**: data unavailable publicly or too large to obtain

The same pipeline developed in Wave 1 will be applied to all feasible papers.

## Repository Structure

```
twfe_survey/
├── literatura/                  PDFs of the papers
│   ├── 2010-2012/               33 papers (Wave 1)
│   ├── 2015-2019/               22 papers (Wave 2; Diamond and Suarez Serrato had no PDF)
│   └── dechaisemartin_dhaultfoeuille_webappendix.pdf
├── data/                        Original replication packages (AER data + code)
│   ├── 2010-2012/               33 folders (one per paper)
│   └── 2015-2019/               23 folders (one per paper)
├── replications/                TWFE replication scripts and logs (my work)
│   ├── 2010-2012/               10 completed papers (run_twowayfe.do + .log)
│   └── 2015-2019/               (empty, pending)
├── latex/                       Generated LaTeX tables and compiled PDFs (my work)
│   ├── 2010-2012/               10 completed papers (.tex + .pdf)
│   └── 2015-2019/               (empty, pending)
├── reports/
│   ├── AER_2011-2012_Feasibility_Report.xlsx
│   └── tracker_papers_tabla1_2015-2019.xlsx
├── scripts/
│   └── generate_report.py
└── README.md
```

### Key distinction

- `data/` contains **original** files as downloaded from openICPSR/AEA (replication packages, data, original code)
- `replications/` contains **my** TWFE analysis scripts (`run_twowayfe.do`) and their execution logs
- `latex/` contains **my** generated output (LaTeX tables, compiled PDF summaries)

## Wave 1 — Replication Results

| Paper | Negative Weights (%) | Notes |
|-------|---------------------|-------|
| Algan & Cahuc (2010) | 50.0% | Trust and growth |
| Zhang & Zhu (2011) | 0.0% | Clean control — no negative weights |
| Bagwell & Staiger (2011) | 29.7% | Trade agreements |
| Wang (2011) | Detected | Colonial institutions |
| Duranton & Turner (2011) | 49.1% | Urban highways and sprawl |
| Moser & Voena (2012) | 0.0% | Clean control — compulsory licensing |
| Enikolopov et al. (2011) | 52.6% | Media and political persuasion |
| Forman et al. (2012) | 27.1% | Internet and wage inequality |
| Acemoglu et al. (2011) | 0-12.5% | Trade and war (specification-dependent) |
| Hornbeck (2012) | 21.0% | Dust Bowl long-run effects |

**Key finding**: 8 out of 10 replicated papers exhibit significant negative weights in their TWFE specifications (range: 12.5% to 52.6%). Two papers serve as clean controls with 0% negative weights.

## Reference

de Chaisemartin, C., & D'Haultfoeuille, X. (2020). Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects. *American Economic Review*, 110(9), 2964-2996.

Web appendix: `literatura/dechaisemartin_dhaultfoeuille_webappendix.pdf`
