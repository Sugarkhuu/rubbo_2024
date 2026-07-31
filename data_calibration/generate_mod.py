"""
Generate a full-native-resolution (N-sector) Dynare .mod file from a
*_calibration_full_results.json produced by build_{chile,korea,czechia}_
calibration.py's build_full().

This is an ordinary Python string-templating generator (loops + f-strings),
NOT Dynare's @#for macro language -- see CLAUDE.md's task note on why (would
be unreadable/undebuggable at N=33/81 equations per block). It mirrors
open_economy_network_chile.mod's structure exactly, just reindexed i,j = 1..N
and with the steady state solved via soe_ss_solve_dense_N.m (vector/matrix
call) instead of the hand-unrolled 3x3 cofactor algebra.

Usage:
    python generate_mod.py chile_calibration_full_results.json float chile
    -> writes oen_full_chile_float.mod (or peg / managed)
"""

import json
import sys
from pathlib import Path

HERE = Path(__file__).parent
REPO_ROOT = HERE.parent

# Behavioral / policy parameters -- literature calibration, identical across
# countries in the existing 3-sector .mod files (confirmed by diff against
# open_economy_network_chile.mod). Not derivable from IO data at any N.
BETA = 0.99
GAMMA = 1.00
VARPHI = 2.00
EPS = 8.00
BF_TOT = 0.10
ETA = 1.50
PSI = 0.020
THETA_S = 2.00
KAPEX_SCALE = 0.50
BSTARBAR = 0.00
PHI_PI = 1.50
PHI_Y = 0.50
PHI_S = 0.30
RHO_A = 0.90
RHO_PF = 0.85
RHO_D = 0.80
RHO_PX = 0.85
RHO_RP = 0.80


def generate(calib, regime, country_tag):
    N = calib["N"]
    OmegaH = calib["OmegaH"]
    OmegaF = calib["OmegaF"]
    alpha = calib["alpha"]
    betaH = calib["betaH"]
    delta = calib["delta_raw_used"]
    dhat = calib["dhat_derived"]
    lambda_d = calib["domar_weight"]
    wdc = calib["dc_weight"]

    idx = list(range(1, N + 1))

    def joinlines(lines):
        return "\n".join(lines)

    # ---------------- variables ----------------
    sect_vars = []
    for i in idx:
        sect_vars.append(f"Y{i} L{i} P{i} PI{i} MC{i} PSTAR{i} X1_{i} X2_{i} A{i} y_gap{i}")
    var_block = "  " + "\n  ".join(sect_vars) + "\n"
    agg_vars = ("C CH CF PH PC PIC Ltot W S PF PFH BSTAR I EX IM DSTAR PX RP piDC y_gap GDP")

    # ---------------- shocks ----------------
    shock_list = " ".join(f"eps_a{i}" for i in idx) + " eps_pF eps_D eps_pX eps_rp"

    # ---------------- parameters ----------------
    par_sect = []
    for i in idx:
        par_sect.append(f"ALPHA{i} OF{i} BH{i} DELTA{i} DHAT{i} LAMBDA_D{i} WDC{i}")
    par_sect_block = "  " + "\n  ".join(par_sect)
    par_oh = []
    for i in idx:
        par_oh.append(" ".join(f"OH{i}_{j}" for j in idx))
    par_oh_block = "  " + "\n  ".join(par_oh)
    par_agg = ("BETA GAMMA VARPHI EPS BF_TOT OMEGA ETA PSI THETA_S KAPEX_SCALE BSTARBAR "
               "ISTAR PHI_PI PHI_Y PHI_S RHO_A RHO_PF RHO_D RHO_PX RHO_RP")

    # ---------------- parameter values ----------------
    lines = []
    lines.append(f"BETA = {BETA};\nGAMMA = {GAMMA};\nVARPHI = {VARPHI};\nEPS = {EPS};")
    lines.append("// Raw Calvo reset probabilities: literature default by macro-category")
    lines.append("// (Resource/Manufacturing/Services -- Dhyne et al. 2005/ECB IPN, see")
    lines.append("// open_economy_network_chile.mod's DELTA1-3 comment for full derivation),")
    lines.append("// assigned per RAW sector via the category concordance kept in the")
    lines.append("// calibration script SOLELY for this purpose (all other objects below are")
    lines.append("// genuine full-resolution IO data, not category aggregates).")
    for i in idx:
        lines.append(f"DELTA{i} = {delta[i-1]:.6f};")
    lines.append("// Value-added shares (ALPHA), domestic IO matrix (OH), import cost shares")
    lines.append("// (OF), household consumption shares (BH): DATA, full native resolution.")
    for i in idx:
        lines.append(f"ALPHA{i} = {alpha[i-1]:.8f};")
    for i in idx:
        for j in idx:
            v = OmegaH[i-1][j-1]
            lines.append(f"OH{i}_{j} = {v:.8f};")
    for i in idx:
        lines.append(f"OF{i} = {OmegaF[i-1]:.8f};")
    for i in idx:
        lines.append(f"BH{i} = {betaH[i-1]:.8f};")
    lines.append(f"BF_TOT = {BF_TOT};\nOMEGA = 1 - BF_TOT;\nETA = {ETA};")
    lines.append(f"PSI = {PSI};\nTHETA_S = {THETA_S};\nKAPEX_SCALE = {KAPEX_SCALE};\nBSTARBAR = {BSTARBAR};")
    lines.append(f"PHI_PI = {PHI_PI};\nPHI_Y = {PHI_Y};\nPHI_S = {PHI_S};")
    lines.append(f"RHO_A = {RHO_A};\nRHO_PF = {RHO_PF};\nRHO_D = {RHO_D};\nRHO_PX = {RHO_PX};\nRHO_RP = {RHO_RP};")
    lines.append("ISTAR = 1/BETA;")
    param_values_block = "\n".join(lines)

    # ---------------- derived network/policy objects (computed in Python, see
    # data_calibration/full_calibration_common.py -- calibrated as plain
    # constants here per CLAUDE.md task point 2, no in-Dynare matrix inversion) ----
    derived_lines = []
    for i in idx:
        derived_lines.append(f"DHAT{i} = {dhat[i-1]:.10f};")
    for i in idx:
        derived_lines.append(f"LAMBDA_D{i} = {lambda_d[i-1]:.10f};")
    for i in idx:
        derived_lines.append(f"WDC{i} = {wdc[i-1]:.10f};")
    derived_block = "\n".join(derived_lines)

    # ---------------- model equations ----------------
    model_lines = []
    model_lines.append("//------------------------------------------------------------")
    model_lines.append("// [1] Nominal marginal cost, Cobb-Douglas cost minimization (dense N x N)")
    model_lines.append("//------------------------------------------------------------")
    for i in idx:
        prod_terms = " * ".join(f"P{j}^OH{i}_{j}" for j in idx)
        model_lines.append(f"MC{i} = (1/A{i}) * W^ALPHA{i} * {prod_terms} * PFH^OF{i};")

    model_lines.append("//------------------------------------------------------------")
    model_lines.append("// [2] Recursive Calvo pricing (exact nonlinear recursion), per sector")
    model_lines.append("//------------------------------------------------------------")
    for i in idx:
        model_lines.append(f"X1_{i} = (MC{i}/P{i})*Y{i} + (1-DELTA{i})*BETA*(C(+1)/C)^(-GAMMA)*PI{i}(+1)^EPS *X1_{i}(+1);")
        model_lines.append(f"X2_{i} = Y{i} + (1-DELTA{i})*BETA*(C(+1)/C)^(-GAMMA)*PI{i}(+1)^(EPS-1) *X2_{i}(+1);")
        model_lines.append(f"PSTAR{i} = (EPS/(EPS-1)) * X1_{i}/X2_{i};")
        model_lines.append(f"1 = (1-DELTA{i})*PI{i}^(EPS-1) + DELTA{i}*PSTAR{i}^(1-EPS);")
        model_lines.append(f"P{i} = PI{i}*P{i}(-1);")

    model_lines.append("//------------------------------------------------------------")
    model_lines.append("// [3] Labour demand (Cobb-Douglas cost share ALPHA_i of total cost)")
    model_lines.append("//------------------------------------------------------------")
    for i in idx:
        model_lines.append(f"L{i} = ALPHA{i}*MC{i}*Y{i}/W;")
    model_lines.append("Ltot = " + " + ".join(f"L{i}" for i in idx) + ";")

    model_lines.append("//------------------------------------------------------------")
    model_lines.append("// [4] Goods market clearing: domestic consumption + dense domestic")
    model_lines.append("//     intermediate demand (from ALL buying sectors) + exports")
    model_lines.append("//------------------------------------------------------------")
    for i in idx:
        interm = " + ".join(f"OH{j}_{i}*MC{j}*Y{j}" for j in idx)
        model_lines.append(f"Y{i} = BH{i}*PH*CH/P{i} + ({interm})/P{i} + BH{i}*PH*EX/P{i};")

    model_lines.append("//------------------------------------------------------------")
    model_lines.append("// [5] Consumption aggregation: Cobb-Douglas domestic bundle,")
    model_lines.append("//     CES nest between domestic (H) and imported (F) bundles")
    model_lines.append("//------------------------------------------------------------")
    ph_terms = " * ".join(f"P{i}^BH{i}" for i in idx)
    model_lines.append(f"PH = {ph_terms};")
    model_lines.append("PC = ( OMEGA*PH^(1-ETA) + (1-OMEGA)*PFH^(1-ETA) )^(1/(1-ETA));")
    model_lines.append("CH = OMEGA*(PH/PC)^(-ETA)*C;")
    model_lines.append("CF = (1-OMEGA)*(PFH/PC)^(-ETA)*C;")
    model_lines.append("PIC = PC/PC(-1);")

    model_lines.append("//------------------------------------------------------------")
    model_lines.append("// [6] Household Euler equation and labour supply (nonlinear CRRA/Frisch)")
    model_lines.append("//------------------------------------------------------------")
    model_lines.append("C^(-GAMMA) = BETA*I*(C(+1)^(-GAMMA))/PIC(+1);")
    model_lines.append("W/PC = C^GAMMA * Ltot^VARPHI;")

    model_lines.append("//------------------------------------------------------------")
    model_lines.append("// [7] Exchange rate block: LOP for imports, UIP with debt-elastic premium")
    model_lines.append("//------------------------------------------------------------")
    model_lines.append("PFH = S*PF;")
    model_lines.append("I = ISTAR*(1 - PSI*(BSTAR - BSTARBAR)) * RP * S(+1)/S;")

    model_lines.append("//------------------------------------------------------------")
    model_lines.append("// [8] Net foreign assets: current-account identity")
    model_lines.append("//------------------------------------------------------------")
    model_lines.append("BSTAR = (I(-1)/PIC)*BSTAR(-1) + (PH*EX - PFH*IM)/PC;")

    model_lines.append("//------------------------------------------------------------")
    model_lines.append("// [9] Export demand and total import demand")
    model_lines.append("//------------------------------------------------------------")
    model_lines.append("EX = KAPEX_SCALE*DSTAR*PX*(PH/PFH)^(-THETA_S);")
    im_terms = " + ".join(f"OF{i}*MC{i}*Y{i}/PFH" for i in idx)
    model_lines.append(f"IM = CF + {im_terms};")

    model_lines.append("//------------------------------------------------------------")
    model_lines.append("// [10] Policy rule (regime-dependent)")
    model_lines.append("//------------------------------------------------------------")
    model_lines.append('@#if REGIME == "float"')
    model_lines.append("log(I/ISTAR) = PHI_PI*piDC + PHI_Y*y_gap;")
    model_lines.append('@#elseif REGIME == "peg"')
    model_lines.append("S = 1;")
    model_lines.append('@#elseif REGIME == "managed"')
    model_lines.append("log(I/ISTAR) = PHI_PI*piDC + PHI_Y*y_gap + PHI_S*log(S);")
    model_lines.append('@#elseif REGIME == "cpi_it"')
    model_lines.append("log(I/ISTAR) = PHI_PI*log(PIC) + PHI_Y*y_gap;")
    model_lines.append('@#elseif REGIME == "ppi_it"')
    model_lines.append("log(I/ISTAR) = PHI_PI*log(PH/PH(-1)) + PHI_Y*y_gap;")
    model_lines.append('@#endif')

    model_lines.append("//------------------------------------------------------------")
    model_lines.append("// [11] DC inflation index and output gap")
    model_lines.append("//------------------------------------------------------------")
    model_lines.append("piDC = " + " + ".join(f"WDC{i}*log(PI{i})" for i in idx) + ";")
    for i in idx:
        model_lines.append(f"y_gap{i} = LAMBDA_D{i}*(log(Y{i}/STEADY_STATE(Y{i})) - log(A{i}));")
    model_lines.append("y_gap = " + " + ".join(f"y_gap{i}" for i in idx) + ";")

    model_lines.append("//------------------------------------------------------------")
    model_lines.append("// [12] Exogenous shock processes (AR(1) in logs)")
    model_lines.append("//------------------------------------------------------------")
    for i in idx:
        model_lines.append(f"log(A{i}) = RHO_A *log(A{i}(-1))  + eps_a{i};")
    model_lines.append("log(PF) = RHO_PF*log(PF(-1))  + eps_pF;")
    model_lines.append("log(DSTAR) = RHO_D*log(DSTAR(-1)) + eps_D;")
    model_lines.append("log(PX) = RHO_PX*log(PX(-1)) + eps_pX;")
    model_lines.append("log(RP) = RHO_RP*log(RP(-1)) + eps_rp;")

    model_lines.append("//------------------------------------------------------------")
    model_lines.append("// [13] Reporting: nominal GDP = absorption + net exports")
    model_lines.append("//------------------------------------------------------------")
    model_lines.append("GDP = PC*C + PH*EX - PFH*IM;")

    model_block = "\n".join(model_lines)

    # ---------------- steady_state_model ----------------
    ss_lines = []
    ss_lines.append("  " + " ".join(f"A{i} = 1;" for i in idx))
    ss_lines.append("  PF = 1; DSTAR = 1; PX = 1; RP = 1; S = 1;")
    ss_lines.append("  PFH = S*PF;")
    ss_lines.append("  MU = EPS/(EPS-1);")
    # Dynare's steady_state_model block does NOT accept bracket matrix/vector
    # literals ("[a;b;c]") as function-call arguments (confirmed empirically:
    # preprocessor syntax error) -- so pass a FLAT scalar argument list
    # instead, matching soe_ss_solve_dense_N.m's documented varargin order:
    # OH (row-major, N^2), ALPHA (N), OF (N), BH (N), then the 7 scalars.
    oh_flat = ",".join(f"OH{i}_{j}" for i in idx for j in idx)
    alpha_flat = ",".join(f"ALPHA{i}" for i in idx)
    of_flat = ",".join(f"OF{i}" for i in idx)
    bh_flat = ",".join(f"BH{i}" for i in idx)
    out_lhs = (["W", "C", "EX", "PH", "PC"] + [f"P{i}" for i in idx] + [f"MC{i}" for i in idx]
               + [f"Y{i}" for i in idx] + [f"L{i}" for i in idx] + ["Ltot", "CH", "CF"])
    ss_lines.append(
        f"  [{','.join(out_lhs)}] = soe_ss_solve_dense_N({N},"
        f"{oh_flat},{alpha_flat},{of_flat},{bh_flat},OMEGA,ETA,THETA_S,KAPEX_SCALE,GAMMA,VARPHI,MU);"
    )
    ss_lines.append("  IM = PH*EX/PFH;")
    ss_lines.append("  " + " ".join(f"PI{i} = 1;" for i in idx))
    ss_lines.append("  PIC = 1;")
    ss_lines.append("  " + " ".join(f"PSTAR{i} = 1;" for i in idx))
    for i in idx:
        ss_lines.append(f"  X1_{i} = (MC{i}/P{i})*Y{i}/(1-(1-DELTA{i})*BETA); X2_{i} = Y{i}/(1-(1-DELTA{i})*BETA);")
    ss_lines.append("  I = 1/BETA;")
    ss_lines.append("  BSTAR = BSTARBAR;")
    ss_lines.append("  piDC = 0; y_gap = 0;")
    ss_lines.append("  " + " ".join(f"y_gap{i} = 0;" for i in idx))
    ss_lines.append("  GDP = PC*C + PH*EX - PFH*IM;")
    ss_block = "\n".join(ss_lines)

    # ---------------- shocks ----------------
    shock_lines = []
    for i in idx:
        shock_lines.append(f"var eps_a{i}  = 0.01^2;")
    shock_lines.append("var eps_pF  = 0.01^2;")
    shock_lines.append("var eps_D   = 0.01^2;")
    shock_lines.append("var eps_pX  = 0.01^2;")
    shock_lines.append("var eps_rp  = 0.01^2;")
    shocks_block = "\n".join(shock_lines)

    # ---------------- stoch_simul reporting vars (unchanged, aggregate only) ----------------
    report_vars_1 = "piDC PIC y_gap I BSTAR " + " ".join(f"PI{i}" for i in idx)
    report_vars_2 = "piDC PIC y_gap I BSTAR S GDP EX IM C PX RP PF DSTAR"

    n_sectors_comment = calib.get("N")
    src = calib.get("source", "")

    # NOTE (see docs_notes/calibration.md's order-2 note for the same class of
    # issue at order=1 here): at higher N, one generalized eigenvalue lands
    # numerically almost exactly at the unit-root boundary, which can make
    # Dynare's ANALYTIC (periods=0) moment formulas return NaN for variables
    # that load on it even though the BK/determinacy check itself passes
    # cleanly. Using simulated moments (periods>0) sidesteps this exactly as
    # the project's existing order2/run_order1sim.m pipeline already does.
    sim_periods = 20000
    mod_text = f"""// =========================================================================
// Open-Economy Production-Network New Keynesian Model
// Rubbo (2024) extended to a Small Open Economy -- FULL-NATIVE-RESOLUTION
// {country_tag.upper()} DATA CALIBRATION, N={n_sectors_comment} sectors
//
// AUTO-GENERATED by data_calibration/generate_mod.py from
// {country_tag}_calibration_full_results.json -- do not hand-edit; edit the
// calibration script or generator and regenerate instead.
//
// Source: {src}
//
// Full-resolution generalization of open_economy_network_chile.mod (which
// hand-derives (I-Omega^H)^-1 via a 3x3 cofactor formula written as scalar
// Dynare parameter algebra -- infeasible at N={n_sectors_comment}). Instead:
//   - LAMBDA_D_i (Domar/domestic-supplier centrality) and WDC_i (DC-index
//     weights) are computed in Python (numpy.linalg.inv) and written in here
//     as plain calibrated CONSTANTS, not derived via in-Dynare matrix
//     inversion -- see data_calibration/full_calibration_common.py.
//   - The steady state is solved by soe_ss_solve_dense_N.m /
//     soe_ss_resid_dense_N.m, ordinary MATLAB matrix algebra (backslash
//     solves), generalizing soe_ss_solve_dense.m/soe_ss_resid_dense.m from
//     3x3 to NxN.
//   - DELTA_i (raw Calvo reset probability) is NOT identifiable from IO data
//     at any resolution; each raw sector inherits its macro-category's
//     (Resource/Manufacturing/Services) literature default (Dhyne et al.
//     2005/ECB IPN), via a category concordance kept ONLY for this purpose
//     -- see build_{country_tag}_calibration.py's build_full().
//
// REGIMES (set via -DREGIME=... on the command line):
//   float    Taylor rule targets the DC index (benchmark)
//   peg      exchange rate fixed, S_t = 1
//   managed  Taylor rule + partial FX stabilisation
//   cpi_it   strict CPI (PIC) inflation targeting
//   ppi_it   strict PPI/domestic-bundle (PH) inflation targeting
// =========================================================================

@#ifndef REGIME
@#define REGIME = "{regime}"
@#endif

// -------------------------------------------------------------------------
// VARIABLES
// -------------------------------------------------------------------------
var
{var_block}  {agg_vars}
;

// -------------------------------------------------------------------------
// EXOGENOUS SHOCKS
// -------------------------------------------------------------------------
varexo {shock_list};

// -------------------------------------------------------------------------
// PARAMETERS
// -------------------------------------------------------------------------
parameters
{par_sect_block}
{par_oh_block}
  {par_agg}
;

// -------------------------------------------------------------------------
// PARAMETER VALUES (primitive calibration)
// -------------------------------------------------------------------------
{param_values_block}

// -------------------------------------------------------------------------
// DERIVED NETWORK / POLICY OBJECTS
// (computed in Python from the calibrated OmegaH/OmegaF/betaH/DELTA -- see
// data_calibration/full_calibration_common.py -- and inserted here as plain
// calibrated constants, per the "avoid hand-unrolling matrix algebra in
// Dynare" architectural decision for N>3.)
// -------------------------------------------------------------------------
{derived_block}

// -------------------------------------------------------------------------
// MODEL BLOCK (nonlinear -- levels, NOT model(linear))
// -------------------------------------------------------------------------
model;

{model_block}

end;

// -------------------------------------------------------------------------
// STEADY STATE
// -------------------------------------------------------------------------
steady_state_model;
{ss_block}
end;

resid;
steady;
check;

// -------------------------------------------------------------------------
// SHOCKS (1 s.d. innovations)
// -------------------------------------------------------------------------
shocks;
{shocks_block}
end;

// -------------------------------------------------------------------------
// SOLUTION
// -------------------------------------------------------------------------
set_dynare_seed(20260731);
stoch_simul(order=1, irf=0, periods={sim_periods}, nograph) {report_vars_1};

stoch_simul(order=1, irf=0, periods=0, nomoments, nocorr, nodecomposition, noprint, nograph) {report_vars_2};
"""
    return mod_text


def main():
    if len(sys.argv) != 4:
        print("Usage: python generate_mod.py <calibration_full_results.json> <regime> <country_tag>")
        sys.exit(1)
    calib_path = Path(sys.argv[1])
    regime = sys.argv[2]
    country_tag = sys.argv[3]
    calib = json.loads(calib_path.read_text())
    mod_text = generate(calib, regime, country_tag)
    out_path = REPO_ROOT / f"oen_full_{country_tag}_{regime}.mod"
    out_path.write_text(mod_text)
    print(f"Wrote {out_path}  (N={calib['N']} sectors)")


if __name__ == "__main__":
    main()
