# Results Summary

See `calibration.md` for how the numbers below were produced and `model_equations.md` for the
objects referenced.

## Headline welfare result (Chile calibration)
Welfare loss (×10⁻⁴): **Float 25.47, Managed 10.17, Peg 102.05.**
Managed float dominates; Peg is dominated by a risk-premium/UIP shock (75% of its loss), not
terms-of-trade.

**After adding the cross-sector welfare term** (2026-07-23, see below): new totals
**26.31 / 11.03 / 106.62 ×10⁻⁴** (Float/Managed/Peg) — ranking unchanged.

## Robustness checks (pre-presentation)
- Same ranking holds under **Korea and Czechia** calibrations, and under a separate stylized
  triangular network used for continuous sweeps (φ_s, import intensity, exposure concentration,
  network density).
- **DC index does not survive** with two cost-push channels (TFP + FX) under float; restored only by
  assuming flexible import pricing (knife-edge Γ ∝ B). Proof + knife-edge test in appendix.
- **Network-isolation experiment** (scaling domestic I-O density ρ): confirms the network channel
  itself matters, not just "open economy" — roughly triples the Float/Peg welfare gap as density
  rises, reallocates which sector bears the cost by regime.
- **Second-order welfare check** (2026-07-17): order-2 pruned perturbation, welfare recomputed from
  E[X²]. Net effect (controlled for MC noise via identical-seed order=1 comparison): loss rises
  Float +2.0%, Managed +0.6%, Peg +0.7% — ranking unchanged. Risk-adjusted means are real (Peg's
  output gap sits ~-45bp on average, an order of magnitude larger than Float/Managed; NFA carries a
  bigger precautionary buffer under Peg) but contribute <0.5% of squared welfare loss in every
  regime — almost all of the correction is variance amplification, not the mean-shift channel.

## Post-presentation revision findings (2026-07-22/23)
Responding to Christian/Benny/Adam's feedback (`speech_feedback_20260722.txt`). 8 new main-flow
slides added (deck grew 22 → 30 physical pages). All wired into `soe_fx_presentation.tex` and
`speech_notes.md`. New code in `code/`, outputs in `results/`+`figs/`.

### Christian — "Why Services?" mechanism (three hypotheses, all real and compounding)
He proposed three competing explanations for why Services (rigid + low import share) still absorbs
so much welfare cost; all three turned out real and compounding, not competing:
1. **Network/cost-push:** total import centrality M_i splits into direct (Ω^F_i) and indirect
   (inherited via suppliers) exposure. Services: 41% of its exposure is indirect (vs. 50% Resource,
   32% Manufacturing) — grows with network density ρ, mechanically zero at ρ=0. Pure linear algebra
   (`code/network_exposure_decomposition.py`).
2. **Monetary-mismatch/demand under Peg** and **3. pure size** — resolved via Dynare's own variance
   decomposition of y_gap3: risk-premium/UIP (a pure aggregate, non-import shock) dominates
   Services' own output-gap variance in every regime (63% Float, 78% Peg); the import-price/network
   channel is secondary (2–22%). Reconciled with the Domar-weight (λ_D,3) decomposition: Services'
   size is 92% already present at ρ=0 (own consumption share + within-sector input reuse), network
   adds only ~9% more — contrast Resource, where network more than doubles its (much smaller)
   weight (`code/services_mechanism_decomposition.py`).

**Takeaway used throughout the deck:** size (λ_D) determines who absorbs a generic aggregate shock,
rigidity (δ̂) converts that into welfare cost, network amplifies an already-large sector more than
it creates new exposure from scratch.

### Christian — does the optimal managed-float parameter change with the network?
`code/sweep_phi_s_netdens_chile.m` (36 fresh Dynare solves: 12 φ_s values × ρ∈{0,1,2}). Result:
**φ_s* = 0.15 → 0.20 → 0.30** as density rises from none → baseline → 2× baseline — confirms his
hypothesis directly, the optimal parameter shifts, not just the loss level. Welfare curve is flat
near each optimum (~2–3%) — real but not a knife-edge.

### Christian — persistence and the UIP welfare loss
`code/sweep_rp_persistence_netdens_chile.m` (24 points: ρ_RP∈{0,.40,.80,.95} × network density
{0,1} × 3 regimes). Welfare loss is **convex in persistence**, not linear (AR(1) variance
∝ σ²/(1−ρ²)) — ρ_RP: 0.80 → 0.95 causes a **5× jump** in Peg's loss, far more than any size or
density effect alone.

**Caution flagged on the slide itself:** at ρ_RP=0.95 the model is near a second unit-root region
(on top of NFA's already-near-unit-root persistence, Corr(BSTAR_t, BSTAR_{t-1})≈0.99), and the
order-1 solution shows one anomalous result there (network *lowering* Float's loss, opposite of
every other slide). Treat ρ_RP≤0.80 as reliable, 0.95 as a stress test, not a calibration target.

### Christian — cross-sector welfare term (Rubbo Prop. 3)
Previously an acknowledged gap. Closed form derived: Cobb-Douglas cross-sector aggregators ⇒
Allen-Uzawa elasticity exactly 1 ⇒ Φ_C, Φ_s collapse to a weighted variance of the markup gap
(outer C^H/C^F nest η=1.5 as a practical stand-in — an approximation, flagged as such). Added
MARKUPGAP1/2/3 reporting variables to the `.mod` files (steady state unchanged, confirmed
MARKUPGAP_i=0 at steady state). **Result: adds 3.3% / 8.4% / 4.5% (Float/Managed/Peg) — ranking
unchanged**, new totals 26.31/11.03/106.62 ×10⁻⁴. Full derivation in
`rubbo_proofs_and_extension.tex`. See `decisions.md` for the approximation caveat.

### Adam — how much does Peg's loss depend on the risk-premium shock? (important, uncomfortable)
`code/sweep_risk_premium_chile.m` (scales sd(ε^RP), real Chile calibration). **With the
risk-premium shock switched off entirely, Peg is not dominated — essentially tied with Float
(0.95×), fractionally better.** The entire "Peg is worst" headline depends on this one shock existing
at roughly its calibrated size: half-strength already flips it (1.7× Float), full calibrated
strength gives 3.6×, 3× calibrated gives 14.5×. Defended as a reasonable default (same 1% s.d. as
every other shock, literature-consistent) but flagged explicitly: **the margin of the Peg-dominated
result needs an independently estimated σ_RP for a paper draft**, not an assumed-equal-to-everything-
else one. See `paper_context.md` for the related ψ-sensitivity sweep still to be built.

### Adam — upstream/downstream robustness
Pooled Chile/Korea/Czechia × 3 sectors = 9 points (`code/upstream_downstream_robustness.py`).
Honest result: only a **moderate, noisy** relationship (r=0.55, n=9) between how much a sector
sources domestically and how much of its import exposure is indirect — 3 sectors is a weak test,
said so on the slide. What **is** robust across all three calibrations: Services sources the
*least* domestically of any sector in every calibration, yet still derives 41–65% of its exposure
indirectly — a composition effect (concentrated in the one import-heavy supplier), not a volume
effect.

### Adam — clarity asks
Folded into existing/new slides as footnotes rather than new slides: units footnote on "Welfare
Ranking"; shock typology on "This Paper"; multiply-direction note on "Firms: Production Network";
not-over-identified note + shock table on "Equilibrium System"; new slide "Reading the Robustness
Slides: What Varies, What's Fixed" (first slide of Results); methodology footnote on "What Drives
Each Regime's Loss?".

## Three follow-up exercises (2026-07-21/23, `todo_three_exercises.txt`)
Numerically complete and committed (`a403e1e`, `8425b18`); this section is the write-up that was
missing. Priority order was payoff-per-effort: #3 (psi) > #1 (network premium) > #2 (export
reallocation, full version).

### Task #3 — psi-sensitivity sweep (risk-premium/UIP robustness)
`code/sweep_psi_point.m`, PSI scaled 0.25x–4x baseline (0.005/0.01/0.02/0.04/0.08) →
`results/psi_sweep_welfare.csv`. Answers the ψ-sensitivity question flagged in `paper_context.md`.
**Ranking is robust across the whole grid** (Peg worst at every ψ), but the *margin* is not
constant: Peg/Float ratio shrinks from **5.4× at ψ=0.005 to 2.7× at ψ=0.08**, and the risk-premium
shock's share of Peg's loss (the "75%" headline, at baseline ψ=0.02) ranges from **83% (ψ=0.005) to
58% (ψ=0.08)**. Risk-premium/UIP remains the single dominant channel throughout — the qualitative
story survives — but the exact 75% figure is itself a function of an under-scrutinized calibration
choice, reinforcing Adam's original caution rather than resolving it. No steady-state re-derivation
needed (ψ only enters the UIP dynamics).

### Task #1 — network vs. no-network on the REAL Chile calibration
`code/run_nonetwork_chile.m` zeroes all nine Ω^H entries (own Chile calibration, not the stylized
triangular-network proxy), re-derives the steady state, re-simulates all three regimes →
`results/task1_network_premium.csv`. **Network premium (×10⁻⁴, with-network vs. no-network):**
Float 25.47 vs 8.13 (**+213%**), Peg 102.05 vs 37.94 (**+169%**), Managed 10.17 vs 5.30 (**+92%**).
Confirms — with the paper's actual headline calibration, not the illustrative stylized network —
that the production network itself, not just "open economy," drives most of the welfare loss, and
that it amplifies Float most and Managed least in relative terms. Replaces the stylized
network-isolation experiment's premium number with a real one; ranking (Float < Managed < Peg
dominance of Peg) unaffected in either version.

### Task #2 — sector-specific export demand, full version
Replaced the single aggregate `EX_t` (allocated via consumption shares β^H, Services-heavy) with
three sector-specific export equations calibrated so steady-state EX_i/Y_i matches the real export
shares (Resource 0.602/Manuf. 0.180/Services 0.036) via `code/calibrate_kapex_chile.m` (damped
fixed-point on KAPEX_i, no Optimization Toolbox available), re-derived steady state, re-ran all
three regimes (`open_economy_network_chile_exp*.mod`). **Export/ToT shock's (eps_pX) welfare
contribution, old (β^H-allocated) → new (real export-share-allocated), ×10⁻⁴:** Float 0.105→0.165
(**+57%**), Managed 0.175→0.142 (**-19%**), Peg 2.155→1.171 (**-46%**). Peg's total welfare loss
falls from 102.05 to **90.45** (-11.4%) once exports are allocated to the actual export-heavy
(Resource) sector rather than the export-light, Services-heavy consumption-share proxy — the old
allocation was *overstating* how much export-price risk Peg absorbs. Ranking unchanged. Network
premium re-checked under this new export model (`results/exp_baseline_network_premium.csv`): Float
+190%, Peg +169%, Managed +88% — consistent with Task #1's numbers. Additional robustness sweeps
over the export demand elasticity (θ_X, `results/export_thetaX_welfare.csv`) and reallocation
intensity (ζ, `results/export_zeta_welfare.csv`) both show smooth, monotonic sensitivity with no
ranking flips.

**Not yet done:** none of these three numbers have been folded into `soe_fx_presentation.tex` or
`speech_notes.md` yet — `todo_three_exercises.txt` explicitly gated that on sanity-checking the
numbers first, which this write-up constitutes. Next step if these are wanted in the deck: a new
"Robustness: Real Chile Network & Export Reallocation" slide, likely paired with the existing
network-isolation and risk-premium-volatility slides.

## Tier 1 robustness campaign + regime variants (2026-07-27, written up 2026-07-30)
Numerically run but never written up until now (found via file-comment dates, not tracked in any
todo file). All use the real Chile calibration; ρ scales domestic network density the same way as
`sweep_phi_s_netdens_chile.m` (ρ=0 no network, ρ=1 real Chile, ρ=2 double density).

### Tier 1A — does ψ-sensitivity depend on network density?
`code/sweep_psi_netdens_chile.m` (5 ψ × 3 ρ × 3 regimes) → `code/analysis_psi_netdens_chile.py` →
`figs/psi_netdens_robustness.pdf`. **No — ψ-sensitivity is essentially independent of network
density.** Peg/Float ratio moves from ~5.3–5.5× (ψ=0.005) down to ~2.7–2.8× (ψ=0.08) at *every* ρ
∈{0,1,2} — the pattern found in the plain ψ sweep (real Chile, ρ=1 only) generalizes unchanged to
the no-network and double-density cases. Cross-validated against `results/psi_sweep_welfare.csv`:
the ρ=1 column reproduces those numbers to within 0.2%.

### Tier 1B — uniform rigidity × network density
`code/sweep_rigidity_netdens_chile.m` (κ scales all three sectors' stickiness by a common
multiplier) + `code/drive_rigidity_netdens_sweep.sh` (built 2026-07-30, driver didn't exist before)
→ `code/analysis_rigidity_netdens_chile.py` → `figs/rigidity_netdens_robustness.pdf`. **Grid had to
be adjusted**: the original 0.5–2.0× plan is infeasible above κ≈1.18 given the current Calvo
calibration — Services' baseline DELTA₃=0.16 means κ=1.5 already implies a *negative* reset
probability (caught cleanly by the script's own feasibility guard, not a crash). Used κ∈{0.5,
0.75, 1.0, 1.15} instead.
- **Peg's welfare loss rises monotonically and steeply in rigidity at every ρ** (e.g. ρ=2: 60→104→
  182→251 ×10⁻⁴ across the κ grid) — rigidity compounds with Peg's existing risk-premium/UIP
  problem, a clean result.
- **Float and Managed are NOT monotonic across the grid, and the κ=1.15 endpoint should be treated
  as a stress test, not a reliable point** — same caution as the ρ_RP=0.95 persistence result.
  Reason: dhat₃ (Services' Calvo persistence index) collapses from 0.031 at baseline (κ=1.0) to
  0.0015 at κ=1.15, an order of magnitude closer to zero, right as DELTA₃ approaches the model's own
  0.01 feasibility floor (DELTA₃=0.034 at κ=1.15). Since the welfare weight scales like
  (1-dhat)/dhat, this point is numerically fragile by construction. **Read κ≤1.0 as reliable, κ=1.15
  as a stress test.**

### New regime variants — strict CPI/PPI inflation targeting
`open_economy_network_chile_cpiit.mod` / `_ppiit.mod` (added 2026-07-27, alternative Taylor rules
targeting PIC-only or PH-only instead of the DC index) — added to all three master `.mod` files but
never run until now (`code/run_it_regimes_chile.m`, `code/analysis_it_regimes_chile.py`). **Both
solve cleanly and land statistically indistinguishable from Float**: cpi_it 25.36, ppi_it 25.26 vs
Float's 25.47 (×10⁻⁴) — within 1% of each other. **Takeaway: targeting the DC index specifically
(vs. naively targeting CPI or PPI inflation) buys almost nothing on its own; Managed's ~2.5×
improvement over all three comes entirely from the explicit FX-stabilization term (φ_s log S), not
from smarter inflation targeting.** Useful context for the "why does the DC index matter" framing —
the DC index's theoretical role (as the object a *divine-coincidence* rule would target) is distinct
from its practical welfare payoff in this calibration, where φ_s does the real work.

## Full robustness campaign, Tiers 1C/2/3 (2026-07-30)
Continuation of the Tier 1A/1B campaign above. Plan doc:
`C:\Users\sugarkhuu\.claude\plans\noble-strolling-feather.md`; handoff note (superseded by this
section): `docs_notes/handoff_20260730.md`. All real Chile calibration.

### Tier 1B (Services-only rigidity cut)
`code/sweep_services_rigidity_chile.m` (DELTA3 ∈ {0.05,0.10,0.16(baseline),0.25,0.40,0.60}, DELTA1/2
held fixed, × ρ∈{0,1,2} × 3 regimes, 54 solves, all clean — no near-degenerate points, unlike the
uniform-κ cut). **Peg's loss falls monotonically as Services becomes more flexible** at every ρ
(e.g. ρ=1: 122.9→113.7→102.1→85.0→60.7→37.0 ×10⁻⁴ as DELTA3 rises 0.05→0.60) — a clean, robust
result: Services' own rigidity is a first-order driver of Peg's dominance. **Float and Managed are
hump-shaped**, peaking around DELTA3≈0.25–0.40, not monotonic — the price-dispersion welfare weight
(∝(1-dhat)/dhat) and the Phillips-curve slope move in offsetting directions as DELTA3 falls, so this
isn't a numerical artifact, just a genuine non-monotonicity in the smaller-loss regimes.

### Tier 1C (ψ × σ_RP interaction, Peg only)
`code/sweep_psi_sigmarp_joint_chile.m` (ψ_scale × σ_RP_scale ∈ {0.5,1,2}², 9 solves). Log-log
regression: elasticity of Peg's loss w.r.t. σ_RP ≈ **+1.44** (dominant, convex), w.r.t. ψ ≈ **−0.24**
(real but secondary), interaction term ≈ **−0.16** (non-trivial: ψ's dampening effect is *stronger*
when σ_RP is larger — W(ψ=2×)/W(ψ=0.5×) shrinks from 0.85 at σ_RP=0.5× to 0.62 at σ_RP=2×). The two
calibration choices flagged in `calibration.md` reinforce rather than offset each other.

### Tier 2 (alternative network topologies)
`code/network_topologies.py` (analytical Ω^H construction, matched total off-diagonal mass 0.6501)
+ `code/sweep_topology_chile.m`, three shapes at matched mass: **triangle** (baseline, all 9
entries), **hub-spoke** (Manufacturing as hub, Resource↔Services ≈0), **chain**
(Resource→Manufacturing→Services one-directional). 45 solves (9 base regime comparison + 36 φ_s
grid search), all clean.
- **Ranking (Peg worst, Managed best) survives in every topology.** Welfare loss (×10⁻⁴, Float/
  Managed/Peg): triangle 25.5/10.2/102.1, hub-spoke 28.9/11.3/113.5, chain 33.7/12.7/115.5 — the
  chain topology (most concentrated pass-through) is uniformly worse than the triangle across all
  three regimes, hub-spoke intermediate.
- **Optimal φ_s shifts with topology, not just density**: triangle φ_s*=0.20, hub-spoke and chain
  both φ_s*=0.30 — consistent with (and reinforcing) the earlier φ_s-vs-ρ finding.
- **Services' indirect-exposure share is not triangle-specific — it's larger in the chain** (63% of
  its total import centrality is indirect in the chain vs. 41% triangle, 46% hub-spoke,
  `results/topology_exposure_decomposition.csv`) — the "Why Services?" mechanism generalizes to, and
  strengthens under, more concentrated pass-through structures.

### Tier 3 (regime-rule variants)
`code/sweep_regime_variants_chile.m`. **Regression check passed first** (see below) — confirms the
2026-07-27 `cpi_it`/`ppi_it` `.mod` edit didn't perturb the existing three regimes (reproduces
25.47/10.17/102.05 exactly).
- **3A/3B/3C — strict inflation targeting** (PHI_PI=5 proxy for →∞, PHI_Y=0) applied to DC-IT
  (float), CPI-IT, and PPI-IT, × ρ∈{0,1,2}: at ρ=1, **PPI-IT (10.55) < DC-IT (12.57) < CPI-IT
  (18.48)** ×10⁻⁴ — once the rule is aggressive, targeting the DC index is *not* the best choice;
  strict domestic (PPI) targeting wins. This nuances the earlier cpi_it/ppi_it-vs-float finding
  (which used baseline, non-aggressive Taylor coefficients and found all three indistinguishable):
  **the DC index's advantage over naive alternatives, if any, is specific to moderate policy
  aggressiveness — it doesn't hold under strict targeting.**
- **3D — dual-mandate grid** (PHI_PI∈{1.5,3,5} × PHI_Y∈{0,0.5,1}, float/DC-IT branch, ρ=1): best in
  grid is PHI_PI=5, PHI_Y=0.5 → loss=9.55 ×10⁻⁴, essentially matching (fractionally beating)
  Managed's headline 10.17 **without any FX-stabilization term**. **Caveat, not yet a "Managed isn't
  needed" result**: this is a coarse 3×3 grid on the float branch only; Managed's own PHI_PI/PHI_Y
  were left at their original (1.5, 0.5) baseline rather than re-optimized at the same aggressive
  level, so the comparison isn't apples-to-apples yet. What it does establish cleanly: the baseline
  PHI_PI=1.5 materially undersells how well plain DC-index targeting can do — φ_π was never itself
  swept before this.

**Regression check** (`code/regression_check_it_edit.m`): re-ran float/peg/managed through the
current (post-cpi_it/ppi_it-edit) master `.mod` files at ρ=1 baseline — reproduces 25.4735/10.1707/
102.0458 ×10⁻⁴ exactly (cross-validated independently against `results/psi_sweep_welfare.csv`'s
ψ=0.02 row too). The two new regime branches are additive and non-breaking as designed.

**Process note**: a background-task management error caused two copies of the Tier 3 driver to run
concurrently for a few minutes (a stale run continued after being fixed mid-flight, and a second
corrected run was launched without confirming the first had stopped), producing interleaved
duplicate rows in `regime_variants_sweep.csv`/`dual_mandate_grid_sweep.csv`. Caught immediately,
deduplicated, and verified against the MATLAB process list before analysis — final CSVs contain
exactly one row per grid point.

**Not done from the full plan** (judgment call, not required by the plan doc): Tier 1B's
`services_rigidity` cut used a coarser grid at the sticky end (0.05 floor, not more extreme) to stay
clear of the numerical edge found in the uniform-κ cut; no additional network shapes beyond the two
specified; Managed's own rule coefficients weren't re-swept under Tier 3D's aggressive PHI_PI range
(flagged above as the reason the "Managed may not be needed" finding is preliminary).

## Bugs found and fixed
See `decisions.md` for the sweep-crash and concurrent-fileread lessons, and the λ_D(ρ) bug in
`analysis_netdens_chile.py` (network welfare premium understated by up to ~25% at sweep extremes,
ranking unaffected).

## New code inventory (2026-07-22/23)
All in `code/`, outputs in `results/`+`figs/`: `network_exposure_decomposition.py`,
`services_mechanism_decomposition.py`, `upstream_downstream_robustness.py`,
`sweep_phi_s_netdens_chile.m` + `drive_phi_s_netdens_chile_sweep.sh`,
`sweep_rp_persistence_netdens_chile.m` + `drive_rp_persistence_netdens_chile.sh`,
`analysis_rp_persistence_netdens.py`, `sweep_risk_premium_chile.m` +
`drive_risk_premium_chile_sweep.sh` (rewritten), `analysis_risk_premium_chile.py`,
`run_markupgap_chile.m`, `cross_sector_welfare.py`, `analysis_netdens_chile_v2.py`,
`analysis_phi_s_netdens.py`.
