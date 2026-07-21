import os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHOCK = "eps_pF"  # imported-input (foreign price) shock -- the motivating shock
HORIZON = 20

REGIMES = ["float", "managed", "peg"]
REGIME_LABEL = {"float": "Float", "managed": "Managed", "peg": "Peg"}
REGIME_COLOR = {"float": "#16a34a", "managed": "#6b7280", "peg": "#dc2626"}
COLOR_OFF = "#c3c2b7"
SURFACE = "#fcfcfb"

panels = [
    ("piDC", "DC inflation ($\\pi_t^{DC}$)"),
    ("S", "exchange rate ($\\hat s_t$)"),
    ("y_gap", "output gap ($\\tilde y_t$)"),
]

fig, axes = plt.subplots(3, 3, figsize=(11.5, 8.2), dpi=200)
fig.patch.set_facecolor(SURFACE)
t = range(HORIZON)

for row, regime in enumerate(REGIMES):
    on = pd.read_csv(os.path.join(REPO_ROOT, "results_chile_exp", f"irf_{regime}_{SHOCK}.csv")).iloc[:HORIZON]
    off = pd.read_csv(os.path.join(REPO_ROOT, "results_chile_exp_nonetwork", f"irf_{regime}_{SHOCK}.csv")).iloc[:HORIZON]
    color_on = REGIME_COLOR[regime]
    for col, (var, title) in enumerate(panels):
        ax = axes[row, col]
        ax.set_facecolor(SURFACE)
        ax.axhline(0, color="#c3c2b7", linewidth=0.8)
        ax.plot(t, off[var] * 100, color=COLOR_OFF, linestyle="--", linewidth=1.8,
                 label="Network OFF" if (row == 0 and col == 0) else None)
        ax.plot(t, on[var] * 100, color=color_on, linestyle="-", linewidth=1.8,
                 label="Network ON" if (row == 0 and col == 0) else None)
        if row == 0:
            ax.set_title(title, fontsize=10.5, color="#0b0b0b")
        if col == 0:
            ax.set_ylabel(f"{REGIME_LABEL[regime]}\npercent", fontsize=9.5, color="#52514e")
        if row == 2:
            ax.set_xlabel("quarters", fontsize=9.5, color="#52514e")
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_color("#c3c2b7")
        ax.spines["bottom"].set_color("#c3c2b7")
        ax.tick_params(colors="#898781", labelsize=8.5)
        ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
        ax.set_axisbelow(True)

handles, labels = axes[0, 0].get_legend_handles_labels()
fig.legend(handles, labels, loc="upper center", ncol=2, frameon=False, fontsize=10.5, bbox_to_anchor=(0.5, 1.02))
fig.suptitle("Import-price shock, real Chile calibration -- each row a regime", fontsize=10, color="#52514e", y=1.055)
fig.tight_layout()
fig.savefig(os.path.join(REPO_ROOT, "figs", "mechanism_network.pdf"), facecolor=fig.get_facecolor(), bbox_inches="tight")
fig.savefig(os.path.join(REPO_ROOT, "figs", "mechanism_network.png"), facecolor=fig.get_facecolor(), bbox_inches="tight")
print("saved")
