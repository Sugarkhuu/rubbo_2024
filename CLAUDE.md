# Project: Small Open Economy Extension of Rubbo (2024)

## What this project is
Extending Rubbo (2024) "Networks, Phillips Curves, and Monetary Policy" to a small open economy with FX policy analysis. Presentation deadline: **July 22, 2026**.

## Key files
- `rubbo_2024.pdf` — main paper
- `appendix_website_2.pdf` — appendix with all proofs
- `supplemental_revision.pdf` — supplemental material
- `rubbo_proofs_and_extension.tex` — detailed step-by-step proofs of all Rubbo results + open economy extension outline (compile with Ctrl+Alt+B in VS Code)
- `soe_fx_presentation.tex` — the presentation deck (30 main-counted slides + appendix backup, 44 physical pages, 4:3, single-column except the 7 IRF slides). This is the primary deliverable right now.
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

## Model section rebuild (2026-07-20, done)
The Model section of `soe_fx_presentation.tex` was rebuilt slide-by-slide (was previously a denser, less self-contained treatment). Current slide order (all between the `%% my slides` markers, right after `\section{Model}`):
**Model Components (roadmap) → Households → Firms: Technology → Production Network → Foreign Sector → Equilibrium: Market Clearing → Firms: Price Setting → Monetary Policy Regimes.**
- **Why this order:** Households/Firms/Network/Foreign-Sector lay out primitives first; Equilibrium (goods/labor/bond market clearing) closes the model; only then does Firms: Price Setting show the reduced-form vector Phillips curve ($\bm\pi_t=\rho(I-\mathcal V)\mathbb E\bm\pi_{t+1}+\mathcal B(\gamma+\varphi)\tilde y_t-\mathcal V\bm\chi_t+\Gamma\Delta e_t$), since that object is only derivable after market clearing — showing it earlier would reference $\tilde y_t$ before it's defined. Monetary Policy comes last since its Taylor rule targets objects ($DC_t$, $\tilde y_t$) defined by the Phillips curve.
- Every slide ends with a compact "where:" glossary table (scriptsize/footnotesize) so it's readable without narration — this was an explicit ask, not just a style choice.
- Key intuitive content preserved on the Firms: Price Setting slide: $\mathcal B$ and $\Gamma$ are literally the same rigidity-adjusted network operator $\tilde A=\Delta(I-\Omega^H\Delta)^{-1}$ applied to labor share $\bm\alpha$ vs. import share $\bm\omega_F$ ("same amplifier, two shocks"); $\mathcal V\mathbf 1=\mathbf 0$ so only relative (not uniform) TFP shocks generate cost-push.
- Household consumption shares $\bm\beta^H$ (Cobb-Douglas across domestic sectors within $C_t^H$) are defined once, on the Households slide, then referenced (not re-derived) on Production Network's Domar-weight formula.
- Foreign consumption $C_t^F$ is a single Armington import composite (not sector-indexed) — matches `open_economy_network_chile.mod`; this asymmetry (home disaggregated, foreign not) was confirmed against the code, not assumed.
- Domestic bond $B_t$ is included explicitly in the household budget constraint (with a note that it nets to zero in equilibrium — representative household, no domestic counterparty) rather than silently omitted.
- GDP was deliberately **not** added to the Equilibrium slide: it's a reporting identity (`GDP_t=P_t^CC_t+P_t^HEX_t-P_t^{FH}IM_t`, matches the `.mod` file's own "Reporting" comment), not a market-clearing condition, so it doesn't belong there.
- **Template swapped (2026-07-20)** to a simpler/plainer look at the user's request: default beamer frametitle (white bg, black text, `\Large\bfseries`), default Computer Modern font (dropped `fontenc`/`lmodern`/`tgheros` sans-serif), simple title-left/page-number-right footline, no colored top nav bar or green bold-text override. Kept (required, heavily used — do not remove): `booktabs`, `tikz`/`pgfplots`/`pgffor`/`\usetikzlibrary`/`\pgfplotsset{compat=1.18}` (7+ IRF plot slides), `appendixnumberbeamer` (the `\appendix` call that excludes backup from the page count), colors `sectorres`/`sectorman`/`sectorserv`/`riskred`, macros `\bpi`/`\ty`/`\tA`/`\bom`/`\shockregimelegend`, the `slide fig` pgfplots style — all used 200+ times in IRF/mechanism slides.
- Recurring gotcha when editing these slides: joining two display equations on one line with `\qquad` reliably overflows the 4:3 slide width (hit this 3 times — Households CES aggregator, Equilibrium market-clearing, Firms: Price Setting) — stack them as separate `\[...\]` blocks instead. Also avoid negative `\vspace` to fix vertical overflow — it visually overlaps text instead of freeing space; shorten the actual prose/table entries instead.

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
- Qiu, Wang, Xu & Zanetti (2026, JME) — closest paper: open-economy DC index, independently confirms DC breakdown, but static/no UIP/no FX-regime choice (see Literature check below)
- Silva (2024, Boston Fed WP 24-12 / arXiv 2410.00705) — production-network CPI pass-through, empirically applied to Chile

## Literature check (2026-07-17, full-text read) — RESOLVED, not a threat to the core claim
Full text obtained for the paper flagged earlier the same day (see `docs/QWXZ-Open-Econ-Network-JME-2026.pdf`) and read in full — the initial "urgent, could be in tension" flag from the abstract-only search was too cautious. Verdict: closely related, needs citing prominently, does **not** preempt the core contribution.
- **Qiu, Wang, Xu & Zanetti, "Monetary Policy in Open Economies with Production Networks"** (*Journal of Monetary Economics* 159 (2026), 103918; WP since Oct 2024, LSE CFM DP2025-01). Derives an open-economy DC index (three channels: CPI, expenditure-switching, profit) extending Rubbo (2023) to cross-border + IO linkages; calibrated to WIOD (43 countries × 56 sectors). Key differences from this project, all confirmed from the full text:
  - **Static model** — one period, no dynamics, no persistence. The persistence/near-unit-root-NFA mechanism this project's headline result rests on is structurally impossible in their setup.
  - **No UIP, no NFA, no debt-elastic risk premium** — the exchange rate is pinned by a static trade-balance condition only. Their own conclusion lists **"relax the assumption of financial autarky... study the interplay between incompleteness of the financial market and production networks"** as their *first, top-priority* future extension — i.e. exactly the piece this project already builds. This is the single clearest evidence the FX-regime/UIP/NFA angle is still open territory.
  - **No FX-regime choice** — money supply targets an inflation index; there is no peg vs. float vs. managed comparison anywhere in the paper.
  - **They independently reach the same qualitative DC-breakdown result**: their Section 5 states outright that "the divine coincidence... fails to hold in our multi-sector open economies," via a differently-structured model (Galí-Monacelli trade block + expenditure-switching/profit channels vs. this project's import-cost-share Γ vector). That's corroboration from an independent derivation, not competition.
  - Their WIOD 43×56 calibration is the disaggregation benchmark this project's own "next steps" item (OECD TiVA multi-sector calibration) should aim to match or explain a deliberate departure from.
  - **Action taken (2026-07-17, complete)**: added to (1) the Literature slide and the appendix "How Our Results Compare to the Literature" table in `soe_fx_presentation.tex`, (2) a full entry in `literature_survey.tex` (§"Qiu, Wang, Xu and Zanetti (2026)", right after Galí-Monacelli), and (3) an `insight` box in `rubbo_proofs_and_extension.tex`'s "Breakdown of Divine Coincidence" subsection noting the independent corroboration. All three recompile clean. Still to do for the eventual paper draft: engage their OG-weight/DC-index derivation directly in the model section prose, not just as a lit-review citation.
- **Alvaro Silva (Boston Fed), "Inflation in Disaggregated Small Open Economies"** (arXiv 2410.00705, Boston Fed WP 24-12). Production-network SOE model, applied empirically to **Chile** and UK COVID inflation via CPI-elasticity decomposition. Positive/empirical, not a policy-regime comparison — lower competitive risk. **Action taken (2026-07-17, complete)**: full entry added to `literature_survey.tex` (§"Silva (2024)", right after the QWXZ entry) as the closest empirical precedent for a Chile-calibrated network pass-through framework — noted as a cross-check candidate for the $\Gamma$ vector's Chile magnitudes, not added to the presentation slides (empirical/positive paper, lower priority for the talk itself).

## Publication-readiness assessment (2026-07-17)
Honest read on "is this ready for a top-5 journal (AER/QJE/JPE/Econometrica/ReStud)": **not yet, and "close" understates the remaining distance** — treat the July 22 presentation as a checkpoint, not a near-final draft.
- **What's genuinely strong:** the theory (DC breakdown under a second cost-push channel) is rigorously proven and builds on an already-top-5-published framework (Rubbo 2024, Econometrica); three independent real-data calibrations (Chile/Korea/Czechia) all give the same ranking; the network-isolation and second-order-welfare checks pre-empt exactly the critiques a referee would raise; the "Peg dominated via risk-premium/UIP, not terms-of-trade" result is a genuinely different mechanism than the classical Mundell-Friedman/Galí-Monacelli story reaching a similar conclusion — that's a good hook.
- **What's missing before a submission:**
  1. **No full paper draft exists.** `rubbo_proofs_and_extension.tex` is a working derivation document (codeboxes, "insight" boxes), not journal prose — a submittable paper needs a proper intro, model section, complete formal appendix, and results/discussion, which is months of writing on its own.
  2. **Sectoral resolution.** Only 3 sectors (collapsed from 12-sector national IO tables). A genuinely multi-sector calibration (OECD TiVA, or WIOD like Qiu et al. use) is likely to be requested by referees, and — see above — a competing paper has already cleared peer review using a more disaggregated cross-border IO dataset.
  3. **Calibration vs. identification.** Several parameters driving the headline result (Ψ, θ_S, KAPEX_SCALE, shock persistences, and especially the risk-premium/UIP process) are literature defaults, not estimated from data specific to this setting.
  4. **No empirical validation section** — nothing ties the model's quantitative magnitudes to observed data under an actual historical FX regime.
  5. Even a strong, complete draft typically goes through 2-3 referee rounds over 1-2+ years at these journals — that clock hasn't started.
- **Bottom line:** the necessary condition (a real, non-incremental contribution) looks met — reading the Qiu et al. paper in full (see Literature check below) actually *strengthens* this: the closest related paper explicitly flags the UIP/NFA/financial-autarky piece as its own top open extension, meaning the gap this project fills is confirmed open by the closest competing authors themselves. The sufficient condition (a complete, referee-proofed paper) is realistically 6-12+ months of further work away, starting with the multi-sector calibration and a full paper draft that engages Qiu et al.'s DC-index derivation directly.

## Preferences
- Don't ask before taking actions, just do them
- For math: write to .tex file and compile rather than showing raw LaTeX in chat
- VS Code has MiKTeX + LaTeX Workshop installed (Ctrl+Alt+B builds, Ctrl+Alt+V opens preview)
