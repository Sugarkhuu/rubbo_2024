"""
Tier 1B of the full robustness campaign (2026-07-27): uniform price-
rigidity x network density robustness. Reads
results/rigidity_netdens_regime_sweep.csv (code/sweep_rigidity_netdens_chile.m
via code/drive_rigidity_netdens_sweep.sh, kappa in {0.5,0.75,1,1.5,2} scaling
ALL THREE sectors' stickiness by a common multiplier, rho in {0,1,2} scaling
network density, 3 regimes).

Unlike the psi/netdens analysis, dhat is NOT rho-invariant here -- it IS
kappa-dependent (dhat_i = DELTA_i(kappa)*(1-BETA*(1-DELTA_i(kappa))) /
(1-BETA*DELTA_i(kappa)*(1-DELTA_i(kappa))), same formula as DHAT1 in
open_economy_network_chile.mod:222), so it's recomputed per kappa here.
lambda_D(rho) is unaffected by kappa (only depends on Omega^H, which kappa
never touches) -- reused from network_exposure_decomposition.py.

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/analysis_rigidity_netdens_chile.py
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

DELTA_BASE = np.array([0.90, 0.31, 0.16])


def dhat_of_kappa(kappa, beta):
    delta_k = 1 - kappa * (1 - DELTA_BASE)
    return delta_k * (1 - beta * (1 - delta_k)) / (1 - beta * delta_k * (1 - delta_k))


def main():
    df = pd.read_csv(os.path.join(RESULTS, "rigidity_netdens_regime_sweep.csv"))
    params_df = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params_df["name"], params_df["value"]))
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    eps = params["EPS"]
    beta = params["BETA"]

    rows = []
    for _, r in df.iterrows():
        rho, kappa = r["rho"], r["kappa"]
        lam = lambda_D(rho)
        dhat = dhat_of_kappa(kappa, beta)
        disp_weight = lam * eps * (1 - dhat) / dhat
        var_pi = np.array([r["PI1"], r["PI2"], r["PI3"]])
        w_output = 0.5 * gamma_phi * r["y_gap"]
        w_pi = 0.5 * disp_weight * var_pi
        rows.append({"kappa": kappa, "rho": rho, "regime": r["regime"],
                     "total": (w_output + w_pi.sum()) * 1e4})
    out = pd.DataFrame(rows).sort_values(["rho", "regime", "kappa"])
    out.to_csv(os.path.join(RESULTS, "rigidity_netdens_welfare.csv"), index=False)

    print("=== Welfare loss (x1e-4) by kappa (uniform rigidity scale) x rho x regime ===")
    for rho in sorted(out["rho"].unique()):
        sub = out[out["rho"] == rho]
        piv = sub.pivot(index="kappa", columns="regime", values="total")
        print(f"\n-- rho={rho:.1f} --")
        print(piv.round(3))

    print("\n=== Peg/Float welfare ratio, by rho and kappa (endpoints) ===")
    for rho in sorted(out["rho"].unique()):
        sub = out[out["rho"] == rho]
        piv = sub.pivot(index="kappa", columns="regime", values="total")
        k_lo, k_hi = sub["kappa"].min(), sub["kappa"].max()
        ratio_lo = piv.loc[k_lo, "peg"] / piv.loc[k_lo, "float"]
        ratio_hi = piv.loc[k_hi, "peg"] / piv.loc[k_hi, "float"]
        print(f"  rho={rho:.1f}: Peg/Float ratio {ratio_lo:.2f}x (kappa={k_lo}, more flexible) -> "
              f"{ratio_hi:.2f}x (kappa={k_hi}, stickier)")

    SURFACE = "#fcfcfb"
    fig, axes = plt.subplots(1, 3, figsize=(14, 4.4), dpi=200, sharey=True)
    fig.patch.set_facecolor(SURFACE)
    rho_vals = sorted(out["rho"].unique())
    for ax, rho in zip(axes, rho_vals):
        ax.set_facecolor(SURFACE)
        sub = out[out["rho"] == rho]
        for regime in REGIMES:
            s2 = sub[sub.regime == regime].sort_values("kappa")
            ax.plot(s2["kappa"], s2["total"], color=COLORS[regime], marker="o", markersize=4,
                    linewidth=2.2, label=REGIME_LABELS[regime])
        ax.axvline(1.0, color="#c3c2b7", linestyle="--", linewidth=1)
        ax.set_title(rf"$\rho={rho:.0f}$" + (" (no network)" if rho == 0 else " (real Chile)" if rho == 1 else " (2x density)"),
                     fontsize=10.5, color="#0b0b0b")
        ax.set_xlabel(r"$\kappa$ (uniform rigidity scale)", fontsize=9.5, color="#52514e")
        ax.set_yscale("log")
        ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
        ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
        ax.tick_params(colors="#898781", labelsize=8.5)
        ax.yaxis.grid(True, which="both", color="#e1e0d9", linewidth=0.6, zorder=0)
        ax.set_axisbelow(True)
    axes[0].set_ylabel(r"welfare loss ($\times10^4$)", fontsize=10, color="#52514e")
    axes[0].legend(loc="upper left", frameon=False, fontsize=8.5)
    fig.tight_layout()
    out_pdf = os.path.join(FIGS, "rigidity_netdens_robustness.pdf")
    out_png = os.path.join(FIGS, "rigidity_netdens_robustness.png")
    fig.savefig(out_pdf, facecolor=fig.get_facecolor(), bbox_inches="tight")
    fig.savefig(out_png, facecolor=fig.get_facecolor(), bbox_inches="tight")
    print(f"\nSaved {out_pdf} and {out_png}")


if __name__ == "__main__":
    main()
