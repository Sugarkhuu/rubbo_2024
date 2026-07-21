import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

regimes = ["Float", "Managed", "Peg"]

output_gap = [0.98, 2.29, 70.01]
disp_resource = [0.05, 0.04, 0.27]
disp_manuf = [3.87, 1.92, 4.28]
disp_services = [20.25, 6.71, 15.88]

COLOR_OUTPUT_GAP = "#334155"
COLOR_RESOURCE = "#7c3aed"
COLOR_MANUF = "#d97706"
COLOR_SERVICES = "#0891b2"
SURFACE = "#fcfcfb"

fig, ax = plt.subplots(figsize=(8.6, 4.6), dpi=200)
fig.patch.set_facecolor(SURFACE)
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

for i, total in enumerate(bottom):
    ax.text(x[i], total + 1.5, f"{total:.2f}", ha="center", fontsize=10.5, color="#0b0b0b")

ax.set_xticks(x)
ax.set_xticklabels(regimes, fontsize=12, color="#0b0b0b")
ax.set_ylabel("welfare loss ($\\times10^4$)", fontsize=11, color="#52514e")
ax.set_ylim(0, 112)
ax.legend(loc="upper left", frameon=False, fontsize=9.5)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["left"].set_color("#c3c2b7")
ax.spines["bottom"].set_color("#c3c2b7")
ax.tick_params(colors="#898781", labelsize=10)
ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
ax.set_axisbelow(True)

fig.tight_layout()
fig.savefig("welfare_gap_dispersion.pdf", facecolor=fig.get_facecolor(), bbox_inches="tight")
fig.savefig("welfare_gap_dispersion.png", facecolor=fig.get_facecolor(), bbox_inches="tight")
print("saved")
