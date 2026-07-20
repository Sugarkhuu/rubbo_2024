import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

regimes = ["Float", "Managed", "Peg"]
tfp           = [23.14, 8.02, 11.31]
import_price  = [0.07, 1.05, 10.09]
foreign_dem   = [0.05, 0.13, 1.67]
export_price  = [0.11, 0.18, 2.16]
risk_premium  = [2.11, 0.79, 76.83]

COLOR_TFP = "#6b7280"
COLOR_IMPORT = "#2a78d6"
COLOR_FOREIGN = "#0891b2"
COLOR_EXPORT = "#d97706"
COLOR_RISK = "#dc2626"
SURFACE = "#fcfcfb"

fig, ax = plt.subplots(figsize=(8.6, 4.6), dpi=200)
fig.patch.set_facecolor(SURFACE)
ax.set_facecolor(SURFACE)

x = np.arange(len(regimes))
width = 0.55
bottom = np.zeros(len(regimes))
series = [
    ("TFP", tfp, COLOR_TFP),
    ("Import price (FX)", import_price, COLOR_IMPORT),
    ("Foreign demand", foreign_dem, COLOR_FOREIGN),
    ("Export price (ToT)", export_price, COLOR_EXPORT),
    ("Risk premium (UIP)", risk_premium, COLOR_RISK),
]
for label, vals, color in series:
    ax.bar(x, vals, width, bottom=bottom, color=color, label=label)
    bottom += np.array(vals)

for i, total in enumerate(bottom):
    ax.text(x[i], total + 1.5, f"{total:.2f}", ha="center", fontsize=11, color="#0b0b0b")

ax.set_xticks(x)
ax.set_xticklabels(regimes, fontsize=13, color="#0b0b0b")
ax.set_ylabel("welfare loss ($\\times10^4$)", fontsize=12, color="#52514e")
ax.set_ylim(0, 112)
ax.legend(loc="upper left", frameon=False, fontsize=10.5)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["left"].set_color("#c3c2b7")
ax.spines["bottom"].set_color("#c3c2b7")
ax.tick_params(colors="#898781", labelsize=10)
ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
ax.set_axisbelow(True)

fig.tight_layout()
fig.savefig("shock_decomposition.pdf", facecolor=fig.get_facecolor(), bbox_inches="tight")
fig.savefig("shock_decomposition.png", facecolor=fig.get_facecolor(), bbox_inches="tight")
print("saved")
