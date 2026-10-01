"""Summarize results/opt_rule_grid.csv (code/opt_rule_point.m output).

For each scenario: (i) global optimum over the (phi_pi, phi_y, phi_s) grid; (ii) the best plain
Taylor rule (phi_s = 0); (iii) the value of the FX term = (ii)-(i) as % of (ii); (iv) optimal
phi_s at the baseline (phi_pi=1.5, phi_y=0.5); (v) boundary flags. Losses in units of 1e-4.
"""
import os
import pandas as pd
import numpy as np

R = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "results")
df = pd.concat([pd.read_csv(os.path.join(R, f)) for f in ("opt_rule_grid.csv", "opt_rule_grid_hipi.csv")
                if os.path.exists(os.path.join(R, f))]).drop_duplicates(["scen", "phi_pi", "phi_y", "phi_s"])
df = df[df.status == 0].reset_index(drop=True)
df["L"] = df.total * 1e4
PI, Y, S = sorted(df.phi_pi.unique()), sorted(df.phi_y.unique()), sorted(df.phi_s.unique())

rows = []
for scen, g in df.groupby("scen", sort=False):
    best = g.loc[g.L.idxmin()]
    taylor = g[g.phi_s == 0]
    bt = taylor.loc[taylor.L.idxmin()]
    base = g[(g.phi_pi == 1.5) & (g.phi_y == 0.5)]
    bb = base.loc[base.L.idxmin()]
    b0 = base[base.phi_s == 0].L.iloc[0]
    edge = []
    if best.phi_pi in (PI[0], PI[-1]): edge.append("pi")
    if best.phi_y in (Y[0], Y[-1]): edge.append("y")
    if best.phi_s in (S[0], S[-1]): edge.append("s")
    rows.append(dict(scen=scen, rho=best.rho, rp=best.rp_scale,
                     L_opt=best.L, pi_opt=best.phi_pi, y_opt=best.phi_y, s_opt=best.phi_s,
                     L_taylor=bt.L, pi_T=bt.phi_pi, y_T=bt.phi_y,
                     fx_value_pct=100 * (bt.L - best.L) / bt.L,
                     s_opt_at_base=bb.phi_s, L_base_opt=bb.L, L_base_s0=b0,
                     L_base_s03=base[base.phi_s == 0.3].L.iloc[0], edge="/".join(edge),
                     n_ok=len(g)))
out = pd.DataFrame(rows)
out.to_csv(os.path.join(R, "opt_rule_summary.csv"), index=False)
pd.set_option("display.width", 250)
print(out.round(2).to_string(index=False))

# ---- clean slice: the near-optimal plain rule (phi_pi=20, phi_y=1) -------------------------------
sl = df[(df.phi_pi == 20) & (df.phi_y == 1)]
rows2 = []
for scen, g in sl.groupby("scen", sort=False):
    g = g.sort_values("phi_s")
    b = g.loc[g.L.idxmin()]
    L0 = g[g.phi_s == 0].L.iloc[0]
    plateau = g[g.L <= 1.01 * b.L].phi_s
    rows2.append(dict(scen=scen, rho=b.rho, rp=b.rp_scale, L_s0=L0, L_best=b.L, s_star=b.phi_s,
                      plateau_lo=plateau.min(), plateau_hi=plateau.max(),
                      fx_value_pct=100 * (L0 - b.L) / L0, L_s03=g[g.phi_s == 0.3].L.iloc[0]))
sl_out = pd.DataFrame(rows2)
sl_out.to_csv(os.path.join(R, "opt_rule_slice_pi20_y1.csv"), index=False)
print("\n=== slice phi_pi=20, phi_y=1 ===")
print(sl_out.round(2).to_string(index=False))
