"""
Corrected version of analysis_netdens_chile.py's welfare computation.

The original script (results/netdens_chile_welfare.csv, feeding
figs/isolating_network.pdf) used lambda_D and dhat read from
results_chile/network_objects.csv -- i.e. the rho=1 (baseline) values --
for EVERY rho in the sweep. dhat is genuinely rho-invariant (it only
depends on Calvo DELTA_i and BETA), but lambda_D_i = BH' (I-Omega^H)^-1
is NOT: it's a function of the very domestic IO matrix rho is scaling.
At rho=0 the true lambda_D collapses toward BH itself (no network
amplification of Domar weights); using the rho=1 lambda_D at rho=0
overstates how "network-free" the rho=0 counterfactual really is.

This script re-does compute_welfare() with lambda_D(rho) from
code/network_exposure_decomposition.py's closed form (same formula
Dynare itself uses internally, LAMBDA_D_i in the .mod files), holding
dhat fixed (correctly rho-invariant). Reuses
results/netdens_chile_sweep.csv (variances), no new Dynare runs needed.

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/analysis_netdens_chile_v2.py
"""
import os
import sys
import pandas as pd
import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from network_exposure_decomposition import lambda_D  # noqa: E402

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS = os.path.join(REPO_ROOT, "results")


def main():
    df = pd.read_csv(os.path.join(RESULTS, "netdens_chile_sweep.csv"))
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    params_df = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params_df["name"], params_df["value"]))
    dhat = net_obj.loc["dhat"].values  # rho-invariant (Calvo-only)
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    eps = params["EPS"]

    rows = []
    for _, r in df.iterrows():
        rho = r["rho"]
        lam = lambda_D(rho)
        disp_weight = lam * eps * (1 - dhat) / dhat
        var_y = r["y_gap"]
        var_pi = np.array([r["PI1"], r["PI2"], r["PI3"]])
        w_output = 0.5 * gamma_phi * var_y
        w_pi = 0.5 * disp_weight * var_pi
        rows.append({"rho": rho, "regime": r["regime"], "output_gap": w_output,
                     "price_disp_sector1": w_pi[0], "price_disp_sector2": w_pi[1],
                     "price_disp_sector3": w_pi[2], "price_disp_total": w_pi.sum(),
                     "total": w_output + w_pi.sum()})
    out = pd.DataFrame(rows).sort_values(["regime", "rho"])
    out.to_csv(os.path.join(RESULTS, "netdens_chile_welfare_v2.csv"), index=False)

    piv = out.pivot(index="rho", columns="regime", values="total") * 1e4
    print("=== Corrected total welfare loss (x1e-4), lambda_D(rho) ===")
    print(piv.round(3))

    old = pd.read_csv(os.path.join(RESULTS, "netdens_chile_welfare.csv"))
    old_piv = old.pivot(index="rho", columns="regime", values="total")  # already x1e4-scaled when saved
    print("\n=== Old (fixed lambda_D=rho1) total welfare loss (x1e-4), for comparison ===")
    print(old_piv.round(3))
    print("\n=== Difference (corrected - old), pct ===")
    print(((piv - old_piv) / old_piv * 100).round(2))


if __name__ == "__main__":
    main()
