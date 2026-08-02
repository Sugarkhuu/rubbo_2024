"""
Follow-up to the full-native-resolution calibration campaign (2026-07-31):
docs_notes/results_summary.md flagged Korea (N=33) and Czechia (N=81) Peg's
huge output-gap-variance blow-up (58x / 30x larger than Float) as a
"plausible reading, not yet confirmed" mechanism, and asked for exactly
what code/run_full_shock_decomposition.m + this script provide: a shock-
GROUP decomposition of Var(y_gap), analogous in STYLE to
code/services_mechanism_decomposition.py's use of Dynare's own
oo_.variance_decomposition, but built by the isolate-the-shock-and-rerun-
stoch_simul method instead, because Dynare's built-in
variance_decomposition field is only populated by the ANALYTIC (periods=0)
moment path, which returns NaN at this N (near-unit-root eigenvalue) -- see
run_full_shock_decomposition.m's header comment for the full explanation.

Reads results/full_calib_shock_decomposition.csv (produced by
code/run_full_shock_decomposition.m, one row per country x regime x
shock-group: all_shocks [sanity-check rerun], tfp_all [all N sectoral TFP
shocks together], eps_pF [import price], eps_D [foreign demand], eps_pX
[export price/ToT], eps_rp [risk-premium/UIP]).

Finding (see printed output): eps_rp (risk-premium/UIP) is NOT swamped by
the sheer number of independent sectoral TFP shocks at full N -- it
remains the dominant driver of Var(y_gap) in every country x regime cell,
and its dominance is MOST extreme precisely in the Peg regime where the
blow-up happens (Korea Peg: 82% of Var(y_gap); Czechia Peg: 77%) -- i.e.
the 3-sector Chile story's mechanism (risk-premium/UIP dominates the
output gap) survives fully intact at full resolution; what changed at
full N is not WHICH shock drives the output gap, but how large Peg makes
that same shock's variance relative to Float (Peg amplifies eps_rp's
output-gap contribution ~50x at Korea, ~25x at Czechia, whereas eps_rp's
share of the *composition* stays roughly 80% flat across regimes). TFP-all
contributes under 1% of Var(y_gap) in every cell despite comprising 33/37
(Korea) or ~81/85 (Czechia) of all shocks -- individually-small,
idiosyncratic sectoral TFP shocks do NOT aggregate into a large *output
gap* mover (they matter far more for sectoral PI_i price-dispersion
variance instead, see the w_pi_total column, where tfp_all is often the
LARGEST single contributor -- consistent with each TFP shock being
essentially a unit-specific relative-price shock for its own sector's PI_i
term). The additivity sanity check (isolated shocks' Var(y_gap) should sum
to the all_shocks value up to order=1 simulation noise, since shocks are
independent) holds to within ~1-3% in every cell -- confirms the isolation
method (zeroing out other shocks' M_.Sigma_e diagonal entries and rerunning
stoch_simul on the same solved decision rule) is sound.

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/full_calib_shock_decomposition_analysis.py
"""
import os
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS = os.path.join(REPO_ROOT, "results")
FIGS = os.path.join(REPO_ROOT, "figs")

SHOCK_GROUP_ORDER = ["tfp_all", "eps_pF", "eps_D", "eps_pX", "eps_rp"]
GROUP_LABELS = {
    "tfp_all": "TFP (all sectors)",
    "eps_pF": "Import price",
    "eps_D": "Foreign demand",
    "eps_pX": "Export price / ToT",
    "eps_rp": "Risk premium / UIP",
}
GROUP_COLORS = {
    "tfp_all": "#d97706",
    "eps_pF": "#0891b2",
    "eps_D": "#c3c2b7",
    "eps_pX": "#7c3aed",
    "eps_rp": "#dc2626",
}
COUNTRIES = ["korea", "czechia"]
COUNTRY_LABELS = {"korea": "Korea (N=33)", "czechia": "Czechia (N=81)"}
REGIMES = ["float", "managed", "peg"]
REGIME_LABELS = {"float": "Float", "managed": "Managed", "peg": "Peg"}


def main():
    df = pd.read_csv(os.path.join(RESULTS, "full_calib_shock_decomposition.csv"))
    welfare = pd.read_csv(os.path.join(RESULTS, "full_calib_welfare.csv"))

    print("=" * 78)
    print("SANITY CHECK: sum of isolated shock-group Var(y_gap) vs. all_shocks rerun")
    print("(should match up to order=1 simulation noise -- shocks are independent)")
    print("=" * 78)
    check_rows = []
    for country in COUNTRIES:
        for regime in REGIMES:
            sub = df[(df.country == country) & (df.regime == regime)]
            all_shocks_val = sub[sub.shock_group == "all_shocks"]["var_ygap"].iloc[0]
            iso_sum = sub[sub.shock_group.isin(SHOCK_GROUP_ORDER)]["var_ygap"].sum()
            pct_diff = (iso_sum - all_shocks_val) / all_shocks_val * 100
            check_rows.append({
                "country": country, "regime": regime,
                "all_shocks_var_ygap": all_shocks_val,
                "sum_isolated_var_ygap": iso_sum,
                "pct_diff": pct_diff,
            })
    check_df = pd.DataFrame(check_rows)
    print(check_df.to_string(index=False, float_format=lambda x: f"{x:.6g}"))
    max_abs_diff = check_df["pct_diff"].abs().max()
    print(f"\nMax |pct_diff| across all 6 cells: {max_abs_diff:.2f}%"
          f" -- {'OK, isolation method validated' if max_abs_diff < 10 else 'WARNING: large discrepancy, investigate'}")

    print("\n" + "=" * 78)
    print("Var(y_gap) SHARE by shock group, % of all_shocks total (the output-gap term)")
    print("=" * 78)
    share_rows = []
    for country in COUNTRIES:
        for regime in REGIMES:
            sub = df[(df.country == country) & (df.regime == regime)]
            all_shocks_val = sub[sub.shock_group == "all_shocks"]["var_ygap"].iloc[0]
            for grp in SHOCK_GROUP_ORDER:
                val = sub[sub.shock_group == grp]["var_ygap"].iloc[0]
                share_rows.append({
                    "country": country, "regime": regime, "group": GROUP_LABELS[grp],
                    "pct_of_var_ygap": val / all_shocks_val * 100,
                })
    share_df = pd.DataFrame(share_rows)
    for country in COUNTRIES:
        print(f"\n-- {COUNTRY_LABELS[country]} --")
        piv = share_df[share_df.country == country].pivot(index="group", columns="regime", values="pct_of_var_ygap")
        piv = piv.reindex(index=[GROUP_LABELS[g] for g in SHOCK_GROUP_ORDER], columns=REGIMES)
        print(piv.round(1).to_string())

    print("\n" + "=" * 78)
    print("Does eps_rp survive as the dominant driver, or get swamped by TFP-all?")
    print("=" * 78)
    for country in COUNTRIES:
        for regime in REGIMES:
            sub = df[(df.country == country) & (df.regime == regime)]
            all_shocks_val = sub[sub.shock_group == "all_shocks"]["var_ygap"].iloc[0]
            rp_share = sub[sub.shock_group == "eps_rp"]["var_ygap"].iloc[0] / all_shocks_val * 100
            tfp_share = sub[sub.shock_group == "tfp_all"]["var_ygap"].iloc[0] / all_shocks_val * 100
            print(f"  {country:8s} {regime:8s}: eps_rp = {rp_share:5.1f}%   tfp_all = {tfp_share:5.2f}%"
                  f"   ({'eps_rp dominates' if rp_share > tfp_share else 'TFP dominates'})")

    print("\n" + "=" * 78)
    print("How much does Peg AMPLIFY eps_rp's absolute Var(y_gap) contribution vs. Float?")
    print("=" * 78)
    for country in COUNTRIES:
        sub = df[(df.country == country) & (df.shock_group == "eps_rp")]
        float_val = sub[sub.regime == "float"]["var_ygap"].iloc[0]
        peg_val = sub[sub.regime == "peg"]["var_ygap"].iloc[0]
        print(f"  {country:8s}: eps_rp Var(y_gap) Float={float_val:.6g}  Peg={peg_val:.6g}"
              f"  ratio Peg/Float = {peg_val/float_val:.1f}x")

    print("\n" + "=" * 78)
    print("Which shock group dominates the PRICE-DISPERSION welfare term (w_pi_total)?")
    print("=" * 78)
    for country in COUNTRIES:
        for regime in REGIMES:
            sub = df[(df.country == country) & (df.regime == regime) & (df.shock_group.isin(SHOCK_GROUP_ORDER))]
            top = sub.loc[sub["w_pi_total"].idxmax()]
            print(f"  {country:8s} {regime:8s}: largest w_pi_total contributor = {GROUP_LABELS[top.shock_group]:22s}"
                  f" ({top.w_pi_total:.6g}, {top.w_pi_total/sub['w_pi_total'].sum()*100:.1f}% of isolated sum)")

    # ---- Figure: stacked bar of Var(y_gap) share by shock group, per country, 3 regimes ----
    SURFACE = "#fcfcfb"
    fig, axes = plt.subplots(1, 2, figsize=(12.5, 4.8), dpi=200)
    fig.patch.set_facecolor(SURFACE)

    for ax, country in zip(axes, COUNTRIES):
        ax.set_facecolor(SURFACE)
        x = np.arange(len(REGIMES))
        bottoms = np.zeros(len(REGIMES))
        piv = share_df[share_df.country == country].pivot(index="regime", columns="group", values="pct_of_var_ygap")
        piv = piv.reindex(index=REGIMES, columns=[GROUP_LABELS[g] for g in SHOCK_GROUP_ORDER])
        for grp in SHOCK_GROUP_ORDER:
            vals = piv[GROUP_LABELS[grp]].values
            ax.bar(x, vals, bottom=bottoms, color=GROUP_COLORS[grp], label=GROUP_LABELS[grp], width=0.55, alpha=0.9)
            bottoms += vals
        ax.set_xticks(x); ax.set_xticklabels([REGIME_LABELS[r] for r in REGIMES], fontsize=10, color="#0b0b0b")
        ax.set_ylabel("share of Var(y_gap), %", fontsize=9.5, color="#52514e")
        ax.set_title(f"What drives Var(y_gap)? {COUNTRY_LABELS[country]}", fontsize=10.5, color="#0b0b0b")
        ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
        ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
        ax.tick_params(colors="#898781", labelsize=9)
        ax.set_ylim(0, 100)
    axes[1].legend(loc="upper center", bbox_to_anchor=(0.5, -0.14), frameon=False, fontsize=8.5, ncol=3)

    fig.tight_layout()
    os.makedirs(FIGS, exist_ok=True)
    out_pdf = os.path.join(FIGS, "full_calib_shock_decomposition.pdf")
    out_png = os.path.join(FIGS, "full_calib_shock_decomposition.png")
    fig.savefig(out_pdf, facecolor=fig.get_facecolor(), bbox_inches="tight")
    fig.savefig(out_png, facecolor=fig.get_facecolor(), bbox_inches="tight")
    print(f"\nSaved {out_pdf} and {out_png}")


if __name__ == "__main__":
    main()
