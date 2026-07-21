"""
Analysis for the three follow-up exercises (todo_three_exercises.txt):

  Task 3: psi-sensitivity sweep for risk-premium/UIP welfare share (Peg)
  Task 1: network vs. no-network welfare comparison, real Chile calibration
  Task 2: sector-specific export demand -- welfare/eps_pX contribution

Reuses code/analysis.py's welfare formulas (compute_welfare,
compute_welfare_by_shock) verbatim, just pointed at different results
directories. Run from repo root: `python code/analysis_three_exercises.py`
(needs D:\anaconda3\python.exe per CLAUDE.md).
"""
import os
import sys
import pandas as pd

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from analysis import compute_welfare, compute_welfare_by_shock, SHOCK_GROUPS  # noqa: E402

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load_dir(results_dir):
    variances = pd.read_csv(os.path.join(results_dir, "variances.csv"), index_col="regime")
    vardec = pd.read_csv(os.path.join(results_dir, "variance_decomposition.csv"))
    net_obj = pd.read_csv(os.path.join(results_dir, "network_objects.csv"), index_col="object")
    params_df = pd.read_csv(os.path.join(results_dir, "params.csv"))
    params = dict(zip(params_df["name"], params_df["value"]))
    return variances, vardec, net_obj, params


# ═══════════════════════════════════════════════════════════════════════
# TASK 1: network vs. no-network, real Chile calibration
# ═══════════════════════════════════════════════════════════════════════
def task1_network_premium():
    print("=" * 70)
    print("TASK 1: Network vs. no-network welfare, real Chile calibration")
    print("=" * 70)

    base_dir = os.path.join(REPO_ROOT, "results_chile")
    nn_dir = os.path.join(REPO_ROOT, "results_chile_nonetwork")

    variances_b, vardec_b, net_obj_b, params_b = load_dir(base_dir)
    variances_nn, vardec_nn, net_obj_nn, params_nn = load_dir(nn_dir)

    welfare_b = compute_welfare(variances_b, net_obj_b, params_b) * 1e4
    welfare_nn = compute_welfare(variances_nn, net_obj_nn, params_nn) * 1e4

    print("\nWith network (baseline, x1e-4):")
    print(welfare_b[["output_gap", "price_disp_total", "total"]])
    print("\nNo network (counterfactual, x1e-4):")
    print(welfare_nn[["output_gap", "price_disp_total", "total"]])

    premium = pd.DataFrame({
        "with_network": welfare_b["total"],
        "no_network": welfare_nn["total"],
    })
    premium["network_premium"] = premium["with_network"] - premium["no_network"]
    premium["network_premium_pct"] = 100 * premium["network_premium"] / premium["no_network"]
    print("\nNetwork premium (with - without), x1e-4:")
    print(premium)

    out_path = os.path.join(REPO_ROOT, "results", "task1_network_premium.csv")
    premium.to_csv(out_path)
    print(f"\nWrote {out_path}")
    return premium


# ═══════════════════════════════════════════════════════════════════════
# TASK 2: sector-specific export demand
# ═══════════════════════════════════════════════════════════════════════
def task2_export_reallocation():
    print("\n" + "=" * 70)
    print("TASK 2: Sector-specific export demand (FULL VERSION)")
    print("=" * 70)

    base_dir = os.path.join(REPO_ROOT, "results_chile")
    exp_dir = os.path.join(REPO_ROOT, "results_chile_exp")

    variances_b, vardec_b, net_obj_b, params_b = load_dir(base_dir)
    variances_e, vardec_e, net_obj_e, params_e = load_dir(exp_dir)

    welfare_b = compute_welfare(variances_b, net_obj_b, params_b) * 1e4
    welfare_e = compute_welfare(variances_e, net_obj_e, params_e) * 1e4

    print("\nOLD (BH-allocated aggregate export) total welfare loss, x1e-4:")
    print(welfare_b["total"])
    print("\nNEW (sector-specific, real export-share-calibrated) total welfare loss, x1e-4:")
    print(welfare_e["total"])

    by_shock_b = compute_welfare_by_shock(variances_b, vardec_b, net_obj_b, params_b) * 1e4
    by_shock_e = compute_welfare_by_shock(variances_e, vardec_e, net_obj_e, params_e) * 1e4

    tot_col = "total"
    old_pX = by_shock_b.xs("Export price (ToT)", level="shock_group")[tot_col]
    new_pX = by_shock_e.xs("Export price (ToT)", level="shock_group")[tot_col]
    compare = pd.DataFrame({"old_eps_pX_welfare": old_pX, "new_eps_pX_welfare": new_pX})
    compare["ratio"] = compare["new_eps_pX_welfare"] / compare["old_eps_pX_welfare"]
    print("\nExport/ToT shock (eps_pX) welfare contribution, old vs. new, x1e-4:")
    print(compare)

    out_path = os.path.join(REPO_ROOT, "results", "task2_export_reallocation.csv")
    compare.to_csv(out_path)
    totals_path = os.path.join(REPO_ROOT, "results", "task2_totals_old_vs_new.csv")
    pd.DataFrame({"old_total": welfare_b["total"], "new_total": welfare_e["total"]}).to_csv(totals_path)
    print(f"\nWrote {out_path} and {totals_path}")
    return compare


# ═══════════════════════════════════════════════════════════════════════
# TASK 3: psi-sensitivity sweep (risk-premium/UIP welfare share)
# ═══════════════════════════════════════════════════════════════════════
def task3_psi_sweep():
    print("\n" + "=" * 70)
    print("TASK 3: psi-sensitivity sweep (risk-premium share of Peg's loss)")
    print("=" * 70)

    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    params_df = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params_df["name"], params_df["value"]))

    var_all = pd.read_csv(os.path.join(REPO_ROOT, "results", "psi_sweep_variances.csv"))
    vardec_all = pd.read_csv(os.path.join(REPO_ROOT, "results", "psi_sweep_vardec.csv"))

    rows = []
    for psi in sorted(var_all["psi"].unique()):
        variances = var_all[var_all["psi"] == psi].set_index("regime")
        vardec = vardec_all[vardec_all["psi"] == psi].drop(columns="psi")
        welfare = compute_welfare(variances, net_obj, params) * 1e4
        by_shock = compute_welfare_by_shock(variances, vardec, net_obj, params) * 1e4

        for regime in variances.index:
            total = welfare.loc[regime, "total"]
            rp_share = by_shock.loc[(regime, "Risk premium (UIP)"), "total"]
            rows.append({
                "psi": psi, "regime": regime,
                "total_welfare_x1e4": total,
                "risk_premium_welfare_x1e4": rp_share,
                "risk_premium_pct_of_total": 100 * rp_share / total,
            })

    out = pd.DataFrame(rows)
    print("\nRisk-premium share of total welfare loss, by psi and regime:")
    print(out.to_string(index=False))

    peg_only = out[out["regime"] == "peg"]
    print("\nPeg-only, risk-premium %% share vs. psi (headline claim: ~75%% at psi=0.020):")
    print(peg_only[["psi", "risk_premium_pct_of_total"]].to_string(index=False))

    out_path = os.path.join(REPO_ROOT, "results", "psi_sweep_welfare.csv")
    out.to_csv(out_path, index=False)
    print(f"\nWrote {out_path}")
    return out


if __name__ == "__main__":
    if os.path.exists(os.path.join(REPO_ROOT, "results", "psi_sweep_variances.csv")):
        task3_psi_sweep()
    if os.path.exists(os.path.join(REPO_ROOT, "results_chile_nonetwork", "variances.csv")):
        task1_network_premium()
    if os.path.exists(os.path.join(REPO_ROOT, "results_chile_exp", "variances.csv")):
        task2_export_reallocation()
