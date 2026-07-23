# Slides Outline

Deck: `soe_fx_presentation.tex` ("Exchange Rate Regimes in Production Networks"). 30 main-counted
slides + appendix backup, 44 physical pages, 4:3, single-column except the 7 IRF slides. Talk script
+ Q&A in `speech_notes.md`, kept in sync slide-by-slide. See `decisions.md` for why the order below
was chosen and what was deliberately *not* reordered.

## High-level flow
Theory → SOE Model → Results (mechanism shock + regime comparison) → Generalization (structural
sweeps) → Conclusion → Next Steps → Appendix (backup IRFs).

## Model section (rebuilt 2026-07-20 — see `decisions.md`)
In order, all between the `%% my slides` markers, right after `\section{Model}`:
1. Model Components (roadmap)
2. Households
3. Firms: Technology
4. Production Network
5. Foreign Sector
6. Equilibrium: Market Clearing
7. Firms: Price Setting — the reduced-form vector Phillips curve (see `model_equations.md`)
8. Monetary Policy Regimes

Every slide ends with a compact "where:" glossary table.

## Results section (first slide added post-revision)
0. **"Reading the Robustness Slides: What Varies, What's Fixed"** (Adam's clarity ask) — single
   source of truth for what's held fixed across every sweep slide that follows.
1. Welfare Ranking (headline numbers — see `results_summary.md`), units footnote (Adam)
2. What Drives Each Regime's Loss? (methodology footnote, Adam)
3. Shock Decomposition

## Post-presentation revision slides (8 new, added 2026-07-22/23)
Full content and findings behind each of these are in `results_summary.md`; this list is just the
deck placement / titles.
1. **Why Services? Direct vs. Indirect Import Exposure** (Christian)
2. **Which Channel Actually Drives Services' Exposure?** (Christian)
3. **Does the Optimal Managed-Float Response Depend on the Network?** (Christian)
4. **Persistence, Not Just Size: Why UIP Losses Are So Large** (Christian)
5. **Counting the Cross-Sector Term (Rubbo Prop. 3)** (Christian)
6. **How Much Does Peg's Loss Depend on the Risk-Premium Shock?** (Adam)
7. **Robustness: Is Indirect Exposure a General Pattern?** (Adam)
8. (Adam's clarity asks folded into footnotes on existing slides, not standalone — see above)

## Literature
Consolidated to **one slide** (network side / open-economy side / gap), paper-by-paper comparison
table pushed to appendix backup — includes the closest competing paper (Qiu, Wang, Xu & Zanetti
2026, see `literature_notes.md`).

## Appendix (backup, excluded from page count via `appendixnumberbeamer`)
- IRF slides (7, the only multi-column ones)
- Knife-edge DC-index test
- Literature comparison table (paper-by-paper)
- Second-order welfare check slide

## Known open item — not yet acted on
Benny's flow-reorder suggestion (mechanics/shocks before welfare) — flagged in `speech_notes.md` as a
candidate for the *next* revision, not this one. See `decisions.md` for why it was deferred.

## Style constraints to respect when editing (see `decisions.md` for the "why")
- Default beamer frametitle, default Computer Modern font, plain footline — no colored nav bar.
- Never join two display equations with `\qquad` on one line (4:3 width overflow, hit 3 times).
- Never use negative `\vspace` to fix vertical overflow — shorten prose/table entries instead.
- Do not remove: booktabs; tikz/pgfplots/pgffor/`\usetikzlibrary`/`\pgfplotsset{compat=1.18}`;
  `appendixnumberbeamer`; colors sectorres/sectorman/sectorserv/riskred; macros
  `\bpi`/`\ty`/`\tA`/`\bom`/`\shockregimelegend`; the `slide fig` pgfplots style.
