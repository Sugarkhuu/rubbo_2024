import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

categories = ["Resource", "Manuf.", "Services"]

series = [
    (r"$\lambda_{D,i}$", [0.072, 0.382, 1.108], "#2a78d6"),
    ("Import share", [0.0767, 0.1945, 0.0704], "#1baf7a"),
    (r"$\mathcal{M}_i$", [0.155, 0.285, 0.119], "#008300"),
    ("Export share", [0.602, 0.180, 0.036], "#e87ba4"),
    (r"$\mathcal{M}_i^X$", [0.721, 0.329, 0.077], "#eda100"),
]

n_series = len(series)
n_cat = len(categories)
x = np.arange(n_cat)
bar_width = 0.115
group_span = bar_width * n_series

fig, ax = plt.subplots(figsize=(9, 4.2), dpi=200)
fig.patch.set_facecolor("#fcfcfb")
ax.set_facecolor("#fcfcfb")

for i, (label, values, color) in enumerate(series):
    offset = (i - (n_series - 1) / 2) * bar_width
    bars = ax.bar(x + offset, values, width=bar_width * 0.92, color=color,
                   edgecolor="none", label=label, zorder=3)
    for rect, v in zip(bars, values):
        ax.text(rect.get_x() + rect.get_width() / 2, rect.get_height() + 0.02,
                f"{v:.2f}" if v >= 0.01 else f"{v:.4f}",
                ha="center", va="bottom", fontsize=9.5, color="#0b0b0b")

ax.set_xticks(x)
ax.set_xticklabels(categories, fontsize=13, color="#0b0b0b")
ax.set_ylim(0, 1.25)
ax.set_ylabel("value", fontsize=11, color="#52514e")

ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["left"].set_visible(False)
ax.spines["bottom"].set_color("#c3c2b7")
ax.tick_params(axis="y", colors="#898781", labelsize=10)
ax.tick_params(axis="x", length=0)
ax.yaxis.grid(True, color="#e1e0d9", linewidth=0.8, zorder=0)
ax.set_axisbelow(True)

ax.legend(loc="upper center", bbox_to_anchor=(0.5, 1.16), ncol=5,
          frameon=False, fontsize=10, handlelength=1.2, columnspacing=1.1)

fig.tight_layout()
fig.savefig("network_properties.pdf", facecolor=fig.get_facecolor(), bbox_inches="tight")
fig.savefig("network_properties.png", facecolor=fig.get_facecolor(), bbox_inches="tight")
print("saved")
