# Model Equations (Quick Reference)

Full derivations/proofs live in `rubbo_proofs_and_extension.tex` and `model_equations.tex` — this
file is a quick-lookup summary of the objects that recur across slides, code, and discussion, not a
replacement for either.

## Reduced-form vector Phillips curve (the central object)
```
π_t = ρ(I − V) E[π_{t+1}] + B(γ+φ) ỹ_t − V χ_t + Γ Δe_t
```
where:
- `π_t` — vector of sectoral inflation rates
- `ỹ_t` — output gap
- `χ_t` — sectoral TFP shocks
- `Δe_t` — nominal exchange rate depreciation (the SOE's *second* cost-push channel, absent in
  closed-economy Rubbo)
- `V` — network operator satisfying **V·1 = 0** (only *relative*, not uniform, TFP shocks generate
  cost-push)
- `B`, `Γ` — both built from the same rigidity-adjusted network operator
  `Ã = Δ(I − Ω^H Δ)^{-1}` ("same amplifier, two shocks"): `B` applies it to labor share **α**,
  `Γ` applies it to import share **ω_F**

This object is only derivable *after* market clearing — hence it's shown on the "Firms: Price
Setting" slide, after Equilibrium, not before (see `decisions.md`).

## Divine coincidence (DC) index
- **Closed economy (Rubbo):** DC index is unique — one cost-push channel (TFP) admits a single
  price index whose targeting replicates the flexible-price allocation.
- **Open economy, this project:** DC generically **breaks down** under float — two cost-push
  channels (TFP + FX) can't in general be collapsed to one target. Breakdown vanishes only in the
  knife-edge case Γ ∝ B (FX exposure proportional to labor intensity), i.e. flexible import pricing
  restores it. See `rubbo_proofs_and_extension.tex` for the full theorem and knife-edge test.

## Import centrality (total import exposure of sector i)
```
M_i = [(I − Ω^H)^{-1} Ω^F 1]_i
```
Splits into **direct** (Ω^F_i, imports the sector buys itself) and **indirect** (inherited via
suppliers) parts. Used in the "Why Services?" mechanism slides — see `results_summary.md`.

## Domar weight (sectoral size in the network)
```
λ_D^⊤ = β^{H⊤} (I − Ω^H)^{-1}
```
Function of network density ρ — a bug where this was held fixed at its ρ=1 value in one sweep
understated the network welfare premium by up to ~25%; see `decisions.md`.

## Export-side Domar weight (not currently implemented)
```
λ_X^⊤ = ω_X^⊤ (I − Ω^H)^{-1}
```
Would mirror import centrality M_i on the demand side instead of the cost side, using the
already-computed but currently-unused `export_share` data. See `paper_context.md` future
extensions.

## Welfare (Rubbo Prop. 3, extended)
```
W_loss = (output-gap variance term) + Σ_s λ_s (price-dispersion-weighted sectoral inflation
         variance term) + [Φ_C + Σ_s λ_s Φ_s]   (cross-sector term, added 2026-07-23)
```
- The bracketed cross-sector term collapses to a weighted variance of the markup gap
  `μ_it = log(P_it/MC_it) − log(ε/(ε−1))` under the Cobb-Douglas cross-sector aggregators used here
  (Allen-Uzawa elasticity exactly 1) — see `decisions.md` for the approximation caveat (outer nest
  η=1.5 stand-in).
- Reporting variables `MARKUPGAP1/2/3` added to the `.mod` files purely for this computation; do not
  change the steady state (`MARKUPGAP_i = 0` at steady state, confirmed).

## Household/firm primitives
- `β^H` — household Cobb-Douglas consumption shares across domestic sectors within `C_t^H`
  (defined once on the Households slide, reused for the Domar-weight formula).
- `C_t^F` — foreign consumption, a **single** Armington import composite, not sector-indexed
  (matches `open_economy_network_chile.mod`; confirmed against code).
- `B_t` — domestic bond, included explicitly in the household budget constraint, nets to zero in
  equilibrium (representative household, no domestic counterparty).
- `GDP_t = P_t^C C_t + P_t^H EX_t − P_t^{FH} IM_t` — a reporting identity, not a market-clearing
  condition (deliberately excluded from the Equilibrium slide, see `decisions.md`).

## Monetary policy regimes
- **Float** — free float, no FX targeting.
- **Peg** — hard peg.
- **Managed float** — Taylor rule responds to `φ_π, φ_y, φ_s`, the last being the FX-stabilization
  weight. `φ_s^*` (the optimal weight) itself shifts with network density ρ — see
  `results_summary.md`.
