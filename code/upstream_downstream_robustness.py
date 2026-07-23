"""
Adam's feedback (2026-07-22): "robustness on sectors that are upstream vs
downstream" -- is the Services story (low direct import share, but high
INDIRECT exposure inherited from suppliers) a general pattern, or just an
artifact of one sector in one calibration?

With only 3 aggregated sectors, a sharp upstream/downstream classification
is not really identifiable within one calibration -- Chile's Services
sector is itself heavily bought FROM by Resource and Manufacturing
(0.1932+0.1453 domestic cost share), so it's a hub, not a purely distal
"downstream" sector. Instead of forcing an upstream/downstream label, this
tests the cleaner, well-defined claim implied by the mechanism: **a
sector's OWN indirect import exposure share should be predictable from how
much it buys from other domestic sectors (row-sum off-diagonal Omega^H_i),
independent of which specific sector that is** -- i.e. "buyer dependence
on the domestic network" should predict "how much of my import exposure is
inherited," almost by construction of the Leontief-inverse formula, but
worth checking it holds with real numbers, not just algebraically.

Pools all 3 real calibrations (Chile, Korea, Czechia) x 3 sectors = 9
independent (buyer_dependence, indirect_share) pairs -- three separate
national IO tables, not the same data three times -- for more power than
one calibration's n=3 alone.

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/upstream_downstream_robustness.py
"""
import os
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FIGS = os.path.join(REPO_ROOT, "figs")
RESULTS = os.path.join(REPO_ROOT, "results")
SECTORS = ["Resource", "Manufacturing", "Services"]

# OH_ij = buyer i's cost share on seller j (row = buyer). OF_i = import cost share.
CALIBRATIONS = {
    "Chile": dict(
        OH=np.array([[0.0750, 0.1526, 0.1932],
                      [0.0991, 0.2022, 0.1453],
                      [0.0018, 0.0581, 0.2661]]),
        OF=np.array([0.0767, 0.1945, 0.0704]),
    ),
    "Korea": dict(
        OH=np.array([[0.0444, 0.3106, 0.1470],
                      [0.0147, 0.3624, 0.1238],
                      [0.0050, 0.1430, 0.2438]]),
        OF=np.array([0.0404, 0.2409, 0.0508]),
    ),
    "Czechia": dict(
        OH=np.array([[0.1244, 0.1667, 0.1521],
                      [0.0207, 0.2624, 0.1432],
                      [0.0035, 0.0672, 0.2798]]),
        OF=np.array([0.1560, 0.3178, 0.1009]),
    ),
}


def analyze(name, OH, OF):
    M = np.linalg.inv(np.eye(3) - OH) @ OF
    indirect = M - OF
    indirect_share = indirect / M
    buyer_dependence = OH.sum(axis=1) - np.diag(OH)  # row sum, off-diagonal: how much i buys from OTHER sectors
    return pd.DataFrame({
        "calibration": name, "sector": SECTORS,
        "direct": OF, "total": M, "indirect_share": indirect_share,
        "buyer_dependence": buyer_dependence,
    })


def main():
    dfs = [analyze(name, c["OH"], c["OF"]) for name, c in CALIBRATIONS.items()]
    df = pd.concat(dfs, ignore_index=True)
    df.to_csv(os.path.join(RESULTS, "upstream_downstream_robustness.csv"), index=False)

    print("=== Buyer-dependence (row-sum, buys from OTHER domestic sectors) vs. indirect import-exposure share ===")
    print(df[["calibration", "sector", "buyer_dependence", "indirect_share"]].round(3).to_string(index=False))

    corr = df["buyer_dependence"].corr(df["indirect_share"])
    print(f"\nPooled correlation (n={len(df)}, 3 calibrations x 3 sectors): r = {corr:.3f}")

    SURFACE = "#fcfcfb"
    MARKERS = {"Chile": "o", "Korea": "s", "Czechia": "^"}
    COLORS = {"Resource": "#7c3aed", "Manufacturing": "#d97706", "Services": "#0891b2"}
    fig, ax = plt.subplots(figsize=(6.4, 4.8), dpi=200)
    fig.patch.set_facecolor(SURFACE)
    ax.set_facecolor(SURFACE)
    for _, r in df.iterrows():
        ax.scatter(r["buyer_dependence"], r["indirect_share"], marker=MARKERS[r["calibration"]],
                   color=COLORS[r["sector"]], s=90, edgecolor="white", linewidth=0.8, zorder=5)
    # regression line
    x = df["buyer_dependence"].values; y = df["indirect_share"].values
    b, a = np.polyfit(x, y, 1)
    xx = np.linspace(x.min() * 0.9, x.max() * 1.05, 20)
    ax.plot(xx, a + b * xx, color="#898781", linestyle="--", linewidth=1.3, zorder=1)
    ax.text(0.03, 0.95, f"pooled $r={corr:.2f}$, $n=9$\n(3 calibrations $\\times$ 3 sectors)",
            transform=ax.transAxes, fontsize=9, va="top", color="#52514e")
    for sec, col in COLORS.items():
        ax.scatter([], [], color=col, label=sec, s=70)
    for name, mk in MARKERS.items():
        ax.scatter([], [], marker=mk, color="#52514e", label=name, s=70)
    ax.set_xlabel(r"buyer dependence: $\sum_{j\neq i}\Omega^H_{ij}$ (buys from other domestic sectors)", fontsize=9.5, color="#0b0b0b")
    ax.set_ylabel("indirect share of total import exposure", fontsize=10, color="#52514e")
    ax.legend(loc="lower right", frameon=False, fontsize=8, ncol=2)
    ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=9)
    ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
    ax.set_axisbelow(True)
    fig.tight_layout()

    out_pdf = os.path.join(FIGS, "upstream_downstream_robustness.pdf")
    out_png = os.path.join(FIGS, "upstream_downstream_robustness.png")
    fig.savefig(out_pdf, facecolor=fig.get_facecolor(), bbox_inches="tight")
    fig.savefig(out_png, facecolor=fig.get_facecolor(), bbox_inches="tight")
    print(f"\nSaved {out_pdf} and {out_png}")


if __name__ == "__main__":
    main()
