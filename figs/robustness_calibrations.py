import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

regimes = ["Float", "Managed", "Peg"]
calibrations = [
    ("Chile", [25.15, 10.96, 90.45], "#16a34a"),
    ("S. Korea", [38.91, 14.43, 133.81], "#d97706"),
    ("Czechia", [32.20, 11.82, 84.03], "#dc2626"),
]

SURFACE = "#fcfcfb"

fig, ax = plt.subplots(figsize=(8.6, 4.6), dpi=200)
fig.patch.set_facecolor(SURFACE)
ax.set_facecolor(SURFACE)

x = np.arange(len(regimes))
n = len(calibrations)
width = 0.24
offsets = (np.arange(n) - (n - 1) / 2) * width

for (label, vals, color), off in zip(calibrations, offsets):
    bars = ax.bar(x + off, vals, width, color=color, label=label,
                   edgecolor=color, linewidth=0.8)
    for rect, v in zip(bars, vals):
        ax.text(rect.get_x() + rect.get_width() / 2, rect.get_height() + 2, f"{v:.2f}",
                ha="center", va="bottom", fontsize=8, color="#0b0b0b", rotation=90)

ax.set_xticks(x)
ax.set_xticklabels(regimes, fontsize=13, color="#0b0b0b")
ax.set_ylabel("welfare loss ($\\times10^4$)", fontsize=12, color="#52514e")
ax.set_ylim(0, 155)
ax.legend(loc="upper center", ncol=3, frameon=False, fontsize=10, bbox_to_anchor=(0.5, 1.12))
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["left"].set_color("#c3c2b7")
ax.spines["bottom"].set_color("#c3c2b7")
ax.tick_params(colors="#898781", labelsize=10)
ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
ax.set_axisbelow(True)

fig.tight_layout()
fig.savefig("robustness_calibrations.pdf", facecolor=fig.get_facecolor(), bbox_inches="tight")
fig.savefig("robustness_calibrations.png", facecolor=fig.get_facecolor(), bbox_inches="tight")
print("saved")
