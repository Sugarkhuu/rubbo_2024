"""
Tier 1A of the full robustness campaign (2026-07-27): does the psi-
sensitivity result (results/psi_sweep_welfare.csv, real Chile calibration,
network density fixed at its real rho=1 value) depend on whether the
domestic production network is present at all? Reads
results/psi_netdens_regime_sweep.csv (raw variances, 5 psi x 3 rho x 3
regimes, code/sweep_psi_netdens_chile.m via
code/drive_psi_netdens_sweep.sh) and computes welfare using lambda_D(rho)
from code/network_exposure_decomposition.py's closed form (same
OH_diag/OH_offdiag_base/OF_base parameterization the sweep itself uses),
dhat held fixed (rho-invariant, Calvo-only).

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/analysis_psi_netdens_chile.py
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
REGIMES = ["float", "managed", "peg"]
REGIME_LABELS = {"float": "Float", "managed": "Managed", "peg": "Peg"}
COLORS = {"float": "#16a34a", "managed": "#6b7280", "peg": "#dc2626"}


def main():
    df = pd.read_csv(os.path.join(RESULTS, "psi_netdens_regime_sweep.csv"))
    params_df = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params_df["name"], params_df["value"]))
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    dhat = net_obj.loc["dhat"].values
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    eps = params["EPS"]

    rows = []
    for _, r in df.iterrows():
        rho = r["rho"]
        lam = lambda_D(rho)
        disp_weight = lam * eps * (1 - dhat) / dhat
        var_pi = np.array([r["PI1"], r["PI2"], r["PI3"]])
        w_output = 0.5 * gamma_phi * r["y_gap"]
        w_pi = 0.5 * disp_weight * var_pi
        rows.append({"psi": r["psi"], "rho": rho, "regime": r["regime"],
                     "total": (w_output + w_pi.sum()) * 1e4})
    out = pd.DataFrame(rows).sort_values(["rho", "regime", "psi"])
    out.to_csv(os.path.join(RESULTS, "psi_netdens_welfare.csv"), index=False)

    print("=== Welfare loss (x1e-4) by psi x network density (rho) x regime ===")
    for rho in sorted(out["rho"].unique()):
        sub = out[out["rho"] == rho]
        piv = sub.pivot(index="psi", columns="regime", values="total")
        print(f"\n-- rho={rho:.1f} --")
        print(piv.round(3))

    print("\n=== Peg/Float welfare ratio, by rho and psi (endpoints) ===")
    for rho in sorted(out["rho"].unique()):
        sub = out[out["rho"] == rho]
        piv = sub.pivot(index="psi", columns="regime", values="total")
        psi_lo, psi_hi = sub["psi"].min(), sub["psi"].max()
        ratio_lo = piv.loc[psi_lo, "peg"] / piv.loc[psi_lo, "float"]
        ratio_hi = piv.loc[psi_hi, "peg"] / piv.loc[psi_hi, "float"]
        print(f"  rho={rho:.1f}: Peg/Float ratio {ratio_lo:.2f}x (psi={psi_lo}) -> "
              f"{ratio_hi:.2f}x (psi={psi_hi})")

    SURFACE = "#fcfcfb"
    fig, axes = plt.subplots(1, 3, figsize=(14, 4.4), dpi=200, sharey=True)
    fig.patch.set_facecolor(SURFACE)
    rho_vals = sorted(out["rho"].unique())
    for ax, rho in zip(axes, rho_vals):
        ax.set_facecolor(SURFACE)
        sub = out[out["rho"] == rho]
        for regime in REGIMES:
            s2 = sub[sub.regime == regime].sort_values("psi")
            ax.plot(s2["psi"], s2["total"], color=COLORS[regime], marker="o", markersize=4,
                    linewidth=2.2, label=REGIME_LABELS[regime])
        ax.axvline(0.02, color="#c3c2b7", linestyle="--", linewidth=1)
        ax.set_title(rf"$\rho={rho:.0f}$" + (" (no network)" if rho == 0 else " (real Chile)" if rho == 1 else " (2x density)"),
                     fontsize=10.5, color="#0b0b0b")
        ax.set_xlabel(r"$\psi$ (debt-elastic risk-premium coefficient)", fontsize=9.5, color="#52514e")
        ax.set_yscale("log")
        ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
        ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
        ax.tick_params(colors="#898781", labelsize=8.5)
        ax.yaxis.grid(True, which="both", color="#e1e0d9", linewidth=0.6, zorder=0)
        ax.set_axisbelow(True)
    axes[0].set_ylabel(r"welfare loss ($\times10^4$)", fontsize=10, color="#52514e")
    axes[0].legend(loc="upper right", frameon=False, fontsize=8.5)
    fig.tight_layout()
    out_pdf = os.path.join(FIGS, "psi_netdens_robustness.pdf")
    out_png = os.path.join(FIGS, "psi_netdens_robustness.png")
    fig.savefig(out_pdf, facecolor=fig.get_facecolor(), bbox_inches="tight")
    fig.savefig(out_png, facecolor=fig.get_facecolor(), bbox_inches="tight")
    print(f"\nSaved {out_pdf} and {out_png}")


if __name__ == "__main__":
    main()
