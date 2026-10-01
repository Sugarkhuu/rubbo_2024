"""Figures for the optimal-FX-rule exercise (results/opt_rule_*.csv).
  opt_rule_network.pdf : value of the FX term and optimal phi_s vs network density, by risk-premium size
  opt_rule_regimes.pdf : welfare loss by regime, baseline rules vs optimized rules, no network vs network
"""
import os
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
R = os.path.join(os.path.dirname(HERE), "results")
sl = pd.read_csv(os.path.join(R, "opt_rule_slice_pi20_y1.csv"))
sl = sl[sl.scen.str.startswith("net_")]
peg = pd.read_csv(os.path.join(R, "opt_rule_peg.csv"))
summ = pd.read_csv(os.path.join(R, "opt_rule_summary.csv"))

C_FLOAT, C_PEG, C_MAN = "#2563EB", "#DC2626", "#16A34A"
plt.rcParams.update({"font.size": 9, "axes.spines.top": False, "axes.spines.right": False})

# ---- Figure 1 -----------------------------------------------------------------------------------
fig, ax = plt.subplots(1, 2, figsize=(7.2, 2.9))
cols = {0.0: "#6B7280", 1.0: "#2563EB", 2.0: "#DC2626"}
labs = {0.0: "no risk-premium shock", 1.0: "baseline (1%)", 2.0: "doubled (2%)"}
for rp, c in cols.items():
    g = sl[sl.rp == rp].sort_values("rho")
    ax[0].plot(g.rho, g.fx_value_pct, marker="o", color=c, label=labs[rp])
    ax[1].plot(g.rho, g.s_star, marker="o", color=c)
ax[0].set_xlabel(r"network density $\rho$ (1 = Chile data)")
ax[0].set_ylabel("welfare gain from FX term (%)")
ax[0].set_title("Value of responding to the exchange rate", fontsize=9)
ax[0].legend(frameon=False, fontsize=8)
ax[1].set_xlabel(r"network density $\rho$")
ax[1].set_ylabel(r"optimal $\phi_s$")
ax[1].set_title(r"Optimal FX weight ($\phi_\pi=20,\ \phi_y=1$)", fontsize=9)
fig.tight_layout()
fig.savefig(os.path.join(HERE, "opt_rule_network.pdf"))
fig.savefig(os.path.join(HERE, "opt_rule_network.png"), dpi=200)

# ---- Figure 2 -----------------------------------------------------------------------------------
fig, ax = plt.subplots(1, 2, figsize=(7.2, 3.0), sharey=True)
for a, rho in zip(ax, [0.0, 1.0]):
    s = summ[(summ.rho == rho) & (summ.rp == 1.0) & summ.scen.str.startswith("net_")].iloc[0]
    sl1 = sl[(sl.rho == rho) & (sl.rp == 1.0)].iloc[0]
    pg = peg[(peg.rho == rho) & (peg.rp_scale == 1.0)].total.iloc[0] * 1e4
    vals = [s.L_base_s0, s.L_base_s03, sl1.L_s0, sl1.L_best, pg]
    names = ["Float\n(baseline rule)", "Managed\n(baseline rule)", "Float\n(optimized)", "Managed\n(optimized)", "Peg"]
    colors = [C_FLOAT, C_MAN, C_FLOAT, C_MAN, C_PEG]
    hatch = ["", "", "//", "//", ""]
    bars = a.bar(range(5), vals, color=colors, hatch=hatch, edgecolor="white")
    for i, v in enumerate(vals):
        a.text(i, v + 1.5, f"{v:.1f}", ha="center", fontsize=8)
    a.set_xticks(range(5))
    a.set_xticklabels(names, fontsize=7)
    a.set_title(("No network ($\\rho=0$)" if rho == 0 else "Chile network ($\\rho=1$)"), fontsize=9)
ax[0].set_ylabel(r"welfare loss ($\times10^{-4}$)")
fig.tight_layout()
fig.savefig(os.path.join(HERE, "opt_rule_regimes.pdf"))
fig.savefig(os.path.join(HERE, "opt_rule_regimes.png"), dpi=200)
print("ok")
