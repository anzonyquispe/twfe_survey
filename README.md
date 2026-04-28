# TWFE Survey — Negative Weights in AER Papers

Systematic replication of AER papers to document the prevalence of negative weights in two-way fixed effects (TWFE) regressions, following the methodology of de Chaisemartin & D'Haultfoeuille (2020).

## Objective

Apply the `twowayfeweights` diagnostic (Stata/R) to published AER papers that use TWFE specifications with staggered adoption or heterogeneous treatment effects designs. The goal is to quantify how many published results are affected by negative weighting of treatment effects, as documented in the web appendix (Table 1) of de Chaisemartin & D'Haultfoeuille (2020).

## Summary — 21 / 59 papers replicated (36%)

| Wave | Replicated | Total | Rate |
|------|-----------|-------|------|
| Wave 1 (AER 2010-2012) | 14 | 33 | 42% |
| Wave 2 (AER 2015-2019) | 7 | 26 | 27% |
| **Total** | **21** | **59** | **36%** |

Additionally, **8 papers** were identified as **No TWFE** (not amenable to `twowayfeweights` due to cross-sectional Bartik designs, RDD, or non-TWFE identification strategies) or **Sin data** (restricted/proprietary microdata that cannot be accessed).

## All 21 Replicated Papers

| # | Paper | Negative Weights (%) | Wave | Notes |
|---|-------|---------------------|------|-------|
| 1 | Algan & Cahuc (2010) | 50.0% | 1 | Trust and growth |
| 2 | Zhang & Zhu (2011) | 0.0% | 1 | Clean control — no negative weights |
| 3 | Bagwell & Staiger (2011) | 29.7% | 1 | Trade agreements |
| 4 | Wang (2011) | Detected | 1 | Colonial institutions |
| 5 | Duranton & Turner (2011) | 49.1% | 1 | Urban highways and sprawl |
| 6 | Moser & Voena (2012) | 0.0% | 1 | Clean control — compulsory licensing |
| 7 | Enikolopov et al. (2011) | 52.6% | 1 | Media and political persuasion |
| 8 | Forman et al. (2012) | 27.1% | 1 | Internet and wage inequality |
| 9 | Acemoglu et al. (2011) | 0-12.5% | 1 | Trade and war (specification-dependent) |
| 10 | Hornbeck (2012) | 21.0% | 1 | Dust Bowl long-run effects |
| 11 | Besley & Mueller (2012) | 40.5% | 1 | Conflict and investment in Northern Ireland |
| 12 | Simcoe (2012) | 54.2% / 48.7% | 1 | Standard-setting committees (techarea FE / WG FE) |
| 13 | Dinkelman (2011) | 0.0% | 1 | Binary treatment x 2 periods |
| 14 | Gentzkow et al. (2011) | 41.1% | 1 | 5919 pos / 4137 neg weights |
| 15 | Antecol et al. (2018) | 7.1% | 2 | Table 2. 182 pos / 14 neg weights |
| 16 | Burgess et al. (2015) | 0.0% | 2 | Table 1 Col 1. 319 pos / 0 neg weights |
| 17 | Favara & Imbs (2015) | 31.9% | 2 | Table 4 Col 1. 4406 pos / 2067 neg weights |
| 18 | Suarez Serrato & Zidar (2016) | 50.0% | 2 | Table 4 Panel A Col 1. 4 pos / 4 neg weights |
| 19 | Fetzer (2019) | 55.1% | 2 | Table 1 Panel A Col 1. 483 pos / 592 neg weights |
| 20 | Donaldson (2018) | 51.0% | 2 | Table 4 Col 1. 3169 pos / 3293 neg weights |
| 21 | Berman et al. (2017) | 60.9% | 2 | Table 2 Col 2. 416 pos / 648 neg weights |

### Top 5 papers by negative weight share

| Paper | Negative Weights (%) | Design |
|-------|---------------------|--------|
| Berman et al. (2017) | 60.9% | Continuous treatment, district-year panel |
| Fetzer (2019) | 55.1% | Continuous treatment, constituency-year panel |
| Simcoe (2012) | 54.2% | Multi-valued treatment, committee panel |
| Enikolopov et al. (2011) | 52.6% | Continuous treatment, regional panel |
| Donaldson (2018) | 51.0% | Continuous treatment, district-year panel |

All top 5 involve continuous or multi-valued treatments with complex panel structures — precisely the settings where TWFE heterogeneity bias is expected to be most severe.

## Papers Identified as No TWFE or Sin Data (Wave 2)

| Paper | Category | Reason |
|-------|----------|--------|
| Hershbein & Kahn (2018) | No TWFE | Cross-sectional Bartik design |
| Handley & Limao (2017) | No TWFE | Trade policy uncertainty, not standard TWFE |
| Dell (2015) | No TWFE | RDD, not panel TWFE |
| Munshi & Rosenzweig (2016) | No TWFE | Cross-sectional caste networks |
| Atkin (2016) | Sin data | IMSS proprietary microdata |
| Pierce & Schott (2016) | Sin data | Census Bureau LBD restricted |
| Allcott et al. (2016) | Sin data | ASI microdata India (must be purchased) |
| Hoynes et al. (2016) | Sin data | Restricted-use vital statistics |

Additional Wave 2 papers without data or not yet replicated: Di Maggio et al. (2017), Brandt et al. (2017), Dix-Carneiro & Kovak (2017), Besley et al. (2017), Fuest et al. (2018), Monte et al. (2018), Huber (2018), Naritomi (2019), Bloom et al. (2019), Diamond et al. (2019), Kaur (2019).

## Technical Notes

- The `twowayfeweights` Stata command had a bug where `e(b)` and `e(V)` were not always populated after execution, requiring fallback to scalar extraction. This was resolved during the replication process.
- All replications use the `feTR` decomposition type (fixed effects, treatment regression) unless the original paper uses first-differences (`fdTR`).
- LaTeX tables include both the original regression replication and the `twowayfeweights` diagnostic output.

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
│   └── 2015-2019/               7 completed
├── latex/                       Generated LaTeX tables and compiled PDFs
│   ├── 2010-2012/               14 completed papers (.tex + .pdf)
│   └── 2015-2019/               7 completed
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
