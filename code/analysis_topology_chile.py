"""
Tier 2 analysis: does the Float/Managed/Peg welfare ranking, and the
optimal phi_s, survive alternative network SHAPES (not just density)?
Reads results/topology_regime_sweep.csv (3 topologies x 3 regimes) and
results/topology_phi_s_sweep.csv (12-point phi_s grid x 3 topologies,
managed only). Uses lambda_D(topology) from code/network_topologies.py
(each topology has its own domestic IO matrix, hence its own lambda_D and
dhat is topology-invariant since DELTA_i is untouched here).

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/analysis_topology_chile.py
"""
import os
import sys
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from network_topologies import TOPOLOGIES, lambda_D  # noqa: E402

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS = os.path.join(REPO_ROOT, "results")
FIGS = os.path.join(REPO_ROOT, "figs")
TOPO_LABELS = {"triangle": "Triangle (baseline)", "hub_spoke": "Hub-spoke (Manuf. hub)", "chain": "Chain (R\u2192M\u2192S)"}
COLORS = {"triangle": "#16a34a", "hub_spoke": "#2563eb", "chain": "#dc2626"}


def welfare(var_y, var_pi, lam, dhat, gamma_phi, eps):
    disp_weight = lam * eps * (1 - dhat) / dhat
    return (0.5 * gamma_phi * var_y + 0.5 * (disp_weight * var_pi).sum()) * 1e4


def main():
    params_df = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params_df["name"], params_df["value"]))
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    dhat = net_obj.loc["dhat"].values  # topology-invariant (Calvo-only)
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    eps = params["EPS"]

    # --- Part 1: base regime comparison per topology ---
    df1 = pd.read_csv(os.path.join(RESULTS, "topology_regime_sweep.csv"))
    rows = []
    for _, r in df1.iterrows():
        lam = lambda_D(TOPOLOGIES[r["topology"]])
        var_pi = np.array([r["PI1"], r["PI2"], r["PI3"]])
        w = welfare(r["y_gap"], var_pi, lam, dhat, gamma_phi, eps)
        rows.append({"topology": r["topology"], "regime": r["regime"], "total": w})
    out1 = pd.DataFrame(rows)
    out1.to_csv(os.path.join(RESULTS, "topology_regime_welfare.csv"), index=False)
    piv1 = out1.pivot(index="topology", columns="regime", values="total")
    print("=== Welfare loss (x1e-4) by topology x regime ===")
    print(piv1.round(3))
    print("\nRanking check (Peg worst, Managed best) holds in every topology:",
          all((piv1.loc[t, "peg"] > piv1.loc[t, "float"] > piv1.loc[t, "managed"]) for t in piv1.index))

    # --- Part 2: phi_s search per topology ---
    df2 = pd.read_csv(os.path.join(RESULTS, "topology_phi_s_sweep.csv"))
    rows2 = []
    for _, r in df2.iterrows():
        lam = lambda_D(TOPOLOGIES[r["topology"]])
        var_pi = np.array([r["PI1"], r["PI2"], r["PI3"]])
        w = welfare(r["y_gap"], var_pi, lam, dhat, gamma_phi, eps)
        rows2.append({"topology": r["topology"], "phi_s": r["phi_s"], "total": w})
    out2 = pd.DataFrame(rows2).sort_values(["topology", "phi_s"])
    out2.to_csv(os.path.join(RESULTS, "topology_phi_s_welfare.csv"), index=False)

    print("\n=== Optimal phi_s per topology (managed regime) ===")
    for topo in TOPOLOGIES:
        sub = out2[out2.topology == topo]
        best = sub.loc[sub["total"].idxmin()]
        print(f"  {topo}: phi_s*={best['phi_s']:.2f} (loss={best['total']:.3f})")

    SURFACE = "#fcfcfb"
    fig, ax = plt.subplots(figsize=(6.8, 4.6), dpi=200)
    fig.patch.set_facecolor(SURFACE)
    ax.set_facecolor(SURFACE)
    for topo in TOPOLOGIES:
        sub = out2[out2.topology == topo].sort_values("phi_s")
        ax.plot(sub["phi_s"], sub["total"], color=COLORS[topo], marker="o", markersize=4,
                linewidth=2.2, label=TOPO_LABELS[topo])
    ax.set_xlabel(r"$\phi_s$ (FX-stabilization weight, managed float)", fontsize=10, color="#0b0b0b")
    ax.set_ylabel(r"welfare loss ($\times10^4$)", fontsize=10.5, color="#52514e")
    ax.legend(loc="upper right", frameon=False, fontsize=9)
    ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=9)
    ax.yaxis.grid(True, which="both", color="#e1e0d9", linewidth=0.6, zorder=0)
    ax.set_axisbelow(True)
    fig.tight_layout()
    out_pdf = os.path.join(FIGS, "topology_phi_s.pdf")
    out_png = os.path.join(FIGS, "topology_phi_s.png")
    fig.savefig(out_pdf, facecolor=fig.get_facecolor(), bbox_inches="tight")
    fig.savefig(out_png, facecolor=fig.get_facecolor(), bbox_inches="tight")
    print(f"\nSaved {out_pdf} and {out_png}")


if __name__ == "__main__":
    main()
