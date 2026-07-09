// =========================================================
// Open Economy Production Network NK Model
// Rubbo (2024) extended to Small Open Economy
// 3 sectors: Resource (1), Manufacturing (2), Services (3)
//
// REGIMES (uncomment one):
// @#define REGIME = "float"    // Free float (default)
// @#define REGIME = "peg"      // Hard peg
// @#define REGIME = "managed"  // Managed float
@#define REGIME = "float"
// =========================================================

// ---------------------------------------------------------
// VARIABLES
// ---------------------------------------------------------
var
// Sectoral inflation
pi1 pi2 pi3

// Aggregate inflation measures
piDC piCPI

// Output gap and interest rate
y_gap i_hat

// Exchange rate (log deviation, depreciation = positive)
s_hat

// Sectoral price levels (log deviation)
p1 p2 p3

// Consumer price level (log deviation)
pC_hat

// Real wage (log deviation)
w_hat

// Net foreign assets (log deviation)
bstar

// TFP shocks (sectoral)
a1 a2 a3

// Import price shock
pF

// Foreign demand shock
D_star
;

// ---------------------------------------------------------
// EXOGENOUS SHOCKS
// ---------------------------------------------------------
varexo eps_a1 eps_a2 eps_a3 eps_pF eps_D;

// ---------------------------------------------------------
// PARAMETERS
// ---------------------------------------------------------
parameters
// Preferences
BETA GAMMA VARPHI

// Adjusted Calvo parameters (Rubbo eq. after (14))
DHAT1 DHAT2 DHAT3

// Labour shares
ALPHA1 ALPHA2 ALPHA3

// Domestic input-output shares
OH21      // Manuf. buys from Resource (domestic)
OH32      // Services buys from Manuf. (domestic)

// Import shares (total per sector)
OF1 OF2 OF3

// Final consumption shares (domestic sectors)
BH1 BH2 BH3

// Total import share in final consumption
BF_TOT

// DC index weights
WDC1 WDC2 WDC3

// Open economy
PSI       // NFA premium
THETA_S   // export price elasticity
KAP_EX    // exports/GDP
KAP_IM    // imports/GDP
NU_D      // foreign demand sensitivity

// Policy
PHI_PI PHI_Y PHI_S

// Shock persistence
RHO_A RHO_PF RHO_D
;

// ---------------------------------------------------------
// PARAMETER VALUES
// ---------------------------------------------------------

// Preferences
BETA    = 0.99;
GAMMA   = 1.00;
VARPHI  = 2.00;

// Adjusted Calvo (delta_hat from eq. (2))
// delta = [0.75, 0.50, 0.25], beta = 0.99
// dhat_i = delta_i*(1-beta*(1-delta_i))/(1-beta*delta_i*(1-delta_i))
DHAT1   = 0.693;
DHAT2   = 0.336;
DHAT3   = 0.079;

// Labour shares (alpha_i = 1 - sum_j(omega_H_ij + omega_F_ij))
ALPHA1  = 0.70;   // Resource:  1 - 0.00 - 0.30
ALPHA2  = 0.70;   // Manuf.:    1 - 0.20 - 0.10
ALPHA3  = 0.70;   // Services:  1 - 0.25 - 0.05

// Domestic I-O shares
OH21    = 0.20;   // Manuf. <- Resource (domestic)
OH32    = 0.25;   // Services <- Manuf. (domestic)

// Total import shares per sector
OF1     = 0.30;   // Resource
OF2     = 0.10;   // Manufacturing
OF3     = 0.05;   // Services

// Final consumption shares
BH1     = 0.05;
BH2     = 0.15;
BH3     = 0.80;
BF_TOT  = 0.10;

// DC index weights  w_i propto lambda_D_i*(1-dhat_i)/dhat_i
// lambda_D = [0.12, 0.35, 0.80] (domestic supplier centrality)
// raw weights:
//   w1 = 0.12*(1-0.693)/0.693 = 0.0532
//   w2 = 0.35*(1-0.336)/0.336 = 0.6916
//   w3 = 0.80*(1-0.079)/0.079 = 9.328
//   total = 10.073
WDC1    = 0.0053;
WDC2    = 0.0686;
WDC3    = 0.9261;

// Open economy
PSI      = 0.020;
THETA_S  = 2.00;
KAP_EX   = 0.85;
KAP_IM   = 0.45;
NU_D     = 0.30;

// Policy
PHI_PI   = 1.50;
PHI_Y    = 0.50;
PHI_S    = 0.30;   // managed float only

// Shock persistence
RHO_A    = 0.90;
RHO_PF   = 0.85;
RHO_D    = 0.80;

// ---------------------------------------------------------
// MODEL BLOCK
// ---------------------------------------------------------
model(linear);

//----------------------------------------------------------
// [1] Sectoral Phillips curves  (eqs. 3-5 in paper)
// pi_it = beta*(1-dhat_i)*E[pi_{i,t+1}]
//       + dhat_i*[alpha_i*w + omega_H_ij*p_j - p_i(-1)
//                + omega_F_i*(s+pF) - a_i]
// Note: p_jt = p_j(-1) + pi_j  is substituted inline
//----------------------------------------------------------

// Resource (no domestic inputs)
pi1 = BETA*(1-DHAT1)*pi1(+1)
+ DHAT1*(   ALPHA1*w_hat
          + OF1*(s_hat + pF)
          - a1
          - p1(-1)
        );

// Manufacturing (buys from Resource domestic)
pi2 = BETA*(1-DHAT2)*pi2(+1)
+ DHAT2*(   ALPHA2*w_hat
          + OH21*(p1(-1) + pi1)
          + OF2*(s_hat + pF)
          - a2
          - p2(-1)
        );

// Services (buys from Manufacturing domestic)
pi3 = BETA*(1-DHAT3)*pi3(+1)
+ DHAT3*(   ALPHA3*w_hat
          + OH32*(p2(-1) + pi2)
          + OF3*(s_hat + pF)
          - a3
          - p3(-1)
        );

//----------------------------------------------------------
// [2] Price level laws of motion  (eq. 6)
//----------------------------------------------------------
p1 = p1(-1) + pi1;
p2 = p2(-1) + pi2;
p3 = p3(-1) + pi3;

//----------------------------------------------------------
// [3] Consumer price level  (eq. 9)
//----------------------------------------------------------
pC_hat = BH1*p1 + BH2*p2 + BH3*p3 + BF_TOT*(s_hat + pF);

//----------------------------------------------------------
// [4] CPI inflation  (eq. 8)
//----------------------------------------------------------
piCPI = BH1*pi1 + BH2*pi2 + BH3*pi3
  + BF_TOT*((s_hat + pF) - (s_hat(-1) + pF(-1)));

//----------------------------------------------------------
// [5] Real wage  (eq. 7, labour supply)
// w_hat = pC_hat + (gamma+varphi)*y_gap
//----------------------------------------------------------
w_hat = pC_hat + (GAMMA + VARPHI)*y_gap;

//----------------------------------------------------------
// [6] DC inflation index  (eq. 10, Proposition 1)
//----------------------------------------------------------
piDC = WDC1*pi1 + WDC2*pi2 + WDC3*pi3;

//----------------------------------------------------------
// [7] IS curve  (eq. 11)
// y_gap = E[y_gap(+1)] - (1/gamma)*(i_hat - E[piCPI(+1)])
//       + nu_D * D_star
// (natural rate r_nat = 0 in deviations from SS)
//----------------------------------------------------------
y_gap = y_gap(+1) - (1/GAMMA)*(i_hat - piCPI(+1)) + NU_D*D_star;

//----------------------------------------------------------
// [8] UIP  (eq. 12)
// i_hat = -psi*bstar + E[s(+1)] - s
//----------------------------------------------------------
i_hat = -PSI*bstar + s_hat(+1) - s_hat;

//----------------------------------------------------------
// [9] NFA accumulation  (eq. 13)
// bstar = (1/beta - psi)*bstar(-1)
//       + kap_EX*(-theta_s*s + D_star)
//       - kap_IM*(pF + y_gap)
// Eigenvalue = 1/beta - psi = 0.990 < 1 (stationary)
//----------------------------------------------------------
bstar = (1/BETA - PSI)*bstar(-1)
  + KAP_EX*(-THETA_S*s_hat + D_star)
  - KAP_IM*(pF + y_gap);

//----------------------------------------------------------
// [10] Policy rule (regime-dependent)
//----------------------------------------------------------
@#if REGIME == "float"
// Free float: Taylor rule on DC index
i_hat = PHI_PI*piDC + PHI_Y*y_gap;

@#elseif REGIME == "peg"
// Hard peg: exchange rate fixed
s_hat = 0;
// i_hat determined residually by UIP (already in eq. 8)

@#elseif REGIME == "managed"
// Managed float: Taylor rule + FX stabilisation
i_hat = PHI_PI*piDC + PHI_Y*y_gap + PHI_S*s_hat;

@#endif

//----------------------------------------------------------
// [11] Shock processes  (eqs. 15-17)
//----------------------------------------------------------
a1 = RHO_A*a1(-1)  + eps_a1;
a2 = RHO_A*a2(-1)  + eps_a2;
a3 = RHO_A*a3(-1)  + eps_a3;
pF = RHO_PF*pF(-1) + eps_pF;
D_star = RHO_D*D_star(-1) + eps_D;

end;

// ---------------------------------------------------------
// STEADY STATE
// (All log-deviations are zero by construction)
// ---------------------------------------------------------
initval;
pi1 = 0; pi2 = 0; pi3 = 0;
piDC = 0; piCPI = 0;
y_gap = 0; i_hat = 0; s_hat = 0;
p1 = 0; p2 = 0; p3 = 0;
pC_hat = 0; w_hat = 0; bstar = 0;
a1 = 0; a2 = 0; a3 = 0;
pF = 0; D_star = 0;
end;

// ---------------------------------------------------------
// SHOCKS (unit standard deviations)
// ---------------------------------------------------------
shocks;
var eps_a1  = 0.01^2;   // 1% TFP shock, sector 1 (Resource)
var eps_a2  = 0.01^2;   // 1% TFP shock, sector 2 (Manuf.)
var eps_a3  = 0.01^2;   // 1% TFP shock, sector 3 (Services)
var eps_pF  = 0.01^2;   // 1% import price shock
var eps_D   = 0.01^2;   // 1% foreign demand shock
end;

// ---------------------------------------------------------
// SOLUTION AND OUTPUT
// ---------------------------------------------------------
stoch_simul(
order       = 1,       // linear model
periods     = 0,       // no simulation; compute IRFs only
irf         = 40,      // 40-quarter IRF horizon
graph_format = pdf,
nograph     = 0,
noprint     = 0
);

// Print key model moments
disp('=== DC index weights ===');
disp([WDC1 WDC2 WDC3]);

disp('=== Import centrality (network exposure to FX shock) ===');
// M_i = [((I-OmegaH)^{-1}) * OF] -- computed externally from network matrices
// Values: [0.30, 0.16, 0.09] for Resource, Manuf., Services

\paragraph{Switching regimes.}
To compare the peg, change line 12 to
\texttt{@\#define REGIME = "peg"} and re-run.
For the managed float, use \texttt{"managed"}.
Dynare will automatically drop or add the exchange-rate equation.

\paragraph{Note on the peg.}
Under the peg (\texttt{s\_hat = 0}), the interest-rate equation \texttt{i\_hat}
is no longer set by the Taylor rule; instead it is determined residually by
UIP \eqref{eq:UIP} (equation~[8] in the model block remains active).
Dynare handles this automatically since the number of equations equals
the number of variables in both cases.

\paragraph{Welfare comparison.}
After obtaining the second-order moments from \texttt{stoch\_simul},
compute the per-period welfare loss:
\begin{equation}
\mathcal{W}=\tfrac{1}{2}\!\left[(\gamma+\varphi)\,\text{Var}(\tl y_t)
+\sum_i\lambda_{D,i}\varepsilon_i\frac{1-\wh\delta_i}{\wh\delta_i}\,\text{Var}(\pi_{it})\right].
\label{eq:welfare}
\end{equation}
In Dynare add after \texttt{stoch\_simul}:
// Welfare (Rubbo Prop. 3 adapted for open economy)
GAMMA_PHI = GAMMA + VARPHI;
EPS = 8;       // within-sector substitution elasticity (same for all i)
LD = [0.12, 0.35, 0.80];   // lambda_D
DHAT = [DHAT1, DHAT2, DHAT3];

W_output = 0.5 * GAMMA_PHI * oo_.var(strmatch('y_gap', M_.endo_names,'exact'), ...
       strmatch('y_gap', M_.endo_names,'exact'));

W_pi = 0;
for i = 1:3
var_name = ['pi', num2str(i)];
idx = strmatch(var_name, M_.endo_names, 'exact');
W_pi = W_pi + 0.5 * LD(i) * EPS * (1-DHAT(i))/DHAT(i) * oo_.var(idx,idx);
end

W_total = W_output + W_pi;
fprintf('Welfare loss (x10^4): %.4f\n', W_total * 1e4);
fprintf('  Output gap component: %.4f\n', W_output * 1e4);
fprintf('  Inflation component:  %.4f\n', W_pi * 1e4);
