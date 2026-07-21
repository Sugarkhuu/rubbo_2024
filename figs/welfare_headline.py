import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

regimes = ["Float", "Managed", "Peg"]
totals = [25.15, 10.96, 90.45]

output_gap = [0.98, 2.29, 70.01]
disp_resource = [0.05, 0.04, 0.27]
disp_manuf = [3.87, 1.92, 4.28]
disp_services = [20.25, 6.71, 15.88]

COLOR_TOTAL = "#2a78d6"
COLOR_OUTPUT_GAP = "#334155"
COLOR_RESOURCE = "#7c3aed"
COLOR_MANUF = "#d97706"
COLOR_SERVICES = "#0891b2"
SURFACE = "#fcfcfb"

fig, axes = plt.subplots(1, 2, figsize=(11, 4.0), dpi=200)
fig.patch.set_facecolor(SURFACE)

# --- Left: total welfare loss, horizontal bars ---
ax = axes[0]
ax.set_facecolor(SURFACE)
y = np.arange(len(regimes))
bars = ax.barh(y, totals, color=COLOR_TOTAL, height=0.55)
for rect, v in zip(bars, totals):
    ax.text(rect.get_width() + 1.5, rect.get_y() + rect.get_height() / 2, f"{v:.2f}",
            va="center", fontsize=11, color="#0b0b0b")
ax.set_yticks(y)
ax.set_yticklabels(regimes, fontsize=12, color="#0b0b0b")
ax.set_xlabel("welfare loss ($\\times10^4$)", fontsize=11, color="#52514e")
ax.set_xlim(0, 112)
ax.invert_yaxis()
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["left"].set_visible(False)
ax.spines["bottom"].set_color("#c3c2b7")
ax.tick_params(colors="#898781", labelsize=10)
ax.xaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
ax.set_axisbelow(True)

# --- Right: output-gap vs. sector dispersion, stacked bars ---
ax = axes[1]
ax.set_facecolor(SURFACE)
x = np.arange(len(regimes))
width = 0.55
bottom = np.zeros(len(regimes))
for label, vals, color in [
    ("Output gap", output_gap, COLOR_OUTPUT_GAP),
    ("Disp. Resource", disp_resource, COLOR_RESOURCE),
    ("Disp. Manuf.", disp_manuf, COLOR_MANUF),
    ("Disp. Services", disp_services, COLOR_SERVICES),
]:
    ax.bar(x, vals, width, bottom=bottom, color=color, label=label)
    bottom += np.array(vals)
ax.set_xticks(x)
ax.set_xticklabels(regimes, fontsize=12, color="#0b0b0b")
ax.set_ylabel("welfare loss ($\\times10^4$)", fontsize=11, color="#52514e")
ax.legend(loc="upper left", frameon=False, fontsize=9.5)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["left"].set_color("#c3c2b7")
ax.spines["bottom"].set_color("#c3c2b7")
ax.tick_params(colors="#898781", labelsize=10)
ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
ax.set_axisbelow(True)

fig.tight_layout()
fig.savefig("welfare_headline.pdf", facecolor=fig.get_facecolor(), bbox_inches="tight")
fig.savefig("welfare_headline.png", facecolor=fig.get_facecolor(), bbox_inches="tight")
print("saved")
