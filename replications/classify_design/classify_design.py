"""classify_design.py - Python shadow of classify_design.ado.

Replicates the Stata logic at /workspace/replications/classify_design/classify_design.ado
so the 30 paper datasets can be classified from this environment (no local Stata).

Order of detection (most restrictive first):
    CLA   - binary absorbing, single common switch date
    SAD   - binary absorbing, multiple switch dates
    SFSD  - non-binary or non-absorbing, switch timing varies among switchers
              sub-classify as SSFSD (Var(F_g | D_g1) > 0 for some D_g1) or RSFSD
    HAD   - common adoption period t*; D == 0 for t < t*; heterogeneous dose
    Other - none of the above

Returns a Classification namedtuple with .design and .subtype.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
import numpy as np
import pandas as pd


@dataclass
class Classification:
    design: str                       # "CLA" | "SAD" | "SFSD" | "HAD" | "Other"
    subtype: Optional[str] = None     # "SSFSD" | "RSFSD" when design == "SFSD"
    reason: Optional[str] = None      # human-readable note (esp. for "Other")
    n_groups: int = 0
    n_periods: int = 0
    t_star: Optional[int] = None      # HAD only

    def label(self) -> str:
        if self.design == "SFSD" and self.subtype:
            return f"SFSD ({self.subtype})"
        return self.design


def classify_design(
    df: pd.DataFrame,
    group: str,
    time: str,
    treatment: str,
) -> Classification:
    """Classify a (G, T, D) panel into CLA / SAD / SFSD / HAD / Other.

    Parameters
    ----------
    df : DataFrame containing at least the three named columns.
    group, time, treatment : column names.

    Returns
    -------
    Classification
    """
    df = df[[group, time, treatment]].dropna().copy()
    if df.empty:
        return Classification("Other", reason="no rows after dropna")

    # ---- Rank-index group and time (mimics gegen group(...) in did_multiplegt_dyn)
    df["_G"] = pd.Categorical(df[group]).codes + 1
    df["_T"] = pd.Categorical(df[time]).codes + 1
    df["_D"] = pd.to_numeric(df[treatment], errors="coerce")

    # If there are multiple rows per (G,T) (within-cell), collapse by mean of D.
    # This is *not* how the .ado handles it (Stata uses xtset and assumes
    # unique panel id), but for survey-style data we need to be robust.
    df = (
        df.groupby(["_G", "_T"], as_index=False)["_D"]
        .mean()
        .sort_values(["_G", "_T"], kind="mergesort")
        .reset_index(drop=True)
    )

    Tmin = int(df["_T"].min())
    Tmax = int(df["_T"].max())
    n_periods = int(df["_T"].nunique())
    n_groups = int(df["_G"].nunique())

    # ---- _diff_D = D_{g,t} - D_{g,t-1}
    df["_diff_D"] = df.groupby("_G")["_D"].diff()

    # ---- _D_g1 = D at first ranked period within each group
    # (use the actual first observation per group, mimicking d_sq_XX_temp).
    first_per_g = df.groupby("_G").head(1)[["_G", "_D"]].rename(columns={"_D": "_D_g1"})
    df = df.merge(first_per_g, on="_G", how="left")

    # ---- _F_g = first t with _diff_D != 0 (within group); Tmax+1 if never
    changes = df[(df["_diff_D"] != 0) & df["_diff_D"].notna()]
    F_g_series = changes.groupby("_G")["_T"].min()
    F_g = (
        pd.Series(F_g_series, index=pd.Index(np.arange(1, n_groups + 1), name="_G"))
        .reindex(np.arange(1, n_groups + 1))
        .fillna(Tmax + 1)
        .astype(int)
    )

    # Convenience: per-group view
    grp = pd.DataFrame({
        "_G": F_g.index,
        "_F_g": F_g.values,
    })
    grp = grp.merge(first_per_g, on="_G", how="left")

    # ============================ CLA test ============================
    # Restrict to groups with _D_g1 == 0 (silently drop always-treated).
    mask_clean = df["_D_g1"] == 0
    diff_clean = df.loc[mask_clean, "_diff_D"]
    nonbinary_violations = int(
        ((~diff_clean.isin([0, 1, np.nan])) & diff_clean.notna()).sum()
    )

    grp_clean = grp[grp["_D_g1"] == 0]
    switchers = grp_clean[grp_clean["_F_g"] <= Tmax]
    controls = grp_clean[grp_clean["_F_g"] > Tmax]
    distinct_switch_dates = sorted(switchers["_F_g"].unique().tolist())
    n_switch_dates = len(distinct_switch_dates)

    if (
        nonbinary_violations == 0
        and len(switchers) > 0
        and len(controls) > 0
        and n_switch_dates == 1
    ):
        return Classification(
            "CLA",
            n_groups=n_groups,
            n_periods=n_periods,
            reason=f"T0 = {distinct_switch_dates[0] - 1}",
        )

    # ============================ SAD test ============================
    if (
        nonbinary_violations == 0
        and len(switchers) > 0
        and n_switch_dates >= 2
    ):
        return Classification(
            "SAD",
            n_groups=n_groups,
            n_periods=n_periods,
            reason=f"{n_switch_dates} distinct switch dates",
        )

    # ============================ SFSD test ===========================
    # No binarity restriction. Use the agreed FIX:
    # variation in _F_g among switchers (over ALL groups, not just _D_g1 == 0).
    switchers_all = grp[grp["_F_g"] <= Tmax]
    if len(switchers_all) >= 2 and switchers_all["_F_g"].var(ddof=0) > 0:
        # Sub-classify: SSFSD if some _D_g1 has within-baseline F_g variation.
        within_sd = (
            switchers_all.groupby("_D_g1")["_F_g"].std(ddof=0).fillna(0).max()
        )
        if within_sd > 0:
            return Classification(
                "SFSD",
                subtype="SSFSD",
                n_groups=n_groups,
                n_periods=n_periods,
            )
        return Classification(
            "SFSD",
            subtype="RSFSD",
            n_groups=n_groups,
            n_periods=n_periods,
        )

    # ============================ HAD test ============================
    positives = df[df["_D"] > 0]
    if not positives.empty:
        t_star = int(positives["_T"].min())
        # Guard: t* must be strictly after the first observed period, otherwise
        # there is no pre-period and the HAD definition is degenerate.
        if t_star <= Tmin:
            return Classification(
                "Other",
                reason=f"degenerate HAD candidate: t*={t_star} == Tmin",
                n_groups=n_groups,
                n_periods=n_periods,
            )
        # (a) D == 0 for all (g, t < t*)
        pre_violations = int(((df["_D"] != 0) & (df["_T"] < t_star)).sum())
        # (b) E(D | T == t*) > 0
        d_at_tstar = df.loc[df["_T"] == t_star, "_D"]
        mean_D_tstar = float(d_at_tstar.mean()) if not d_at_tstar.empty else 0.0
        # (c) Var(D | T == t*, D > 0) > 0
        d_pos_at_tstar = d_at_tstar[d_at_tstar > 0]
        var_D_tstar_pos = float(d_pos_at_tstar.var(ddof=0)) if len(d_pos_at_tstar) >= 2 else 0.0
        n_pos_at_tstar = int(len(d_pos_at_tstar))

        if (
            pre_violations == 0
            and mean_D_tstar > 0
            and n_pos_at_tstar >= 2
            and var_D_tstar_pos > 0
        ):
            return Classification(
                "HAD",
                n_groups=n_groups,
                n_periods=n_periods,
                t_star=t_star,
            )

    return Classification(
        "Other",
        reason="no design conditions satisfied",
        n_groups=n_groups,
        n_periods=n_periods,
    )


# ============================ self-test ============================
if __name__ == "__main__":
    rng = np.random.default_rng(0)

    # CLA: 100 groups, 10 periods, 50 treated at t=6
    rows = []
    for g in range(1, 101):
        for t in range(1, 11):
            D = 1 if (g <= 50 and t >= 6) else 0
            rows.append({"g": g, "t": t, "D": D})
    res = classify_design(pd.DataFrame(rows), "g", "t", "D")
    print("CLA  ->", res.label())
    assert res.design == "CLA", res

    # SAD: 100 groups, 10 periods, F_g in {4,6,8,11}
    rows = []
    Fg_map = {**{g: 4 for g in range(1, 26)},
              **{g: 6 for g in range(26, 51)},
              **{g: 8 for g in range(51, 76)},
              **{g: 11 for g in range(76, 101)}}
    for g in range(1, 101):
        Fg = Fg_map[g]
        for t in range(1, 11):
            D = 1 if t >= Fg else 0
            rows.append({"g": g, "t": t, "D": D})
    res = classify_design(pd.DataFrame(rows), "g", "t", "D")
    print("SAD  ->", res.label())
    assert res.design == "SAD", res

    # SFSD: D in {1,2,3}, no baseline-0 cohort (so the silent-drop in the
    # CLA/SAD test leaves zero groups → falls through to SFSD). Some groups
    # switch UP, some switch DOWN (baseline 3) → non-binary _diff_D. Within
    # each baseline value half the groups switch at t=4 and half at t=8, so
    # within-baseline F_g variance > 0 → SSFSD.
    rows = []
    for g in range(1, 101):
        baseline = ((g - 1) % 3) + 1   # cycles 1, 2, 3
        Fg = 4 if g <= 50 else 8
        for t in range(1, 11):
            if t >= Fg:
                D = baseline + 1 if baseline < 3 else baseline - 1
            else:
                D = baseline
            rows.append({"g": g, "t": t, "D": D})
    res = classify_design(pd.DataFrame(rows), "g", "t", "D")
    print("SFSD ->", res.label())
    assert res.design == "SFSD" and res.subtype == "SSFSD", res

    # HAD: D=0 for t<6; at t=6, 30 groups stay 0, 70 receive Uniform(1,10)
    rows = []
    for g in range(1, 101):
        dose = 0.0 if g <= 30 else float(rng.uniform(1, 10))
        for t in range(1, 11):
            if t < 6:
                D = 0.0
            elif t == 6:
                D = dose
            else:
                D = dose + (rng.normal(0, 0.3) if dose > 0 else 0)
                D = max(D, 0.0)
            rows.append({"g": g, "t": t, "D": D})
    res = classify_design(pd.DataFrame(rows), "g", "t", "D")
    print("HAD  ->", res.label())
    assert res.design == "HAD", res

    print("\nAll Python shadow self-tests passed.")
