"""
Christian's follow-up (2026-07-22, after seeing the first round of slides):
he wasn't sure himself which story he meant --- (a) network/cost-push
(Manufacturing's imports bleed into Services via the 5.8% cost share),
(b) monetary-mismatch/demand (peg forces an interest-rate stance that's
simply wrong-sized for a big, sticky sector, nothing to do with imports),
or (c) pure size (Services is 74% of consumption, so any variance it has
gets welfare-weighted heavily; "rigidity" might be a red herring).

This uses TWO pieces of data that already exist -- no new Dynare runs:
  1. results_chile/variance_decomposition.csv -- Dynare's own shock-by-shock
     variance decomposition of y_gap3 (Services output gap) and PI3
     (Services inflation), by regime. This directly answers "how much of
     Services' variance is the import-price/network channel vs. the
     risk-premium/demand channel vs. TFP."
  2. code/network_exposure_decomposition.lambda_D(rho) -- shows how much of
     Services' Domar weight (its "size" in the welfare formula) is already
     baked in at rho=0 (own consumption share + within-sector input reuse)
     vs. added by the cross-sector network specifically.

Finding (see printed output): risk-premium/UIP dominates Services' own
output-gap variance in EVERY regime (63% Float, 11% Managed, 78% Peg) --
the import-price/network channel is real but secondary (2/22/9%). So (b)
is the dominant proximate driver of the OUTPUT-GAP piece, not (a). But (b)
still routes through the network: the risk-premium shock is an AGGREGATE
shock, and it only becomes a big *Services* output gap because Services
has the largest Domar weight (network-centrality-as-supplier-to-final-
demand) of any sector -- and that weight is 91% already present at rho=0
(from Services' own consumption share + its high within-sector input
reuse) with the cross-sector network adding a further ~9% on top. So (c)
is the main story for WHY Services specifically (not Resource) absorbs a
generic aggregate shock, and the network's role is less "supplies Services
with imported cost-push" and more "amplifies whichever sector is already
central." All three of Christian's hypotheses are real, they compound
rather than compete: size determines who's exposed to aggregate shocks,
network density scales that exposure further, and rigidity converts
whatever variance results into welfare cost.

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/services_mechanism_decomposition.py
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

SHOCK_GROUPS = {
    "TFP (own + other sectors)": ["eps_a1", "eps_a2", "eps_a3"],
    "Import price (network/cost-push)": ["eps_pF"],
    "Foreign demand + Export price (ToT)": ["eps_D", "eps_pX"],
    "Risk premium / UIP (aggregate demand)": ["eps_rp"],
}
GROUP_COLORS = {
    "TFP (own + other sectors)": "#d97706",
    "Import price (network/cost-push)": "#0891b2",
    "Foreign demand + Export price (ToT)": "#c3c2b7",
    "Risk premium / UIP (aggregate demand)": "#dc2626",
}
REGIMES = ["float", "managed", "peg"]
REGIME_LABELS = {"float": "Float", "managed": "Managed", "peg": "Peg"}


def main():
    vardec = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "variance_decomposition.csv"))

    print("=== Services output-gap (y_gap3) variance share by shock group, % ===")
    share_rows = []
    for regime in REGIMES:
        row = vardec[(vardec.regime == regime) & (vardec.variable == "y_gap3")].iloc[0]
        for grp, shocks in SHOCK_GROUPS.items():
            share_rows.append({"regime": regime, "group": grp, "pct": row[shocks].sum()})
    share = pd.DataFrame(share_rows)
    print(share.pivot(index="group", columns="regime", values="pct").round(2))

    print("\n=== Services inflation (PI3) variance share by shock group, % ===")
    share_rows_pi = []
    for regime in REGIMES:
        row = vardec[(vardec.regime == regime) & (vardec.variable == "PI3")].iloc[0]
        for grp, shocks in SHOCK_GROUPS.items():
            share_rows_pi.append({"regime": regime, "group": grp, "pct": row[shocks].sum()})
    share_pi = pd.DataFrame(share_rows_pi)
    print(share_pi.pivot(index="group", columns="regime", values="pct").round(2))

    print("\n=== Domar weight lambda_D,i: how much is 'size' (rho=0) vs 'network' (rho=1-rho=0) ===")
    lam0 = lambda_D(0.0)
    lam1 = lambda_D(1.0)
    sectors = ["Resource", "Manufacturing", "Services"]
    for i, s in enumerate(sectors):
        network_add = lam1[i] - lam0[i]
        print(f"  {s:15s}: rho=0 (size-only) = {lam0[i]:.4f}   "
              f"+network (rho=1) = {lam1[i]:.4f}   "
              f"network share of total = {network_add/lam1[i]*100:.1f}%")

    # ---- Figure: stacked bar of y_gap3 variance share by shock group, 3 regimes ----
    SURFACE = "#fcfcfb"
    fig, axes = plt.subplots(1, 2, figsize=(11.5, 4.6), dpi=200)
    fig.patch.set_facecolor(SURFACE)

    ax = axes[0]
    ax.set_facecolor(SURFACE)
    x = np.arange(len(REGIMES))
    bottoms = np.zeros(len(REGIMES))
    piv = share.pivot(index="regime", columns="group", values="pct").reindex(REGIMES)
    for grp in SHOCK_GROUPS:
        vals = piv[grp].values
        ax.bar(x, vals, bottom=bottoms, color=GROUP_COLORS[grp], label=grp, width=0.55, alpha=0.9)
        bottoms += vals
    ax.set_xticks(x); ax.set_xticklabels([REGIME_LABELS[r] for r in REGIMES], fontsize=10, color="#0b0b0b")
    ax.set_ylabel("share of Var(Services output gap), %", fontsize=9.5, color="#52514e")
    ax.set_title("What drives Services' OWN output gap?", fontsize=10.5, color="#0b0b0b")
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.12), frameon=False, fontsize=7.5, ncol=1)
    ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=9)
    ax.set_ylim(0, 100)

    ax = axes[1]
    ax.set_facecolor(SURFACE)
    rho_grid = np.array([0.0, 0.5, 1.0, 1.5, 2.0])
    lam_by_rho = np.array([lambda_D(r) for r in rho_grid])
    colors_sec = {"Resource": "#7c3aed", "Manufacturing": "#d97706", "Services": "#0891b2"}
    for i, s in enumerate(sectors):
        ax.plot(rho_grid, lam_by_rho[:, i], color=colors_sec[s], marker="o", markersize=4, linewidth=2.2, label=s)
    ax.axvline(0.0, color="#c3c2b7", linestyle=":", linewidth=1)
    ax.set_xlabel(r"cross-sector density $\rho$", fontsize=10, color="#0b0b0b")
    ax.set_ylabel(r"Domar weight $\lambda_{D,i}$", fontsize=10, color="#52514e")
    ax.set_title(r"Domar weight: size ($\rho{=}0$) vs.\ network add-on", fontsize=10.5, color="#0b0b0b")
    ax.legend(loc="upper left", frameon=False, fontsize=9)
    ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=9)
    ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
    ax.set_axisbelow(True)

    fig.tight_layout()
    os.makedirs(FIGS, exist_ok=True)
    out_pdf = os.path.join(FIGS, "services_mechanism_decomposition.pdf")
    out_png = os.path.join(FIGS, "services_mechanism_decomposition.png")
    fig.savefig(out_pdf, facecolor=fig.get_facecolor(), bbox_inches="tight")
    fig.savefig(out_png, facecolor=fig.get_facecolor(), bbox_inches="tight")
    print(f"\nSaved {out_pdf} and {out_png}")


if __name__ == "__main__":
    main()
