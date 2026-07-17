# Project: Small Open Economy Extension of Rubbo (2024)

## What this project is
Extending Rubbo (2024) "Networks, Phillips Curves, and Monetary Policy" to a small open economy with FX policy analysis. Presentation deadline: **July 22, 2026**.

## Key files
- `rubbo_2024.pdf` — main paper
- `appendix_website_2.pdf` — appendix with all proofs
- `supplemental_revision.pdf` — supplemental material
- `rubbo_proofs_and_extension.tex` — detailed step-by-step proofs of all Rubbo results + open economy extension outline (compile with Ctrl+Alt+B in VS Code)
- `soe_fx_presentation.tex` — the presentation deck (35 pages, 4:3, single-column except the 7 IRF slides). This is the primary deliverable right now.
- `speech_notes.md` — full talk script + anticipated Q&A, one block per slide, kept in sync with the deck
- `data_calibration/build_chile_calibration.py` — builds the Chile IO calibration from Banco Central de Chile CdeR tables (also Korea/Czechia variants)
- `replication files/` — Rubbo's Matlab replication code and data (gitignored, large)

## GitHub
https://github.com/Sugarkhuu/rubbo_2024

## Current status (as of 2026-07-16)
Proofs are done (see `rubbo_proofs_and_extension.tex`: Lemmas 1-4, Propositions 1-3, open economy extension). Work has moved to the **presentation**, which is essentially complete for the July 22 deadline:
- Full model, theory (DC-index breakdown proof), and results built out across 21 main slides + appendix backup.
- Headline results use the real Chile calibration (Banco Central de Chile national IO table, 12 sectors collapsed to 3): welfare loss Float 25.47, Managed 10.17, Peg 102.05 (×10⁻⁴). Managed float dominates; Peg is dominated by a risk-premium/UIP shock (75% of its loss), not terms-of-trade.
- Robustness: same ranking holds under Korea and Czechia calibrations, and under a separate "stylized" triangular network used for the continuous sweeps (φ_s, import intensity, exposure concentration, network density) — three real calibrations are discrete data points, so the stylized network is the one built with a scalar dial. Slides now label which numbers come from which network to avoid confusion.
- DC index does **not** survive with two cost-push channels (TFP + FX) under float; restored only by assuming flexible import pricing. Proof + knife-edge test in appendix.
- Network-isolation experiment (scaling domestic I-O density ρ) confirms the network channel itself matters, not just "open economy": it roughly triples the Float/Peg welfare gap as density rises and reallocates which sector bears the cost by regime.
- Literature consolidated to one slide (network side / open-economy side / gap), with a paper-by-paper comparison table pushed to appendix backup, including the closest competing paper (Gnocato, Montes-Galdón & Stamato 2025, ECB — network + open economy but no FX-regime choice).
- Second-order welfare check (2026-07-17, done): re-solved the Chile calibration to a genuine order-2 pruned perturbation (Dynare, Kim-Kim-Schaumburg pruning, simulated 260k periods since the Taylor rule leaves price levels/S with a unit root that breaks Dynare's analytic order-2 moments) and recomputed welfare from E[X^2] directly, not Var(X), so any risk-adjusted-steady-state mean shift is captured. Net effect (controlled for Monte Carlo noise via an identical-seed order=1 comparison run): loss rises Float +2.0%, Managed +0.6%, Peg +0.7% — ranking (Managed < Float < Peg) is unchanged. Risk-adjusted means are real (Peg's output gap sits ~-45bp on average, an order of magnitude larger than Float/Managed; NFA carries a bigger precautionary buffer under Peg) but contribute <0.5% of the squared welfare loss in every regime — almost all of the correction is a modest variance amplification, not the mean-shift channel. See `rubbo_proofs_and_extension.tex` §"Second-Order Welfare (Numerical Verification)", the new appendix slide in the deck, and `order2/` for the reproducible Dynare/Matlab pipeline (`run_order2.m`, `run_order1sim.m`, `results_order2/*.csv`).

## Planned paper structure
1. Introduction — position vs Rubbo and La'O & Tahbaz-Salehi (2022, Econometrica)
2. SOE model — N domestic sectors + import sector, UIP, law of one price
3. Phillips curve with ER — Γ·Δe term, network amplification of pass-through
4. Divine coincidence in open economy — breaks down under float (two cost-push channels)
5. Welfare and optimal FX policy — float vs peg vs managed float
6. Quantitative — done for the presentation with 3-sector real IO calibrations (Chile, Korea, Czechia); a genuinely many-sector OECD TiVA calibration is the natural next step, not yet built

## Core theoretical contribution
In Rubbo, the DC index is unique because there is one cost-push channel (productivity). In the SOE, there are two channels (productivity + exchange rate). The central result is whether a modified DC index exists under flexible ER, or whether the inflation-output tradeoff is irreducible.

## Key papers to cite
- La'O & Tahbaz-Salehi (2022, Econometrica) — optimal MP in production networks
- Auer, Levchenko & Sauré (2019, ReStud) — international inflation spillovers via IO linkages
- Pasten, Schoenle & Weber (2020, JPE) — MP propagation in heterogeneous production economy
- Fanelli & Straub (2021, JPE) — theory of FX interventions
- Gopinath & Itskhoki (2022) — dominant currency paradigm
- Amiti, Itskhoki & Konings (2019, QJE) — variable markups and pass-through

## Preferences
- Don't ask before taking actions, just do them
- For math: write to .tex file and compile rather than showing raw LaTeX in chat
- VS Code has MiKTeX + LaTeX Workshop installed (Ctrl+Alt+B builds, Ctrl+Alt+V opens preview)
