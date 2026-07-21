import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

regimes = ["Float", "Managed", "Peg"]

# Network ON (baseline, real Chile Omega^H) -- from results_chile_exp
on = dict(
    output_gap=[0.9804, 2.2938, 70.0119],
    disp_resource=[0.0499, 0.0355, 0.2679],
    disp_manuf=[3.8667, 1.9162, 4.2843],
    disp_services=[20.2549, 6.7129, 15.8813],
)
# Network OFF (Omega^H = 0) -- from results_chile_exp_nonetwork
off = dict(
    output_gap=[0.2010, 1.1358, 13.4888],
    disp_resource=[0.0276, 0.0153, 0.2650],
    disp_manuf=[2.2295, 0.9361, 5.3166],
    disp_services=[6.2151, 3.7357, 14.5904],
)

COLOR_OUTPUT_GAP = "#334155"
COLOR_RESOURCE = "#7c3aed"
COLOR_MANUF = "#d97706"
COLOR_SERVICES = "#0891b2"
SURFACE = "#fcfcfb"

fig, ax = plt.subplots(figsize=(9.4, 4.8), dpi=200)
fig.patch.set_facecolor(SURFACE)
ax.set_facecolor(SURFACE)

x = np.arange(len(regimes))
width = 0.32
gap = 0.02
x_on = x - width / 2 - gap / 2
x_off = x + width / 2 + gap / 2

series = [
    ("Output gap", "output_gap", COLOR_OUTPUT_GAP),
    ("Disp. Resource", "disp_resource", COLOR_RESOURCE),
    ("Disp. Manuf.", "disp_manuf", COLOR_MANUF),
    ("Disp. Services", "disp_services", COLOR_SERVICES),
]

bottom_on = np.zeros(len(regimes))
for label, key, color in series:
    vals = np.array(on[key])
    ax.bar(x_on, vals, width, bottom=bottom_on, color=color, label=label)
    bottom_on += vals

bottom_off = np.zeros(len(regimes))
for label, key, color in series:
    vals = np.array(off[key])
    ax.bar(x_off, vals, width, bottom=bottom_off, color=color, alpha=0.45, hatch="//", edgecolor=SURFACE, linewidth=0.4)
    bottom_off += vals

for i in range(len(regimes)):
    ax.text(x_on[i], bottom_on[i] + 1.5, f"{bottom_on[i]:.2f}", ha="center", fontsize=9.5, color="#0b0b0b")
    ax.text(x_off[i], bottom_off[i] + 1.5, f"{bottom_off[i]:.2f}", ha="center", fontsize=9.5, color="#52514e")
    ax.text(x_on[i], -6, "ON", ha="center", fontsize=8, color="#52514e")
    ax.text(x_off[i], -6, "OFF", ha="center", fontsize=8, color="#52514e")

ax.set_xticks(x)
ax.set_xticklabels(regimes, fontsize=12, color="#0b0b0b")
ax.set_ylabel("welfare loss ($\\times10^4$)", fontsize=11, color="#52514e")
ax.set_ylim(0, 112)
ax.legend(loc="upper left", frameon=False, fontsize=9)
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
