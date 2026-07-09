# Classification decisions — TWFE tracker

Documents the design-classification pass on `reports/tracker_master_consolidado_final.xlsx` (Master sheet, `classification` column). Scope: 30 papers with `Estado ∈ {Replicado, Replicado completo, Replicado parcial}`.

## 1. Classification scheme (dCDH)

| Label | Definition |
|-------|------------|
| **CLA** | Classical DiD. Single treatment date, binary D∈{0,1}, never-treated control units, units remain treated once switched. |
| **SAD** | Staggered Adoption Design. Many treatment dates, binary D∈{0,1}, absorbing (once treated, stays treated). |
| **SFSD** | Staggered First Switch Design. ∃ g≠g′ with (i) D_{g,1}=D_{g′,1} and (ii) F_g≠F_{g′}. Heterogeneous first-switch dates; treatment may turn on *and* off. |
| **HAD** | Heterogeneous Adoption Design. D₁=0, D₂≥0, E(D₂)>0, Var(D₂\|D₂>0)>0. 2-period continuous-treatment design with clean baseline + stayers. |
| **OTHER** | None of the above: multi-period continuous treatments without staggered structure, RD designs, cross-sectional OLS, etc. |

## 2. Decision rules

These were applied in order:

1. **Treatment binary 0/1?**
   - Yes → continue to (2).
   - No (continuous, count, or interaction) → continue to (3).
2. **Binary treatment structure:**
   - Single treatment date + never-treated + absorbing → **CLA**.
   - Many dates + absorbing → **SAD**.
   - Switches on/off (non-absorbing) OR heterogeneous first-switch with shared period-1 status → **SFSD**.
3. **Non-binary treatment:**
   - 2-period continuous with D₁=0 + stayers → **HAD**.
   - Anything else (continuous multi-period, count variables varying up/down, RD, cross-section OLS) → **OTHER**.

Continuous multi-period treatments were *not* forced into HAD even when they had absorbing-like structure, because HAD is specifically a 2-period definition. SFSD was reserved for binary on/off cases to keep it distinguishable from SAD.

## 3. Evidence sources

For each paper, the classification was informed by:
- `Diseño` column already present in the tracker (when populated).
- `latex/<wave>/<paper>/table_twowayfeweights.tex` — weight decomposition tables that explicitly state treatment type, panel structure, and stable-groups status.
- Replication notes (`Notas` column) — negative-weight counts and sums, dCDH web-appendix classifications.
- Paper-level `tables.tex` headers for context on outcome and treatment.

## 4. Per-paper rationale (only changed/filled cells)

### CLA (n=1)
- **Dinkelman (2011).** 2-period reshape (1996, 2001 South Africa Census), binary electrification, 0% negative weights. Textbook 2×2 DiD.

### SAD (n=7 newly filled, two were already SAD)
- **Enikolopov et al. (2011), Forman et al. (2012), Hornbeck (2012), Moser & Voena (2012), Zhang & Zhu (2011).** Diseño already labeled "Binary, staggered"; treatment is absorbing in all five. Moser-Voena and Zhang-Zhu have 0% neg weights (clean control), Enikolopov 52.6%, Forman 27.1%, Hornbeck 21%.

### SFSD (n=4)
- **Acemoglu et al. (2011).** Already SFSD. Binary with multiple switches, some never-treated.
- **Burgess et al. (2015).** Tex confirms `President's coethnic` is a 0/1 dummy that switches on/off across presidencies. 49 years × 41 districts. → SFSD.
- **Faye & Niehaus (2012).** Weights table explicitly states "Executive election (binary), treatment switches on/off". Election cycles repeat → not absorbing. → SFSD.
- **Kaur (2019).** Binary rainfall shock (transient, switches on/off year to year). 1.2% neg weights. → SFSD.

### HAD (n=1 — reclassified from OTHER)
- **Algan & Cahuc (2010).** Diseño = "Continuous treatment with lagged outcome with no pretreatment period and some stayers". Matches the HAD definition literally: D₁=0, D₂≥0 with variance, stayers present. Was OTHER; updated to HAD.

### OTHER (n=17)
Filled or kept based on the structure described in the tex files:

| Paper | Why OTHER |
|-------|-----------|
| Aaronson et al. (2012) | Continuous log min wage, multi-period state panel |
| Anderson & Sallee (2011) | CAFE manufacturer panel — not a DiD design |
| Bagwell & Staiger (2011) | Continuous tariff variation, multi-period |
| Berman et al. (2017) | Continuous shock, 60.9% neg weights, multi-period |
| Besley & Mueller (2012) | Continuous killings/SD across 11 regions × quarterly periods |
| Bloom et al. (2012) | Cross-sectional OLS on decentralization — no DiD |
| Dell (2015) | Regression discontinuity (close PAN elections) — not DiD |
| Donaldson (2018) | Continuous railroad market access, 51% neg weights |
| Duranton & Turner (2011) | Continuous roads (km), multi-period, 49.1% neg |
| Favara & Imbs (2015) | Continuous credit, switches on/off, 31.9% neg |
| Fetzer (2019) | Continuous rainfall/conflict every period |
| Gentzkow et al. (2011) | Discrete count (number of newspapers), varies up and down |
| Handley & Limão (2017) | Continuous tariff uncertainty |
| Munshi & Rosenzweig (2016) | Cross-sectional OLS on migration — no DiD |
| Simcoe (2012) | Continuous Suit-share × S-track |
| Suárez Serrato & Zidar (2016) | Continuous tax rate with negative values |
| Wang (2011) | Continuous treatment, neg weights detected |

## 5. Borderline cases

These required judgment calls beyond the straightforward rules:

- **Continuous treatments with monotonic/absorbing rollout** (Donaldson, Duranton, Aaronson, Handley-Limão). A loose reading of SFSD (which allows continuous D) would put them there. We kept them as OTHER because (a) the user's SFSD examples were all binary, (b) HAD is the dCDH-canonical home for continuous treatment and these papers' multi-period structure breaks HAD's 2-period requirement.
- **Bloom et al. (2012), Munshi & Rosenzweig (2016).** These are cross-sectional OLS — not DiD at all. Classified OTHER rather than leaving blank, because the tracker treats `classification` as required for replicated papers.
- **Dell (2015).** Uses an RD design rather than DiD. OTHER for the same reason.
- **Gentzkow et al. (2011).** Treatment is a count of daily newspapers — not binary, not continuous-with-stayers, can go up and down. Closest to HAD if forced, but doesn't satisfy the D₁=0 baseline cleanly. OTHER.

## 6. Final distribution

| Design | Count | Share |
|--------|-------|-------|
| CLA    | 1  | 3.3% |
| SAD    | 7  | 23.3% |
| SFSD   | 4  | 13.3% |
| HAD    | 1  | 3.3% |
| OTHER  | 17 | 56.7% |
| **Total** | **30** | **100%** |

By wave:
| Wave | CLA | SAD | SFSD | HAD | OTHER | Total |
|------|-----|-----|------|-----|-------|-------|
| 2010–2012 | 1 | 5 | 2 | 1 | 10 | 19 |
| 2015–2019 | 0 | 2 | 2 | 0 | 7  | 11 |

## 7. Open items

- **Sin data / Con data papers** (n=27) were not classified — out of scope per user instruction ("focus only on these which we already have the replication results").
- **`Diseño` column** was *not* edited. Some rows still read "Por clasificar" or "pending" even though the new `classification` is filled. Leaving them as-is preserves the audit trail (originally-flagged designs vs. the user's classification decision).
- **OTHER share is high (57%).** If the user later wants a finer split (e.g., separating "continuous staggered" from "RD" from "cross-section OLS"), the OTHER bucket should be subdivided rather than the four canonical labels widened.
