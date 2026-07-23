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
