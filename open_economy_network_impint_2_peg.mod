// =========================================================================
// Open-Economy Production-Network New Keynesian Model
// Rubbo (2024) extended to a Small Open Economy
// 3 sectors: Resource (1), Manufacturing (2), Services (3)
//
// THIS FILE CONTAINS THE ORIGINAL (NONLINEAR) STRUCTURAL MODEL, not a
// hand-linearized version. Every equation below is a genuine nonlinear
// first-order condition or identity (Cobb-Douglas cost minimization,
// recursive Calvo pricing, CRRA Euler equation, CES consumption
// aggregation, UIP with a debt-elastic premium). Dynare computes the
// non-stochastic steady state numerically (see `initval`/`steady;`
// below) and then perturbs around it (order=1 or order=2) -- Dynare
// itself derives the local dynamics; nothing here is pre-linearized by
// hand. The fully hand-linearized system that Rubbo-style algebra
// implies is documented separately in model_equations.tex, Section 3,
// so you can cross-check Dynare's own order=1 decision rules against it.
//
// MICROFOUNDATIONS
// -----------------
// Production: sector i uses Cobb-Douglas technology in labor and
// (domestic + imported) intermediates, Y_it = A_it*L_it^alpha_i *
// prod_j X_ijt^omegaH_ij * M_it^omegaF_i. Cobb-Douglas cost minimization
// gives nominal marginal cost MC_it = (1/A_it)*W_t^alpha_i *
// prod_j P_jt^omegaH_ij * PFH_t^omegaF_i (eq. mc_structural in the tex).
//
// Pricing: standard Calvo (Rubbo, proofs .tex eq. around line 75): a
// fraction DELTA_i of firms in sector i reset their price optimally
// each period; survivors keep last period's price. The reset price and
// the recursive aggregator (X1,X2) below are the *exact* nonlinear
// Calvo recursion -- the "adjusted Calvo parameter" dhat_i used in the
// old linear file is NOT a primitive here; it is a pure function of
// (DELTA_i, BETA) that shows up only after log-linearizing this exact
// recursion (see proofs .tex eq. around line 198). We still compute it
// below (as DHAT1-3) purely to build the theory-implied DC-index
// weights used in the policy rule.
//
// Household: CRRA/GHH-free preferences, CES aggregation of a domestic
// bundle (Cobb-Douglas across sectors, shares BH_i) and an imported
// bundle, single internationally traded bond with a debt-elastic
// premium (Schmitt-Grohe & Uribe, 2003) for stationarity.
//
// Output gap: uses Rubbo's Lemma 1 (natural/flex-price output level =
// Domar-weighted TFP) in closed form, so no separate shadow flex-price
// block is needed -- y_gap_t = sum_i lambda_D_i*[log(Y_it/Ybar_i) -
// log(A_it)] is an EXACT implication of the model, not an approximation.
//
// REGIMES (set via -DREGIME=... on the command line, or edit below):
//   float    Taylor rule targets the DC index (benchmark)
//   peg      exchange rate fixed, S_t = 1
//   managed  Taylor rule + partial FX stabilisation
// =========================================================================

@#ifndef REGIME
@#define REGIME = "peg"
@#endif

// -------------------------------------------------------------------------
// VARIABLES
// -------------------------------------------------------------------------
var
  Y1 Y2 Y3            // sectoral gross output
  L1 L2 L3            // sectoral labor
  P1 P2 P3            // sectoral price levels (nominal, level)
  PI1 PI2 PI3         // sectoral gross inflation P_i/P_i(-1)
  MC1 MC2 MC3         // nominal marginal cost, sector i
  PSTAR1 PSTAR2 PSTAR3    // optimal reset price relative to P_i (P_i#/P_i)
  X1_1 X2_1 X1_2 X2_2 X1_3 X2_3   // Calvo recursive aggregators (num/denom)
  C CH CF             // aggregate, domestic-bundle, imported-bundle consumption
  PH PC PIC           // domestic-bundle price, CPI, CPI gross inflation
  Ltot W              // aggregate labor, nominal wage
  S PF PFH            // exchange rate, foreign import price, PFH = S*PF
  BSTAR I             // net foreign assets, gross nominal interest rate
  EX IM               // real exports, real imports (composite units)
  DSTAR               // foreign demand shifter
  PX                   // export price / commodity ToT shifter (world price of home export bundle)
  RP                    // foreign risk-premium / UIP shifter (country-premium "sudden stop" shock)
  A1 A2 A3            // sectoral TFP levels
  piDC y_gap          // DC inflation index (policy target), output gap (Lemma 1)
  y_gap1 y_gap2 y_gap3  // sector-level contributions to y_gap (Domar-weighted, pre-sum)
  GDP                 // nominal GDP (absorption + net exports), reporting only
;

// -------------------------------------------------------------------------
// EXOGENOUS SHOCKS
// -------------------------------------------------------------------------
varexo eps_a1 eps_a2 eps_a3 eps_pF eps_D eps_pX eps_rp;

// -------------------------------------------------------------------------
// PARAMETERS
// -------------------------------------------------------------------------
parameters
  BETA GAMMA VARPHI EPS
  DELTA1 DELTA2 DELTA3          // raw Calvo RESET probabilities (primitives)
  ALPHA1 ALPHA2 ALPHA3          // labour cost shares
  OH21 OH32                     // domestic input-output shares
  OF1 OF2 OF3                   // total imported-input cost shares
  BH1 BH2 BH3                   // domestic consumption shares (Cobb-Douglas)
  BF_TOT OMEGA ETA               // aggregate import share in CPI, home-bias weight, home/foreign elasticity
  PSI THETA_S KAPEX_SCALE BSTARBAR   // open-economy: NFA premium, export elasticity, export scale, NFA target
  ISTAR                          // steady-state foreign gross rate (pinned by BETA)
  PHI_PI PHI_Y PHI_S             // policy
  RHO_A RHO_PF RHO_D RHO_PX RHO_RP // shock persistence
  LAMBDA_D1 LAMBDA_D2 LAMBDA_D3   // Domar / domestic-supplier centrality (derived)
  DHAT1 DHAT2 DHAT3               // adjusted Calvo parameters (derived, reporting/weights only)
  WDC1 WDC2 WDC3                   // DC-index weights (derived)
  MIMP1 MIMP2 MIMP3                // import centrality (derived, reporting only)
;

// -------------------------------------------------------------------------
// PARAMETER VALUES (primitive calibration)
// -------------------------------------------------------------------------
BETA    = 0.99;
GAMMA   = 1.00;
VARPHI  = 2.00;
EPS     = 8.00;      // within-sector elasticity of substitution (all sectors)

// Raw Calvo reset probabilities (delta_i in proofs.tex, NOT dhat_i)
DELTA1  = 0.75;      // Resource: flexible (commodity prices)
DELTA2  = 0.50;      // Manufacturing: intermediate stickiness
DELTA3  = 0.25;      // Services: sticky

ALPHA1  = 0.850000;
ALPHA2  = 0.750000;
ALPHA3  = 0.725000;

OH21    = 0.20;      // Manuf. <- Resource (domestic)
OH32    = 0.25;      // Services <- Manuf. (domestic)

OF1     = 0.150000;      // Resource: imported machinery
OF2     = 0.050000;      // Manufacturing: imported components
OF3     = 0.025000;      // Services: indirect imports

BH1     = 0.05;
BH2     = 0.15;
BH3     = 0.80;
BF_TOT  = 0.10;
OMEGA   = 1 - BF_TOT;   // home bias weight in the outer CES nest
ETA     = 1.50;         // home/foreign substitution elasticity (Gali-Monacelli 2005)

PSI        = 0.020;
THETA_S    = 2.00;
KAPEX_SCALE = 0.50;      // export-demand scale constant -- calibrated, see note below
BSTARBAR    = 0.00;      // target/steady-state NFA position (debt-elastic premium reference)

PHI_PI  = 1.50;
PHI_Y   = 0.50;
PHI_S   = 0.30;

RHO_A   = 0.90;
RHO_PF  = 0.85;
RHO_D   = 0.80;
RHO_PX  = 0.85;      // export price/ToT shock persistence (commodity prices: persistent, mirrors RHO_PF)
RHO_RP  = 0.80;      // risk-premium/UIP shock persistence ("sudden stop" style, transient-to-moderate)

ISTAR = 1/BETA;   // pins down the foreign nominal rate so UIP + Euler are
                  // jointly consistent with a zero-inflation steady state
                  // at BSTAR = BSTARBAR (standard SOE closure).

// -------------------------------------------------------------------------
// DERIVED NETWORK / POLICY OBJECTS
// (computed once from the primitives above -- no magic numbers)
//
// Dynare's preprocessor only accepts SCALAR expressions for top-level
// parameter assignments (no Matlab matrix literals like [0,0,0;...]), so
// the 3x3 Leontief-inverse algebra is unrolled here by hand into closed
// form for this triangular network (Omega^H strictly lower triangular:
// sector 2 buys from 1 via OH21, sector 3 buys from 2 via OH32, so
// (I-Omega^H)^-1 = I + Omega^H + Omega^H^2 exactly, no higher terms).
// -------------------------------------------------------------------------
LAMBDA_D1 = BH1 + BH2*OH21 + BH3*OH21*OH32;   // eq. (lambdaD)
LAMBDA_D2 = BH2 + BH3*OH32;
LAMBDA_D3 = BH3;

MIMP1 = OF1;                                   // eq. (importcent)
MIMP2 = OH21*OF1 + OF2;
MIMP3 = OH32*OH21*OF1 + OH32*OF2 + OF3;

DHAT1 = DELTA1*(1-BETA*(1-DELTA1)) / (1-BETA*DELTA1*(1-DELTA1));
DHAT2 = DELTA2*(1-BETA*(1-DELTA2)) / (1-BETA*DELTA2*(1-DELTA2));
DHAT3 = DELTA3*(1-BETA*(1-DELTA3)) / (1-BETA*DELTA3*(1-DELTA3));

WDC1 = (LAMBDA_D1*(1-DHAT1)/DHAT1) / ( LAMBDA_D1*(1-DHAT1)/DHAT1 + LAMBDA_D2*(1-DHAT2)/DHAT2 + LAMBDA_D3*(1-DHAT3)/DHAT3 );
WDC2 = (LAMBDA_D2*(1-DHAT2)/DHAT2) / ( LAMBDA_D1*(1-DHAT1)/DHAT1 + LAMBDA_D2*(1-DHAT2)/DHAT2 + LAMBDA_D3*(1-DHAT3)/DHAT3 );
WDC3 = (LAMBDA_D3*(1-DHAT3)/DHAT3) / ( LAMBDA_D1*(1-DHAT1)/DHAT1 + LAMBDA_D2*(1-DHAT2)/DHAT2 + LAMBDA_D3*(1-DHAT3)/DHAT3 );

disp('=== Domar / domestic-supplier centrality (lambda_D1-3) ===');
disp([LAMBDA_D1, LAMBDA_D2, LAMBDA_D3]);
disp('=== Import centrality (M_1-3) ===');
disp([MIMP1, MIMP2, MIMP3]);
disp('=== Adjusted Calvo parameters (dhat_1-3, reporting only) ===');
disp([DHAT1, DHAT2, DHAT3]);
disp('=== DC-index weights (w_DC_1-3) ===');
disp([WDC1, WDC2, WDC3]);

// -------------------------------------------------------------------------
// MODEL BLOCK (nonlinear -- levels, NOT model(linear))
// -------------------------------------------------------------------------
model;

//----------------------------------------------------------------
// [1] Nominal marginal cost, Cobb-Douglas cost minimization
//----------------------------------------------------------------
MC1 = (1/A1) * W^ALPHA1                          * PFH^OF1;
MC2 = (1/A2) * W^ALPHA2 * P1^OH21                * PFH^OF2;
MC3 = (1/A3) * W^ALPHA3 * P2^OH32                * PFH^OF3;

//----------------------------------------------------------------
// [2] Recursive Calvo pricing (exact nonlinear recursion), sector 1
//----------------------------------------------------------------
X1_1 = (MC1/P1)*Y1 + (1-DELTA1)*BETA*(C(+1)/C)^(-GAMMA)*PI1(+1)^EPS      *X1_1(+1);
X2_1 = Y1     + (1-DELTA1)*BETA*(C(+1)/C)^(-GAMMA)*PI1(+1)^(EPS-1)  *X2_1(+1);
PSTAR1 = (EPS/(EPS-1)) * X1_1/X2_1;
1 = (1-DELTA1)*PI1^(EPS-1) + DELTA1*PSTAR1^(1-EPS);
P1 = PI1*P1(-1);

// sector 2
X1_2 = (MC2/P2)*Y2 + (1-DELTA2)*BETA*(C(+1)/C)^(-GAMMA)*PI2(+1)^EPS      *X1_2(+1);
X2_2 = Y2     + (1-DELTA2)*BETA*(C(+1)/C)^(-GAMMA)*PI2(+1)^(EPS-1)  *X2_2(+1);
PSTAR2 = (EPS/(EPS-1)) * X1_2/X2_2;
1 = (1-DELTA2)*PI2^(EPS-1) + DELTA2*PSTAR2^(1-EPS);
P2 = PI2*P2(-1);

// sector 3
X1_3 = (MC3/P3)*Y3 + (1-DELTA3)*BETA*(C(+1)/C)^(-GAMMA)*PI3(+1)^EPS      *X1_3(+1);
X2_3 = Y3     + (1-DELTA3)*BETA*(C(+1)/C)^(-GAMMA)*PI3(+1)^(EPS-1)  *X2_3(+1);
PSTAR3 = (EPS/(EPS-1)) * X1_3/X2_3;
1 = (1-DELTA3)*PI3^(EPS-1) + DELTA3*PSTAR3^(1-EPS);
P3 = PI3*P3(-1);

//----------------------------------------------------------------
// [3] Labour demand (Cobb-Douglas cost share ALPHA_i of total cost)
//----------------------------------------------------------------
L1 = ALPHA1*MC1*Y1/W;
L2 = ALPHA2*MC2*Y2/W;
L3 = ALPHA3*MC3*Y3/W;
Ltot = L1 + L2 + L3;

//----------------------------------------------------------------
// [4] Goods market clearing: output = domestic consumption
//     + domestic intermediate demand + exports
//     (export bundle shares the same Cobb-Douglas composition BH_i
//      as domestic consumption -- "one home good sold at home and abroad")
//----------------------------------------------------------------
Y1 = BH1*PH*CH/P1 + OH21*MC2*Y2/P1 + BH1*PH*EX/P1;
Y2 = BH2*PH*CH/P2 + OH32*MC3*Y3/P2 + BH2*PH*EX/P2;
Y3 = BH3*PH*CH/P3                  + BH3*PH*EX/P3;

//----------------------------------------------------------------
// [5] Consumption aggregation: Cobb-Douglas domestic bundle,
//     CES nest between domestic (H) and imported (F) bundles
//----------------------------------------------------------------
PH = P1^BH1 * P2^BH2 * P3^BH3;
PC = ( OMEGA*PH^(1-ETA) + (1-OMEGA)*PFH^(1-ETA) )^(1/(1-ETA));
CH = OMEGA*(PH/PC)^(-ETA)*C;
CF = (1-OMEGA)*(PFH/PC)^(-ETA)*C;
PIC = PC/PC(-1);

//----------------------------------------------------------------
// [6] Household Euler equation and labour supply (nonlinear CRRA/Frisch)
//----------------------------------------------------------------
C^(-GAMMA) = BETA*I*(C(+1)^(-GAMMA))/PIC(+1);
W/PC = C^GAMMA * Ltot^VARPHI;

//----------------------------------------------------------------
// [7] Exchange rate block: LOP for imports, UIP with debt-elastic premium
//     RP: exogenous country risk-premium / foreign-rate shifter -- multiplies
//     the same wedge as the debt-elastic term, so a shock here is the
//     "foreign interest rate" / sudden-stop shock (Schmitt-Grohe & Uribe,
//     2003 style), isolating the pure monetary-autonomy channel: it hits
//     every sector symmetrically via I_t and UIP, unlike eps_pF/eps_pX
//     which route through the network via Omega^F.
//----------------------------------------------------------------
PFH = S*PF;
I = ISTAR*(1 - PSI*(BSTAR - BSTARBAR)) * RP * S(+1)/S;

//----------------------------------------------------------------
// [8] Net foreign assets: current-account identity
//     BSTAR_t = gross return on BSTAR_{t-1} + real trade balance
//----------------------------------------------------------------
BSTAR = (I(-1)/PIC)*BSTAR(-1) + (PH*EX - PFH*IM)/PC;

//----------------------------------------------------------------
// [9] Export demand and total import demand
//     EX: reduced-form ROW demand for the home composite good,
//         decreasing in the real exchange rate PH/PFH, increasing in DSTAR,
//         and shifted by PX (an exogenous world commodity-price/ToT term,
//         distinct from DSTAR: DSTAR moves ROW demand at a given relative
//         price, PX moves the terms on which that demand is offered --
//         e.g. a Resource-sector world price boom)
//     IM: final imported consumption + imported intermediate inputs
//----------------------------------------------------------------
EX = KAPEX_SCALE*DSTAR*PX*(PH/PFH)^(-THETA_S);
IM = CF + OF1*MC1*Y1/PFH + OF2*MC2*Y2/PFH + OF3*MC3*Y3/PFH;

//----------------------------------------------------------------
// [10] Policy rule (regime-dependent)
//----------------------------------------------------------------
@#if REGIME == "float"
log(I/ISTAR) = PHI_PI*piDC + PHI_Y*y_gap;

@#elseif REGIME == "peg"
S = 1;
// I is residual, pinned down by the UIP equation in block [7]

@#elseif REGIME == "managed"
log(I/ISTAR) = PHI_PI*piDC + PHI_Y*y_gap + PHI_S*log(S);

@#endif

//----------------------------------------------------------------
// [11] DC inflation index and output gap
//      DC weights from Rubbo Prop. 1 (log measure of realized inflation)
//      y_gap from Lemma 1: natural output = Domar-weighted TFP, in closed form
//----------------------------------------------------------------
piDC = WDC1*log(PI1) + WDC2*log(PI2) + WDC3*log(PI3);
y_gap1 = LAMBDA_D1*(log(Y1/STEADY_STATE(Y1)) - log(A1));
y_gap2 = LAMBDA_D2*(log(Y2/STEADY_STATE(Y2)) - log(A2));
y_gap3 = LAMBDA_D3*(log(Y3/STEADY_STATE(Y3)) - log(A3));
y_gap = y_gap1 + y_gap2 + y_gap3;

//----------------------------------------------------------------
// [12] Exogenous shock processes (AR(1) in logs)
//----------------------------------------------------------------
log(A1) = RHO_A *log(A1(-1))  + eps_a1;
log(A2) = RHO_A *log(A2(-1))  + eps_a2;
log(A3) = RHO_A *log(A3(-1))  + eps_a3;
log(PF) = RHO_PF*log(PF(-1))  + eps_pF;
log(DSTAR) = RHO_D*log(DSTAR(-1)) + eps_D;
log(PX) = RHO_PX*log(PX(-1)) + eps_pX;
log(RP) = RHO_RP*log(RP(-1)) + eps_rp;

//----------------------------------------------------------------
// [13] Reporting: nominal GDP = absorption + net exports
//----------------------------------------------------------------
GDP = PC*C + PH*EX - PFH*IM;

end;

// -------------------------------------------------------------------------
// STEADY STATE
// Closed-form/semi-analytical, not guessed. At zero shocks and zero
// inflation: PSTAR_i=1, PI_i=1, and (since no price dispersion) the
// optimal price is exactly a markup over marginal cost, P_i=MU*MC_i
// with MU=eps/(eps-1). That collapses the whole 46-equation nonlinear
// system to a single scalar root-find in the real wage W (see
// soe_ss_resid.m for the full cascade: given W, prices are closed-form
// Cobb-Douglas; EX is closed-form export demand; C is closed-form from
// the zero-trade-balance condition, which must hold because UIP+Euler
// force BSTAR_ss=BSTARBAR exactly whenever PSI!=0). fzero (base MATLAB,
// no Optimization Toolbox) then finds W. This is "let the solver find
// the answer", just exploiting the model's own structure to make that
// solve 1-dimensional instead of a blind 46-dimensional Newton search.
// -------------------------------------------------------------------------
steady_state_model;
A1 = 1; A2 = 1; A3 = 1;
PF = 1; DSTAR = 1; PX = 1; RP = 1; S = 1;
PFH = S*PF;
MU = EPS/(EPS-1);

[W,C,EX,PH,PC,P1,P2,P3,MC1,MC2,MC3,Y1,Y2,Y3,L1,L2,L3,Ltot,CH,CF] = soe_ss_solve(ALPHA1,ALPHA2,ALPHA3,OH21,OH32,OF1,OF2,OF3,BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX_SCALE,GAMMA,VARPHI,MU);
IM = PH*EX/PFH;   % zero trade balance holds exactly by construction

PI1 = 1; PI2 = 1; PI3 = 1; PIC = 1;
PSTAR1 = 1; PSTAR2 = 1; PSTAR3 = 1;
X1_1 = (MC1/P1)*Y1/(1-(1-DELTA1)*BETA); X2_1 = Y1/(1-(1-DELTA1)*BETA);
X1_2 = (MC2/P2)*Y2/(1-(1-DELTA2)*BETA); X2_2 = Y2/(1-(1-DELTA2)*BETA);
X1_3 = (MC3/P3)*Y3/(1-(1-DELTA3)*BETA); X2_3 = Y3/(1-(1-DELTA3)*BETA);

I = 1/BETA;
BSTAR = BSTARBAR;
piDC = 0; y_gap = 0; y_gap1 = 0; y_gap2 = 0; y_gap3 = 0;
GDP = PC*C + PH*EX - PFH*IM;
end;

resid;
steady;
check;

// -------------------------------------------------------------------------
// SHOCKS (1 s.d. innovations)
// -------------------------------------------------------------------------
shocks;
var eps_a1  = 0.01^2;
var eps_a2  = 0.01^2;
var eps_a3  = 0.01^2;
var eps_pF  = 0.01^2;
var eps_D   = 0.01^2;
var eps_pX  = 0.01^2;
var eps_rp  = 0.01^2;
end;

// -------------------------------------------------------------------------
// SOLUTION
// order=1: a pure inflation/output-gap Taylor rule (no price-level or
// ER-level target) leaves the LEVEL of P1-3, PC, S, GDP as a unit root
// (permanent, non-mean-reverting) even though inflation rates and the
// output gap are stationary -- standard and expected in NK models
// without price-level targeting. Dynare's order>=2 pruned state-space
// cannot handle that unit root (pruned_state_space_system errors out),
// so order=1 is used here; theoretical moments/variances are requested
// only for the stationary variables (inflation rates, output gap, DC
// index, interest rate, NFA). IRFs for S, GDP, P1-3 are still available
// in oo_.irfs regardless of what is listed below.
// Caveat: welfare comparisons across regimes are therefore first-order
// (Kim-Kim / Woodford: strictly, curvature terms enter welfare only at
// second order) -- treat cross-regime welfare rankings as indicative,
// not certainty-equivalent-exact.
// -------------------------------------------------------------------------
stoch_simul(order=1, irf=40, periods=0, graph_format=pdf) piDC PIC y_gap y_gap1 y_gap2 y_gap3 PI1 PI2 PI3 I BSTAR;

// Second call, IRFs only (nomoments/nocorr/noprint): adds the unit-root
// variables (S, GDP, P1-3, PC, EX, IM, C) so their IRFs land in
// oo_.irfs too, without asking Dynare to compute unconditional variances
// for non-stationary variables (which would either error or be
// economically meaningless -- their IRFs do not decay back to zero,
// which is the expected, correct behavior of a pure inflation/output-gap
// Taylor rule with no price-level anchor).
stoch_simul(order=1, irf=40, periods=0, nomoments, nocorr, nodecomposition, noprint) piDC PIC y_gap y_gap1 y_gap2 y_gap3 PI1 PI2 PI3 I BSTAR S GDP EX IM C P1 P2 P3 PX RP A1 A2 A3 PF DSTAR;
