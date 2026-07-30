"""
Tier 1B (Services-only cut) analysis. Reads
results/services_rigidity_netdens_sweep.csv (code/sweep_services_rigidity_chile.m,
DELTA3 in {0.05,0.10,0.16(baseline),0.25,0.40,0.60}, DELTA1/DELTA2 held at
baseline, rho in {0,1,2}, 3 regimes). dhat1/dhat2 are fixed at baseline
(unaffected); dhat3 is recomputed as a function of delta3 via the same
formula as DHAT1 in open_economy_network_chile.mod:222. lambda_D(rho)
reused from network_exposure_decomposition.py.

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/analysis_services_rigidity_chile.py
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


def dhat_scalar(delta, beta):
    return delta * (1 - beta * (1 - delta)) / (1 - beta * delta * (1 - delta))


def main():
    df = pd.read_csv(os.path.join(RESULTS, "services_rigidity_netdens_sweep.csv"))
    params_df = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params_df["name"], params_df["value"]))
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    eps = params["EPS"]
    beta = params["BETA"]
    dhat_base = net_obj.loc["dhat"].values  # [dhat1, dhat2, dhat3] at baseline

    rows = []
    for _, r in df.iterrows():
        rho, delta3 = r["rho"], r["delta3"]
        lam = lambda_D(rho)
        dhat = dhat_base.copy()
        dhat[2] = dhat_scalar(delta3, beta)
        disp_weight = lam * eps * (1 - dhat) / dhat
        var_pi = np.array([r["PI1"], r["PI2"], r["PI3"]])
        w_output = 0.5 * gamma_phi * r["y_gap"]
        w_pi = 0.5 * disp_weight * var_pi
        rows.append({"delta3": delta3, "rho": rho, "regime": r["regime"],
                     "total": (w_output + w_pi.sum()) * 1e4})
    out = pd.DataFrame(rows).sort_values(["rho", "regime", "delta3"])
    out.to_csv(os.path.join(RESULTS, "services_rigidity_welfare.csv"), index=False)

    print("=== Welfare loss (x1e-4) by Services' DELTA3 (0.05=very sticky .. 0.60=flexible) x rho x regime ===")
    for rho in sorted(out["rho"].unique()):
        sub = out[out["rho"] == rho]
        piv = sub.pivot(index="delta3", columns="regime", values="total")
        print(f"\n-- rho={rho:.1f} --")
        print(piv.round(3))

    SURFACE = "#fcfcfb"
    fig, axes = plt.subplots(1, 3, figsize=(14, 4.4), dpi=200, sharey=True)
    fig.patch.set_facecolor(SURFACE)
    rho_vals = sorted(out["rho"].unique())
    for ax, rho in zip(axes, rho_vals):
        ax.set_facecolor(SURFACE)
        sub = out[out["rho"] == rho]
        for regime in REGIMES:
            s2 = sub[sub.regime == regime].sort_values("delta3")
            ax.plot(s2["delta3"], s2["total"], color=COLORS[regime], marker="o", markersize=4,
                    linewidth=2.2, label=REGIME_LABELS[regime])
        ax.axvline(0.16, color="#c3c2b7", linestyle="--", linewidth=1)
        ax.invert_xaxis()  # sticky (low delta3) on the left, matching "more rigid -> "
        ax.set_title(rf"$\rho={rho:.0f}$" + (" (no network)" if rho == 0 else " (real Chile)" if rho == 1 else " (2x density)"),
                     fontsize=10.5, color="#0b0b0b")
        ax.set_xlabel(r"Services $\Delta_3$ (Calvo reset prob., sticky $\to$ flexible)", fontsize=9, color="#52514e")
        ax.set_yscale("log")
        ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
        ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
        ax.tick_params(colors="#898781", labelsize=8.5)
        ax.yaxis.grid(True, which="both", color="#e1e0d9", linewidth=0.6, zorder=0)
        ax.set_axisbelow(True)
    axes[0].set_ylabel(r"welfare loss ($\times10^4$)", fontsize=10, color="#52514e")
    axes[0].legend(loc="upper right", frameon=False, fontsize=8.5)
    fig.tight_layout()
    out_pdf = os.path.join(FIGS, "services_rigidity_robustness.pdf")
    out_png = os.path.join(FIGS, "services_rigidity_robustness.png")
    fig.savefig(out_pdf, facecolor=fig.get_facecolor(), bbox_inches="tight")
    fig.savefig(out_png, facecolor=fig.get_facecolor(), bbox_inches="tight")
    print(f"\nSaved {out_pdf} and {out_png}")


if __name__ == "__main__":
    main()
