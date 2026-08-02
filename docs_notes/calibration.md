# Calibration

See `model_equations.md` for the objects being calibrated and `results_summary.md` for what the
calibrated model produces.

## Full-resolution calibration (2026-07-31) — NEW HEADLINE
The model now runs at each country's FULL native IO resolution (Chile N=12, Korea N=33, Czechia
N≈81) instead of the collapsed 3-macro-sector version, per project decision (see
`results_summary.md`'s "Full-native-resolution calibration campaign" section for the numbers and
findings). The 3-sector calibration/pipeline described below is retained as-is (files not deleted,
still fully functional) and reframed as a superseded/stylized precursor / lower-N robustness check.

**Pipeline (new files):**
1. `data_calibration/full_calibration_common.py` — shared numpy logic: given a raw NxN Ω^H and
   N-vectors Ω^F/β^H/export_share plus a raw-sector→{Resource,Manufacturing,Services} category map
   (used ONLY to assign each raw sector its category's literature Calvo δ_i — everything else is
   genuine full-resolution IO data), computes δ_i/δ̂_i/λ_D,i (Domar)/M_i (import centrality)/w_DC,i,
   same formulas as the 3-sector `main()` in each build script, just at full N via
   `numpy.linalg.inv`.
2. Each `build_{chile,korea,czechia}_calibration.py` gained a `build_full()` function: identical
   data-reading code to the existing `main()`, but skips the `CONCORDANCE`-based aggregation step
   entirely and calls `compute_full_calibration()` on the raw N-resolution matrices. Writes
   `{country}_calibration_full_results.json`. Czechia's `build_full()` also drops 8 leaf CPA codes
   with zero/undefined gross output in the 2022 CZ table (`CPA_E37/E38/E39/G47/L68A/T97/T98/U`),
   landing at N=81 of the nominal ~89 leaf codes in `LEAF_CODES`.
3. `data_calibration/generate_mod.py` — ordinary Python string-templating generator (loops +
   f-strings, explicitly NOT Dynare's `@#for` macro language, per the architectural decision that
   loops in Python are far more debuggable at N=33/81 equation counts than Dynare macros) that reads
   a `*_calibration_full_results.json` and emits a complete `oen_full_{country}_{regime}.mod` file:
   sector-indexed variables/parameters/shocks for i=1..N, dense NxN Cobb-Douglas cost/market-
   clearing equations, the same Calvo/Euler/UIP/policy-rule block structure as
   `open_economy_network_chile.mod` reindexed to N, and LAMBDA_D_i/WDC_i/DHAT_i inserted as plain
   calibrated PARAMETER CONSTANTS (computed in Python, per the "avoid hand-unrolling matrix algebra
   in Dynare" decision — infeasible at N>3 via the old cofactor/adjugate approach).
4. `soe_ss_solve_dense_N.m` / `soe_ss_resid_dense_N.m` — N-sector generalization of
   `soe_ss_solve_dense.m` / `soe_ss_resid_dense.m` (kept unchanged for the 3-sector `.mod` files).
   Same ordinary-MATLAB-matrix-algebra strategy (backslash solves), just NxN/N-vector instead of
   3x3/3-vector.

**Two Dynare `steady_state_model` restrictions discovered empirically while building the
generator (neither documented anywhere, both confirmed via preprocessor errors, not assumed):**
- Bracket matrix/vector literals (`[a;b;c]`, `[a b; c d]`) are **not** accepted as function-call
  arguments inside `steady_state_model` (`syntax error, unexpected '['`) — so
  `soe_ss_solve_dense_N.m` takes a FLAT scalar argument list (`varargin`) instead of a matrix/vector,
  reconstructed inside the `.m` file via ordinary loops.
- A locally-named multi-element array returned from a function (e.g. `SSPv` then indexed
  `SSPv(1)`) is rejected too (`Symbol SSPv cannot take arguments`) — only declared model
  variables/parameters may appear in `steady_state_model`. Fix: `soe_ss_solve_dense_N.m` returns
  `varargout` unpacked directly into `P1,...,PN,MC1,...,MCN,Y1,...,YN,L1,...,LN` (N-generic version
  of the existing `P1,P2,P3`/`MC1,MC2,MC3`/... pattern), assembled by `generate_mod.py`.

**A third issue, not a bug but worth flagging for any future full-resolution work:** at N=33/81,
Dynare's ANALYTIC (`periods=0`) unconditional-moment formulas return `NaN` for `piDC`/`PIC`/`y_gap`/
`I` even though `check`/BK conditions pass cleanly — one generalized eigenvalue lands numerically
almost exactly on the unit circle. `generate_mod.py` works around this by requesting SIMULATED
moments (`periods=20000`, fixed `set_dynare_seed`) instead, mirroring what `order2/run_order1sim.m`
already does elsewhere in this project for the identical class of problem at order=2. Welfare is
computed by `code/run_full_regime_welfare.m` from the resulting `oo_.var` diagonal, using the exact
same formula as `code/analysis.py`'s `compute_welfare()`.

**Chile (N=12): UNBLOCKED 2026-08-02.** The user supplied `mip_12x12.xlsx`/`cou_12x12.xlsx`
directly (manual download, bypassing the Incapsula bot-protection that blocked automated retrieval
the prior session). These turned out to be a **2008-vintage** CdeR table (base year 2008), not the
"2023 vintage" the original docstring assumed sight-unseen — a completely different sheet layout:
35 numbered sheets across four price-basis blocks (user/producer/basic prices + production/
investment matrices) instead of 25 sheets, product/activity codes stored as strings not ints, zero
cells as empty strings not `None`, a 13th residual PRODUCT row in the use matrices (a margins/taxes
wedge with no matching activity column — dropped, not attributable to any of the 12 real sectors),
and the final-use sheet's column headers spanning 2-3 physical rows. `build_chile_calibration.py`
was rewritten (sheet numbers 7/27/28/30 in the basic-prices block, `_cell_num`/`_cell_code` helper
coercions, header-anchored rather than fixed-offset parsing for the final-use sheet) rather than
force-fitting the old assumptions — see the module's updated docstring for the full sheet map. The
12-activity classification itself also differs slightly from the old placeholder (Pesca is its own
activity, not merged into Agropecuario; Servicios de vivienda is its own activity) — `SECTOR_NAMES`/
`CONCORDANCE` updated to match. Sanity check passed: `alpha + row-sum(Ω^H) + Ω^F = 1.000000` exactly
for all 12 sectors after renormalization, and the resulting shares (Ω^F 0.08–0.21, β^H highly
Services-concentrated, export share Resource 0.60/Manuf 0.19/Services 0.07) are in the same range as
the old placeholder numbers. `generate_mod.py` + `run_full_regime_welfare.m` then ran all three
regimes with no steady-state issues — see `results_summary.md` for the numbers, which **resolve**
the open question from the 2026-07-31 campaign (see below).

## Data source and construction (3-sector version, superseded as headline, still functional)
- `data_calibration/build_chile_calibration.py` builds the Chile IO calibration from Banco Central
  de Chile CdeR (Cuadro de Origen y Recursos) tables — 12-sector national IO table collapsed to 3
  (Resource / Manufacturing / Services). Also has Korea and Czechia variants.
- `export_share` (export intensity by sector: Resource 0.602 / Manufacturing 0.180 / Services 0.036)
  is already computed there but currently **unused** in any `.mod` file — see the sector-specific
  export channel item in `paper_context.md`.

## Three real calibrations, one stylized network
- **Chile, Korea, Czechia** — three real national IO calibrations, discrete data points, headline
  numbers (now superseded by the full-resolution versions above where available).
- **Stylized triangular network** — a separate network built with a scalar density dial ρ, used for
  the continuous sweeps (φ_s, import intensity, exposure concentration, network density) since the
  three real calibrations can't be swept continuously. Slides label which numbers come from which
  network to avoid confusion.

## Key parameters
- **PSI (ψ = 0.020)** — debt-elastic risk-premium closing device (Schmitt-Grohé–Uribe 2003),
  `open_economy_network_chile.mod:158`. Literature default, not swept yet — see
  `paper_context.md` future extensions.
- **σ_RP** — risk-premium shock standard deviation, calibrated equal to every other shock's 1% s.d.
  (not tuned). Literature-consistent (Broda 2004; Edwards-Levy-Yeyati 2005; Céspedes-Chang-Velasco
  2004), but the *margin* of the headline Peg-dominance result is highly sensitive to this specific
  value — see risk-premium volatility sweep in `results_summary.md`.
- **KAPEX_SCALE, θ_S** — literature defaults, not estimated from data specific to this setting
  (flagged in `paper_context.md`'s publication-readiness assessment).
- **φ_π, φ_y, φ_s** — Taylor rule coefficients under managed float; φ_s is the FX-stabilization
  weight, its optimum shifts with network density (see `results_summary.md`).

## Toolchain
- **MATLAB** at `C:\Program Files\MATLAB\R2018a\bin\matlab.exe` — R2018a, predates the `-batch` CLI
  flag (added R2019a). Use `-wait -logfile <log> -r "..."` instead.
- **Dynare 6.3** at `C:\dynare\6.3\matlab` — `addpath` it, then `addpath('code')`, before calling any
  sweep function.
- **Python** at `C:\Users\sugarkhuu\anaconda3` — not on PATH for Bash (`python`/`python3`/`py`
  resolve to non-functional Windows Store stubs). Invoke directly:
  `"/c/Users/sugarkhuu/anaconda3/python.exe" script.py`. Has matplotlib/PIL.
- Typical invocation from Bash:
  ```bash
  "/c/Program Files/MATLAB/R2018a/bin/matlab.exe" -wait -nosplash -logfile <log> -r \
    "try; addpath('C:\dynare\6.3\matlab'); addpath('code'); <call>; catch e; disp(getReport(e)); end; exit"
  ```
- One Dynare solve (Chile calibration, order=1) takes ~20-30s wall time including MATLAB startup.

## Sweep script pattern (load-bearing — see `decisions.md` for the crash history)
Write sweep `.m` files as a **function taking one grid point**, called **once per fresh MATLAB
process** from a bash driver script (`for ... do matlab -wait ... ; done`), each appending one row
to a results CSV. Never loop many `dynare` calls inside one MATLAB session — unclosed IRF figure
handles from `graph_format=pdf` crash MATLAB's graphics subsystem after ~15-18 calls. Regex-strip
`graph_format=pdf`→`nograph` in any sweep `.mod` file — sweeps only need `oo_.var`.

Launching a long MATLAB run via Bash: use `run_in_background: true` on the Bash call itself; do
**not** additionally append `&`/`nohup` inside the command string (double-backgrounds it, loses
completion tracking).

## Sweeps run so far
| Sweep | Script | Grid | Purpose |
|---|---|---|---|
| Network density (ρ) | `sweep_netdens_chile.m` | — | isolates the network channel vs. "just open economy" |
| φ_s × network density | `sweep_phi_s_netdens_chile.m` | 12 φ_s × ρ∈{0,1,2} | does the optimal managed-float weight shift with the network? |
| RP persistence × network density | `sweep_rp_persistence_netdens_chile.m` | ρ_RP∈{0,.40,.80,.95} × ρ∈{0,1} × 3 regimes | convexity of welfare loss in shock persistence |
| Risk-premium volatility | `sweep_risk_premium_chile.m` | scales sd(ε^RP) | how much does Peg's dominance depend on σ_RP |
| ψ sensitivity | `sweep_psi_point.m` | 0.25×–4× baseline | robustness of risk-premium dominance to the NFA-feedback elasticity — **done**, see `results_summary.md` |
| Network vs. no-network, real Chile calib. | `run_nonetwork_chile.m` | — | Task #1 of `todo_three_exercises.txt` — **done**, see `results_summary.md` |
| Sector-specific export reallocation | `calibrate_kapex_chile.m` + `_exp.mod` variants | θ_X, ζ | Task #2 (full version) — **done**, see `results_summary.md` |
| ψ × network density | `sweep_psi_netdens_chile.m` | 5 ψ × ρ∈{0,1,2} | Tier 1A — **done**, ψ-sensitivity independent of density |
| Rigidity × network density (uniform) | `sweep_rigidity_netdens_chile.m` | κ∈{0.5,0.75,1.0,1.15} × ρ∈{0,1,2} | Tier 1B — **done**, κ=1.15 is a stress test (near Calvo floor) |
| Rigidity × network density (Services-only) | `sweep_services_rigidity_chile.m` | DELTA3∈{0.05..0.60} × ρ∈{0,1,2} | Tier 1B — **done**, Peg monotonic, Float/Managed hump-shaped |
| ψ × σ_RP joint (Peg only) | `sweep_psi_sigmarp_joint_chile.m` | 3×3 scale grid | Tier 1C — **done**, genuine (if modest) interaction |
| Network topology (hub-spoke, chain) | `sweep_topology_chile.m` + `network_topologies.py` | 3 topologies × regime/φ_s | Tier 2 — **done**, ranking survives, φ_s* shifts |
| Regime-rule variants (strict IT, dual mandate) | `sweep_regime_variants_chile.m` | PHI_PI/PHI_Y grid | Tier 3 — **done**, see `results_summary.md` caveats |

## Second-order welfare check (2026-07-17, done)
Re-solved the Chile calibration to a genuine order-2 pruned perturbation (Dynare, Kim-Kim-Schaumburg
pruning, simulated 260k periods — the Taylor rule leaves price levels/S with a unit root that breaks
Dynare's analytic order-2 moments), welfare recomputed from E[X²] directly, not Var(X). See
`order2/` for the reproducible pipeline (`run_order2.m`, `run_order1sim.m`,
`results_order2/*.csv`). Result summarized in `results_summary.md`.
