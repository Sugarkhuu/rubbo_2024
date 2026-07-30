# Paper Context

## What this project is
Extending Rubbo (2024), "Networks, Phillips Curves, and Monetary Policy," to a small open economy
(SOE) with an exchange-rate channel, asking whether Rubbo's "divine coincidence" (DC) result for
optimal monetary policy in production networks survives when the exchange rate becomes a *second*
cost-push channel alongside productivity.

Presentation given **July 22, 2026**. Work is now in the **post-presentation revision** phase,
responding to feedback from Christian, Benny, and Adam (`speech_feedback_20260722.txt`). See
`results_summary.md` for what that revision produced.

## Core theoretical contribution
In Rubbo, the DC index is unique because there is one cost-push channel (productivity). In the SOE,
there are two channels (productivity + exchange rate). The central result is whether a modified DC
index exists under flexible ER, or whether the inflation-output tradeoff is irreducible. Answer:
generically breaks down under float unless FX exposure (Γ) happens to be proportional to labor
intensity (B) — a knife-edge condition, not a generic property of production networks. See
`model_equations.md` for the formal statement.

## Planned paper structure
1. Introduction — position vs Rubbo and La'O & Tahbaz-Salehi (2022, Econometrica)
2. SOE model — N domestic sectors + import sector, UIP, law of one price
3. Phillips curve with ER — Γ·Δe term, network amplification of pass-through
4. Divine coincidence in open economy — breaks down under float (two cost-push channels)
5. Welfare and optimal FX policy — float vs peg vs managed float
6. Quantitative — done for the presentation with 3-sector real IO calibrations (Chile, Korea,
   Czechia); a genuinely many-sector OECD TiVA calibration is the natural next step, not yet built

## Publication-readiness assessment (2026-07-17)
Honest read on "is this ready for a top-5 journal (AER/QJE/JPE/Econometrica/ReStud)": **not yet,
and "close" understates the remaining distance** — treat the July 22 presentation as a checkpoint,
not a near-final draft.

**What's genuinely strong:**
- Theory (DC breakdown under a second cost-push channel) rigorously proven, builds on an
  already-top-5-published framework (Rubbo 2024, Econometrica).
- Three independent real-data calibrations (Chile/Korea/Czechia) all give the same ranking.
- Network-isolation and second-order-welfare checks pre-empt exactly the critiques a referee would
  raise.
- "Peg dominated via risk-premium/UIP, not terms-of-trade" is a genuinely different mechanism than
  the classical Mundell-Friedman/Galí-Monacelli story reaching a similar conclusion — a good hook.

**What's missing before a submission:**
1. **No full paper draft exists.** `rubbo_proofs_and_extension.tex` is a working derivation
   document, not journal prose — proper intro/model/appendix/results is months of writing on its
   own.
2. **Sectoral resolution.** Only 3 sectors (collapsed from 12-sector national IO tables). A
   genuinely multi-sector calibration (OECD TiVA, or WIOD like Qiu et al. use) is likely to be
   requested by referees — a competing paper has already cleared peer review using a more
   disaggregated cross-border IO dataset.
3. **Calibration vs. identification.** Several parameters driving the headline result (Ψ, θ_S,
   KAPEX_SCALE, shock persistences, especially the risk-premium/UIP process) are literature
   defaults, not estimated from data specific to this setting.
4. **No empirical validation section** — nothing ties the model's quantitative magnitudes to
   observed data under an actual historical FX regime.
5. Even a strong, complete draft typically goes through 2-3 referee rounds over 1-2+ years at these
   journals — that clock hasn't started.

**Bottom line:** the necessary condition (a real, non-incremental contribution) looks met — the
closest related paper (Qiu, Wang, Xu & Zanetti 2026) explicitly flags the UIP/NFA/financial-autarky
piece as its own top open extension, meaning the gap this project fills is confirmed open by the
closest competing authors themselves. The sufficient condition (a complete, referee-proofed paper)
is realistically 6-12+ months of further work away, starting with the multi-sector calibration and
a full paper draft that engages Qiu et al.'s DC-index derivation directly.

## Future extensions (not urgent, do not build unless asked)
- ~~Sector-specific export channel~~ — **DONE (full version), 2026-07-21/23.** See
  `results_summary.md`'s "Task #2" writeup.
- ~~Cross-sector markup-dispersion welfare term~~ — **DONE 2026-07-23.** See `results_summary.md`.
- ~~ψ-sensitivity sweep for the risk-premium/UIP dominance result~~ — **DONE 2026-07-21/23.** See
  `results_summary.md`'s "Task #3" writeup — ranking robust, margin is not (Peg/Float ratio
  5.4×→2.7× across the ψ grid).
- ~~Network vs. no-network on the real Chile calibration~~ — **DONE 2026-07-21/23** (was previously
  only tested on the stylized triangular-network proxy). See `results_summary.md`'s "Task #1"
  writeup.
- **Fold the three write-ups above into `soe_fx_presentation.tex`/`speech_notes.md`.** Numbers exist
  and are sanity-checked (see `results_summary.md`); `todo_three_exercises.txt` explicitly deferred
  slide edits until that point. Not done yet — next natural step if a deck update is wanted.

## Key files
- `rubbo_2024.pdf` — main paper (Rubbo 2024)
- `appendix_website_2.pdf` — appendix with all proofs
- `supplemental_revision.pdf` — supplemental material
- `rubbo_proofs_and_extension.tex` — step-by-step proofs of all Rubbo results + open economy
  extension (Ctrl+Alt+B to compile)
- `soe_fx_presentation.tex` — the presentation deck, primary deliverable
- `speech_notes.md` — full talk script + anticipated Q&A, kept in sync with the deck
- `data_calibration/build_chile_calibration.py` — Chile IO calibration (also Korea/Czechia)
- `replication files/` — Rubbo's Matlab replication code (gitignored, **not present locally**,
  confirmed 2026-07-23)
- `speech_feedback_20260722.txt` — raw feedback from Christian/Benny/Adam, source of
  `results_summary.md`'s post-presentation section
