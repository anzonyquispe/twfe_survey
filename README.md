# TWFE Survey — Negative Weights in AER Papers

Systematic replication of AER papers to document the prevalence of negative weights in two-way fixed effects (TWFE) regressions, following the methodology of de Chaisemartin & D'Haultfoeuille (2020).

## Objective

Apply the `twowayfeweights` diagnostic (Stata/R) to published AER papers that use TWFE specifications with staggered adoption or heterogeneous treatment effects designs. The goal is to quantify how many published results are affected by negative weighting of treatment effects, as documented in the web appendix (Table 1) of de Chaisemartin & D'Haultfoeuille (2020).

## Two Waves of Replication

### Wave 1 — AER 2010-2012: 14 / 33 replicated (42%)

33 candidate papers evaluated from AER volumes 2010-2012:

- **14 fully replicated**: TWFE specification identified, `twowayfeweights` (feTR/fdTR) applied, LaTeX tables generated
- **5 with data (pending)**: data confirmed available, replication feasible but not yet completed
- **14 without data**: restricted/proprietary data or main dataset not included in replication packages

### Wave 2 — AER 2015-2019: 0 / 26 replicated

26 papers from Table 1 of the de Chaisemartin & D'Haultfoeuille web appendix:

- **16 with data**: replication packages downloaded, replication not yet started
- **9 without data**: restricted or proprietary data
- **1 unclassified**: awaiting evaluation

The same pipeline developed in Wave 1 will be applied to all feasible papers.

## Wave 1 — Replicated Papers

| # | Paper | Negative Weights (%) | Notes |
|---|-------|---------------------|-------|
| 1 | Algan & Cahuc (2010) | 50.0% | Trust and growth |
| 2 | Zhang & Zhu (2011) | 0.0% | Clean control — no negative weights |
| 3 | Bagwell & Staiger (2011) | 29.7% | Trade agreements |
| 4 | Wang (2011) | Detected | Colonial institutions |
| 5 | Duranton & Turner (2011) | 49.1% | Urban highways and sprawl |
| 6 | Moser & Voena (2012) | 0.0% | Clean control — compulsory licensing |
| 7 | Enikolopov et al. (2011) | 52.6% | Media and political persuasion |
| 8 | Forman et al. (2012) | 27.1% | Internet and wage inequality |
| 9 | Acemoglu et al. (2011) | 0-12.5% | Trade and war (specification-dependent) |
| 10 | Hornbeck (2012) | 21.0% | Dust Bowl long-run effects |
| 11 | Besley & Mueller (2012) | 40.5% | Conflict and investment in Northern Ireland |
| 12 | Simcoe (2012) | 54.2% / 48.7% | Standard-setting committees (techarea FE / WG FE) |
| 13 | Dinkelman (2011) | 0.0% | Table 4 replicated exact (Cols 1,3,5,7). Binary treatment x 2 periods |
| 14 | Gentzkow et al. (2011) | 41.1% | Table 2 Cols 2-4 replicated. 5919 pos / 4137 neg weights |

**Key finding**: 11 out of 14 replicated papers exhibit significant negative weights in their TWFE specifications (range: 12.5% to 54.2%). Three papers have 0% negative weights (clean binary treatment designs).

## Wave 1 — Papers without Data (14)

| Paper | Missing Data |
|-------|-------------|
| Anderson & Sallee (2011) | transactions1.dta (proprietary) |
| Bloom et al. (2012) | UK census data at VML/ONS London |
| Aizer (2010) | Hospital data from OSHPD |
| Bajari et al. (2012) | DataQuick housing data |
| Duggan & Morton (2010) | IMS Health pharmaceutical data |
| Chaney et al. (2012) | COMPUSTAT + commercial price data |
| Brambilla et al. (2012) | Argentine firm survey (EIA/INDEC, restricted by law) |
| Hotz & Xiao (2011) | Census RDC confidential microdata |
| Bustos (2011) | Missing main dataset |
| Chandra et al. (2012) | Missing main dataset |
| Dafny (2010) | Missing main dataset |
| Ellul et al. (2010) | Missing main dataset |
| Imberman (2011) | Missing main dataset |
| Mian & Sufi (2012) | Missing main dataset |

## Wave 1 — Papers with Data (Pending, 5)

| Paper | Status |
|-------|--------|
| Aaronson et al. (2012) | Data available, large replication package |
| Baum-Snow & Lutz (2011) | Data available |
| Dahl & Lochner (2012) | Requires TAXSIM software |
| Fang & Gavazza (2011) | Data available |
| Faye & Niehaus (2012) | Data available |

## Repository Structure

```
twfe_survey/
├── literatura/                  PDFs of the papers
│   ├── 2010-2012/               33 papers (Wave 1)
│   ├── 2015-2019/               22 papers (Wave 2)
│   └── dechaisemartin_dhaultfoeuille_webappendix.pdf
├── data/                        Original replication packages (AER data + code)
│   ├── 2010-2012/               33 folders (one per paper)
│   └── 2015-2019/               23 folders (one per paper)
├── replications/                TWFE replication scripts and logs
│   ├── 2010-2012/               14 completed (run_twowayfe.do + .log)
│   └── 2015-2019/               (pending)
├── latex/                       Generated LaTeX tables and compiled PDFs
│   ├── 2010-2012/               14 completed papers (.tex + .pdf)
│   └── 2015-2019/               (pending)
├── reports/
│   ├── tracker_master_consolidado.xlsx    Master tracker (all papers, both waves)
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

## Reference

de Chaisemartin, C., & D'Haultfoeuille, X. (2020). Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects. *American Economic Review*, 110(9), 2964-2996.

Web appendix: `literatura/dechaisemartin_dhaultfoeuille_webappendix.pdf`
