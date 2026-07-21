"""
Chile-calibrated replacement for the "Isolating the Network Channel"
slide's data. Reads results/netdens_chile_sweep.csv (written by
code/sweep_netdens_chile.m via code/drive_netdens_chile_sweep.sh),
computes welfare with the same formula as code/analysis.py
(compute_welfare), and overwrites figs/isolating_network.pdf/png in the
same two-panel style as before (mirrors figs/isolating_network.py, but
sourced from the real Chile network instead of the stylized triangular
one).

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/analysis_netdens_chile.py
"""
import os
import sys
import pandas as pd
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from analysis import compute_welfare  # noqa: E402

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS = os.path.join(REPO_ROOT, "results")
FIGS = os.path.join(REPO_ROOT, "figs")
SECTOR_COLS = ["price_disp_sector1", "price_disp_sector2", "price_disp_sector3"]


def main():
    df = pd.read_csv(os.path.join(RESULTS, "netdens_chile_sweep.csv"))
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    params_df = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params_df["name"], params_df["value"]))

    rows = []
    sector_rows = []
    for rho in sorted(df["rho"].unique()):
        variances = df[df["rho"] == rho].set_index("regime")
        w = compute_welfare(variances, net_obj, params) * 1e4
        for regime in variances.index:
            rows.append({"rho": rho, "regime": regime, "total": w.loc[regime, "total"]})
            sector_rows.append({"rho": rho, "regime": regime,
                                 "sector1": w.loc[regime, "price_disp_sector1"],
                                 "sector2": w.loc[regime, "price_disp_sector2"],
                                 "sector3": w.loc[regime, "price_disp_sector3"]})

    welfare = pd.DataFrame(rows)
    sector = pd.DataFrame(sector_rows)
    welfare.to_csv(os.path.join(RESULTS, "netdens_chile_welfare.csv"), index=False)
    sector.to_csv(os.path.join(RESULTS, "netdens_chile_sector_welfare.csv"), index=False)

    print("=== Network density (rho) welfare (x1e-4), Chile-calibrated ===")
    print(welfare.pivot(index="rho", columns="regime", values="total").to_string())

    pivot = welfare.pivot(index="rho", columns="regime", values="total")

    regimes = ["Float", "Managed", "Peg"]
    rho0 = sector[sector["rho"] == 0.0].set_index("regime")
    rho1 = sector[sector["rho"] == 1.0].set_index("regime")
    premium = {
        "Resource": [(rho1.loc[r.lower(), "sector1"] - rho0.loc[r.lower(), "sector1"]) for r in regimes],
        "Manuf.": [(rho1.loc[r.lower(), "sector2"] - rho0.loc[r.lower(), "sector2"]) for r in regimes],
        "Services": [(rho1.loc[r.lower(), "sector3"] - rho0.loc[r.lower(), "sector3"]) for r in regimes],
    }
    print("\n=== Per-sector price-dispersion premium (rho=1 minus rho=0), x1e-4 ===")
    for sec, vals in premium.items():
        print(f"{sec}: Float={vals[0]:.4f} Managed={vals[1]:.4f} Peg={vals[2]:.4f}")

    COLOR_PEG = "#dc2626"
    COLOR_MANAGED = "#6b7280"
    COLOR_FLOAT = "#16a34a"
    COLOR_RESOURCE = "#7c3aed"
    COLOR_MANUF = "#d97706"
    COLOR_SERVICES = "#0891b2"
    SURFACE = "#fcfcfb"

    fig, axes = plt.subplots(1, 2, figsize=(11, 4.2), dpi=200)
    fig.patch.set_facecolor(SURFACE)

    ax = axes[0]
    ax.set_facecolor(SURFACE)
    rho_x = pivot.index.values
    ax.plot(rho_x, pivot["peg"].values, color=COLOR_PEG, linestyle=":", marker="o", markersize=4,
            linewidth=2, label="Peg")
    ax.plot(rho_x, pivot["managed"].values, color=COLOR_MANAGED, linestyle="--", marker="o", markersize=4,
            linewidth=2, label="Managed")
    ax.plot(rho_x, pivot["float"].values, color=COLOR_FLOAT, linestyle="-", marker="o", markersize=4,
            linewidth=2, label="Float")
    ax.axvline(1.0, color="#c3c2b7", linestyle="--", linewidth=1)
    ax.text(1.05, pivot.values.min() * 0.9, "baseline", fontsize=9, color="#52514e")
    ax.set_xlabel("cross-sector density $\\rho$ (0 = no domestic network)", fontsize=10, color="#0b0b0b")
    ax.set_ylabel("welfare loss ($\\times10^4$)", fontsize=11, color="#52514e")
    ax.legend(loc="upper left", frameon=False, fontsize=10)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7")
    ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=10)
    ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
    ax.set_axisbelow(True)

    ax = axes[1]
    ax.set_facecolor(SURFACE)
    x = np.arange(len(regimes))
    width = 0.25
    ax.bar(x - width, premium["Resource"], width, color=COLOR_RESOURCE, label="Resource")
    ax.bar(x, premium["Manuf."], width, color=COLOR_MANUF, label="Manuf.")
    ax.bar(x + width, premium["Services"], width, color=COLOR_SERVICES, label="Services")
    ax.axhline(0, color="#898781", linewidth=0.8)
    ax.set_xticks(x)
    ax.set_xticklabels(regimes, fontsize=11, color="#0b0b0b")
    ax.set_ylabel("premium ($\\times10^4$)", fontsize=11, color="#52514e")
    ax.legend(loc="upper right", frameon=False, fontsize=10)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7")
    ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=10)
    ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
    ax.set_axisbelow(True)

    fig.tight_layout()
    os.makedirs(FIGS, exist_ok=True)
    out_pdf = os.path.join(FIGS, "isolating_network.pdf")
    out_png = os.path.join(FIGS, "isolating_network.png")
    fig.savefig(out_pdf, facecolor=fig.get_facecolor(), bbox_inches="tight")
    fig.savefig(out_png, facecolor=fig.get_facecolor(), bbox_inches="tight")
    print(f"\nSaved {out_pdf} and {out_png}")


if __name__ == "__main__":
    main()
