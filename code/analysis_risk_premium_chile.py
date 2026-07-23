"""
Adam's feedback: "effects of the volatility of the exchange rate
processes." Reads results/risk_premium_chile_sweep.csv (sd(eps_rp) scaled
0x-3x baseline, all three regimes, real Chile calibration,
code/sweep_risk_premium_chile.m via code/drive_risk_premium_chile_sweep.sh)
and computes welfare (lambda_D, dhat fixed at baseline rho=1 values --
this sweep never touches the network, only shock size) to see whether the
Managed < Float << Peg ranking, and the relative GAP between them, is
sensitive to how big the risk-premium shock actually is -- since the
headline "risk-premium drives 75-78% of Peg's/Services' loss" result
rests on calibrating sd(eps_rp) equal to every other shock (1%), with no
independent target moment.

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/analysis_risk_premium_chile.py
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
REGIMES = ["float", "managed", "peg"]
REGIME_LABELS = {"float": "Float", "managed": "Managed", "peg": "Peg"}
COLORS = {"float": "#16a34a", "managed": "#6b7280", "peg": "#dc2626"}


def main():
    df = pd.read_csv(os.path.join(RESULTS, "risk_premium_chile_sweep.csv"))
    net_obj = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "network_objects.csv"), index_col="object")
    params = pd.read_csv(os.path.join(REPO_ROOT, "results_chile", "params.csv"))
    params = dict(zip(params["name"], params["value"]))
    lam = net_obj.loc["lambda_D"].values
    dhat = net_obj.loc["dhat"].values
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    eps = params["EPS"]
    disp_weight = lam * eps * (1 - dhat) / dhat

    rows = []
    for _, r in df.iterrows():
        var_pi = np.array([r["PI1"], r["PI2"], r["PI3"]])
        w = 0.5 * gamma_phi * r["y_gap"] + 0.5 * np.sum(disp_weight * var_pi)
        rows.append({"rp_scale": r["rp_scale"], "regime": r["regime"], "total": w * 1e4})
    out = pd.DataFrame(rows).sort_values(["regime", "rp_scale"])
    out.to_csv(os.path.join(RESULTS, "risk_premium_chile_welfare.csv"), index=False)

    piv = out.pivot(index="rp_scale", columns="regime", values="total")
    print("=== Welfare loss (x1e-4) vs. risk-premium shock size (scale x baseline sd=1%) ===")
    print(piv.round(3))

    print("\n=== Peg/Float welfare ratio, by rp_scale ===")
    for scale in sorted(out["rp_scale"].unique()):
        sub = piv.loc[scale]
        print(f"  scale={scale:.2f}: Peg/Float = {sub['peg']/sub['float']:.2f}x, "
              f"Peg/Managed = {sub['peg']/sub['managed']:.2f}x")

    SURFACE = "#fcfcfb"
    fig, ax = plt.subplots(figsize=(6.8, 4.6), dpi=200)
    fig.patch.set_facecolor(SURFACE)
    ax.set_facecolor(SURFACE)
    for regime in REGIMES:
        sub = out[out.regime == regime].sort_values("rp_scale")
        ax.plot(sub["rp_scale"], sub["total"], color=COLORS[regime], marker="o", markersize=4,
                linewidth=2.2, label=REGIME_LABELS[regime])
    ax.axvline(1.0, color="#c3c2b7", linestyle="--", linewidth=1)
    ax.text(1.03, ax.get_ylim()[1] * 0.92, "calibrated (sd=1\\%)", fontsize=8.5, color="#52514e")
    ax.set_xlabel(r"risk-premium shock scale (relative to baseline sd $=1\%$)", fontsize=10, color="#0b0b0b")
    ax.set_ylabel(r"welfare loss ($\times10^4$)", fontsize=10.5, color="#52514e")
    ax.set_yscale("log")
    ax.legend(loc="upper left", frameon=False, fontsize=9.5)
    ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#c3c2b7"); ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#898781", labelsize=9)
    ax.yaxis.grid(True, which="both", color="#e1e0d9", linewidth=0.6, zorder=0)
    ax.set_axisbelow(True)
    fig.tight_layout()

    out_pdf = os.path.join(FIGS, "risk_premium_volatility.pdf")
    out_png = os.path.join(FIGS, "risk_premium_volatility.png")
    fig.savefig(out_pdf, facecolor=fig.get_facecolor(), bbox_inches="tight")
    fig.savefig(out_png, facecolor=fig.get_facecolor(), bbox_inches="tight")
    print(f"\nSaved {out_pdf} and {out_png}")


if __name__ == "__main__":
    main()
