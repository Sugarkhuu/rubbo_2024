# Small Open Economy Extension of Rubbo (2024)

Extending Rubbo (2024), "Networks, Phillips Curves, and Monetary Policy," to a
small open economy (SOE) with an exchange-rate channel, and asking whether
Rubbo's "divine coincidence" (DC) result for optimal monetary policy in
production networks survives when the exchange rate becomes a second
cost-push channel alongside productivity. Presentation deadline: **July 22,
2026**. See [CLAUDE.md](CLAUDE.md) for the full project brief (motivation,
planned paper structure, key citations, working preferences).

## Core question

In Rubbo's closed economy there is one cost-push channel (sectoral TFP), and
that is exactly what makes the DC index unique: a single price index exists
whose targeting replicates the flexible-price allocation. In the SOE, the
exchange rate is a *second* channel. The central theoretical result here
(see `rubbo_proofs_and_extension.tex`) is that the DC index generically
breaks down under a float unless FX exposure ($\Gamma$) happens to be
proportional to labor intensity ($\mathcal{B}$) — a knife-edge condition, not
a generic property of production networks. Everything downstream (the
Dynare model, the regime comparison, the structural sweeps) tests or
quantifies that breakdown.

## Repository map

### Theory
- **`rubbo_proofs_and_extension.tex`** — the core theory document. Full
  step-by-step proofs of Rubbo's results (Lemma 1: natural output =
  Domar-weighted TFP; Lemma 2: output gap = employment gap; Lemma 3: output
  gap = -sales-weighted markup; Proposition 1: DC index uniqueness;
  Proposition 2: sector-level Phillips curves via Sherman-Morrison;
  Proposition 3: welfare function; Lemma 4: Taylor-rule output-gap
  targeting), followed by the open-economy extension and the DC-breakdown
  theorem. Compile with Ctrl+Alt+B in VS Code (MiKTeX + LaTeX Workshop).
- **`literature_survey.tex`** — working notes surveying the production-network
  monetary policy literature (closed economy) and the international
  spillover / FX-intervention literature this project sits alongside (La'O
  & Tahbaz-Salehi, Auer-Levchenko-Sauré, Pasten-Schoenle-Weber, Fanelli &
  Straub, Gopinath & Itskhoki, Amiti-Itskhoki-Konings).
- **`model_equations.tex`**, **`guide_summary.tex`**, **`production_network_guide.m`** —
  supporting derivations and a from-scratch walkthrough of production
  networks, Rubbo's model, and the SOE extension (the `.m` file is a
  narrated script, not code meant to be run for output).

### Quantitative model (Dynare)
Three-sector (Resource / Manufacturing / Services) SOE DSGE with an import
sector, UIP, and the law of one price, solved under three FX regimes:

- **`open_economy_network.mod`** — free float (baseline/default).
- **`open_economy_network_peg.mod`** — hard peg.
- **`open_economy_network_managed.mod`** — managed float (Taylor rule
  responds to $\phi_\pi,\phi_y,\phi_s$, the last being the FX-stabilization
  weight).
- **`soe_ss_solve.m`** / **`soe_ss_resid.m`** — the nonlinear steady state
  collapses to a single scalar root-find in the real wage $W$ (closed-form
  prices, exports, consumption given $W$); these live outside the `.mod`
  file because Dynare's `steady_state_model` block doesn't support
  anonymous functions or struct access.

Build artifacts (`open_economy_network*/` folders, checksums, IRF graphs)
are Dynare output, regenerated on every run; most are gitignored, though a
few crashed-sweep-era build folders from `impint_1..5` remain tracked as
historical debris — leave them alone.

### `code/` — MATLAB (Dynare) + Python pipeline
- **`run_all_regimes.m`** — runs the real Dynare solution for all three
  regimes and exports IRFs, theoretical variances/moments, variance
  decompositions, and derived network objects to `results/*.csv`. This is
  the ground-truth pipeline (cross-checked against hardcoded presentation
  numbers, e.g. the -0.7799% sectoral inflation IRF).
- **`run_sweep_point.m`** — does **one** (grid_value, regime) point of a
  structural-generalization sweep and appends one row to
  `results/impint_sweep.csv` or `results/ofhet_sweep.csv`. Deliberately
  designed to run in its own fresh MATLAB process (see `drive_sweeps.sh`)
  so a Dynare/MEX crash on one point never loses previously computed rows —
  the single-session predecessor scripts crashed after 4-5 points and lost
  everything.
  - `impint` sweep: scales the whole import-cost-share vector $\Omega^F$ by
    $\kappa\in\{0.25,\dots,2.5\}$, holding its relative sectoral pattern
    fixed — tests whether results are an artifact of this economy's overall
    import dependence.
  - `ofhet` sweep: holds total import intensity fixed but varies $\theta$,
    how *unevenly* it's spread across sectors — the direct quantitative test
    of the $\Gamma\propto\mathcal{B}$ theorem (less heterogeneity should
    shrink the float/peg welfare gap).
  - `ALPHA_i` (labor share) absorbs the change so Cobb-Douglas shares still
    sum to 1.
- **`drive_sweeps.sh`** — bash driver looping over the sweep grids × regimes
  (7×3 + 7×3 = 42 points), invoking `run_sweep_point.m` in a fresh
  `matlab -wait -logfile ... -r "..."` process each time. Note: this
  machine's MATLAB (R2018a) predates the `-batch` flag (added in R2019a) and
  needs `-wait` to block until MATLAB exits and `-logfile` to capture
  output, since `matlab.exe` otherwise detaches immediately on Windows.
- **`sweep_phi_s.m`** — single-session sweep of the managed-float policy
  weight $\phi_s$ over a small grid; safe as one session since it only
  re-solves dynamics (φ_s doesn't affect the steady state).
- **`sweep_import_intensity.m`**, **`sweep_import_heterogeneity.m`** —
  superseded single-session predecessors of the `impint`/`ofhet` sweeps
  above; kept for reference, not meant to be re-run (they crash MATLAB
  partway through and lose all progress since they only write output at the
  very end).
- **`process_sweeps.py`** — post-processes `impint_sweep.csv` /
  `ofhet_sweep.csv` into total welfare loss ($\times 10^4$) by regime × grid
  point, using the *same* welfare formula as `analysis.py`'s
  `compute_welfare` (Rubbo Prop. 3: output-gap variance term +
  Domar-weighted, price-dispersion-weighted sectoral inflation-variance
  term). Reuses `results/network_objects.csv` and `results/params.csv` from
  the baseline run since those don't depend on the swept parameters. Prints
  ready-to-paste `pgfplots \addplot coordinates` for the presentation.
- **`analysis.py`** — main analysis/plotting module. Reads the CSVs
  `run_all_regimes.m` produces and builds the figures sketched in
  `OpenEconomy_Networks_FX.pptx`: cross-regime IRFs, sectoral inflation
  under a shock, the production network diagram, welfare cost decomposition,
  the DC-index insulation property, and (via `sweep_phi_s.m`'s output) the
  managed-float policy trade-off. Loads/plots only — does not pick "the"
  result to feature.
- **`model.py`** — a self-contained illustrative/exploratory model script
  (parameters, shock definitions, plotting) used during early model
  development; not part of the Dynare ground-truth pipeline.
- **`synthetic_results.py`** — generates a *synthetic* `results/` directory
  in exactly the schema `run_all_regimes.m` produces, so `analysis.py` could
  be built and tested before Dynare was available. Encodes the qualitative
  mechanisms (float lets services absorb FX shocks; peg has zero monetary
  autonomy so all shocks are poorly stabilized; sectoral inflation vol.
  scales with import centrality; welfare contribution scales with Domar
  weight × price stickiness) but is **not** solved from the nonlinear model.
  Superseded by real Dynare output — keep only as a schema reference.

### `results/`
CSV outputs from the pipeline above: IRFs (`irf_<regime>_<shock>.csv`),
`variances.csv`, `variance_decomposition.csv`, `network_objects.csv`,
`params.csv`, and the sweep outputs (`phi_s_sweep.csv`, `impint_sweep.csv`,
`ofhet_sweep.csv`, plus their `*_welfare.csv` post-processed counterparts).
All regenerated by the scripts in `code/` — safe to delete and rebuild.

### Presentation & writing
- **`soe_fx_presentation.tex`** — the working Beamer deck ("Exchange Rate
  Regimes in Production Networks"): Theory → SOE model → Results (mechanism
  shock + regime comparison) → Generalization (structural sweeps) →
  Conclusion → Next Steps → Appendix (backup IRFs). `.tex.bak` is the
  pre-restructuring backup from the last session.
- **`progress_slides.tex`** — an earlier brown-bag seminar deck.
- **`rubbo_presentation.tex`** — a presentation covering Rubbo (2024) itself
  (closed-economy baseline), separate from the SOE deck.
- **`OpenEconomy_Networks_FX.pptx`** — PowerPoint sketch of the intended
  figures/results, used as a spec for `analysis.py`.
- **`figs/`** — rendered figures (network diagram, IRFs, welfare, DC
  insulation) referenced by the presentations.
- **`docs/`** — compiled PDFs of the proofs and Rubbo presentation, kept
  alongside the source for quick reference.
- **`papers/`** — reference PDFs (e.g. Zanetti et al.).
- **`rubbo_2024.pdf`**, **`rubbo_appendix_website_2.pdf`**,
  **`rubbo_supplemental_revision.pdf`** — Rubbo's original paper, appendix
  (all proofs), and supplemental material.

### Not in this repo
`replication files/` (Rubbo's original MATLAB replication code and data) is
gitignored — large, and available separately.

## Running the pipeline

From the repo root, with MATLAB + Dynare on the path:

```matlab
addpath('C:\dynare\6.3\matlab'); addpath('code');
run_all_regimes        % baseline: float / peg / managed -> results/*.csv
sweep_phi_s             % phi_s sensitivity -> results/phi_s_sweep.csv
```

For the structural-generalization sweeps (42 fresh-process points, crash-safe):

```bash
bash code/drive_sweeps.sh
python code/process_sweeps.py   # -> results/impint_welfare.csv, ofhet_welfare.csv + pgfplots coords
```

Then `python code/analysis.py` to regenerate figures, and Ctrl+Alt+B (or
`latexmk`) to compile `soe_fx_presentation.tex` or
`rubbo_proofs_and_extension.tex`.

**Note on this machine's toolchain:** MATLAB R2018a here predates the
`-batch` CLI flag (added in R2019a) and Dynare 6.3 (not 7.0) is installed at
`C:\dynare\6.3\matlab`. Scripts/comments referencing `-batch` or Dynare 7.0
should use `-wait -logfile ... -r "..."` and the 6.3 path instead — check
`code/drive_sweeps.sh` for the working invocation pattern.
