import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

rho = [0.00, 0.50, 1.00, 1.50, 2.00, 2.20]
rho_peg     = [73.0057, 77.9777, 90.4588, 117.1111, 174.2869, 213.9355]
rho_managed = [10.8387, 10.5883, 10.9593, 12.3985, 15.8451, 18.1947]
rho_float   = [21.5920, 22.2671, 25.2057, 31.0558, 40.1045, 44.5913]

regimes = ["Float", "Managed", "Peg"]
premium_resource = [-0.0202, 0.0021, -0.2947]
premium_manuf    = [-0.2513, -0.0122, -1.6230]
premium_services = [3.3856, 0.2504, 0.3709]

COLOR_PEG = "#dc2626"
COLOR_MANAGED = "#6b7280"
COLOR_FLOAT = "#16a34a"
COLOR_RESOURCE = "#7c3aed"
COLOR_MANUF = "#d97706"
COLOR_SERVICES = "#0891b2"
SURFACE = "#fcfcfb"


def style_axis(ax):
    ax.set_facecolor(SURFACE)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7")
    ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=10)
    ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
    ax.set_axisbelow(True)


# --- Main-deck figure: density sweep only (single panel, widened) ---
fig, ax = plt.subplots(1, 1, figsize=(6.5, 4.2), dpi=200)
fig.patch.set_facecolor(SURFACE)
ax.plot(rho, rho_peg, color=COLOR_PEG, linestyle=":", marker="o", markersize=4,
        linewidth=2, label="Peg")
ax.plot(rho, rho_managed, color=COLOR_MANAGED, linestyle="--", marker="o", markersize=4,
        linewidth=2, label="Managed")
ax.plot(rho, rho_float, color=COLOR_FLOAT, linestyle="-", marker="o", markersize=4,
        linewidth=2, label="Float")
ax.axvline(1.0, color="#c3c2b7", linestyle="--", linewidth=1)
ax.text(1.05, 15, "baseline", fontsize=9, color="#52514e")
ax.set_xlabel("density $\\rho$ (0 = no network)", fontsize=11, color="#0b0b0b")
ax.set_ylabel("welfare loss ($\\times10^4$)", fontsize=11, color="#52514e")
ax.legend(loc="upper left", frameon=False, fontsize=10)
style_axis(ax)
fig.tight_layout()
fig.savefig("isolating_network.pdf", facecolor=fig.get_facecolor(), bbox_inches="tight")
fig.savefig("isolating_network.png", facecolor=fig.get_facecolor(), bbox_inches="tight")

# --- Appendix figure: price-dispersion network premium by sector ---
fig, ax = plt.subplots(1, 1, figsize=(6.5, 4.2), dpi=200)
fig.patch.set_facecolor(SURFACE)
x = np.arange(len(regimes))
width = 0.25
ax.bar(x - width, premium_resource, width, color=COLOR_RESOURCE, label="Resource")
ax.bar(x, premium_manuf, width, color=COLOR_MANUF, label="Manuf.")
ax.bar(x + width, premium_services, width, color=COLOR_SERVICES, label="Services")
ax.axhline(0, color="#898781", linewidth=0.8)
ax.set_xticks(x)
ax.set_xticklabels(regimes, fontsize=11, color="#0b0b0b")
ax.set_ylabel("price-dispersion premium ($\\times10^4$, $\\rho{=}1$ vs.\\ $\\rho{=}0$)", fontsize=10, color="#52514e")
ax.legend(loc="upper right", frameon=False, fontsize=10)
style_axis(ax)
fig.tight_layout()
fig.savefig("isolating_network_premium.pdf", facecolor=fig.get_facecolor(), bbox_inches="tight")
fig.savefig("isolating_network_premium.png", facecolor=fig.get_facecolor(), bbox_inches="tight")

print("saved")
