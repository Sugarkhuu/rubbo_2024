"""
Generate a SYNTHETIC results/ directory in exactly the format that
code/run_all_regimes.m (Dynare) would produce, so that code/analysis.py
can be exercised end-to-end before the actual Dynare run exists -- and so
the numbers used in soe_fx_presentation.tex have a documented, reproducible
source rather than being one-off hand calculations.

NOT Dynare output. The magnitudes here are illustrative: they encode the
qualitative mechanisms of the model (float lets S absorb FX shocks; peg
has zero monetary autonomy so ALL shocks, not just FX ones, are poorly
stabilized; sectoral inflation volatility scales with import centrality
M_i; welfare contribution scales with Domar weight lambda_D_i times
price-stickiness) but are NOT solved from the nonlinear model. Replace
this script's output with a real run_all_regimes.m run as soon as Dynare
is available -- code/analysis.py does not need to change either way,
since it only reads the CSV schema below.

Usage:
    python code/synthetic_results.py
writes to ../results/ (same layout run_all_regimes.m uses).
"""

import os
import numpy as np
import pandas as pd

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS_DIR = os.path.join(REPO_ROOT, "results")

REGIMES = ["float", "peg", "managed"]
SHOCKS = ["eps_a1", "eps_a2", "eps_a3", "eps_pF", "eps_D"]
REPORT_VARS = ["piDC", "PIC", "y_gap", "PI1", "PI2", "PI3", "S", "I", "BSTAR", "GDP"]
HORIZON = 40

# ── Exact network objects, computed from the calibration (NOT synthetic:
#    these follow directly from OmegaH, OmegaF, betaH via the same
#    formulas as the Matlab preprocessing block in open_economy_network.mod)
OH21, OH32 = 0.20, 0.25
OF = np.array([0.30, 0.10, 0.05])
BH = np.array([0.05, 0.15, 0.80])
DELTA = np.array([0.75, 0.50, 0.25])
BETA = 0.99
EPS = 8.0

OmH = np.array([[0, 0, 0], [OH21, 0, 0], [0, OH32, 0]])
L = np.linalg.inv(np.eye(3) - OmH)
LAMBDA_D = BH @ L                      # -> [0.12, 0.35, 0.80]
M_IMPORT = L @ OF                      # -> [0.30, 0.16, 0.09]
DHAT = DELTA * (1 - BETA * (1 - DELTA)) / (1 - BETA * DELTA * (1 - DELTA))
RAW_W = LAMBDA_D * (1 - DHAT) / DHAT
W_DC = RAW_W / RAW_W.sum()             # -> [0.0053, 0.0686, 0.9261]


def ar_decay(peak: float, rho: float, horizon: int = HORIZON) -> np.ndarray:
    """Simple one-shock IRF shape: peak at t=1, geometric decay at rate rho."""
    return peak * rho ** np.arange(horizon)


# ── Regime pass-through / autonomy-loss factors (illustrative) -----------
# FX-channel pass-through fraction (applied multiplicatively to the shock's
# effect on domestic inflation/output): float lets the exchange rate absorb
# most of the shock; peg passes it through fully; managed is in between.
KAPPA_FX = {"float": 0.15, "managed": 0.55, "peg": 1.00}
# TFP-channel stabilization: float/managed run the DC-targeting Taylor
# rule; peg has NO monetary autonomy (rate is residual from UIP), so even
# purely domestic shocks are stabilized worse.
KAPPA_TFP = {"float": 1.00, "managed": 1.00, "peg": 3.00}
RHO = {"eps_a1": 0.90, "eps_a2": 0.90, "eps_a3": 0.90, "eps_pF": 0.85, "eps_D": 0.80}
IS_FX_SHOCK = {"eps_a1": False, "eps_a2": False, "eps_a3": False, "eps_pF": True, "eps_D": True}


def make_irf(regime: str, shock: str) -> pd.DataFrame:
    rho = RHO[shock]
    fx = IS_FX_SHOCK[shock]
    scale = KAPPA_FX[regime] if fx else KAPPA_TFP[regime]

    base_pi = {"eps_a1": 0.20, "eps_a2": 0.20, "eps_a3": 0.20, "eps_pF": 0.55, "eps_D": 0.10}[shock]
    df = pd.DataFrame(index=range(HORIZON), columns=REPORT_VARS, dtype=float)

    # sectoral inflation: scaled by import centrality for FX shocks, by
    # (1/lambda_D) for TFP shocks so a sector's OWN TFP shock mostly shows
    # up in its own price (illustrative asymmetry, not literal)
    for i, m in enumerate(M_IMPORT, start=1):
        weight = m / M_IMPORT.mean() if fx else (1.0 if shock == f"eps_a{i}" else 0.15)
        df[f"PI{i}"] = ar_decay(base_pi * scale * weight / 3, rho)

    df["PIC"] = ar_decay(base_pi * scale, rho)
    df["piDC"] = ar_decay(base_pi * scale * (0.02 if regime == "float" else (0.16 if regime == "managed" else 0.90)), rho)
    df["y_gap"] = ar_decay(0.10 * scale, rho)
    if regime == "peg":
        df["S"] = 0.0
    else:
        s_peak = {"float": 0.90, "managed": 0.45}[regime] * (1.0 if fx else 0.3)
        df["S"] = ar_decay(s_peak, rho)
    df["I"] = ar_decay(0.05 * scale, rho)
    df["BSTAR"] = ar_decay(0.15 * (1.0 if shock == "eps_D" else 0.4) * (1.1 if regime == "float" else (1.0 if regime == "managed" else 0.7)), rho)
    df["GDP"] = ar_decay(0.10 * scale, rho)
    return df


def welfare_by_regime() -> pd.DataFrame:
    """Order-2-style unconditional variances, back-solved so that
    compute_welfare() in analysis.py reproduces the illustrative totals
    used in soe_fx_presentation.tex (Float=18, Managed=22, Peg=64,
    relative units) with the same output-gap / price-dispersion split."""
    gamma_phi = 3.0  # GAMMA + VARPHI = 1.00 + 2.00
    disp_weight = LAMBDA_D * EPS * (1 - DHAT) / DHAT  # [0.43, 5.53, 74.6]

    targets = {
        "float":   {"y_gap": 6.0,  "pi": [0.5, 2.0, 9.5]},
        "managed": {"y_gap": 7.0,  "pi": [0.6, 2.4, 12.0]},
        "peg":     {"y_gap": 14.0, "pi": [3.0, 9.0, 38.0]},
    }
    rows = {}
    for regime, tgt in targets.items():
        var_y = tgt["y_gap"] / (0.5 * gamma_phi)
        var_pi = np.array(tgt["pi"]) / (0.5 * disp_weight)
        rows[regime] = {"y_gap": var_y, "PI1": var_pi[0], "PI2": var_pi[1], "PI3": var_pi[2]}
    return pd.DataFrame(rows).T


def main():
    os.makedirs(RESULTS_DIR, exist_ok=True)

    for regime in REGIMES:
        for shock in SHOCKS:
            df = make_irf(regime, shock)
            df.to_csv(os.path.join(RESULTS_DIR, f"irf_{regime}_{shock}.csv"), index=False)

    net_obj = pd.DataFrame(
        {"sector1": [LAMBDA_D[0], M_IMPORT[0], DHAT[0], W_DC[0]],
         "sector2": [LAMBDA_D[1], M_IMPORT[1], DHAT[1], W_DC[1]],
         "sector3": [LAMBDA_D[2], M_IMPORT[2], DHAT[2], W_DC[2]]},
        index=["lambda_D", "import_centrality", "dhat", "w_dc"])
    net_obj.index.name = "object"
    net_obj.to_csv(os.path.join(RESULTS_DIR, "network_objects.csv"))

    var_df = welfare_by_regime()
    var_df.index.name = "regime"
    for col in ["piDC", "S", "I", "BSTAR", "GDP"]:
        var_df[col] = np.nan  # not needed for compute_welfare(), left blank
    var_df = var_df[REPORT_VARS]
    var_df.to_csv(os.path.join(RESULTS_DIR, "variances.csv"))

    params = pd.DataFrame({"name": ["BETA", "GAMMA", "VARPHI", "EPS"],
                            "value": [BETA, 1.00, 2.00, EPS]})
    params.to_csv(os.path.join(RESULTS_DIR, "params.csv"), index=False)

    print(f"Wrote synthetic results to {RESULTS_DIR}")
    print(f"  lambda_D = {np.round(LAMBDA_D, 3)}")
    print(f"  M_import = {np.round(M_IMPORT, 3)}")
    print(f"  dhat     = {np.round(DHAT, 3)}")
    print(f"  w_DC     = {np.round(W_DC, 4)}")
    print("Run code/analysis.py next to build the figures from these files.")


if __name__ == "__main__":
    main()
