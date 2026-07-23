# Decisions Log

Design/scope choices made along the way, and the reasoning — so they don't get silently re-litigated
or re-broken by a future edit. See `paper_context.md` for the overall project frame.

## Model section slide order (2026-07-20)
Rebuilt slide-by-slide to: **Model Components (roadmap) → Households → Firms: Technology →
Production Network → Foreign Sector → Equilibrium: Market Clearing → Firms: Price Setting →
Monetary Policy Regimes.**
- Households/Firms/Network/Foreign-Sector lay out primitives first; Equilibrium closes the model;
  only then Firms: Price Setting shows the reduced-form vector Phillips curve, since that object is
  only derivable after market clearing — showing it earlier would reference ỹ_t before it's defined.
  Monetary Policy comes last since its Taylor rule targets objects (DC_t, ỹ_t) defined by the
  Phillips curve.
- Every slide ends with a compact "where:" glossary table — explicit ask, not just style.
- GDP deliberately **not** added to the Equilibrium slide: it's a reporting identity, not a
  market-clearing condition, so it doesn't belong there.
- Domestic bond B_t included explicitly in the household budget constraint (nets to zero in
  equilibrium, representative household) rather than silently omitted.
- Foreign consumption C_t^F is a single Armington import composite (not sector-indexed) — matches
  `open_economy_network_chile.mod`; confirmed against the code, not assumed.

## Template swap (2026-07-20)
Swapped to a simpler/plainer look at the user's request: default beamer frametitle (white bg, black
text), default Computer Modern font (dropped fontenc/lmodern/tgheros sans-serif), simple
title-left/page-number-right footline, no colored top nav bar or green bold-text override.
**Kept (required, heavily used, do not remove):** booktabs; tikz/pgfplots/pgffor/
`\usetikzlibrary`/`\pgfplotsset{compat=1.18}` (7+ IRF plot slides); appendixnumberbeamer (excludes
backup from page count); colors sectorres/sectorman/sectorserv/riskred; macros
`\bpi`/`\ty`/`\tA`/`\bom`/`\shockregimelegend`; the `slide fig` pgfplots style.

**Gotcha (hit 3 times):** joining two display equations on one line with `\qquad` overflows the 4:3
slide width (Households CES aggregator, Equilibrium market-clearing, Firms: Price Setting) — stack
as separate `\[...\]` blocks instead. Also avoid negative `\vspace` to fix vertical overflow — it
overlaps text instead of freeing space; shorten the actual prose/table entries instead.

## Benny's flow-reorder suggestion — not acted on
Benny suggested reordering the deck flow (mechanics/shocks before welfare). **Not acted on** for the
July 22 deadline — too large/risky a restructure under deadline pressure, not revisited since.
Flagged as a candidate for the next revision in `speech_notes.md`. Revisit before doing another major
slide reorder.

## Cross-sector welfare term — Cobb-Douglas approximation (2026-07-23)
Christian's ask: Rubbo Prop. 3's Φ_C + Σ_s λ_s Φ_s term (cross-sector welfare), previously an
acknowledged gap. This model's cross-sector aggregators (household consumption shares β^H; firm
input bundles Ω^H, Ω^F) are Cobb-Douglas ⇒ Allen-Uzawa elasticity of substitution exactly 1 by
construction ⇒ Φ_C, Φ_s collapse to a weighted variance of the markup gap. Only the outer C^H/C^F
nest is genuine CES (η=1.5) — used as a practical stand-in for the true domestic-vs-import
cross-elasticity. **This is an approximation, not an exact derivation** — flagged explicitly on the
slide and in `rubbo_proofs_and_extension.tex`. Worth tightening (or defending explicitly) for a
paper draft. Rubbo's own `welf.m`/D2-matrix construction could not be cross-checked
(`replication files/` not present locally).

## Sweep script architecture — one process per grid point
**Rule: write sweep `.m` files as a function taking one grid point, called once per fresh MATLAB
process from a bash driver, appending one row to a results CSV per call.** Never loop many `dynare`
calls inside one MATLAB session.
- **Why:** unclosed IRF figure handles from `graph_format=pdf` accumulate and crash MATLAB's
  graphics subsystem after ~15-18 sequential `dynare` calls ("low-level graphics error... Not
  enough memory resources"), and single-session scripts only write output at the very end — a crash
  loses the whole run.
- **How to apply:** for any future sweep, regex-strip `graph_format=pdf`→`nograph` in the generated
  `.mod` text (sweeps only need `oo_.var`, never plots). Mirrors
  `code/sweep_netdens_chile.m`/`sweep_phi_s_netdens_chile.m`. See `calibration.md` for the concrete
  invocation pattern.

## Don't edit a master .mod file while a sweep is running against it
Editing a master `.mod` file (adding MARKUPGAP1/2/3) while a *different* background sweep was
concurrently `fileread`-ing that same file caused 2 silent point failures (torn read) in
`rp_persistence_netdens_chile_sweep.csv`. Re-ran the 2 missing points manually after the edit
settled. **Lesson: wait for background sweeps sourced from a `.mod` file to finish before editing
it**, or work on a copy.

## λ_D fixed-at-ρ=1 bug in the network-density sweep
`analysis_netdens_chile.py`'s welfare calc used λ_D fixed at its ρ=1 value for every ρ in the
sweep, but λ_D = β^{H⊤}(I−Ω^H)^{-1} is itself a function of ρ. Corrected in
`code/analysis_netdens_chile_v2.py` using closed-form λ_D(ρ) — shows the network welfare premium in
`figs/isolating_network.pdf` was **understated by up to ~25%** at the sweep's extremes (exact at
baseline ρ=1). Ranking/monotonicity unaffected; didn't regenerate that specific figure since it
doesn't change any conclusion — **flag before a paper draft.**
