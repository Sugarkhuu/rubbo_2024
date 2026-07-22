import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

zeta = [0.25, 0.50, 0.75, 1.00, 1.50, 2.00, 2.50]
zeta_peg     = [98.7374, 94.6417, 92.1972, 90.4454, 87.9569, 86.1814, 84.8007]
zeta_managed = [11.2843, 11.1172, 11.0230, 10.9584, 10.8709, 10.8118, 10.7680]
zeta_float   = [25.8147, 25.4700, 25.2804, 25.1519, 24.9798, 24.8646, 24.7791]

COLOR_PEG = "#dc2626"
COLOR_MANAGED = "#6b7280"
COLOR_FLOAT = "#16a34a"
SURFACE = "#fcfcfb"

fig, ax = plt.subplots(1, 1, figsize=(6.5, 4.2), dpi=200)
fig.patch.set_facecolor(SURFACE)

ax.set_facecolor(SURFACE)
ax.plot(zeta, zeta_peg, color=COLOR_PEG, linestyle=":", marker="o", markersize=4,
        linewidth=2, label="Peg")
ax.plot(zeta, zeta_managed, color=COLOR_MANAGED, linestyle="--", marker="o", markersize=4,
        linewidth=2, label="Managed")
ax.plot(zeta, zeta_float, color=COLOR_FLOAT, linestyle="-", marker="o", markersize=4,
        linewidth=2, label="Float")
ax.axvline(1.0, color="#c3c2b7", linestyle="--", linewidth=1)
ax.text(1.05, 8, "baseline", fontsize=9, color="#52514e")
ax.set_xlabel(r"export scale $\zeta$", fontsize=12, color="#0b0b0b")
ax.set_ylabel("welfare loss ($\\times10^4$)", fontsize=11, color="#52514e")
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["left"].set_color("#c3c2b7")
ax.spines["bottom"].set_color("#c3c2b7")
ax.tick_params(colors="#898781", labelsize=10)
ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
ax.set_axisbelow(True)
ax.set_ylim(0, max(zeta_peg) * 1.25)

ax.legend(loc="upper right", frameon=False, fontsize=11)

fig.tight_layout()
fig.savefig("export_openness_concentration.pdf", facecolor=fig.get_facecolor(), bbox_inches="tight")
fig.savefig("export_openness_concentration.png", facecolor=fig.get_facecolor(), bbox_inches="tight")
print("saved")
