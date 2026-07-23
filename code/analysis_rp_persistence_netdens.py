"""
Christian's feedback (2026-07-22/23): "persistence of inflation leading to
higher cost... same conclusion on why UIP welfare loss is so high," plus
the broader ask to trace network density -> import exposure -> Services ->
rigidity/persistence -> welfare as one connected chain. Reads
results/rp_persistence_netdens_chile_sweep.csv (RHO_RP -- risk-premium
shock AR(1) persistence -- crossed with network density rho in {0,1}, all
three regimes; code/sweep_rp_persistence_netdens_chile.m via
code/drive_rp_persistence_netdens_chile.sh) and computes welfare with
lambda_D(rho) (network_exposure_decomposition, NOT fixed at rho=1) since
rho varies here.

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/analysis_rp_persistence_netdens.py
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
    df = pd.read_csv(os.path.join(RESULTS, "rp_persistence_netdens_chile_sweep.csv"))
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    params = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params["name"], params["value"]))
    dhat = net_obj.loc["dhat"].values
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    eps = params["EPS"]

    rows = []
    sector_rows = []
    for _, r in df.iterrows():
        lam = lambda_D(r["rho"])
        disp_weight = lam * eps * (1 - dhat) / dhat
        var_pi = np.array([r["PI1"], r["PI2"], r["PI3"]])
        w_pi = 0.5 * disp_weight * var_pi
        w = 0.5 * gamma_phi * r["y_gap"] + w_pi.sum()
        rows.append({"rho": r["rho"], "rho_rp": r["rho_rp"], "regime": r["regime"], "total": w * 1e4})
        sector_rows.append({"rho": r["rho"], "rho_rp": r["rho_rp"], "regime": r["regime"],
                             "sector3_disp": w_pi[2] * 1e4})
    out = pd.DataFrame(rows).sort_values(["regime", "rho", "rho_rp"])
    sector = pd.DataFrame(sector_rows)
    out.to_csv(os.path.join(RESULTS, "rp_persistence_netdens_welfare.csv"), index=False)

    print("=== Welfare loss (x1e-4) vs. RHO_RP (risk-premium persistence), by rho and regime ===")
    for rho in sorted(out["rho"].unique()):
        print(f"\n-- rho={rho} --")
        print(out[out.rho == rho].pivot(index="rho_rp", columns="regime", values="total").round(3))

    print("\n=== Services' OWN price-dispersion welfare cost (x1e-4) vs. RHO_RP, by rho (Peg) ===")
    sub = sector[sector.regime == "peg"]
    print(sub.pivot(index="rho_rp", columns="rho", values="sector3_disp").round(4))

    SURFACE = "#fcfcfb"
    fig, axes = plt.subplots(1, 2, figsize=(11.5, 4.6), dpi=200)
    fig.patch.set_facecolor(SURFACE)

    ax = axes[0]
    ax.set_facecolor(SURFACE)
    for regime in REGIMES:
        for rho, ls in [(0.0, "--"), (1.0, "-")]:
            sub = out[(out.regime == regime) & (out.rho == rho)].sort_values("rho_rp")
            if len(sub):
                label = f"{REGIME_LABELS[regime]} ({'no network' if rho == 0 else 'baseline'})"
                ax.plot(sub["rho_rp"], sub["total"], color=COLORS[regime], linestyle=ls,
                        marker="o", markersize=3.5, linewidth=2.0, label=label)
    ax.axvline(0.80, color="#c3c2b7", linestyle=":", linewidth=1)
    ax.set_xlabel(r"risk-premium persistence $\rho_{RP}$", fontsize=10, color="#0b0b0b")
    ax.set_ylabel(r"welfare loss ($\times10^4$)", fontsize=10.5, color="#52514e")
    ax.set_yscale("log")
    ax.legend(loc="upper left", frameon=False, fontsize=7, ncol=1)
    ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=9)
    ax.set_title("Total welfare loss: persistence x network", fontsize=10.5, color="#0b0b0b")

    ax = axes[1]
    ax.set_facecolor(SURFACE)
    sub = sector[sector.regime == "peg"]
    for rho, ls, col in [(0.0, "--", "#898781"), (1.0, "-", "#dc2626")]:
        s2 = sub[sub.rho == rho].sort_values("rho_rp")
        ax.plot(s2["rho_rp"], s2["sector3_disp"], color=col, linestyle=ls, marker="o", markersize=4,
                linewidth=2.2, label="no network" if rho == 0 else "baseline network")
    ax.axvline(0.80, color="#c3c2b7", linestyle=":", linewidth=1)
    ax.set_xlabel(r"risk-premium persistence $\rho_{RP}$", fontsize=10, color="#0b0b0b")
    ax.set_ylabel(r"Services price-disp.\ cost ($\times10^4$)", fontsize=10, color="#52514e")
    ax.legend(loc="upper left", frameon=False, fontsize=9)
    ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=9)
    ax.set_title("Peg, Services only: persistence x network", fontsize=10.5, color="#0b0b0b")

    fig.tight_layout()
    out_pdf = os.path.join(FIGS, "rp_persistence_netdens.pdf")
    out_png = os.path.join(FIGS, "rp_persistence_netdens.png")
    fig.savefig(out_pdf, facecolor=fig.get_facecolor(), bbox_inches="tight")
    fig.savefig(out_png, facecolor=fig.get_facecolor(), bbox_inches="tight")
    print(f"\nSaved {out_pdf} and {out_png}")


if __name__ == "__main__":
    main()
