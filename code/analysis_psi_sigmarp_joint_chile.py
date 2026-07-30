"""
Tier 1C analysis: does the risk-premium shock size (sigma_RP) and the
debt-elastic risk-premium coefficient (psi) reinforce each other on Peg's
welfare loss, or are their effects roughly separable (additive in logs)?
Reads results/psi_sigmarp_joint_peg_sweep.csv (code/sweep_psi_sigmarp_joint_chile.m,
psi_scale x rp_scale in {0.5,1,2}^2, Peg only).

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/analysis_psi_sigmarp_joint_chile.py
"""
import os
import numpy as np
import pandas as pd

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS = os.path.join(REPO_ROOT, "results")


def main():
    df = pd.read_csv(os.path.join(RESULTS, "psi_sigmarp_joint_peg_sweep.csv"))
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    params_df = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params_df["name"], params_df["value"]))
    lam = net_obj.loc["lambda_D"].values
    dhat = net_obj.loc["dhat"].values
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    eps = params["EPS"]
    disp_weight = lam * eps * (1 - dhat) / dhat

    rows = []
    for _, r in df.iterrows():
        var_pi = np.array([r["PI1"], r["PI2"], r["PI3"]])
        w = 0.5 * gamma_phi * r["y_gap"] + 0.5 * (disp_weight * var_pi).sum()
        rows.append({"psi_scale": r["psi_scale"], "rp_scale": r["rp_scale"], "total": w * 1e4})
    out = pd.DataFrame(rows)
    out.to_csv(os.path.join(RESULTS, "psi_sigmarp_joint_welfare.csv"), index=False)

    piv = out.pivot(index="psi_scale", columns="rp_scale", values="total")
    print("=== Peg welfare loss (x1e-4), rows=psi_scale, cols=rp_scale (both x baseline) ===")
    print(piv.round(2))

    # Test separability: if effects were additive in logs, log(W) should be
    # ~ a + b*log(psi_scale) + c*log(rp_scale) with no interaction term.
    out["log_w"] = np.log(out["total"])
    out["log_psi"] = np.log(out["psi_scale"])
    out["log_rp"] = np.log(out["rp_scale"])
    X = np.column_stack([np.ones(len(out)), out["log_psi"], out["log_rp"],
                          out["log_psi"] * out["log_rp"]])
    coef, *_ = np.linalg.lstsq(X, out["log_w"], rcond=None)
    print("\nlog(W) ~ a + b*log(psi_scale) + c*log(rp_scale) + d*log(psi_scale)*log(rp_scale)")
    print(f"  a={coef[0]:.4f}  b={coef[1]:.4f}  c={coef[2]:.4f}  d(interaction)={coef[3]:.4f}")
    print("  (d near 0 => effects are roughly separable/multiplicative in scales, not reinforcing;")
    print("   |d| comparable to |b|,|c| => genuine interaction)")

    print("\n=== Ratio check: does psi's effect (2x/0.5x at fixed rp_scale) change with rp_scale? ===")
    for rp in sorted(out["rp_scale"].unique()):
        sub = piv[rp]
        ratio = sub.loc[2.0] / sub.loc[0.5]
        print(f"  rp_scale={rp}: W(psi=2x)/W(psi=0.5x) = {ratio:.3f}")


if __name__ == "__main__":
    main()
