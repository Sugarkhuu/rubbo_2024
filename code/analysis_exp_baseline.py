"""
Full welfare/mechanism analysis for the sector-specific-export (KAPEX1/2/3)
model as the new presentation baseline, comparing:
  results_chile_exp            -- baseline (network ON, sector-specific export)
  results_chile_exp_nonetwork  -- network-OFF counterfactual (same export model)

Mirrors analysis_three_exercises.py's task1_network_premium, plus prints
everything needed to hand-fill the presentation: welfare by sector/output-gap,
network premium %, shock decomposition, and output-gap variance by sector.
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


base_dir = os.path.join(REPO_ROOT, "results_chile_exp")
nn_dir = os.path.join(REPO_ROOT, "results_chile_exp_nonetwork")

variances_b, vardec_b, net_obj_b, params_b = load_dir(base_dir)
variances_nn, vardec_nn, net_obj_nn, params_nn = load_dir(nn_dir)

welfare_b = compute_welfare(variances_b, net_obj_b, params_b) * 1e4
welfare_nn = compute_welfare(variances_nn, net_obj_nn, params_nn) * 1e4

print("=" * 70)
print("EXP-MODEL BASELINE: welfare with network (x1e-4)")
print("=" * 70)
print(welfare_b)

print("\nEXP-MODEL no-network counterfactual (x1e-4):")
print(welfare_nn)

premium = pd.DataFrame({
    "with_network": welfare_b["total"],
    "no_network": welfare_nn["total"],
})
premium["network_premium"] = premium["with_network"] - premium["no_network"]
premium["network_premium_pct"] = 100 * premium["network_premium"] / premium["no_network"]
print("\nNetwork premium (with - without), x1e-4:")
print(premium)

by_shock = compute_welfare_by_shock(variances_b, vardec_b, net_obj_b, params_b) * 1e4
print("\nShock decomposition, exp-model baseline (x1e-4):")
print(by_shock)

peg_total = welfare_b.loc["peg", "total"]
peg_rp = by_shock.loc[("peg", "Risk premium (UIP)"), "total"]
peg_output_gap = welfare_b.loc["peg", "output_gap"]
print(f"\nPeg: risk-premium share of total = {100*peg_rp/peg_total:.1f}%")
print(f"Peg: output-gap share of total = {100*peg_output_gap/peg_total:.1f}%")

print("\nOutput-gap variance by sector (x1e4), raw Var(y_gap_i), baseline vs no-network:")
for regime in ["float", "managed", "peg"]:
    row_b = variances_b.loc[regime, ["y_gap1", "y_gap2", "y_gap3"]] * 1e4
    row_nn = variances_nn.loc[regime, ["y_gap1", "y_gap2", "y_gap3"]] * 1e4
    print(regime, "ON:", row_b.values, "OFF:", row_nn.values)

out_path = os.path.join(REPO_ROOT, "results", "exp_baseline_welfare.csv")
welfare_b.to_csv(out_path)
premium.to_csv(os.path.join(REPO_ROOT, "results", "exp_baseline_network_premium.csv"))
by_shock.to_csv(os.path.join(REPO_ROOT, "results", "exp_baseline_shock_decomposition.csv"))
print(f"\nWrote outputs to {os.path.join(REPO_ROOT, 'results')}")
