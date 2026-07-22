"""
Christian's comment (presentation feedback, 2026-07-22): Services is
price-rigid (low Calvo reset prob DELTA3) and has the LOWEST direct
import share (OF3), but it buys inputs from Manufacturing, which has the
HIGHEST import share (OF2). So Services can be exposed to import-price /
FX shocks almost entirely INDIRECTLY, through the domestic network, even
though it looks "insulated" on direct exposure alone. This script builds
that decomposition analytically (no Dynare re-run needed):

  M_i(rho)      = [(I - rho*OffDiag(Omega^H))^-1 Omega^F 1]_i
                   total (direct + indirect) import centrality
  M_i(rho) - OF_i = the INDIRECT part specifically, as a function of
                   network density rho (rho=0 -> no domestic network ->
                   indirect part is exactly zero by construction)
  lambda_D_i(rho) = BH' * (I - rho*OffDiag(Omega^H))^-1
                   Domar weight / domestic-supplier centrality (needed to
                   recompute welfare correctly at each rho, since the
                   fixed rho=1 lambda_D used by the old
                   analysis_netdens_chile.py is only exact at rho=1)

Same OH_diag / OH_offdiag_base / OF_base / rho parameterization as
code/sweep_netdens_chile.m, so M_i(1) and lambda_D(1) reproduce
results_chile/network_objects.csv exactly (checked at the bottom).

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/network_exposure_decomposition.py
"""
import os
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS = os.path.join(REPO_ROOT, "results")
FIGS = os.path.join(REPO_ROOT, "figs")
SECTORS = ["Resource", "Manufacturing", "Services"]

OH_diag = np.array([0.0750, 0.2022, 0.2661])
OH_offdiag_base = np.array([[0.0000, 0.1526, 0.1932],
                             [0.0991, 0.0000, 0.1453],
                             [0.0018, 0.0581, 0.0000]])
OF_base = np.array([0.0767, 0.1945, 0.0704])
BH = np.array([0.027, 0.229, 0.744])    # household consumption shares (beta^H), real Chile calibration (CLAUDE.md)
DELTA = np.array([0.90, 0.31, 0.16])    # Calvo RESET probability (higher = more flexible)


def omega_h(rho):
    return np.diag(OH_diag) + rho * OH_offdiag_base


def M_total(rho):
    OmH = omega_h(rho)
    Minv = np.linalg.inv(np.eye(3) - OmH)
    return Minv @ OF_base


def lambda_D(rho):
    OmH = omega_h(rho)
    Minv = np.linalg.inv(np.eye(3) - OmH)
    return BH @ Minv


def main():
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    M1_check = M_total(1.0)
    lam1_check = lambda_D(1.0)
    print("Sanity check vs results_chile/network_objects.csv (rho=1):")
    print("  M_i    analytical:", np.round(M1_check, 6), " csv:", net_obj.loc["import_centrality"].values)
    print("  lam_D  analytical:", np.round(lam1_check, 6), " csv:", net_obj.loc["lambda_D"].values)

    rho_grid = np.array([0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.2])
    rows = []
    for rho in rho_grid:
        M = M_total(rho)
        lam = lambda_D(rho)
        indirect = M - OF_base
        for i, sec in enumerate(SECTORS):
            rows.append({"rho": rho, "sector": sec, "direct": OF_base[i], "total": M[i],
                         "indirect": indirect[i], "indirect_share": indirect[i] / M[i],
                         "lambda_D": lam[i]})
    df = pd.DataFrame(rows)
    df.to_csv(os.path.join(RESULTS, "import_exposure_decomposition.csv"), index=False)

    at1 = df[df["rho"] == 1.0].set_index("sector")
    print("\n=== Direct vs indirect import exposure at baseline (rho=1) ===")
    print(at1[["direct", "indirect", "total", "indirect_share"]].round(4))
    print("\n(DELTA reset prob, higher=more flexible):", dict(zip(SECTORS, DELTA)))
    print("dhat (Calvo persistence index, lower=stickier):", net_obj.loc["dhat"].values)

    # ---- Figure: two panels, (1) M_i(rho) stacked direct/indirect, (2) rigidity x total exposure scatter ----
    COLOR_DIRECT = "#7c3aed"
    COLOR_INDIRECT = "#d97706"
    COLOR_SECTOR = {"Resource": "#7c3aed", "Manufacturing": "#d97706", "Services": "#0891b2"}
    SURFACE = "#fcfcfb"

    fig, axes = plt.subplots(1, 2, figsize=(11, 4.4), dpi=200)
    fig.patch.set_facecolor(SURFACE)

    ax = axes[0]
    ax.set_facecolor(SURFACE)
    sub = df[df["sector"] == "Services"].sort_values("rho")
    ax.plot(sub["rho"], sub["direct"], color="#898781", linestyle=":", linewidth=2, label="Direct (fixed by construction)")
    ax.plot(sub["rho"], sub["total"], color=COLOR_SECTOR["Services"], linewidth=2.4, marker="o", markersize=4, label="Total (direct + indirect)")
    ax.fill_between(sub["rho"], sub["direct"], sub["total"], color=COLOR_SECTOR["Services"], alpha=0.15)
    ax.axvline(1.0, color="#c3c2b7", linestyle="--", linewidth=1)
    ax.text(1.05, sub["direct"].values[0] * 1.05, "baseline", fontsize=9, color="#52514e")
    ax.set_xlabel(r"cross-sector density $\rho$ (0 = no domestic network)", fontsize=10, color="#0b0b0b")
    ax.set_ylabel(r"import centrality $M_{\rm Services}$", fontsize=10.5, color="#52514e")
    ax.set_title("Services' import exposure is mostly indirect", fontsize=11, color="#0b0b0b")
    ax.legend(loc="upper left", frameon=False, fontsize=9)
    ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=9)
    ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
    ax.set_axisbelow(True)

    ax = axes[1]
    ax.set_facecolor(SURFACE)
    x = np.arange(3)
    width = 0.35
    direct = at1["direct"].reindex(SECTORS).values
    indirect = at1["indirect"].reindex(SECTORS).values
    ax.bar(x, direct, width, color="#c3c2b7", label="Direct import share $\\Omega^F_i$")
    ax.bar(x, indirect, width, bottom=direct, color=[COLOR_SECTOR[s] for s in SECTORS], alpha=0.85, label="Indirect (via network, $\\rho{=}1$)")
    for xi, sec in zip(x, SECTORS):
        rig = 1 - DELTA[SECTORS.index(sec)]
        ax.text(xi, direct[SECTORS.index(sec)] + indirect[SECTORS.index(sec)] + 0.006,
                 f"stickiness\n(1$-\\delta$)={rig:.2f}", ha="center", fontsize=8, color="#52514e")
    ax.set_xticks(x); ax.set_xticklabels(SECTORS, fontsize=10, color="#0b0b0b")
    ax.set_ylabel("import centrality $M_i$", fontsize=10.5, color="#52514e")
    ax.set_title("Direct vs. indirect exposure, all sectors", fontsize=11, color="#0b0b0b")
    ax.legend(loc="upper left", frameon=False, fontsize=8.5)
    ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=9)
    ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
    ax.set_axisbelow(True)
    ax.set_ylim(0, max(at1["total"]) * 1.35)

    fig.tight_layout()
    os.makedirs(FIGS, exist_ok=True)
    out_pdf = os.path.join(FIGS, "import_exposure_decomposition.pdf")
    out_png = os.path.join(FIGS, "import_exposure_decomposition.png")
    fig.savefig(out_pdf, facecolor=fig.get_facecolor(), bbox_inches="tight")
    fig.savefig(out_png, facecolor=fig.get_facecolor(), bbox_inches="tight")
    print(f"\nSaved {out_pdf} and {out_png}")


if __name__ == "__main__":
    main()
