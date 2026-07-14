"""
Post-process the two structural-generalization sweeps
(sweep_import_intensity.m -> results/import_intensity_sweep.csv,
 sweep_import_heterogeneity.m -> results/import_heterogeneity_sweep.csv)
into total welfare loss by regime x grid point, using the SAME formula as
code/analysis.py's compute_welfare (Rubbo Prop. 3). Network objects
(lambda_D, dhat) are unaffected by OF/ALPHA changes (they depend only on
OH21, OH32, BH_i, DELTA_i), so results/network_objects.csv and
results/params.csv from the baseline run apply unchanged to every grid
point in both sweeps.

Writes results/import_intensity_welfare.csv and
results/import_heterogeneity_welfare.csv (grid_value, regime, total),
and prints pgfplots \\addplot coordinate strings for direct use in
soe_fx_presentation.tex.
"""

import os
import pandas as pd

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS_DIR = os.path.join(REPO_ROOT, "results")

REGIME_COLORS_TEX = {"float": "customgreen!85!black", "peg": "gray!45, densely dotted", "managed": "gray!60!black, dashed"}


def load_network_and_params():
    net_obj = pd.read_csv(os.path.join(RESULTS_DIR, "network_objects.csv"), index_col="object")
    params = pd.read_csv(os.path.join(RESULTS_DIR, "params.csv"))
    params = dict(zip(params["name"], params["value"]))
    return net_obj, params


def welfare_total(row, net_obj, params):
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    lam = net_obj.loc["lambda_D"].values
    dhat = net_obj.loc["dhat"].values
    eps = params["EPS"]
    disp_weight = lam * eps * (1 - dhat) / dhat
    var_y = row["y_gap"]
    var_pi = row[["PI1", "PI2", "PI3"]].values.astype(float)
    w_output = 0.5 * gamma_phi * var_y
    w_pi = 0.5 * (disp_weight * var_pi).sum()
    return w_output + w_pi


def process(sweep_csv, grid_col, out_csv):
    path = os.path.join(RESULTS_DIR, sweep_csv)
    if not os.path.exists(path):
        print(f"Missing {path}, skipping.")
        return None
    df = pd.read_csv(path)
    net_obj, params = load_network_and_params()
    df["welfare_total_x1e4"] = df.apply(lambda r: 1e4 * welfare_total(r, net_obj, params), axis=1)
    out = df[[grid_col, "regime", "welfare_total_x1e4"]]
    out.to_csv(os.path.join(RESULTS_DIR, out_csv), index=False)
    print(f"\n=== {out_csv} ===")
    print(out.pivot(index=grid_col, columns="regime", values="welfare_total_x1e4"))

    print(f"\npgfplots coordinates ({sweep_csv}):")
    for regime in ["peg", "managed", "float"]:
        sub = out[out["regime"] == regime].sort_values(grid_col)
        coords = " ".join(f"({r[grid_col]:.2f},{r['welfare_total_x1e4']:.4f})" for _, r in sub.iterrows())
        print(f"% {regime}\n\\addplot[thick, {REGIME_COLORS_TEX[regime]}] coordinates {{{coords}}};")
    return out


if __name__ == "__main__":
    process("import_intensity_sweep.csv", "kappa", "import_intensity_welfare.csv")
    process("import_heterogeneity_sweep.csv", "theta", "import_heterogeneity_welfare.csv")
