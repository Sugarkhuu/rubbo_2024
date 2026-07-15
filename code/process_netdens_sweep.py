"""
Post-process the network-density sweep (code/run_sweep_point.m,
sweep_type='netdens', driven by code/drive_netdens_sweep.sh) ->
results/netdens_sweep.csv.

This sweep scales the DOMESTIC input-output linkages OH21, OH32 by a
factor rho, holding import exposure OF and stickiness DELTA fixed:
    rho = 0    -> no domestic production network (each sector buys only
                  labor + imports directly; the counterfactual "how much
                  welfare cost is due to the network" benchmark)
    rho = 1    -> baseline calibration (matches results/network_objects.csv)
    rho > 1    -> denser/more vertically-integrated network than baseline

Unlike the import-intensity (impint) and import-heterogeneity (ofhet)
sweeps, lambda_D changes with rho (it is a function of OH21, OH32), so it
is recomputed analytically here from BH_i, OH21(rho), OH32(rho) -- the
same closed-form used in open_economy_network.mod (LAMBDA_D1/2/3) --
rather than read from the (rho=1-only) network_objects.csv. dhat is a
function of DELTA_i, BETA only, so it is unaffected by rho and is reused
from network_objects.csv.

Writes results/netdens_welfare.csv (rho, regime, output_gap,
price_disp_sector1/2/3, price_disp_total, total) and prints the "network
welfare premium" = total(rho=1) - total(rho=0) by regime, i.e. how much
of each regime's welfare loss is attributable to the production network
existing at all, plus pgfplots \\addplot coordinate strings for direct use
in soe_fx_presentation.tex.
"""

import os
import pandas as pd

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS_DIR = os.path.join(REPO_ROOT, "results")

BH = {"sector1": 0.05, "sector2": 0.15, "sector3": 0.80}   # BH1, BH2, BH3 (fixed)
OH21_BASE = 0.20
OH32_BASE = 0.25

REGIME_COLORS_TEX = {"float": "customgreen!85!black", "peg": "gray!45, densely dotted", "managed": "gray!60!black, dashed"}
REGIME_ORDER = ["peg", "managed", "float"]


def lambda_D_at(rho):
    oh21 = rho * OH21_BASE
    oh32 = rho * OH32_BASE
    lam1 = BH["sector1"] + BH["sector2"] * oh21 + BH["sector3"] * oh21 * oh32
    lam2 = BH["sector2"] + BH["sector3"] * oh32
    lam3 = BH["sector3"]
    return [lam1, lam2, lam3]


def load_dhat_and_params():
    net_obj = pd.read_csv(os.path.join(RESULTS_DIR, "network_objects.csv"), index_col="object")
    params = pd.read_csv(os.path.join(RESULTS_DIR, "params.csv"))
    params = dict(zip(params["name"], params["value"]))
    return net_obj.loc["dhat"].values, params


def compute_welfare_netdens(sweep_csv="netdens_sweep.csv", out_csv="netdens_welfare.csv"):
    path = os.path.join(RESULTS_DIR, sweep_csv)
    df = pd.read_csv(path)
    dhat, params = load_dhat_and_params()
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    eps = params["EPS"]

    rows = []
    for _, r in df.iterrows():
        rho = r["rho"]
        lam = lambda_D_at(rho)
        disp_weight = [lam[i] * eps * (1 - dhat[i]) / dhat[i] for i in range(3)]
        var_y = r["y_gap"]
        var_pi = [r["PI1"], r["PI2"], r["PI3"]]
        w_output = 0.5 * gamma_phi * var_y
        w_pi = [0.5 * disp_weight[i] * var_pi[i] for i in range(3)]
        rows.append({
            "rho": rho,
            "regime": r["regime"],
            "output_gap": w_output,
            "price_disp_sector1": w_pi[0],
            "price_disp_sector2": w_pi[1],
            "price_disp_sector3": w_pi[2],
            "price_disp_total": sum(w_pi),
            "total": w_output + sum(w_pi),
        })
    out = pd.DataFrame(rows).sort_values(["regime", "rho"])
    out.to_csv(os.path.join(RESULTS_DIR, out_csv), index=False)

    print(f"\n=== {out_csv} (total welfare loss x1e4) ===")
    piv = out.pivot(index="rho", columns="regime", values="total") * 1e4
    print(piv.round(3))

    print("\n=== Network welfare premium: total(rho=1, baseline) - total(rho=0, no-network) (x1e4) ===")
    for regime in REGIME_ORDER:
        sub = out[out["regime"] == regime].set_index("rho")
        if 1.0 in sub.index and 0.0 in sub.index:
            premium = (sub.loc[1.0, "total"] - sub.loc[0.0, "total"]) * 1e4
            print(f"  {regime:8s}: {premium:+.3f}")

    print("\n=== Per-sector network welfare premium (total, x1e4) ===")
    for regime in REGIME_ORDER:
        sub = out[out["regime"] == regime].set_index("rho")
        if 1.0 in sub.index and 0.0 in sub.index:
            for i in (1, 2, 3):
                col = f"price_disp_sector{i}"
                premium = (sub.loc[1.0, col] - sub.loc[0.0, col]) * 1e4
                print(f"  {regime:8s} sector{i}: {premium:+.4f}")

    print(f"\npgfplots coordinates ({out_csv}, total welfare x1e4 vs rho):")
    for regime in REGIME_ORDER:
        sub = out[out["regime"] == regime].sort_values("rho")
        coords = " ".join(f"({r['rho']:.2f},{1e4*r['total']:.4f})" for _, r in sub.iterrows())
        print(f"% {regime}\n\\addplot[thick, {REGIME_COLORS_TEX[regime]}, mark=*, mark size=1.1pt] coordinates {{{coords}}};")

    return out


if __name__ == "__main__":
    compute_welfare_netdens()
