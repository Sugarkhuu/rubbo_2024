"""
Chile-calibrated replacement for the "Openness & Import Concentration"
slide's data. Reads results/import_zeta_sweep.csv and
results/import_thetaM_sweep.csv (written by code/sweep_import_point.m via
code/drive_import_sweep.sh), computes welfare with the same formula as
code/analysis.py (compute_welfare), and overwrites
figs/openness_concentration.pdf/png in the same visual style as before
(mirrors code/analysis_export_sweep.py exactly).

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/analysis_import_sweep.py
"""
import os
import sys
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from analysis import compute_welfare  # noqa: E402

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS = os.path.join(REPO_ROOT, "results")
FIGS = os.path.join(REPO_ROOT, "figs")


def welfare_by_grid(csv_path, grid_col):
    df = pd.read_csv(csv_path)
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    params_df = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params_df["name"], params_df["value"]))

    rows = []
    for g in sorted(df[grid_col].unique()):
        variances = df[df[grid_col] == g].set_index("regime")
        welfare = compute_welfare(variances, net_obj, params) * 1e4
        for regime in variances.index:
            rows.append({grid_col: g, "regime": regime, "total": welfare.loc[regime, "total"]})
    return pd.DataFrame(rows)


def main():
    zeta_w = welfare_by_grid(os.path.join(RESULTS, "import_zeta_sweep.csv"), "zeta")
    theta_w = welfare_by_grid(os.path.join(RESULTS, "import_thetaM_sweep.csv"), "theta_M")

    zeta_w.to_csv(os.path.join(RESULTS, "import_zeta_welfare.csv"), index=False)
    theta_w.to_csv(os.path.join(RESULTS, "import_thetaM_welfare.csv"), index=False)

    print("=== Import openness (zeta) welfare (x1e-4) ===")
    print(zeta_w.pivot(index="zeta", columns="regime", values="total").to_string())
    print("\n=== Import concentration (theta_M) welfare (x1e-4) ===")
    print(theta_w.pivot(index="theta_M", columns="regime", values="total").to_string())

    zp = zeta_w.pivot(index="zeta", columns="regime", values="total")
    tp = theta_w.pivot(index="theta_M", columns="regime", values="total")

    COLOR_PEG = "#dc2626"
    COLOR_MANAGED = "#6b7280"
    COLOR_FLOAT = "#16a34a"
    SURFACE = "#fcfcfb"

    fig, axes = plt.subplots(1, 2, figsize=(11, 4.0), dpi=200)
    fig.patch.set_facecolor(SURFACE)

    panels = [
        (axes[0], zp, r"scale $\zeta$"),
        (axes[1], tp, r"concentration $\theta_M$"),
    ]

    for ax, pivot, xlabel in panels:
        ax.set_facecolor(SURFACE)
        x = pivot.index.values
        ax.plot(x, pivot["peg"].values, color=COLOR_PEG, linestyle=":", marker="o", markersize=4,
                linewidth=2, label="Peg")
        ax.plot(x, pivot["managed"].values, color=COLOR_MANAGED, linestyle="--", marker="o", markersize=4,
                linewidth=2, label="Managed")
        ax.plot(x, pivot["float"].values, color=COLOR_FLOAT, linestyle="-", marker="o", markersize=4,
                linewidth=2, label="Float")
        ax.set_xlabel(xlabel, fontsize=12, color="#0b0b0b")
        ax.set_ylabel("welfare loss ($\\times10^4$)", fontsize=11, color="#52514e")
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_color("#c3c2b7")
        ax.spines["bottom"].set_color("#c3c2b7")
        ax.tick_params(colors="#898781", labelsize=10)
        ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
        ax.set_axisbelow(True)

    handles, labels = axes[0].get_legend_handles_labels()
    fig.legend(handles, labels, loc="upper center", ncol=3, frameon=False,
               fontsize=12, bbox_to_anchor=(0.5, 1.06))

    fig.tight_layout()
    os.makedirs(FIGS, exist_ok=True)
    out_pdf = os.path.join(FIGS, "openness_concentration.pdf")
    out_png = os.path.join(FIGS, "openness_concentration.png")
    fig.savefig(out_pdf, facecolor=fig.get_facecolor(), bbox_inches="tight")
    fig.savefig(out_png, facecolor=fig.get_facecolor(), bbox_inches="tight")
    print(f"\nSaved {out_pdf} and {out_png}")


if __name__ == "__main__":
    main()
