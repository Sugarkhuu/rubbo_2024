"""
Analysis code for the nonlinear open-economy production-network model.

This reads the CSVs produced by ../code/run_all_regimes.m (which runs the
REAL Dynare solution of open_economy_network.mod for all three FX regimes)
from ../results/, and builds the figures/tables sketched in
OpenEconomy_Networks_FX.pptx:

  - IRFs across shocks x regimes x variables            -> fig_irfs
  - Sectoral inflation under a shock, by regime          -> fig_sectoral_inflation
  - Production network + import/export centrality        -> fig_network
  - Welfare cost of FX regimes, decomposed                -> fig_welfare
  - DC-index insulation property across regimes           -> fig_dc_insulation
  - Managed-float policy trade-off (phi_s sweep)          -> requires re-running
    Dynare for a grid of PHI_S values; see sweep_phi_s() which just shells
    out to a generated .mod per grid point (mirrors run_all_regimes.m).

This module only loads data and plots / computes -- it does not decide
which shock, regime or horizon is "the" result. Call the functions you
need with the data already produced by Dynare.
"""

import os
import subprocess
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# ── Paths ─────────────────────────────────────────────────────────────────
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS_DIR = os.path.join(REPO_ROOT, "results")
FIGS_DIR = os.path.join(REPO_ROOT, "figs")

REGIMES = ["float", "peg", "managed"]
SHOCKS = ["eps_a1", "eps_a2", "eps_a3", "eps_pF", "eps_D", "eps_pX"]
SHOCK_LABELS = {
    "eps_a1": "TFP shock (Resource)",
    "eps_a2": "TFP shock (Manufacturing)",
    "eps_a3": "TFP shock (Services)",
    "eps_pF": "Import price shock",
    "eps_D": "Foreign demand shock",
    "eps_pX": "Export price / ToT shock",
}
SECTOR_NAMES = ["Resource", "Manufacturing", "Services"]

# ── Colour palette (kept consistent with code/model.py) ───────────────────
C_FLOAT = "#2563EB"
C_PEG = "#DC2626"
C_MANAGED = "#16A34A"
C_SECTOR = ["#7C3AED", "#D97706", "#0891B2"]
BG = "#F8FAFC"
DARK = "#1E293B"
REGIME_COLORS = {"float": C_FLOAT, "peg": C_PEG, "managed": C_MANAGED}
REGIME_LABELS = {"float": "Free Float", "peg": "Hard Peg", "managed": "Managed Float"}


# ══════════════════════════════════════════════════════════════════════════
# 1. LOADERS
# ══════════════════════════════════════════════════════════════════════════

def load_irf(regime: str, shock: str) -> pd.DataFrame:
    """IRF panel for one (regime, shock) pair. Columns = report_vars in
    run_all_regimes.m (piDC, PIC, y_gap, PI1-3, S, I, BSTAR, GDP)."""
    path = os.path.join(RESULTS_DIR, f"irf_{regime}_{shock}.csv")
    return pd.read_csv(path)


def load_all_irfs() -> dict:
    """{regime: {shock: DataFrame}} for every regime/shock combo that has
    a CSV in results/ (missing files -- e.g. a shock with a zero IRF that
    Dynare didn't report -- are simply skipped)."""
    out = {}
    for regime in REGIMES:
        out[regime] = {}
        for shock in SHOCKS:
            path = os.path.join(RESULTS_DIR, f"irf_{regime}_{shock}.csv")
            if os.path.exists(path):
                out[regime][shock] = pd.read_csv(path)
    return out


def load_network_objects() -> pd.DataFrame:
    """lambda_D, import_centrality, dhat, w_dc -- indexed by object name,
    columns sector1/2/3. These are computed once inside the .mod file
    from the calibrated Omega^H / Omega^F / beta^H matrices, so they are
    identical across regimes."""
    path = os.path.join(RESULTS_DIR, "network_objects.csv")
    return pd.read_csv(path, index_col="object")


def load_variances() -> pd.DataFrame:
    """Order-2 unconditional variances of report_vars, by regime."""
    path = os.path.join(RESULTS_DIR, "variances.csv")
    return pd.read_csv(path, index_col="regime")


def load_params() -> dict:
    path = os.path.join(RESULTS_DIR, "params.csv")
    df = pd.read_csv(path)
    return dict(zip(df["name"], df["value"]))


def load_variance_decomposition() -> pd.DataFrame:
    """% of each variable's unconditional variance attributable to each
    shock (rows = regime x variable, cols = shock names). Comes straight
    from Dynare's oo_.variance_decomposition (run_all_regimes.m saves it
    to variance_decomposition.csv), NOT a hand computation."""
    path = os.path.join(RESULTS_DIR, "variance_decomposition.csv")
    return pd.read_csv(path)


# ══════════════════════════════════════════════════════════════════════════
# 2. WELFARE DECOMPOSITION (Rubbo Prop. 3, open-economy welfare eq.)
# ══════════════════════════════════════════════════════════════════════════

def compute_welfare(variances: pd.DataFrame, net_obj: pd.DataFrame, params: dict) -> pd.DataFrame:
    """
    W = 0.5*[ (gamma+varphi)*Var(y_gap)
            + sum_i lambda_D_i*eps_i*(1-dhat_i)/dhat_i * Var(pi_i) ]

    Both terms use the SAME order-2 unconditional variances Dynare
    reports for the nonlinear model (oo_.var from run_all_regimes.m),
    i.e. this is the welfare cost implied by the true nonlinear model's
    second moments, not a hand-linearized approximation. Requires
    variances.csv to contain PI1, PI2, PI3, y_gap for each regime
    (see report_vars in run_all_regimes.m).
    """
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    lam = net_obj.loc["lambda_D"].values
    dhat = net_obj.loc["dhat"].values
    eps = params["EPS"]
    disp_weight = lam * eps * (1 - dhat) / dhat   # per-sector price-dispersion weight

    rows = []
    for regime in variances.index:
        var_y = variances.loc[regime, "y_gap"]
        var_pi = variances.loc[regime, ["PI1", "PI2", "PI3"]].values
        w_output = 0.5 * gamma_phi * var_y
        w_pi_by_sector = 0.5 * disp_weight * var_pi
        rows.append({
            "regime": regime,
            "output_gap": w_output,
            "price_disp_sector1": w_pi_by_sector[0],
            "price_disp_sector2": w_pi_by_sector[1],
            "price_disp_sector3": w_pi_by_sector[2],
            "price_disp_total": w_pi_by_sector.sum(),
            "total": w_output + w_pi_by_sector.sum(),
        })
    return pd.DataFrame(rows).set_index("regime")


SHOCK_GROUPS = {
    "TFP": ["eps_a1", "eps_a2", "eps_a3"],
    "Import price (FX)": ["eps_pF"],
    "Foreign demand": ["eps_D"],
    "Export price (ToT)": ["eps_pX"],
}


def compute_welfare_by_shock(variances: pd.DataFrame, vardec: pd.DataFrame,
                              net_obj: pd.DataFrame, params: dict) -> pd.DataFrame:
    """
    Split each regime's total welfare loss (compute_welfare) by shock
    SOURCE, using Dynare's own variance decomposition (% of each
    variable's variance due to each shock) to allocate the SAME
    variances that go into the welfare formula:

        W = 0.5*(gamma+varphi)*Var(y_gap)
          + 0.5*sum_i lambda_D_i*eps_i*(1-dhat_i)/dhat_i*Var(pi_i)

    Because Var(x) = sum_shock (pct_shock/100)*Var(x) exactly (the
    decomposition is additive across independent shocks), summing this
    function's per-shock welfare contributions over shocks reproduces
    compute_welfare()'s "total" column exactly, for every regime.
    Grouped into TFP (eps_a1-3) / Import-price (FX channel) / Foreign
    demand / Export-price (ToT), since that's the economically meaningful
    split (SHOCK_GROUPS).
    """
    gamma_phi = params["GAMMA"] + params["VARPHI"]
    lam = net_obj.loc["lambda_D"].values
    dhat = net_obj.loc["dhat"].values
    eps = params["EPS"]
    disp_weight = lam * eps * (1 - dhat) / dhat

    rows = []
    for regime in variances.index:
        sub = vardec[vardec["regime"] == regime].set_index("variable")
        var_y = variances.loc[regime, "y_gap"]
        var_pi = variances.loc[regime, ["PI1", "PI2", "PI3"]].values

        for group_name, shocks in SHOCK_GROUPS.items():
            pct_y = sub.loc["y_gap", shocks].sum() / 100.0
            pct_pi = sub.loc[["PI1", "PI2", "PI3"], shocks].sum(axis=1).values / 100.0

            w_output = 0.5 * gamma_phi * var_y * pct_y
            w_pi = 0.5 * disp_weight * var_pi * pct_pi
            rows.append({
                "regime": regime,
                "shock_group": group_name,
                "output_gap": w_output,
                "price_disp": w_pi.sum(),
                "total": w_output + w_pi.sum(),
            })
    return pd.DataFrame(rows).set_index(["regime", "shock_group"])


# ══════════════════════════════════════════════════════════════════════════
# 3. FIGURES
# ══════════════════════════════════════════════════════════════════════════

def _style_axis(ax):
    ax.set_facecolor(BG)
    ax.axhline(0, color="black", lw=0.8, alpha=0.4)
    ax.spines[["top", "right"]].set_visible(False)
    ax.spines[["left", "bottom"]].set_color("#CBD5E1")
    ax.tick_params(colors=DARK, labelsize=9)


def fig_irfs(all_irfs: dict, variables=("PIC", "y_gap", "S", "piDC")) -> plt.Figure:
    """IRFs: rows = shocks, cols = variables, lines = regimes."""
    fig, axes = plt.subplots(len(SHOCKS), len(variables), figsize=(4 * len(variables), 3 * len(SHOCKS)),
                              facecolor=BG, squeeze=False)
    fig.suptitle("Impulse Response Functions: FX Regimes x Shocks (Dynare, nonlinear model)",
                  fontsize=14, fontweight="bold", color=DARK, y=0.995)

    for r, shock in enumerate(SHOCKS):
        for c, var in enumerate(variables):
            ax = axes[r, c]
            _style_axis(ax)
            for regime in REGIMES:
                df = all_irfs.get(regime, {}).get(shock)
                if df is not None and var in df.columns:
                    ax.plot(df[var].values, color=REGIME_COLORS[regime], lw=2.0,
                            label=REGIME_LABELS[regime])
            if r == 0:
                ax.set_title(var, fontsize=11, fontweight="bold", color=DARK)
            if c == 0:
                ax.set_ylabel(SHOCK_LABELS[shock], fontsize=9, color=DARK)
            if r == 0 and c == 0:
                ax.legend(fontsize=8, framealpha=0)
    fig.tight_layout(rect=[0, 0, 1, 0.97])
    return fig


def fig_sectoral_inflation(all_irfs: dict, shock: str = "eps_pF") -> plt.Figure:
    """Sectoral inflation (PI1-3) under one shock, one panel per regime."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5), facecolor=BG)
    fig.suptitle(f"Sectoral Inflation -- {SHOCK_LABELS.get(shock, shock)}",
                  fontsize=15, fontweight="bold", color=DARK)
    for ax, regime in zip(axes, REGIMES):
        _style_axis(ax)
        df = all_irfs.get(regime, {}).get(shock)
        ax.set_title(REGIME_LABELS[regime], fontsize=12, fontweight="bold", color=DARK)
        if df is not None:
            for i, (name, col) in enumerate(zip(SECTOR_NAMES, C_SECTOR), start=1):
                ax.plot(df[f"PI{i}"].values, color=col, lw=2.2, label=name)
        ax.set_xlabel("Quarters", fontsize=9, color=DARK)
        ax.set_ylabel("Gross inflation deviation", fontsize=9, color=DARK)
        ax.legend(fontsize=9, framealpha=0)
    fig.tight_layout()
    return fig


def fig_network(net_obj: pd.DataFrame, omega_h: np.ndarray = None, omega_f: np.ndarray = None) -> plt.Figure:
    """Network structure: domestic I-O matrix, import shares, import
    centrality. omega_h/omega_f are the calibrated matrices (pass them
    in from the same numbers used in open_economy_network.mod, e.g.
    OH21/OH32 and OF1/OF2/OF3) since Dynare does not export matrices,
    only the derived vectors in network_objects.csv."""
    fig = plt.figure(figsize=(15, 5), facecolor=BG)
    fig.suptitle("Production Network Structure and Import Centrality",
                  fontsize=15, fontweight="bold", color=DARK)

    if omega_h is not None:
        ax1 = fig.add_subplot(131)
        im = ax1.imshow(omega_h, cmap="Blues", vmin=0, vmax=0.35)
        ax1.set_xticks(range(3)); ax1.set_yticks(range(3))
        ax1.set_xticklabels(SECTOR_NAMES, fontsize=9, color=DARK, rotation=30, ha="right")
        ax1.set_yticklabels(SECTOR_NAMES, fontsize=9, color=DARK)
        ax1.set_title("Domestic I-O Matrix (Omega^H)", fontsize=11, fontweight="bold", color=DARK)
        for i in range(3):
            for j in range(3):
                ax1.text(j, i, f"{omega_h[i, j]:.2f}", ha="center", va="center", fontsize=10,
                          color="black" if omega_h[i, j] < 0.2 else "white")
        plt.colorbar(im, ax=ax1, fraction=0.046)

    if omega_f is not None:
        ax2 = fig.add_subplot(132)
        bars = ax2.bar(SECTOR_NAMES, omega_f, color=C_SECTOR, alpha=0.85)
        ax2.set_title("Total Import Share (Omega^F_i)", fontsize=11, fontweight="bold", color=DARK)
        _style_axis(ax2)
        for bar, val in zip(bars, omega_f):
            ax2.text(bar.get_x() + bar.get_width() / 2, val + 0.005, f"{val:.2f}",
                      ha="center", fontsize=10, color=DARK)

    ax3 = fig.add_subplot(133)
    m_import = net_obj.loc["import_centrality"].values
    bars = ax3.barh(SECTOR_NAMES, m_import, color=C_SECTOR, alpha=0.85, height=0.55)
    ax3.set_title("Import Centrality M_i\n(FX pass-through under a peg)", fontsize=11,
                  fontweight="bold", color=DARK)
    ax3.set_xlabel("M_i = [(I-Omega^H)^-1 Omega^F 1]_i", fontsize=9, color=DARK)
    _style_axis(ax3)
    for bar, val in zip(bars, m_import):
        ax3.text(val + 0.005, bar.get_y() + bar.get_height() / 2, f"{val:.3f}",
                  va="center", fontsize=10, color=DARK)

    fig.tight_layout()
    return fig


def fig_welfare(welfare: pd.DataFrame) -> plt.Figure:
    """Total welfare loss and its output-gap / price-dispersion decomposition."""
    regimes = list(welfare.index)
    rlabels = [REGIME_LABELS[r] for r in regimes]
    colors_reg = [REGIME_COLORS[r] for r in regimes]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6), facecolor=BG)
    fig.suptitle("Welfare Loss Decomposition by FX Regime (order-2 moments)",
                  fontsize=15, fontweight="bold", color=DARK)

    _style_axis(ax1)
    bars = ax1.bar(rlabels, welfare["total"].values, color=colors_reg, width=0.5, alpha=0.85)
    ax1.set_title("Total Welfare Loss", fontsize=12, fontweight="bold", color=DARK)
    for bar, val in zip(bars, welfare["total"].values):
        ax1.text(bar.get_x() + bar.get_width() / 2, val, f"{val:.4g}", ha="center",
                  va="bottom", fontsize=10, color=DARK)

    _style_axis(ax2)
    comps = ["output_gap", "price_disp_sector1", "price_disp_sector2", "price_disp_sector3"]
    clabels = ["Output Gap", "Price Disp. (Resource)", "Price Disp. (Manuf.)", "Price Disp. (Services)"]
    ccolors = ["#3B82F6", "#7C3AED", "#D97706", "#0891B2"]
    x = np.arange(len(regimes))
    bottoms = np.zeros(len(regimes))
    for comp, clabel, ccol in zip(comps, clabels, ccolors):
        vals = welfare[comp].values
        ax2.bar(x, vals, bottom=bottoms, label=clabel, color=ccol, width=0.5, alpha=0.85)
        bottoms += vals
    ax2.set_xticks(x); ax2.set_xticklabels(rlabels, fontsize=10, color=DARK)
    ax2.set_title("Welfare Decomposition", fontsize=12, fontweight="bold", color=DARK)
    ax2.legend(fontsize=8, framealpha=0, loc="upper right")

    fig.tight_layout()
    return fig


def fig_dc_insulation(all_irfs: dict) -> plt.Figure:
    """DC-index inflation (piDC) across shocks x regimes -- the closer to
    zero under the float, the better the divine-coincidence property
    survives in the true nonlinear model."""
    fig, axes = plt.subplots(1, len(SHOCKS), figsize=(4 * len(SHOCKS), 4.5), facecolor=BG)
    fig.suptitle("DC-Index Inflation (Divine-Coincidence Property)",
                  fontsize=15, fontweight="bold", color=DARK)
    for ax, shock in zip(axes, SHOCKS):
        _style_axis(ax)
        for regime in REGIMES:
            df = all_irfs.get(regime, {}).get(shock)
            if df is not None:
                ax.plot(df["piDC"].values, color=REGIME_COLORS[regime], lw=2.2,
                        label=REGIME_LABELS[regime])
        ax.set_title(SHOCK_LABELS.get(shock, shock), fontsize=11, fontweight="bold", color=DARK)
        ax.set_xlabel("Quarters", fontsize=9, color=DARK)
        ax.legend(fontsize=8, framealpha=0)
    axes[0].set_ylabel("DC-index inflation", fontsize=9, color=DARK)
    fig.tight_layout()
    return fig


# ══════════════════════════════════════════════════════════════════════════
# 4. MANAGED-FLOAT PHI_S SWEEP (welfare vs FX volatility trade-off)
# ══════════════════════════════════════════════════════════════════════════

def sweep_phi_s(phi_s_values, dynare_cmd="dynare"):
    """
    Re-runs the nonlinear model under the managed-float regime for a grid
    of PHI_S values, generating one temp .mod file per grid point (same
    approach as run_all_regimes.m) and shelling out to `dynare_cmd`.
    Requires Matlab/Octave with Dynare on the path to be callable from
    the shell as e.g. `matlab -batch "..."` or `octave --eval "..."`.
    This function only builds the .mod files and the driver call; you
    must point `dynare_cmd` at your local Matlab/Octave invocation.

    Returns the list of generated .mod file paths (one per PHI_S) -- run
    them, then read back results/variances_managed_phiS_<value>.csv,
    which the generated .mod's stoch_simul writes if you add an
    `oo_.var`-to-CSV dump (see the WELFARE section comment near
    stoch_simul in open_economy_network.mod for the oo_.var indices to
    grab).
    """
    master_path = os.path.join(REPO_ROOT, "open_economy_network.mod")
    with open(master_path) as f:
        master_txt = f.read()

    generated = []
    for phi_s in phi_s_values:
        txt = master_txt.replace('@#define REGIME = "float"', '@#define REGIME = "managed"')
        txt = txt.replace("PHI_S   = 0.30;", f"PHI_S   = {phi_s:.6f};")
        out_path = os.path.join(REPO_ROOT, f"open_economy_network_managed_phiS_{phi_s:.3f}.mod")
        with open(out_path, "w") as f:
            f.write(txt)
        generated.append(out_path)

    print(f"Generated {len(generated)} .mod files for PHI_S in {list(phi_s_values)}.")
    print("Run each with Dynare (e.g. loop `dynare <file>` in Matlab/Octave), "
          "then load oo_.var for y_gap/PI1-3 into a DataFrame the same way "
          "load_variances() does, and call compute_welfare() on each.")
    return generated


# ══════════════════════════════════════════════════════════════════════════
# 5. MAIN (wire everything together once results/ exists)
# ══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    os.makedirs(FIGS_DIR, exist_ok=True)

    all_irfs = load_all_irfs()
    net_obj = load_network_objects()
    variances = load_variances()
    params = load_params()

    welfare = compute_welfare(variances, net_obj, params)
    print(welfare)

    # Same Omega^H / Omega^F used in open_economy_network.mod -- kept in
    # sync by hand since Dynare doesn't export matrices, only vectors.
    omega_h = np.array([[0.00, 0.00, 0.00],
                         [0.20, 0.00, 0.00],
                         [0.00, 0.25, 0.00]])
    omega_f = np.array([0.30, 0.10, 0.05])

    figs = {
        "fig1_irfs": fig_irfs(all_irfs),
        "fig2_sectoral": fig_sectoral_inflation(all_irfs, shock="eps_pF"),
        "fig3_network": fig_network(net_obj, omega_h, omega_f),
        "fig4_welfare": fig_welfare(welfare),
        "fig5_dc": fig_dc_insulation(all_irfs),
    }
    for name, fig in figs.items():
        path = os.path.join(FIGS_DIR, f"{name}.png")
        fig.savefig(path, dpi=150, bbox_inches="tight", facecolor=BG)
        plt.close(fig)
        print(f"Saved {path}")
