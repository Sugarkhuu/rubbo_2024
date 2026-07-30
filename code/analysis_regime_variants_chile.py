"""
Tier 3 analysis: regime-rule variants. Reads
results/regime_variants_sweep.csv (strict inflation targeting, PHI_PI=5
PHI_Y=0 proxy for ->infinity, applied to float=strict DC-IT, cpi_it,
ppi_it, x rho in {0,1,2}) and results/dual_mandate_grid_sweep.csv
(PHI_PI x PHI_Y grid on the float/DC-IT branch at baseline rho=1).

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/analysis_regime_variants_chile.py
"""
import os
import sys
import numpy as np
import pandas as pd

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from network_exposure_decomposition import lambda_D  # noqa: E402

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS = os.path.join(REPO_ROOT, "results")


def welfare(var_y, var_pi, lam, dhat, gamma_phi, eps):
    disp_weight = lam * eps * (1 - dhat) / dhat
    return (0.5 * gamma_phi * var_y + 0.5 * (disp_weight * var_pi).sum()) * 1e4


def main():
    params_df = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params_df["name"], params_df["value"]))
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    dhat = net_obj.loc["dhat"].values
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    eps = params["EPS"]

    # --- 3A/3B/3C: strict inflation targeting, 3 targets x rho ---
    df1 = pd.read_csv(os.path.join(RESULTS, "regime_variants_sweep.csv"))
    rows = []
    for _, r in df1.iterrows():
        lam = lambda_D(r["rho"])
        var_pi = np.array([r["PI1"], r["PI2"], r["PI3"]])
        w = welfare(r["y_gap"], var_pi, lam, dhat, gamma_phi, eps)
        rows.append({"target": r["target"], "rho": r["rho"], "total": w})
    out1 = pd.DataFrame(rows)
    out1.to_csv(os.path.join(RESULTS, "regime_variants_welfare.csv"), index=False)
    piv1 = out1.pivot(index="rho", columns="target", values="total")
    print("=== Strict inflation targeting (PHI_PI=5, PHI_Y=0), welfare loss (x1e-4) ===")
    print(piv1.round(3))
    print("\n(vs. baseline Taylor-coefficient regimes, for context: Float=25.47 at rho=1,")
    print(" cpi_it=25.36, ppi_it=25.26 with PHI_PI=1.5/PHI_Y=0.5 -- see it_regimes_chile_welfare.csv)")

    # --- 3D: dual-mandate grid ---
    df2 = pd.read_csv(os.path.join(RESULTS, "dual_mandate_grid_sweep.csv"))
    rows2 = []
    lam1 = lambda_D(1.0)  # baseline rho=1
    for _, r in df2.iterrows():
        var_pi = np.array([r["PI1"], r["PI2"], r["PI3"]])
        w = welfare(r["y_gap"], var_pi, lam1, dhat, gamma_phi, eps)
        rows2.append({"phi_pi": r["phi_pi"], "phi_y": r["phi_y"], "total": w})
    out2 = pd.DataFrame(rows2)
    out2.to_csv(os.path.join(RESULTS, "dual_mandate_grid_welfare.csv"), index=False)
    piv2 = out2.pivot(index="phi_pi", columns="phi_y", values="total")
    print("\n=== Dual-mandate grid (float/DC-IT branch, rho=1), welfare loss (x1e-4) ===")
    print(piv2.round(3))
    best = out2.loc[out2["total"].idxmin()]
    print(f"\nBest in this 3x3 grid: PHI_PI={best['phi_pi']:.1f}, PHI_Y={best['phi_y']:.1f}, "
          f"loss={best['total']:.3f} (vs. baseline PHI_PI=1.5/PHI_Y=0.5 loss={piv2.loc[1.5, 0.5]:.3f})")


if __name__ == "__main__":
    main()
