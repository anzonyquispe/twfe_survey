"""classify_selected.py - run classify_design on every paper in selected30papers.

For each paper marked "✅ clear" in the runbook, this script loads the .dta
file, builds D when D is a constructed regressor (interactions / lags), and
calls the Python shadow classifier. Anything that errors or fails to satisfy
any of the four design definitions is bucketed as "Other".

Outputs:
    results/classifications.csv
    results/design_counts.png
"""

from __future__ import annotations
import os, sys, traceback
from pathlib import Path
import numpy as np
import pandas as pd

THIS_DIR = Path(__file__).parent
sys.path.insert(0, str(THIS_DIR))
from classify_design import classify_design, Classification

DATA_ROOT = Path("/workspace/data")


# Each entry:
#   key   : (display name, bucket from replication_skill.md)
#   value : a dict with `.dta` and `loader(df) -> (G, T, D)` OR `skip: reason`
PAPERS: dict[str, dict] = {

    # ============== dCDH_webappendix (19 papers) ==============
    "Algan and Cahuc (2010)": {
        "dta": "2010-2012/Algan and Cahuc (2010)/AER_MACRO.dta",
        "loader": lambda df: (df, "cty", "period", "trustgss"),
    },
    "Zhang and Zhu (2011)": {"skip": "raw daily data — D 'after' needs construction from Oct-2005 block date"},
    "Bagwell and Staiger (2011)": {"skip": "ambiguous (G,T) per runbook — two FEs are HS-industry × country, not panel"},
    "Wang (2011)": {
        "dta": "2010-2012/Wang (2011)/aer_wang_data_files/data_aersubmit.dta",
        "loader": "wang",
    },
    "Duranton and Turner (2011)": {"skip": "wide-format MSA cross-section (no (g,t) panel column)"},
    "Moser and Voena (2012)": {
        "dta": "2010-2012/Moser and Voena (2012)/compulsory_licensing_replication/chem_patents_maindataset.dta",
        "loader": "moser_voena",
    },
    "Enikolopov et al. (2011)": {
        "dta": "2010-2012/Enikolopov et al. (2011)/Replication/NTV_Aggregate_Data.dta",
        "loader": "enikolopov",
    },
    "Forman et al. (2012)": {"skip": "single-year cross-section (already differenced); no panel structure"},
    "Acemoglu et al. (2011)": {
        "dta": "2010-2012/Acemoglu et al. (2011)/20100816_replication10/20100816_replication_dataset.dta",
        "loader": "acemoglu",
    },
    "Hornbeck (2012)": {
        "dta": "2010-2012/Hornbeck (2012)/AER-2009-1347_Data_Code/Analyze-Data/DustBowl_All_base1910.dta",
        "loader": "hornbeck",
    },
    "Aaronson et al. (2012)": {"skip": "partial (CPS rotating panel; id non-trivial)"},
    "Anderson and Sallee (2011)": {"skip": "ambiguous (no obvious TWFE spec)"},
    "Baum-SnowandLutz(2011)": {
        "dta": "2010-2012/Baum-SnowandLutz(2011)/MS20080918_data_programs/data/dis70panx.dta",
        "loader": "baum_snow_lutz",
    },
    "Besley and Mueller (2012)": {
        "dta": "2010-2012/Besley and Mueller/data/maindata.dta",
        "loader": "besley_mueller",
    },
    "Bloom et al. (2012)": {"skip": "partial (single absorbed FE; no obvious T)"},
    "Dinkelman (2011)": {"skip": "wide-format 2-period cross-section (Δ rows; no (g,t) panel)"},
    "Faye and Niehaus (2012)": {
        "dta": "2010-2012/Faye and Niehaus (2012)/data_analysis/data/100217_oda_estimation_sample_commit_080107.dta",
        "loader": "faye_niehaus",
    },
    "Gentzkow et al. (2011)": {
        "dta": "2010-2012/Gentzkow et al. (2011)/20091316_data/temp/voting_cnty_clean.dta",
        "loader": "gentzkow",
    },
    "Simcoe (2012)": {
        "dta": "2010-2012/Simcoe (2012)/SSOCommittees-DataFiles/data/idLevel.dta",
        "loader": "simcoe",
    },

    # ============== extension (11 papers) ==============
    "Antecol et al. (2018)": {
        "dta": "2015-2019/Antecol et al. (2018)/data/aer_primarysample.dta",
        "loader": "antecol",
    },
    "Berman et al. (2017)": {
        "dta": "2015-2019/Berman et al. (2017)/20150774_data/Data/BCRT_baseline.dta",
        "loader": "berman",
    },
    "Burgess et al. (2015)": {
        "dta": "2015-2019/Burgess et al. (2015)/AER_2013_1031_replication/main-tables-figures/kenya_roads_exp.dta",
        "loader": "burgess",
    },
    "Dell (2015)": {"skip": "no replication (RD identification)"},
    "Donaldson (2018)": {"loader": "donaldson"},  # bespoke merge of income + RAIL-dummies
    "Favara and Imbs (2015)": {
        "dta": "2015-2019/Favara and Imbs/20121416_1data/data/hmda.dta",
        "loader": "favara",
    },
    "Fetzer (2019)": {
        "dta": "2015-2019/Fetzer (2019)/data-files/DISTRICT.dta",
        "loader": "fetzer",
    },
    "Handley and Limao (2017)": {"skip": "partial (long-difference, not panel)"},
    "Kaur (2019)": {
        "dta": "2015-2019/Kaur (2019)/data/4.Replication-files/data_wb_replication.dta",
        "loader": "kaur",
    },
    "Munshi and Rosenzweig (2016)": {"skip": "partial (mostly cross-section)"},
    "Suárez Serrato and Zidar (2016)": {
        "dta": "2015-2019/Suárez Serrato and Zidar (2016)/AER-2014-1702_Replication_Files/Final-Tables-and-Figures/dta/Tables/Table4.dta",
        "loader": "ssz",
    },
}


# ---------- per-paper loaders --------------------------------------------------
# Each loader takes the raw df and returns (df, G, T, D). They can construct D
# from interactions/lags if needed.

def loader_wang(df: pd.DataFrame):
    # The webappendix spec is Post1993 × mismatchpre, but the raw treatment
    # exposed in the data is `regime2` (the Post1993 indicator). For the
    # design classifier we use the raw binary treatment.
    return df, "province", "year", "regime2"

def loader_moser_voena(df: pd.DataFrame):
    # Time variable in the .dta is `grntyr` (grant year), not `year`.
    return df, "class_id", "grntyr", "treat"

def loader_enikolopov(df: pd.DataFrame):
    # Data is WIDE: NTV1997 / NTV1999. Reshape long to a (tik_id, year, NTV)
    # mini-panel.
    long_rows = []
    for yr in (1995, 1997, 1999):
        col = f"NTV{yr}"
        if col in df.columns:
            tmp = df[["tik_id", col]].rename(columns={col: "NTV"}).copy()
            tmp["year"] = yr
            long_rows.append(tmp)
    long_df = pd.concat(long_rows, ignore_index=True) if long_rows else df
    return long_df, "tik_id", "year", "NTV"

def loader_hornbeck(df: pd.DataFrame):
    # D = m1_2 × I(year > 1930). G is `fips`.
    df = df.copy()
    df["_post1930"] = (df["year"] > 1930).astype(int)
    df["_D_hornbeck"] = df["m1_2"] * df["_post1930"]
    return df, "fips", "year", "_D_hornbeck"

def loader_baum_snow_lutz(df: pd.DataFrame):
    # leaid not always present in 1960. Use `msa` as G (more populated col).
    G = "leaid" if "leaid" in df.columns and df["leaid"].notna().any() else "msa"
    D = "imp_post" if "imp_post" in df.columns else "sd70"
    return df, G, "year", D

def loader_besley_mueller(df: pd.DataFrame):
    df = df.sort_values(["region", "quarter"]).copy()
    df["_L1_wtotaldeaths"] = df.groupby("region")["wtotaldeaths"].shift(1)
    return df, "region", "quarter", "_L1_wtotaldeaths"

def loader_faye_niehaus(df: pd.DataFrame):
    # G = pair_id (donor × recipient); T = year; D = i_elecex
    G = "pair_id" if "pair_id" in df.columns else (
        "pair" if "pair" in df.columns else df.columns[0]
    )
    D = "i_elecex" if "i_elecex" in df.columns else (
        "ielecex" if "ielecex" in df.columns else "election"
    )
    return df, G, "year", D

def loader_gentzkow(df: pd.DataFrame):
    return df, "cnty90", "styr", "numdailies"

def loader_simcoe(df: pd.DataFrame):
    # Column name is `stbafl1yr`, not `st_stbafl1yr`.
    return df, "wg", "pubCohort", "stbafl1yr"

def loader_antecol(df: pd.DataFrame):
    return df, "pol_u", "pol_job_start", "gncs"

def loader_berman(df: pd.DataFrame):
    return df, "cell", "it", "main_lprice_mines"

def loader_burgess(df: pd.DataFrame):
    return df, "distnum", "year", "president"

def loader_favara(df: pd.DataFrame):
    # 'Linter_bra' is not in the raw hmda.dta. Use 'Dl_nbra_oos_lb'
    # (Δ log out-of-state branches, the bank-side branch dereg proxy).
    return df, "county", "year", "Dl_nbra_oos_lb"

def loader_fetzer(df: pd.DataFrame):
    df = df.copy()
    df["_D_fetzer"] = df["post2010"] * df["totalimpact_finlosswapyr"]
    return df, "code", "year", "_D_fetzer"

def loader_kaur(df: pd.DataFrame):
    return df, "dist", "year", "amons80"

def loader_ssz(df: pd.DataFrame):
    return df, "fe_group", "year", "d_keeprate"


def loader_acemoglu(df: pd.DataFrame):
    return df, "id", "year", "fpresence"

def loader_donaldson(_unused: pd.DataFrame):
    base = DATA_ROOT / "2015-2019/Donaldson (2018)/web_materials/Data"
    inc  = pd.read_stata(base / "income/income.dta",      convert_categoricals=False)
    rail = pd.read_stata(base / "maps/RAIL-dummies.dta",   convert_categoricals=False)
    merged = inc.merge(rail[["distid", "year", "RAIL"]], on=["distid", "year"], how="inner")
    return merged, "distid", "year", "RAIL"


LOADERS = {
    "wang":             loader_wang,
    "moser_voena":      loader_moser_voena,
    "enikolopov":       loader_enikolopov,
    "acemoglu":         loader_acemoglu,
    "donaldson":        loader_donaldson,
    "hornbeck":         loader_hornbeck,
    "baum_snow_lutz":   loader_baum_snow_lutz,
    "besley_mueller":   loader_besley_mueller,
    "faye_niehaus":     loader_faye_niehaus,
    "gentzkow":         loader_gentzkow,
    "simcoe":           loader_simcoe,
    "antecol":          loader_antecol,
    "berman":           loader_berman,
    "burgess":          loader_burgess,
    "favara":           loader_favara,
    "fetzer":           loader_fetzer,
    "kaur":             loader_kaur,
    "ssz":              loader_ssz,
}


def run_one(paper: str, spec: dict):
    if "skip" in spec:
        return ("Other", None, spec["skip"], None, None, None)

    if "dta" in spec:
        dta = DATA_ROOT / spec["dta"]
        if not dta.exists():
            return ("Other", None, f"data file missing: {dta.name}", None, None, None)
        try:
            df = pd.read_stata(dta, convert_categoricals=False)
        except Exception as e:
            return ("Other", None, f"read_stata error: {e}", None, None, None)
    else:
        df = None  # loader builds it from scratch

    loader_key = spec["loader"]
    if isinstance(loader_key, str):
        loader = LOADERS[loader_key]
    else:
        loader = loader_key

    try:
        df2, G, T, D = loader(df)
        # Verify columns exist
        missing = [v for v in (G, T, D) if v not in df2.columns]
        if missing:
            return ("Other", None, f"missing columns: {missing}", None, None, None)
        cls: Classification = classify_design(df2, G, T, D)
        return (cls.design, cls.subtype, cls.reason, cls.n_groups, cls.n_periods, f"G={G}, T={T}, D={D}")
    except Exception as e:
        return ("Other", None, f"loader/classifier error: {type(e).__name__}: {e}", None, None, None)


def main():
    rows = []
    for paper, spec in PAPERS.items():
        design, subtype, reason, ng, np_, gtd = run_one(paper, spec)
        rows.append({
            "paper":   paper,
            "design":  design,
            "subtype": subtype,
            "n_groups":  ng,
            "n_periods": np_,
            "GTD":     gtd,
            "reason":  reason,
        })
        sub = f" ({subtype})" if subtype else ""
        print(f"  {paper:<40}  -> {design}{sub}  {reason or ''}")

    out = pd.DataFrame(rows)
    results_dir = THIS_DIR / "results"
    results_dir.mkdir(exist_ok=True)
    csv_path = results_dir / "classifications.csv"
    out.to_csv(csv_path, index=False)
    print(f"\nWrote {csv_path}  ({len(out)} papers)")

    # ---- bar chart ----
    counts = out["design"].value_counts()
    ordered = ["CLA", "SAD", "SFSD", "HAD", "Other"]
    counts = pd.Series([counts.get(k, 0) for k in ordered], index=ordered)

    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(figsize=(7, 4.5))
    colors = ["#1f77b4", "#2ca02c", "#ff7f0e", "#d62728", "#7f7f7f"]
    bars = ax.bar(counts.index, counts.values, color=colors)
    for bar, v in zip(bars, counts.values):
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            bar.get_height() + 0.1,
            str(int(v)),
            ha="center", va="bottom", fontsize=11, fontweight="bold",
        )
    ax.set_title("Design classification — selected30papers", fontsize=13)
    ax.set_ylabel("Number of papers")
    ax.set_ylim(0, max(counts.values) + 2)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    fig.tight_layout()
    png_path = results_dir / "design_counts.png"
    fig.savefig(png_path, dpi=150)
    print(f"Wrote {png_path}")

    # Print summary table to stdout
    print("\n=== Final design counts ===")
    for k, v in counts.items():
        print(f"  {k:<6}  {int(v):>2}")
    print(f"  TOTAL : {len(out)}")


if __name__ == "__main__":
    main()
