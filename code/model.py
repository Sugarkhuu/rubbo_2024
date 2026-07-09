"""
Open-Economy Multi-Sector DSGE with Production Networks
Extends Rubbo (2024) to a small open economy.

Three sectors: Resource (R), Manufacturing (M), Services (S)
Three regimes:  Free Float, Hard Peg, Managed Float
Three shocks:   Import Price, Foreign Demand, Domestic TFP
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec
import warnings
warnings.filterwarnings("ignore")

# ── COLOUR PALETTE ────────────────────────────────────────────────────────────
C_FLOAT   = "#2563EB"   # blue
C_PEG     = "#DC2626"   # red
C_MANAGED = "#16A34A"   # green
C_SECTOR  = ["#7C3AED", "#D97706", "#0891B2"]   # R, M, S
BG        = "#F8FAFC"
DARK      = "#1E293B"


# ══════════════════════════════════════════════════════════════════════════════
# 1. PARAMETERS
# ══════════════════════════════════════════════════════════════════════════════

class Params:
    """Calibration for a 3-sector oil-exporter small open economy."""

    def __init__(self):
        # ── Sectors: Resource(0), Manufacturing(1), Services(2) ─────────────
        self.N = 3
        self.names = ["Resource", "Manufacturing", "Services"]

        # Calvo survival probabilities (1 = perfectly flexible)
        self.delta = np.array([0.70, 0.50, 0.25])

        # Labour share in value-added (alpha per sector)
        self.alpha = np.array([0.30, 0.50, 0.70])

        # ── Input-Output structure ───────────────────────────────────────────
        # OmegaH[i,j] = share of good j in sector i's domestic intermediate use
        # OmegaF[i,j] = share of imported good j in sector i's use
        self.OmegaH = np.array([
            [0.00, 0.05, 0.05],   # Resource buys tiny domestic inputs
            [0.20, 0.10, 0.05],   # Manufacturing buys from all
            [0.05, 0.10, 0.10],   # Services buys mostly from itself
        ])
        self.OmegaF = np.array([
            [0.30, 0.00, 0.00],   # Resource: 30% imported inputs
            [0.05, 0.10, 0.00],   # Manufacturing: 10% imported
            [0.00, 0.02, 0.05],   # Services: 5% imported
        ])
        # Sanity: alpha + sum(OmegaH) + sum(OmegaF) ≈ 1 per sector
        # (residual goes to profits / returns to capital, normalised out)

        # ── Final demand (domestic consumption shares across sectors) ────────
        self.betaH = np.array([0.05, 0.15, 0.80])  # domestic consumption basket
        self.betaF = 0.30                            # aggregate import share in CPI

        # ── Export shares (fraction of sectoral output exported) ─────────────
        self.export_share = np.array([0.65, 0.20, 0.00])

        # ── Preferences / macro ──────────────────────────────────────────────
        self.beta  = 0.99    # discount factor
        self.gamma = 1.0     # CRRA coefficient
        self.phi   = 1.5     # Frisch elasticity inverse
        self.eta   = 1.5     # home/foreign substitution elasticity
        self.psi   = 0.02    # NFA debt-elastic premium (ensures stationarity)

        # ── Monetary policy ──────────────────────────────────────────────────
        self.phi_pi = 1.5    # inflation coefficient
        self.phi_y  = 0.25   # output gap coefficient
        self.phi_s  = 0.50   # exchange rate smoothing (managed float only)

        # ── Shock persistence ────────────────────────────────────────────────
        self.rho_mp  = 0.70   # import price shock
        self.rho_fd  = 0.60   # foreign demand shock
        self.rho_tfp = 0.80   # TFP shock

        # ── Derived objects ───────────────────────────────────────────────────
        self._derive()

    def _derive(self):
        N = self.N
        I = np.eye(N)

        # Leontief inverse: L = (I - OmegaH)^{-1}
        self.L = np.linalg.inv(I - self.OmegaH)

        # Domar weights (domestic supplier centrality)
        # lambda_D = betaH^T @ L  (1×N row vector → make column)
        self.lambda_D = self.betaH @ self.L          # shape (N,)

        # DC index weights: w_i ∝ lambda_D_i * (1 - delta_i) / delta_i
        raw = self.lambda_D * (1 - self.delta) / self.delta
        self.w_DC = raw / raw.sum()

        # Import centrality: M_i = [(I-OmegaH)^{-1} OmegaF 1]_i
        self.M_import = (self.L @ self.OmegaF @ np.ones(N))

        # Calvo adjustment speed matrix: Delta = diag(1-delta)*(I - rho*delta)^{-1}
        # Using standard Calvo: freq of adj = (1-delta)
        self.freq = 1 - self.delta
        # B matrix for Phillips curve: B = (I - Delta @ OmegaH)^{-1} Delta
        Delta = np.diag(self.freq)
        self.Delta = Delta
        IminusDOmH = I - Delta @ self.OmegaH
        self.B = np.linalg.inv(IminusDOmH) @ Delta

        # Output weights for welfare (Domar-weighted)
        self.theta = self.lambda_D / self.lambda_D.sum()


# ══════════════════════════════════════════════════════════════════════════════
# 2. LINEAR MODEL EQUATIONS
# ══════════════════════════════════════════════════════════════════════════════

def build_system(p: Params, regime: str, T: int = 40):
    """
    Solve the period-by-period linear system via MSV (minimum state variable).

    State vector: x_t = (pi_1,pi_2,pi_3, y_gap, s_hat, nfa, w_gap)
    Shocks:       z_t = (mp, fd, tfp)  — exogenous AR(1) processes

    Returns coefficient matrices mapping shocks to endogenous variables.
    """
    N = p.N
    rho_vec = np.array([p.rho_mp, p.rho_fd, p.rho_tfp])

    # For each shock we simulate an IRF by setting shock = 1 at t=0
    results = {}
    for shock_idx, shock_name in enumerate(["import_price", "foreign_demand", "tfp"]):
        pi_all = np.zeros((T, N))    # sectoral inflation
        y_gap  = np.zeros(T)         # output gap
        s_hat  = np.zeros(T)         # log exchange rate (+ = depreciation)
        nfa    = np.zeros(T)         # NFA / Y
        pi_dc  = np.zeros(T)         # DC index inflation
        pi_cpi = np.zeros(T)         # CPI inflation
        i_hat  = np.zeros(T)         # nominal rate
        mc_all = np.zeros((T, N))    # marginal costs

        # Shock state
        z = np.zeros(3)
        z[shock_idx] = 1.0

        for t in range(T):
            mp_t   = z[0]   # import price shock (in foreign currency)
            fd_t   = z[1]   # foreign demand shock
            tfp_t  = z[2]   # TFP shock (common, or can be sectoral)

            # ── Exchange rate determination ──────────────────────────────────
            if regime == "peg":
                s_t = 0.0
            elif regime == "float":
                # UIP + Taylor rule: s absorbs all shocks
                # Under the DC-targeting float, s adjusts to keep pi_DC = 0
                # Simplified: s_t = phi_fd * fd + phi_mp * mp
                s_t = 0.80 * mp_t + 0.40 * fd_t - 0.30 * tfp_t
                if t > 0:
                    s_t += 0.85 * s_hat[t-1]
            else:  # managed
                s_t = 0.45 * mp_t + 0.25 * fd_t - 0.15 * tfp_t
                if t > 0:
                    s_t += 0.70 * s_hat[t-1]
            s_hat[t] = s_t

            # ── Import price in domestic currency ────────────────────────────
            # p_F_hat = s_t + mp_t  (UIP: world price + exchange rate)
            p_F = s_t + mp_t

            # ── Marginal costs (open-economy Rubbo eq. 15) ──────────────────
            # mc_i = alpha_i * w_hat + sum_j OmegaH_ij * p_j + sum_j OmegaF_ij * p_F - A_i
            # Approximate: p_j ≈ pi_j cumulated (simplified for IRF)
            p_level = np.cumsum(pi_all[:max(t,1)], axis=0)[-1] if t > 0 else np.zeros(N)
            tfp_vec = tfp_t * np.ones(N)
            w_hat_t = 0.60 * y_gap[t-1] + 0.20 * pi_cpi[t-1] if t > 0 else 0.0

            mc = (p.alpha * w_hat_t
                  + p.OmegaH @ p_level
                  + p.OmegaF @ (p_F * np.ones(N))
                  - tfp_vec)
            mc_all[t] = mc

            # ── Sectoral Phillips curves (Rubbo Proposition 2, open economy) ─
            # pi_t = B @ mc_t + rho * B @ (I-B)^{-1} * Delta * E[pi_{t+1}]
            # MSV: E[pi_{t+1}] = rho_state * pi_t  (by AR structure)
            rho_state = max(rho_vec[shock_idx] * (0.9 ** t), 0.05)
            I_N = np.eye(N)
            # (I - Delta OmegaH) pi_t = Delta mc_t + rho_state * Delta * E[pi_{t+1}]
            # Approximate E[pi_{t+1}] by rho_state * pi_t (MSV)
            # => (I - Delta OmegaH - rho_state * Delta * rho_state * I) pi_t ≈ Delta mc_t
            A_sys = I_N - p.Delta @ p.OmegaH
            rhs   = p.Delta @ mc + p.beta * rho_state * p.Delta @ (mc * rho_state)
            try:
                pi_t = np.linalg.solve(A_sys, rhs)
            except np.linalg.LinAlgError:
                pi_t = np.zeros(N)
            pi_all[t] = pi_t

            # ── Aggregates ───────────────────────────────────────────────────
            pi_dc[t]  = p.w_DC @ pi_t
            pi_cpi[t] = p.betaH @ pi_t + p.betaF * p_F

            # ── IS / output gap ──────────────────────────────────────────────
            # y_gap_t = -1/gamma * (i - E_pi_cpi - r_nat)
            # r_nat shifts with fd and tfp
            r_nat = 0.30 * fd_t + 0.40 * tfp_t
            if regime == "peg":
                i_t = 0.0   # slaved to world rate
            else:
                i_t = p.phi_pi * pi_dc[t] + p.phi_y * y_gap[t-1] if t > 0 else p.phi_pi * pi_dc[t]
                if regime == "managed":
                    i_t += p.phi_s * (s_t - (s_hat[t-1] if t > 0 else 0))
            i_hat[t] = i_t

            real_rate = i_t - rho_state * pi_cpi[t]
            trade_effect = p.eta * s_t * 0.3 + fd_t * 0.4   # trade balance effect
            y_gap[t] = (-1/p.gamma * (real_rate - r_nat) + trade_effect) * 0.35

            # ── NFA dynamics ─────────────────────────────────────────────────
            # nfa_t = (1+r)nfa_{t-1} + CA_t,  CA includes export boost from s
            ca_t = p.export_share @ np.ones(N) * s_t * 0.3 + fd_t * 0.2 - p.betaF * p_F
            nfa[t] = ((1 + 0.01 - p.psi) * (nfa[t-1] if t > 0 else 0) + ca_t * 0.3)

            # ── Advance shock ─────────────────────────────────────────────────
            z = rho_vec * z

        results[shock_name] = {
            "pi":     pi_all,
            "y_gap":  y_gap,
            "s_hat":  s_hat,
            "nfa":    nfa,
            "pi_dc":  pi_dc,
            "pi_cpi": pi_cpi,
            "i_hat":  i_hat,
            "mc":     mc_all,
        }
    return results


def compute_welfare(p: Params, results: dict, T: int = 40) -> dict:
    """
    Welfare loss decomposition (Rubbo Proposition 3, open-economy extension).
    W = 0.5 * sum_t beta^t [
        (gamma+phi) * y_gap^2
        + sum_i lambda_D_i * eps_i / (delta_i*(1-delta_i)) * pi_i^2    [price dispersion]
        + Phi_cross * chi_cross^2                                        [misallocation]
        + Phi_ToT * (tot_gap)^2                                          [ToT gap]
    ]
    Returns total loss and each component, summed across shocks.
    """
    eps_i = np.ones(p.N)   # elasticity of substitution (normalised)
    disp_weights = p.lambda_D * eps_i / (p.delta * (1 - p.delta) + 1e-6)
    beta_t = np.array([p.beta**t for t in range(T)])

    decomp = {"output_gap": 0., "price_disp": 0., "misallocation": 0., "tot_gap": 0.}

    for shock_name, res in results.items():
        y   = res["y_gap"]
        pi  = res["pi"]      # T × N
        s   = res["s_hat"]
        nfa = res["nfa"]

        # Output gap loss
        decomp["output_gap"] += 0.5 * float(beta_t @ ((p.gamma + p.phi) * y**2))

        # Price dispersion loss (sum over sectors)
        for i in range(p.N):
            decomp["price_disp"] += 0.5 * float(beta_t @ (disp_weights[i] * pi[:, i]**2))

        # Cross-sector misallocation (variance of sectoral marginal costs)
        mc_var = np.var(res["mc"], axis=1)
        decomp["misallocation"] += 0.5 * 0.30 * float(beta_t @ mc_var)

        # Terms-of-trade gap: deviation of s from efficient level
        s_nat = 0.5 * np.ones(T) * s[0]   # simplified natural rate
        decomp["tot_gap"] += 0.5 * 0.20 * float(beta_t @ (s - s_nat)**2)

    return decomp


# ══════════════════════════════════════════════════════════════════════════════
# 3. RUN ALL REGIMES
# ══════════════════════════════════════════════════════════════════════════════

def run_all(p: Params, T: int = 40):
    regimes = ["float", "peg", "managed"]
    all_res = {}
    all_welf = {}
    for reg in regimes:
        res = build_system(p, reg, T)
        all_res[reg]  = res
        all_welf[reg] = compute_welfare(p, res, T)
    return all_res, all_welf


# ══════════════════════════════════════════════════════════════════════════════
# 4. FIGURES
# ══════════════════════════════════════════════════════════════════════════════

def fig_irfs(all_res, p: Params, T: int = 40) -> plt.Figure:
    """Figure 1: IRFs for 3 shocks × 3 regimes (4 variables each)."""
    shocks  = ["import_price", "foreign_demand", "tfp"]
    slabels = ["Import Price Shock", "Foreign Demand Shock", "Domestic TFP Shock"]
    vars_   = ["pi_cpi", "y_gap", "s_hat", "pi_dc"]
    vlabels = ["CPI Inflation", "Output Gap", "Exchange Rate", "DC-Index Inflation"]
    colors  = {"float": C_FLOAT, "peg": C_PEG, "managed": C_MANAGED}
    lw = 2.2
    T_plot = range(T)

    fig, axes = plt.subplots(len(shocks), len(vars_), figsize=(16, 12),
                              facecolor=BG)
    fig.suptitle("Impulse Response Functions: FX Regimes × Shocks",
                 fontsize=16, fontweight="bold", color=DARK, y=0.98)

    for r, (shock, slabel) in enumerate(zip(shocks, slabels)):
        for c, (var, vlabel) in enumerate(zip(vars_, vlabels)):
            ax = axes[r, c]
            ax.set_facecolor(BG)
            ax.axhline(0, color="black", lw=0.8, alpha=0.4)
            for regime in ["float", "peg", "managed"]:
                y = all_res[regime][shock][var]
                ax.plot(T_plot, y, color=colors[regime], lw=lw,
                        label=regime.capitalize())
            ax.tick_params(labelsize=9, colors=DARK)
            ax.spines[["top", "right"]].set_visible(False)
            ax.spines[["left", "bottom"]].set_color("#CBD5E1")
            if r == 0:
                ax.set_title(vlabel, fontsize=11, fontweight="bold", color=DARK)
            if c == 0:
                ax.set_ylabel(slabel, fontsize=10, color=DARK, labelpad=8)
            if r == 2 and c == 0:
                ax.legend(fontsize=9, framealpha=0)

    fig.tight_layout(rect=[0, 0, 1, 0.97])
    return fig


def fig_sectoral_inflation(all_res, p: Params, T: int = 40) -> plt.Figure:
    """Figure 2: Sectoral inflation under import price shock for each regime."""
    shock = "import_price"
    regimes = ["float", "peg", "managed"]
    rlabels = ["Free Float", "Hard Peg", "Managed Float"]
    fig, axes = plt.subplots(1, 3, figsize=(15, 5), facecolor=BG)
    fig.suptitle("Sectoral Inflation — Import Price Shock",
                 fontsize=15, fontweight="bold", color=DARK)

    for ax, reg, rlab in zip(axes, regimes, rlabels):
        ax.set_facecolor(BG)
        ax.axhline(0, color="black", lw=0.6, alpha=0.4)
        pi = all_res[reg][shock]["pi"]
        for i, (name, col) in enumerate(zip(p.names, C_SECTOR)):
            ax.plot(range(T), pi[:, i], color=col, lw=2.2, label=name)
        ax.set_title(rlab, fontsize=12, fontweight="bold", color=DARK)
        ax.spines[["top", "right"]].set_visible(False)
        ax.spines[["left", "bottom"]].set_color("#CBD5E1")
        ax.tick_params(colors=DARK, labelsize=9)
        ax.legend(fontsize=9, framealpha=0)
        ax.set_xlabel("Quarters", color=DARK, fontsize=9)
        ax.set_ylabel("Inflation (pp)", color=DARK, fontsize=9)

    fig.tight_layout()
    return fig


def fig_network(p: Params) -> plt.Figure:
    """Figure 3: Network structure and import centrality."""
    fig = plt.figure(figsize=(15, 5), facecolor=BG)
    fig.suptitle("Production Network Structure and Import Centrality",
                 fontsize=15, fontweight="bold", color=DARK)

    # (a) Input-output heatmap
    ax1 = fig.add_subplot(131)
    im = ax1.imshow(p.OmegaH, cmap="Blues", vmin=0, vmax=0.35)
    ax1.set_xticks(range(3)); ax1.set_yticks(range(3))
    ax1.set_xticklabels(p.names, fontsize=9, color=DARK)
    ax1.set_yticklabels(p.names, fontsize=9, color=DARK)
    ax1.set_title("Domestic I-O Matrix (Ω^H)", fontsize=11, fontweight="bold", color=DARK)
    for i in range(3):
        for j in range(3):
            ax1.text(j, i, f"{p.OmegaH[i,j]:.2f}", ha="center", va="center",
                     fontsize=10, color="black" if p.OmegaH[i,j] < 0.2 else "white")
    plt.colorbar(im, ax=ax1, fraction=0.046)

    # (b) Import shares heatmap
    ax2 = fig.add_subplot(132)
    im2 = ax2.imshow(p.OmegaF, cmap="Reds", vmin=0, vmax=0.35)
    ax2.set_xticks(range(3)); ax2.set_yticks(range(3))
    ax2.set_xticklabels(p.names, fontsize=9, color=DARK)
    ax2.set_yticklabels(p.names, fontsize=9, color=DARK)
    ax2.set_title("Import Matrix (Ω^F)", fontsize=11, fontweight="bold", color=DARK)
    for i in range(3):
        for j in range(3):
            if p.OmegaF[i,j] > 0:
                ax2.text(j, i, f"{p.OmegaF[i,j]:.2f}", ha="center", va="center",
                         fontsize=10, color="black" if p.OmegaF[i,j] < 0.2 else "white")
    plt.colorbar(im2, ax=ax2, fraction=0.046)

    # (c) Import centrality M_i
    ax3 = fig.add_subplot(133)
    bars = ax3.barh(p.names, p.M_import, color=C_SECTOR, alpha=0.85, height=0.55)
    ax3.set_title("Import Centrality M_i\n(FX pass-through under peg)",
                  fontsize=11, fontweight="bold", color=DARK)
    ax3.set_xlabel("M_i = [(I−Ω^H)⁻¹ Ω^F 1]_i", fontsize=9, color=DARK)
    ax3.spines[["top", "right"]].set_visible(False)
    ax3.spines[["left", "bottom"]].set_color("#CBD5E1")
    ax3.tick_params(colors=DARK)
    for bar, val in zip(bars, p.M_import):
        ax3.text(val + 0.005, bar.get_y() + bar.get_height()/2,
                 f"{val:.3f}", va="center", fontsize=10, color=DARK)

    fig.tight_layout()
    return fig


def fig_welfare(all_welf: dict, p: Params) -> plt.Figure:
    """Figure 4: Welfare decomposition across regimes."""
    regimes  = ["float", "peg", "managed"]
    rlabels  = ["Free Float", "Hard Peg", "Managed Float"]
    comps    = ["output_gap", "price_disp", "misallocation", "tot_gap"]
    clabels  = ["Output Gap", "Price Dispersion", "Misallocation", "ToT Gap"]
    ccolors  = ["#3B82F6", "#EF4444", "#F59E0B", "#10B981"]

    totals = [sum(all_welf[r].values()) for r in regimes]
    compvals = {c: [all_welf[r][c] for r in regimes] for c in comps}

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6), facecolor=BG)
    fig.suptitle("Welfare Loss Decomposition by FX Regime",
                 fontsize=15, fontweight="bold", color=DARK)

    # Total welfare bar
    ax1.set_facecolor(BG)
    colors_reg = [C_FLOAT, C_PEG, C_MANAGED]
    bars = ax1.bar(rlabels, totals, color=colors_reg, width=0.5, alpha=0.85)
    ax1.set_title("Total Welfare Loss", fontsize=12, fontweight="bold", color=DARK)
    ax1.set_ylabel("Loss (basis points, scaled)", fontsize=10, color=DARK)
    ax1.spines[["top", "right"]].set_visible(False)
    ax1.spines[["left", "bottom"]].set_color("#CBD5E1")
    ax1.tick_params(colors=DARK)
    for bar, val in zip(bars, totals):
        ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.001,
                 f"{val:.4f}", ha="center", fontsize=10, color=DARK)

    # Stacked decomposition
    ax2.set_facecolor(BG)
    bottoms = np.zeros(3)
    x = np.arange(3)
    for comp, clabel, ccol in zip(comps, clabels, ccolors):
        vals = np.array(compvals[comp])
        ax2.bar(x, vals, bottom=bottoms, label=clabel, color=ccol, width=0.5, alpha=0.85)
        bottoms += vals
    ax2.set_xticks(x); ax2.set_xticklabels(rlabels, fontsize=10, color=DARK)
    ax2.set_title("Welfare Decomposition", fontsize=12, fontweight="bold", color=DARK)
    ax2.set_ylabel("Loss by component", fontsize=10, color=DARK)
    ax2.legend(fontsize=9, framealpha=0, loc="upper right")
    ax2.spines[["top", "right"]].set_visible(False)
    ax2.spines[["left", "bottom"]].set_color("#CBD5E1")
    ax2.tick_params(colors=DARK)

    fig.tight_layout()
    return fig


def fig_dc_insulation(all_res, p: Params, T: int = 40) -> plt.Figure:
    """Figure 5: DC-index insulation property across regimes."""
    shocks  = ["import_price", "foreign_demand", "tfp"]
    slabels = ["Import Price", "Foreign Demand", "TFP"]
    regimes = ["float", "peg", "managed"]
    colors  = {"float": C_FLOAT, "peg": C_PEG, "managed": C_MANAGED}

    fig, axes = plt.subplots(1, 3, figsize=(15, 5), facecolor=BG)
    fig.suptitle("DC-Index Inflation (Divine Coincidence Property)",
                 fontsize=15, fontweight="bold", color=DARK)

    for ax, shock, slabel in zip(axes, shocks, slabels):
        ax.set_facecolor(BG)
        ax.axhline(0, color="black", lw=0.8, alpha=0.4)
        for reg in regimes:
            y = all_res[reg][shock]["pi_dc"]
            ax.plot(range(T), y, color=colors[reg], lw=2.2, label=reg.capitalize())
        ax.set_title(slabel, fontsize=12, fontweight="bold", color=DARK)
        ax.spines[["top", "right"]].set_visible(False)
        ax.spines[["left", "bottom"]].set_color("#CBD5E1")
        ax.tick_params(colors=DARK, labelsize=9)
        ax.set_xlabel("Quarters", color=DARK, fontsize=9)
        ax.set_ylabel("DC-Index Inflation", color=DARK, fontsize=9)
        ax.legend(fontsize=9, framealpha=0)

    fig.tight_layout()
    return fig


def fig_managed_tradeoff(all_res, all_welf, p: Params) -> plt.Figure:
    """Figure 6: Welfare vs exchange rate volatility as phi_s varies."""
    phi_s_vals = np.linspace(0, 3.0, 20)
    totals = []
    s_vols = []
    T = 40

    for phi_s in phi_s_vals:
        p_temp = Params()
        p_temp.phi_s = phi_s
        res = build_system(p_temp, "managed", T)
        welf = compute_welfare(p_temp, res, T)
        totals.append(sum(welf.values()))
        s_vol = np.mean([np.std(res[sh]["s_hat"]) for sh in res])
        s_vols.append(s_vol)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5), facecolor=BG)
    fig.suptitle("Managed Float: Policy Trade-offs as φ_s Varies",
                 fontsize=15, fontweight="bold", color=DARK)

    ax1.set_facecolor(BG)
    ax1.plot(phi_s_vals, totals, color=C_MANAGED, lw=2.5)
    ax1.axhline(sum(all_welf["float"].values()),  color=C_FLOAT,   lw=1.5, ls="--", label="Float")
    ax1.axhline(sum(all_welf["peg"].values()),    color=C_PEG,     lw=1.5, ls="--", label="Peg")
    ax1.set_xlabel("Exchange rate weight φ_s", fontsize=10, color=DARK)
    ax1.set_ylabel("Welfare loss", fontsize=10, color=DARK)
    ax1.set_title("Welfare vs φ_s", fontsize=12, fontweight="bold", color=DARK)
    ax1.legend(fontsize=9, framealpha=0)
    ax1.spines[["top", "right"]].set_visible(False)
    ax1.spines[["left", "bottom"]].set_color("#CBD5E1")
    ax1.tick_params(colors=DARK)

    ax2.set_facecolor(BG)
    ax2.plot(phi_s_vals, s_vols, color=C_MANAGED, lw=2.5)
    ax2.set_xlabel("Exchange rate weight φ_s", fontsize=10, color=DARK)
    ax2.set_ylabel("Exchange rate volatility (std)", fontsize=10, color=DARK)
    ax2.set_title("FX Volatility vs φ_s", fontsize=12, fontweight="bold", color=DARK)
    ax2.spines[["top", "right"]].set_visible(False)
    ax2.spines[["left", "bottom"]].set_color("#CBD5E1")
    ax2.tick_params(colors=DARK)

    fig.tight_layout()
    return fig


# ══════════════════════════════════════════════════════════════════════════════
# 5. MAIN
# ══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    import os
    os.makedirs("figs", exist_ok=True)

    print("Calibrating model...")
    p = Params()
    print(f"  DC weights:        {np.round(p.w_DC, 3)}")
    print(f"  Domar weights λ_D: {np.round(p.lambda_D, 3)}")
    print(f"  Import centrality: {np.round(p.M_import, 3)}")

    print("Solving all regimes...")
    all_res, all_welf = run_all(p, T=40)

    for reg in ["float", "peg", "managed"]:
        tot = sum(all_welf[reg].values())
        print(f"  {reg:10s}: welfare = {tot:.5f} | components: {all_welf[reg]}")

    print("Generating figures...")
    figs = {
        "fig1_irfs":          fig_irfs(all_res, p),
        "fig2_sectoral":      fig_sectoral_inflation(all_res, p),
        "fig3_network":       fig_network(p),
        "fig4_welfare":       fig_welfare(all_welf, p),
        "fig5_dc":            fig_dc_insulation(all_res, p),
        "fig6_managed":       fig_managed_tradeoff(all_res, all_welf, p),
    }
    for name, fig in figs.items():
        path = f"figs/{name}.png"
        fig.savefig(path, dpi=150, bbox_inches="tight", facecolor=BG)
        plt.close(fig)
        print(f"  Saved {path}")

    print("Done!")
