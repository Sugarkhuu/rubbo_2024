"""
Christian's feedback (2026-07-22/23): "he noted about how I miss the
between-sector loss. I really need to count for that." Computes Rubbo's
Prop.\ 3 cross-sector dispersion term, previously flagged in CLAUDE.md as
a known, unbuilt gap:

    Phi_C(mu,mu) + sum_s lambda_s Phi_s(mu,mu)
    Phi_C(X,Y)   = 0.5 sum_{k,h} beta_k beta_h sigma^C_kh (X_k-X_h)(Y_k-Y_h)
    Phi_s(X,Y)   = 0.5 sum_{k,h} omega_sk omega_sh theta^s_kh (X_k-X_h)(Y_k-Y_h)

mu_it is the log markup gap (log(P_it/MC_it) - log(EPS/(EPS-1))), now
tracked in the .mod files (MARKUPGAP1/2/3, see
open_economy_network_chile_exp{,_peg,_managed}.mod +
code/run_markupgap_chile.m -> results/markupgap_chile_covar.csv, the full
3x3 unconditional covariance matrix of mu_t per regime -- needed because
Phi_C/Phi_s are quadratic forms in the FULL covariance, not just each
sector's own variance).

Elasticities sigma^C_kh, theta^s_kh: this model's cross-sector aggregators
are Cobb-Douglas (Households: C_t^H Cobb-Douglas across domestic sectors
via beta^H; Firms: Y_ift Cobb-Douglas in domestic inputs X_ij via
Omega^H_ij). Cobb-Douglas has Allen-Uzawa elasticity of substitution
EXACTLY 1 between any pair of its arguments, regardless of the exponent
weights -- a mathematical fact of the functional form, not an
approximation. So theta^s_kh=1 for all k,h in {1,2,3} (domestic-domestic,
within a sector's production nest) and between a domestic input and
labor/imports (also Cobb-Douglas factors in the SAME production nest, see
Y_ift=A_it L^alpha prod_j X_ij^OmegaH_ij M^OmegaF_i).

The ONE genuine CES (non-unit) elasticity in the model is the OUTER
consumption nest, C_t = CES(C_t^H, C_t^F; eta=1.5) -- domestic composite
vs. imported composite. So Phi_C needs a MIXED elasticity matrix: 1
between two domestic sectors, eta=1.5 between a domestic sector and the
import composite. This is an approximation for a genuinely NESTED CES
(exact nested-CES Allen-Uzawa cross-elasticities are more involved, e.g.
Blackorby-Russell) but using the outer nest's own elasticity for
domestic-vs-import substitution is the standard practical shortcut.

Convention: labor and imports are assumed frictionlessly priced (no
Calvo distortion), so mu_labor = mu_import = 0 exactly -- consistent with
the model's law-of-one-price assumption for imports and a competitive
labor market. This is what lets Phi_s's 5-good sum (labor + 3 domestic +
import) reduce to a closed-form weighted-variance-like quadratic
computable directly from the domestic mu_i covariance matrix plus the
FIXED (zero) values for labor/import.

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/cross_sector_welfare.py
"""
import os
import numpy as np
import pandas as pd

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS = os.path.join(REPO_ROOT, "results")

SECTORS = ["Resource", "Manufacturing", "Services"]
ALPHA = np.array([0.5026, 0.3589, 0.6035])            # labor share, sector s
OH = np.array([[0.0750, 0.1526, 0.1932],               # OH[s,k] = sector s's cost share on domestic k
               [0.0991, 0.2022, 0.1453],
               [0.0018, 0.0581, 0.2661]])
OF = np.array([0.0767, 0.1945, 0.0704])                # import cost share, sector s
BH = np.array([0.0265, 0.2294, 0.7441])                # household consumption share, domestic sector k (within C^H)
BF_TOT = 0.10                                           # import consumption share (within total C)
ETA = 1.50                                              # outer C^H/C^F CES elasticity
GAMMA, VARPHI, EPS = 1.0, 2.0, 8.0


def phi_s_quadratic(cov3, weights5):
    """
    Phi_s(mu,mu) = 0.5 sum_{k,h in 5 goods} w_k w_h theta_kh (mu_k-mu_h)^2,
    theta_kh=1 for ALL pairs (Cobb-Douglas production nest -- labor,
    3 domestic inputs, import all enter the SAME Cobb-Douglas factor).
    With theta=1 everywhere and weights summing to 1, this identity holds
    exactly: Phi_s(mu,mu) = sum_k w_k E[mu_k^2] - E[sum_k w_k mu_k]^2
                           = weighted "variance" of mu over the 5 goods,
    with mu_labor=mu_import=0 FIXED (not random) -- so E[mu_k^2]=0 for
    those two, and cross terms with the domestic mu's still enter through
    the second (subtracted) piece.
    """
    w = weights5  # (w_L, w_1, w_2, w_3, w_F), sums to 1
    # E[mu_k mu_h] matrix over the 5 goods: 0 for any row/col involving L or F,
    # cov3 for the domestic 3x3 block.
    Emumu = np.zeros((5, 5))
    Emumu[1:4, 1:4] = cov3
    term1 = np.sum(w * np.diag(Emumu))  # = sum_k w_k E[mu_k^2]
    # E[(sum_k w_k mu_k)^2] = w' Emumu w  (mean of mu is 0 in this linear model)
    term2 = w @ Emumu @ w
    return term1 - term2


def phi_C_quadratic(cov3, bh, bf_tot, eta):
    """
    Phi_C(mu,mu) = 0.5 sum_{k,h in {1,2,3,F}} w_k w_h sigma_kh (mu_k-mu_h)^2,
    sigma_kh=1 for k,h both domestic (Cobb-Douglas within C^H),
    sigma_kh=eta for one of k,h = F (import composite; outer CES nest),
    mu_F=0 fixed (law of one price, no domestic markup distortion on
    imports).
    """
    w = np.array([bh[0], bh[1], bh[2], bf_tot])  # domestic 3 + import composite, sums to 1
    Emumu = np.zeros((4, 4))
    Emumu[:3, :3] = cov3
    sigma = np.ones((4, 4))
    sigma[:3, 3] = eta
    sigma[3, :3] = eta
    sigma[3, 3] = 1.0  # irrelevant, w_F*w_F term contributes 0 either way since mu_F=0

    total = 0.0
    for k in range(4):
        for h in range(4):
            total += w[k] * w[h] * sigma[k, h] * (Emumu[k, k] + Emumu[h, h] - 2 * Emumu[k, h])
    return 0.5 * total


def main():
    covdf = pd.read_csv(os.path.join(RESULTS, "markupgap_chile_covar.csv"))
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    lam = net_obj.loc["lambda_D"].values

    # within-sector + output-gap total, from the headline numbers (x1e-4),
    # for comparison -- re-derive from results_chile/variances.csv directly
    # so the comparison is apples-to-apples with the SAME simulation.
    variances = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "variances.csv"), index_col="regime")
    params = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params["name"], params["value"]))
    dhat = net_obj.loc["dhat"].values
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    eps = params["EPS"]
    disp_weight = lam * eps * (1 - dhat) / dhat

    rows = []
    for regime in ["float", "peg", "managed"]:
        sub = covdf[covdf.regime == regime]
        cov3 = np.zeros((3, 3))
        for _, r in sub.iterrows():
            cov3[int(r["i"]) - 1, int(r["j"]) - 1] = r["cov"]

        phi_C = phi_C_quadratic(cov3, BH, BF_TOT, ETA)

        phi_s_vals = np.zeros(3)
        for s in range(3):
            weights5 = np.array([ALPHA[s], OH[s, 0], OH[s, 1], OH[s, 2], OF[s]])
            phi_s_vals[s] = phi_s_quadratic(cov3, weights5)
        cross_term = phi_C + np.sum(lam * phi_s_vals)

        var_y = variances.loc[regime, "y_gap"] if regime in variances.index else np.nan
        var_pi = variances.loc[regime, ["PI1", "PI2", "PI3"]].values if regime in variances.index else np.full(3, np.nan)
        within_total = 0.5 * gamma_phi * var_y + 0.5 * np.sum(disp_weight * var_pi)

        rows.append({
            "regime": regime,
            "Phi_C": phi_C * 1e4,
            "sum_lambda_Phi_s": np.sum(lam * phi_s_vals) * 1e4,
            "cross_sector_total": 0.5 * cross_term * 1e4,  # 0.5 factor matches W's overall 1/2 in front of the bracket
            "within_sector_total (headline)": within_total * 1e4,
        })

    out = pd.DataFrame(rows).set_index("regime")
    out["pct_of_within"] = out["cross_sector_total"] / out["within_sector_total (headline)"] * 100
    out["new_total"] = out["within_sector_total (headline)"] + out["cross_sector_total"]
    out.to_csv(os.path.join(RESULTS, "cross_sector_welfare_chile.csv"))
    print("=== Cross-sector welfare term (Phi_C + sum_s lambda_s Phi_s), x1e-4, Chile baseline ===")
    print(out.round(4).to_string())


if __name__ == "__main__":
    main()
