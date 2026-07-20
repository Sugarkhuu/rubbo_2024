import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

zeta = [0.25, 0.50, 0.75, 1.00, 1.50, 2.00, 2.50]
zeta_peg     = [68.0923, 60.6833, 54.6193, 49.6315, 42.1035, 36.9361, 33.4123]
zeta_managed = [7.4890, 6.4723, 5.7864, 5.3573, 5.0557, 5.2553, 5.7752]
zeta_float   = [11.3694, 11.8072, 12.5905, 13.6393, 16.3097, 19.5097, 23.0897]

theta = [0.00, 0.25, 0.50, 0.75, 1.00, 1.25, 1.50]
theta_peg     = [36.7987, 39.3696, 42.3178, 45.7107, 49.6315, 54.1842, 59.4992]
theta_managed = [4.8775, 4.9072, 4.9898, 5.1356, 5.3573, 5.6708, 6.0956]
theta_float   = [16.2751, 15.5831, 14.9098, 14.2598, 13.6393, 13.0564, 12.5219]

COLOR_PEG = "#dc2626"
COLOR_MANAGED = "#6b7280"
COLOR_FLOAT = "#16a34a"
SURFACE = "#fcfcfb"

fig, axes = plt.subplots(1, 2, figsize=(11, 4.0), dpi=200)
fig.patch.set_facecolor(SURFACE)

panels = [
    (axes[0], zeta, zeta_peg, zeta_managed, zeta_float, r"scale $\zeta$"),
    (axes[1], theta, theta_peg, theta_managed, theta_float, r"concentration $\theta_M$"),
]

for ax, x, peg, managed, floatv, xlabel in panels:
    ax.set_facecolor(SURFACE)
    ax.plot(x, peg, color=COLOR_PEG, linestyle=":", marker="o", markersize=4,
            linewidth=2, label="Peg")
    ax.plot(x, managed, color=COLOR_MANAGED, linestyle="--", marker="o", markersize=4,
            linewidth=2, label="Managed")
    ax.plot(x, floatv, color=COLOR_FLOAT, linestyle="-", marker="o", markersize=4,
            linewidth=2, label="Float")
    ax.set_xlabel(xlabel, fontsize=12, color="#0b0b0b")
    ax.set_ylabel("welfare loss ($\\times10^4$)", fontsize=11, color="#52514e")
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7")
    ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=10)
    ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
    ax.set_axisbelow(True)

handles, labels = axes[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="upper center", ncol=3, frameon=False,
           fontsize=12, bbox_to_anchor=(0.5, 1.06))

fig.tight_layout()
fig.savefig("openness_concentration.pdf", facecolor=fig.get_facecolor(), bbox_inches="tight")
fig.savefig("openness_concentration.png", facecolor=fig.get_facecolor(), bbox_inches="tight")
print("saved")
