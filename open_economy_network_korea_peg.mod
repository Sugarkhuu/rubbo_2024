// =========================================================================
// Open-Economy Production-Network New Keynesian Model
// Rubbo (2024) extended to a Small Open Economy -- KOREA DATA CALIBRATION
// 3 sectors: Resource (1), Manufacturing (2), Services (3)
//
// This is a generalization of open_economy_network.mod: that file hard-codes
// a STRICTLY TRIANGULAR domestic network (sector 2 buys only from 1, sector
// 3 buys only from 2, no self-loops, no reverse flows) because the closed-
// form Leontief inverse (I-Omega^H)^-1 = I + Omega^H + Omega^H^2 is exact
// only in that special case. This file instead uses a DENSE, empirically
// calibrated Omega^H (all 9 entries, including diagonal/self-use and
// reverse flows) taken from Korea's actual 2022 national input-output
// table -- see data_calibration/build_korea_calibration.py and
// data_calibration/korea_calibration_results.json for the full source,
// sector concordance, and derivation. Because Omega^H is no longer
// nilpotent, (I-Omega^H)^-1 is computed here via the general 3x3 matrix-
// inverse (adjugate/cofactor) formula, written out as scalar Dynare
// parameter algebra so the whole calibration stays self-contained and
// auditable (no hidden external matrix-inversion step).
//
// CALIBRATED FROM DATA (Bank of Korea, 2022 Input-Output Tables,
// Producer's price, Large-Sized, 33-sector): OH11-OH33 (domestic IO
// matrix), OF1-OF3 (import cost shares), BH1-BH3 (household consumption
// shares), ALPHA1-ALPHA3 (value-added shares, standing in for the
// model's labor share since there is no separate capital factor).
// STILL LITERATURE-CALIBRATED (not identifiable from IO data): BETA,
// GAMMA, VARPHI, EPS, DELTA1-3 (Calvo stickiness), PSI, THETA_S,
// KAPEX_SCALE, shock persistences.
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
  ALPHA1 ALPHA2 ALPHA3          // value-added shares (Korea IO data)
  OH11 OH12 OH13                // domestic IO shares, Resource buyer  <- R,M,S seller (Korea IO data)
  OH21 OH22 OH23                // domestic IO shares, Manuf.  buyer  <- R,M,S seller
  OH31 OH32 OH33                // domestic IO shares, Services buyer <- R,M,S seller
  OF1 OF2 OF3                    // total imported-input cost shares (Korea IO data)
  BH1 BH2 BH3                    // domestic consumption shares (Korea IO data)
  BF_TOT OMEGA ETA               // aggregate import share in CPI, home-bias weight, home/foreign elasticity
  PSI THETA_S KAPEX_SCALE BSTARBAR   // open-economy: NFA premium, export elasticity, export scale, NFA target
  ISTAR                          // steady-state foreign gross rate (pinned by BETA)
  PHI_PI PHI_Y PHI_S             // policy
  RHO_A RHO_PF RHO_D RHO_PX RHO_RP // shock persistence
  LAMBDA_D1 LAMBDA_D2 LAMBDA_D3   // Domar / domestic-supplier centrality (derived)
  DHAT1 DHAT2 DHAT3               // adjusted Calvo parameters (derived, reporting/weights only)
  WDC1 WDC2 WDC3                   // DC-index weights (derived)
  MIMP1 MIMP2 MIMP3                // import centrality (derived, reporting only)
  M11 M12 M13 M21 M22 M23 M31 M32 M33   // I - Omega^H entries (scratch, for the general 3x3 inverse)
  DETM                                    // det(I - Omega^H) (scratch)
  MINV11 MINV12 MINV13 MINV21 MINV22 MINV23 MINV31 MINV32 MINV33  // (I-Omega^H)^-1 entries (scratch)
;

// -------------------------------------------------------------------------
// PARAMETER VALUES (primitive calibration)
// -------------------------------------------------------------------------
BETA    = 0.99;
GAMMA   = 1.00;
VARPHI  = 2.00;
EPS     = 8.00;      // within-sector elasticity of substitution (all sectors)

// Raw Calvo reset probabilities (delta_i in proofs.tex, NOT dhat_i) --
// NOT identifiable from IO data (no country-specific sector-level
// price-microdata estimate was found for Chile, Korea, or Czechia, so all
// three use this SAME literature-sourced default rather than the original
// hand-picked 0.75/0.50/0.25 stylized numbers). Built from monthly
// frequency-of-price-change estimates converted to a quarterly Calvo
// reset probability via delta_q = 1-(1-f_monthly)^3:
//   Resource:      avg(energy 78.0%, unprocessed food 28.3%) = 53.15%/mo
//                  -> delta_q = 0.90   [Dhyne et al. 2005 / ECB IPN]
//   Manufacturing: avg(processed food 13.7%, non-energy industrial
//                  goods 9.2%) = 11.45%/mo -> delta_q = 0.31
//                  [Dhyne et al. 2005 / ECB IPN; cross-checked against
//                  Nakamura & Steinsson (2008) US PPI finished-goods
//                  duration of 8.7 months -> delta_q = 0.31, near-identical]
//   Services:      5.6%/mo -> delta_q = 0.16  [Dhyne et al. 2005 / ECB IPN]
// Source: E. Dhyne et al. (2005/2006), "Price Setting in the Euro Area:
// Some Stylized Facts from Individual Consumer Price Data", as summarized
// in ECB Occasional Paper "Inflation Persistence and Price-Setting
// Behaviour in the Euro Area" (Table 4.1); Nakamura & Steinsson (2008 QJE),
// "Five Facts about Prices". This is a euro-area/US average, not a
// Chile/Korea/Czechia-specific estimate -- see the note in
// data_calibration/*_calibration_results.json.
DELTA1  = 0.90;      // Resource: flexible (energy + unprocessed food)
DELTA2  = 0.31;      // Manufacturing: processed/industrial goods
DELTA3  = 0.16;      // Services: sticky

// Value-added shares: DATA (Bank of Korea, combined transaction sheet,
// row "9690 Total value added", aggregated Resource/Manuf/Services).
ALPHA1  = 0.4576;
ALPHA2  = 0.2582;
ALPHA3  = 0.5574;

// Domestic IO matrix OH_ij = buyer i's cost share spent on seller j: DATA
// (sheet 'Transaction_domestic(producer)', aggregated & renormalized so
// ALPHA_i + sum_j OH_ij + OF_i = 1 exactly -- see build script).
OH11 = 0.0444;  OH12 = 0.3106;  OH13 = 0.1470;   // Resource buys from R, M, S
OH21 = 0.0147;  OH22 = 0.3624;  OH23 = 0.1238;   // Manuf.   buys from R, M, S
OH31 = 0.0050;  OH32 = 0.1430;  OH33 = 0.2438;   // Services buys from R, M, S

// Import cost shares: DATA (sheet 'Transaction_imported(producer)').
OF1     = 0.0404;    // Resource
OF2     = 0.2409;    // Manufacturing (most import-intensive sector in the data -- Korea's
                     // electronics/machinery supply chains run on imported intermediates)
OF3     = 0.0508;    // Services

// Household consumption shares: DATA (combined sheet, column "9111 Private
// final consumption expenditure").
BH1     = 0.0176;
BH2     = 0.2494;
BH3     = 0.7330;
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
// Omega^H is now DENSE (not nilpotent), so (I-Omega^H)^-1 needs the general
// 3x3 matrix inverse. Dynare's preprocessor only accepts SCALAR expressions
// for top-level parameter assignments, so the adjugate/cofactor formula is
// unrolled here by hand instead of calling inv(). Cross-checked numerically
// against data_calibration/build_korea_calibration.py's numpy computation
// (LAMBDA_D = [0.0340, 0.6505, 1.0826], MIMP = [0.1983, 0.4108, 0.1461]).
// -------------------------------------------------------------------------
M11 = 1 - OH11;
M12 = -OH12;
M13 = -OH13;
M21 = -OH21;
M22 = 1 - OH22;
M23 = -OH23;
M31 = -OH31;
M32 = -OH32;
M33 = 1 - OH33;

DETM = M11*(M22*M33 - M23*M32) - M12*(M21*M33 - M23*M31) + M13*(M21*M32 - M22*M31);

MINV11 = (M22*M33 - M23*M32)/DETM;
MINV12 = (M13*M32 - M12*M33)/DETM;
MINV13 = (M12*M23 - M13*M22)/DETM;
MINV21 = (M23*M31 - M21*M33)/DETM;
MINV22 = (M11*M33 - M13*M31)/DETM;
MINV23 = (M13*M21 - M11*M23)/DETM;
MINV31 = (M21*M32 - M22*M31)/DETM;
MINV32 = (M12*M31 - M11*M32)/DETM;
MINV33 = (M11*M22 - M12*M21)/DETM;

// LAMBDA_D = BH' * (I-Omega^H)^-1  (row vector times matrix)
LAMBDA_D1 = BH1*MINV11 + BH2*MINV21 + BH3*MINV31;
LAMBDA_D2 = BH1*MINV12 + BH2*MINV22 + BH3*MINV32;
LAMBDA_D3 = BH1*MINV13 + BH2*MINV23 + BH3*MINV33;

// MIMP = (I-Omega^H)^-1 * OF  (matrix times column vector)
MIMP1 = MINV11*OF1 + MINV12*OF2 + MINV13*OF3;
MIMP2 = MINV21*OF1 + MINV22*OF2 + MINV23*OF3;
MIMP3 = MINV31*OF1 + MINV32*OF2 + MINV33*OF3;

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
//     (dense: each sector buys inputs from ALL three domestic sectors)
//----------------------------------------------------------------
MC1 = (1/A1) * W^ALPHA1 * P1^OH11 * P2^OH12 * P3^OH13 * PFH^OF1;
MC2 = (1/A2) * W^ALPHA2 * P1^OH21 * P2^OH22 * P3^OH23 * PFH^OF2;
MC3 = (1/A3) * W^ALPHA3 * P1^OH31 * P2^OH32 * P3^OH33 * PFH^OF3;

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
//     + domestic intermediate demand (from ALL buying sectors, dense)
//     + exports (export bundle shares the same Cobb-Douglas composition
//       BH_i as domestic consumption -- "one home good sold at home and
//       abroad")
//----------------------------------------------------------------
Y1 = BH1*PH*CH/P1 + (OH11*MC1*Y1 + OH21*MC2*Y2 + OH31*MC3*Y3)/P1 + BH1*PH*EX/P1;
Y2 = BH2*PH*CH/P2 + (OH12*MC1*Y1 + OH22*MC2*Y2 + OH32*MC3*Y3)/P2 + BH2*PH*EX/P2;
Y3 = BH3*PH*CH/P3 + (OH13*MC1*Y1 + OH23*MC2*Y2 + OH33*MC3*Y3)/P3 + BH3*PH*EX/P3;

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
//----------------------------------------------------------------
PFH = S*PF;
I = ISTAR*(1 - PSI*(BSTAR - BSTARBAR)) * RP * S(+1)/S;

//----------------------------------------------------------------
// [8] Net foreign assets: current-account identity
//----------------------------------------------------------------
BSTAR = (I(-1)/PIC)*BSTAR(-1) + (PH*EX - PFH*IM)/PC;

//----------------------------------------------------------------
// [9] Export demand and total import demand
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
// Same "let the solver find the answer" strategy as open_economy_network.mod,
// but with the recursive P1->P2->P3 and Y3->Y2->Y1 substitutions replaced by
// genuine 3x3 linear-system solves (log P = (I-Omega^H)^-1 * cost terms; Y =
// (I - D^-1 Omega^H' diag(MC))^-1 * demand), since the dense network is no
// longer a simple upstream-to-downstream chain. See soe_ss_resid_dense.m.
// -------------------------------------------------------------------------
steady_state_model;
A1 = 1; A2 = 1; A3 = 1;
PF = 1; DSTAR = 1; PX = 1; RP = 1; S = 1;
PFH = S*PF;
MU = EPS/(EPS-1);

[W,C,EX,PH,PC,P1,P2,P3,MC1,MC2,MC3,Y1,Y2,Y3,L1,L2,L3,Ltot,CH,CF] = soe_ss_solve_dense(ALPHA1,ALPHA2,ALPHA3,OH11,OH12,OH13,OH21,OH22,OH23,OH31,OH32,OH33,OF1,OF2,OF3,BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX_SCALE,GAMMA,VARPHI,MU);
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
// SOLUTION (see open_economy_network.mod for the long note on why order=1
// and two stoch_simul calls -- identical reasoning applies here).
// -------------------------------------------------------------------------
stoch_simul(order=1, irf=40, periods=0, graph_format=pdf) piDC PIC y_gap y_gap1 y_gap2 y_gap3 PI1 PI2 PI3 I BSTAR;

stoch_simul(order=1, irf=40, periods=0, nomoments, nocorr, nodecomposition, noprint) piDC PIC y_gap y_gap1 y_gap2 y_gap3 PI1 PI2 PI3 I BSTAR S GDP EX IM C P1 P2 P3 PX RP A1 A2 A3 PF DSTAR;
