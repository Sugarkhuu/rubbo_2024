"""
Christian's feedback (2026-07-22): does the welfare-minimizing managed-
float FX-response coefficient PHI_S shift depending on whether the
domestic production network is present? Reads
results/phi_s_netdens_chile_sweep.csv (code/sweep_phi_s_netdens_chile.m
via code/drive_phi_s_netdens_chile_sweep.sh -- 12 PHI_S values x 3 network
densities rho in {0, 1, 2}, managed-float regime, real Chile calibration),
computes welfare with lambda_D(rho) (code/network_exposure_decomposition
.lambda_D -- NOT the fixed rho=1 value) and dhat (rho-invariant, from
results_chile/network_objects.csv), and reports the argmin PHI_S* per rho.

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/analysis_phi_s_netdens.py
"""
import os
import sys
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from network_exposure_decomposition import lambda_D  # noqa: E402

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS = os.path.join(REPO_ROOT, "results")
FIGS = os.path.join(REPO_ROOT, "figs")


def main():
    df = pd.read_csv(os.path.join(RESULTS, "phi_s_netdens_chile_sweep.csv"))
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    params_df = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params_df["name"], params_df["value"]))
    dhat = net_obj.loc["dhat"].values
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    eps = params["EPS"]

    rows = []
    for _, r in df.iterrows():
        rho = r["rho"]
        lam = lambda_D(rho)
        disp_weight = lam * eps * (1 - dhat) / dhat
        w_output = 0.5 * gamma_phi * r["y_gap"]
        var_pi = np.array([r["PI1"], r["PI2"], r["PI3"]])
        w_pi = 0.5 * disp_weight * var_pi
        rows.append({"rho": rho, "phi_s": r["phi_s"], "total": (w_output + w_pi.sum()) * 1e4})
    out = pd.DataFrame(rows).sort_values(["rho", "phi_s"])
    out.to_csv(os.path.join(RESULTS, "phi_s_netdens_chile_welfare.csv"), index=False)

    print("=== Welfare loss (x1e-4) by phi_s, one column per network density rho ===")
    piv = out.pivot(index="phi_s", columns="rho", values="total")
    print(piv.round(3))

    print("\n=== Welfare-minimizing phi_s* on this grid, by rho ===")
    optima = {}
    for rho in sorted(out["rho"].unique()):
        sub = out[out["rho"] == rho].set_index("phi_s")["total"]
        phi_star = sub.idxmin()
        optima[rho] = (phi_star, sub.min(), sub.loc[0.30] if 0.30 in sub.index else np.nan)
        print(f"  rho={rho:.1f}: phi_s* = {phi_star:.2f}  (loss={sub.min():.3f}; "
              f"at calibrated phi_s=0.30: loss={sub.get(0.30, float('nan')):.3f})")

    # ---- Figure: welfare vs phi_s, one curve per rho, optima marked ----
    COLORS = {0.0: "#898781", 1.0: "#16a34a", 2.0: "#0891b2"}
    LABELS = {0.0: r"No network ($\rho{=}0$)", 1.0: r"Baseline ($\rho{=}1$)", 2.0: r"Denser ($\rho{=}2$)"}
    SURFACE = "#fcfcfb"

    fig, ax = plt.subplots(figsize=(7.2, 4.6), dpi=200)
    fig.patch.set_facecolor(SURFACE)
    ax.set_facecolor(SURFACE)
    for rho in sorted(out["rho"].unique()):
        sub = out[out["rho"] == rho].sort_values("phi_s")
        ax.plot(sub["phi_s"], sub["total"], color=COLORS[rho], marker="o", markersize=4,
                 linewidth=2.2, label=LABELS[rho])
        phi_star, loss_star, _ = optima[rho]
        ax.scatter([phi_star], [loss_star], color=COLORS[rho], s=90, zorder=5, edgecolor="white", linewidth=1.2)
    ax.axvline(0.30, color="#c3c2b7", linestyle="--", linewidth=1)
    ax.text(0.31, ax.get_ylim()[1] * 0.95, "calibrated $\\phi_s{=}0.30$", fontsize=8.5, color="#52514e")
    ax.set_xlabel(r"FX-stabilization coefficient $\phi_s$", fontsize=10.5, color="#0b0b0b")
    ax.set_ylabel(r"welfare loss ($\times10^4$)", fontsize=10.5, color="#52514e")
    ax.set_xlim(-0.05, 2.05)
    ax.legend(loc="upper right", frameon=False, fontsize=9.5)
    ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=9.5)
    ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
    ax.set_axisbelow(True)
    fig.tight_layout()

    os.makedirs(FIGS, exist_ok=True)
    out_pdf = os.path.join(FIGS, "phi_s_netdens.pdf")
    out_png = os.path.join(FIGS, "phi_s_netdens.png")
    fig.savefig(out_pdf, facecolor=fig.get_facecolor(), bbox_inches="tight")
    fig.savefig(out_png, facecolor=fig.get_facecolor(), bbox_inches="tight")
    print(f"\nSaved {out_pdf} and {out_png}")


if __name__ == "__main__":
    main()
