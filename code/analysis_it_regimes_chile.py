"""
Compares the two new strict-inflation-targeting regime variants
(cpi_it: targets PIC only; ppi_it: targets domestic-bundle PH only,
open_economy_network_chile_cpiit.mod / _ppiit.mod, added 2026-07-27,
run via code/run_it_regimes_chile.m) against the paper's three headline
regimes (Float/Managed/Peg) using the same welfare formula as
code/analysis.py::compute_welfare, real Chile calibration, baseline
network density.

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/analysis_it_regimes_chile.py
"""
import os
import pandas as pd

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS = os.path.join(REPO_ROOT, "results")


def main():
    it_df = pd.read_csv(os.path.join(RESULTS, "it_regimes_chile.csv")).set_index("regime")
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    params_df = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params_df["name"], params_df["value"]))
    lam = net_obj.loc["lambda_D"].values
    dhat = net_obj.loc["dhat"].values
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    eps = params["EPS"]
    disp_weight = lam * eps * (1 - dhat) / dhat

    rows = []
    for regime in it_df.index:
        var_y = it_df.loc[regime, "y_gap"]
        var_pi = it_df.loc[regime, ["PI1", "PI2", "PI3"]].values
        w = 0.5 * gamma_phi * var_y + 0.5 * (disp_weight * var_pi).sum()
        rows.append({"regime": regime, "total": w * 1e4})
    it_welfare = pd.DataFrame(rows).set_index("regime")

    # headline numbers from results_summary.md (real Chile, baseline network,
    # pre-cross-sector-term figures so they're on the same footing as it_welfare)
    headline = pd.Series({"float": 25.47, "managed": 10.17, "peg": 102.05})

    combined = pd.concat([headline, it_welfare["total"]]).sort_values()
    print("=== Welfare loss (x1e-4), all five regimes, ranked ===")
    print(combined.round(2))

    print("\ncpi_it vs managed (best existing regime):",
          f"{it_welfare.loc['cpi_it', 'total'] / headline['managed']:.2f}x")
    print("ppi_it vs managed (best existing regime):",
          f"{it_welfare.loc['ppi_it', 'total'] / headline['managed']:.2f}x")
    print("cpi_it vs float:", f"{it_welfare.loc['cpi_it', 'total'] / headline['float']:.2f}x")
    print("ppi_it vs float:", f"{it_welfare.loc['ppi_it', 'total'] / headline['float']:.2f}x")

    it_welfare.to_csv(os.path.join(RESULTS, "it_regimes_chile_welfare.csv"))


if __name__ == "__main__":
    main()
