# Calibration

See `model_equations.md` for the objects being calibrated and `results_summary.md` for what the
calibrated model produces.

## Data source and construction
- `data_calibration/build_chile_calibration.py` builds the Chile IO calibration from Banco Central
  de Chile CdeR (Cuadro de Origen y Recursos) tables — 12-sector national IO table collapsed to 3
  (Resource / Manufacturing / Services). Also has Korea and Czechia variants.
- `export_share` (export intensity by sector: Resource 0.602 / Manufacturing 0.180 / Services 0.036)
  is already computed there but currently **unused** in any `.mod` file — see the sector-specific
  export channel item in `paper_context.md`.

## Three real calibrations, one stylized network
- **Chile, Korea, Czechia** — three real national IO calibrations, discrete data points, headline
  numbers.
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
