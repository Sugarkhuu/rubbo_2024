"""Analytic 'anatomy' objects of the 3-sector Chile calibration as a function of network density rho.

 - Domar weights lambda(rho), total import centrality M(rho) split direct/indirect
 - Pass-through vector Gamma ~ A_tilde * Omega^F  (A_tilde = Delta (I - Omega^H Delta)^-1) and labor
   vector B ~ A_tilde * alpha: how far is Gamma from proportional to B (the knife-edge)?
 - DC-index weights and the 'DC-residual exposure' s = w_DC' Gamma: the part of FX pass-through that the
   divine-coincidence index cannot remove. This is the analytic quantity that should predict how much an
   explicit exchange-rate term in the policy rule is worth.
 - Christian's two-sector worked example (speech_feedback_20260722.txt).
"""
import os
import numpy as np
import pandas as pd

R = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "results")
BETA = 0.99
OH_diag = np.array([0.0750, 0.2022, 0.2661])
OH_off = np.array([[0.1526, 0.1932], [0.0991, 0.1453], [0.0018, 0.0581]])
OF = np.array([0.0767, 0.1945, 0.0704])
BH = np.array([0.0265, 0.2294, 0.7441])
DELTA = np.array([0.90, 0.31, 0.16])
dhat = DELTA * (1 - BETA * (1 - DELTA)) / (1 - BETA * DELTA * (1 - DELTA))


def build(rho, OF_vec=OF, dhat_vec=dhat):
    OH = np.zeros((3, 3))
    for i in range(3):
        OH[i, i] = OH_diag[i]
        cols = [j for j in range(3) if j != i]
        OH[i, cols] = rho * OH_off[i]
    alpha = 1 - OH.sum(1) - OF_vec
    return OH, alpha


def objects(rho, OF_vec=OF, dhat_vec=dhat):
    OH, alpha = build(rho, OF_vec, dhat_vec)
    I = np.eye(3)
    lam = BH @ np.linalg.inv(I - OH)
    Minv = np.linalg.inv(I - OH)
    M_total = Minv @ OF_vec
    M_direct = OF_vec
    D = np.diag(dhat_vec)
    At = D @ np.linalg.inv(I - OH @ D)
    kappa = 1 - BH @ At @ alpha
    Bv = At @ alpha / kappa
    Gam = At @ OF_vec / kappa
    w = lam * (1 - dhat_vec) / dhat_vec
    w = w / w.sum()
    cos = Gam @ Bv / np.linalg.norm(Gam) / np.linalg.norm(Bv)
    # DC-residual exposure: scale-free = (w'Gamma) / (w'B)  vs  mean ratio Gamma_i/B_i
    resid = (w @ Gam) / (w @ Bv)
    return dict(rho=rho, lam1=lam[0], lam2=lam[1], lam3=lam[2], M1=M_total[0], M2=M_total[1], M3=M_total[2],
                ind3=(M_total[2] - M_direct[2]) / M_total[2], Gam1=Gam[0], Gam2=Gam[1], Gam3=Gam[2],
                B1=Bv[0], B2=Bv[1], B3=Bv[2], w_DC1=w[0], w_DC2=w[1], w_DC3=w[2],
                cos_Gamma_B=cos, wGamma=w @ Gam, wB=w @ Bv, resid_ratio=resid,
                dist_from_knife_edge=1 - cos)


if __name__ == "__main__":
    rows = [objects(r) for r in [0, 0.5, 1, 1.5]]
    # ablations: uniform OF, uniform stickiness
    for name, kw in [("unifOF", dict(OF_vec=np.array([0.1, 0.1, 0.1]))),
                     ("unifDelta", dict(dhat_vec=np.full(3, 0.23 * (1 - BETA * 0.77) / (1 - BETA * 0.23 * 0.77))))]:
        for r in [0, 1]:
            d = objects(r, **kw); d["rho"] = f"{name}_r{r}"; rows.append(d)
    out = pd.DataFrame(rows)
    out.to_csv(os.path.join(R, "network_anatomy.csv"), index=False)
    pd.set_option("display.width", 250)
    print(out.round(4).T.to_string())

    # Christian's example: S1 hires 30 labor, buys 55 imported-goods-from-S2; p_S2 up 0.1
    print("\nChristian's example: dMC1 =", 0.1 * 55 / (30 + 55))
