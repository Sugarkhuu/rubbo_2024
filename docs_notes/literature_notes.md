# Literature Notes

See `paper_context.md` for how this fits the planned paper's Introduction section.

## Key papers to cite
- **La'O & Tahbaz-Salehi (2022, Econometrica)** — optimal MP in production networks
- **Auer, Levchenko & Sauré (2019, ReStud)** — international inflation spillovers via IO linkages
- **Pasten, Schoenle & Weber (2020, JPE)** — MP propagation in heterogeneous production economy
- **Fanelli & Straub (2021, JPE)** — theory of FX interventions
- **Gopinath & Itskhoki (2022)** — dominant currency paradigm
- **Amiti, Itskhoki & Konings (2019, QJE)** — variable markups and pass-through
- **Qiu, Wang, Xu & Zanetti (2026, JME)** — closest paper: open-economy DC index, independently
  confirms DC breakdown, but static/no UIP/no FX-regime choice (see below)
- **Silva (2024, Boston Fed WP 24-12 / arXiv 2410.00705)** — production-network CPI pass-through,
  empirically applied to Chile

## Literature check (2026-07-17, full-text read) — RESOLVED, not a threat to the core claim
Full text obtained (`docs/QWXZ-Open-Econ-Network-JME-2026.pdf`) and read in full — the initial
"urgent, could be in tension" flag from an abstract-only search was too cautious. Verdict: closely
related, needs citing prominently, does **not** preempt the core contribution.

### Qiu, Wang, Xu & Zanetti, "Monetary Policy in Open Economies with Production Networks"
*Journal of Monetary Economics* 159 (2026), 103918; WP since Oct 2024, LSE CFM DP2025-01. Derives an
open-economy DC index (three channels: CPI, expenditure-switching, profit) extending Rubbo (2023) to
cross-border + IO linkages; calibrated to WIOD (43 countries × 56 sectors).

Key differences from this project, all confirmed from the full text:
- **Static model** — one period, no dynamics, no persistence. The persistence/near-unit-root-NFA
  mechanism this project's headline result rests on is structurally impossible in their setup.
- **No UIP, no NFA, no debt-elastic risk premium** — the exchange rate is pinned by a static
  trade-balance condition only. Their own conclusion lists **"relax the assumption of financial
  autarky... study the interplay between incompleteness of the financial market and production
  networks"** as their *first, top-priority* future extension — i.e. exactly the piece this project
  already builds. This is the clearest evidence the FX-regime/UIP/NFA angle is still open territory.
- **No FX-regime choice** — money supply targets an inflation index; no peg vs. float vs. managed
  comparison anywhere in the paper.
- **They independently reach the same qualitative DC-breakdown result** — Section 5 states outright
  that "the divine coincidence... fails to hold in our multi-sector open economies," via a
  differently-structured model (Galí-Monacelli trade block + expenditure-switching/profit channels
  vs. this project's import-cost-share Γ vector). Corroboration from an independent derivation, not
  competition.
- Their WIOD 43×56 calibration is the disaggregation benchmark this project's own OECD TiVA
  multi-sector calibration (see `paper_context.md` future extensions) should aim to match or
  explain a deliberate departure from.

**Action taken (2026-07-17, complete):** added to (1) the Literature slide + appendix "How Our
Results Compare to the Literature" table in `soe_fx_presentation.tex`, (2) full entry in
`literature_survey.tex` right after Galí-Monacelli, (3) an insight box in
`rubbo_proofs_and_extension.tex`'s "Breakdown of Divine Coincidence" subsection noting the
independent corroboration. All three recompile clean.

**Still to do for the eventual paper draft:** engage their OG-weight/DC-index derivation directly in
the model section prose, not just as a lit-review citation.

### Alvaro Silva (Boston Fed), "Inflation in Disaggregated Small Open Economies"
arXiv 2410.00705, Boston Fed WP 24-12. Production-network SOE model, applied empirically to
**Chile** and UK COVID inflation via CPI-elasticity decomposition. Positive/empirical, not a
policy-regime comparison — lower competitive risk.

**Action taken (2026-07-17, complete):** full entry added to `literature_survey.tex` right after the
QWXZ entry, as the closest empirical precedent for a Chile-calibrated network pass-through
framework — noted as a cross-check candidate for the Γ vector's Chile magnitudes. Not added to the
presentation slides (empirical/positive paper, lower priority for the talk itself).
