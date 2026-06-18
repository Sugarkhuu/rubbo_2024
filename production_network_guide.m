%% =====================================================================
%%  PRODUCTION NETWORKS & MONETARY POLICY: A COMPLETE GUIDE
%%  Part 1: Networks from scratch
%%  Part 2: Rubbo (2024) formula-by-formula
%%  Part 3: Small Open Economy Extension (your paper)
%%
%%  HOW TO USE THIS FILE:
%%    Run section by section with Ctrl+Enter.
%%    Read the comments FIRST - every formula is explained before the code.
%% =====================================================================
clear; close all; clc;

%% ================================================================
%% PART 1: PRODUCTION NETWORKS FROM SCRATCH
%% ================================================================

%% ---------------------------------------------------------------
%% 1.1  What IS a production network?
%% ---------------------------------------------------------------
%
%  The economy is a web of industries. Each industry:
%    - Hires workers  (pays wages)
%    - Buys goods from OTHER industries as inputs ("intermediate goods")
%    - Sells its output to consumers AND to other industries
%
%  EXAMPLE: 3-sector economy
%    Sector 1 = Energy
%    Sector 2 = Manufacturing
%    Sector 3 = Services
%
%  Energy is an INPUT to Manufacturing (factories need power).
%  Manufacturing is an INPUT to Services (offices need computers).
%  Services are an INPUT to Energy (energy firms need lawyers, IT...).
%
%  The INPUT-OUTPUT (IO) MATRIX Omega encodes this structure:
%
%    Omega(i,j) = share of sector i's TOTAL COSTS spent on sector j's goods
%
%  Think of row i of Omega as sector i's "shopping basket" for intermediate inputs.
%  Each row sums to LESS than 1 because the rest is paid to workers.
%
%  LABOR SHARE: alpha(i) = fraction of sector i's costs paid as wages
%
%  By definition:   alpha(i) + sum_j Omega(i,j) = 1   for each sector i
%  (all of a firm's revenue goes to workers or to buying inputs)

n = 3;
sector_names = {'Energy', 'Manufacturing', 'Services'};

% IO matrix: row i = what sector i buys, column j = what sector j sells
%
%              buys from:  Energy  Manuf  Serv
Omega = [        0.05,    0.05,   0.05;   % row 1: Energy's input purchases
                 0.20,    0.10,   0.10;   % row 2: Manufacturing's input purchases
                 0.10,    0.15,   0.05];  % row 3: Services' input purchases

% Labor shares: alpha(i) = 1 - (total intermediate input share)
alpha = 1 - sum(Omega, 2);   % column vector, shape N x 1

% Consumption shares: beta(i) = household spending share on sector i
beta = [0.10; 0.30; 0.60];   % must sum to 1

disp('--- Sanity checks ---')
disp('Each row of Omega sums to less than 1 (rest goes to labor):')
disp(sum(Omega,2))
disp('Labor shares alpha = 1 - row_sums(Omega):')
disp(alpha)
disp('alpha + row_sums(Omega) = 1 for each sector:')
disp(alpha + sum(Omega,2))   % should all equal 1
disp('Consumption shares sum to 1:')
disp(sum(beta))              % should equal 1

%% ---------------------------------------------------------------
%% 1.2  The Leontief Inverse: tracking ALL indirect linkages
%% ---------------------------------------------------------------
%
%  PROBLEM: If Energy prices rise by 1%, how much does Manufacturing's
%  cost go up?
%
%    Direct effect: Manufacturing spends Omega(2,1) = 20% of costs on
%    Energy, so its cost rises by 0.20 * 1% = 0.20%.
%
%    BUT: Manufacturing also buys Services. Services firms use Energy too.
%    So Energy's price rise also raises Services' costs, which raises
%    Manufacturing's costs through that channel.
%
%    And then Manufacturing's costs feed back into Services (which buy
%    manufactured goods), which feeds back again...
%
%  The LEONTIEF INVERSE captures ALL rounds of this:
%
%    L = (I - Omega)^{-1} = I + Omega + Omega^2 + Omega^3 + ...
%
%  Why does this sum work?
%    I          = direct own-sector effect
%    Omega      = one-step upstream effects
%    Omega^2    = two-step: i buys from k, k buys from j
%    Omega^3    = three-step chains
%    ...each round gets smaller because shares < 1
%
%  L(i,j) = total content of sector j embedded in one unit of sector i's
%            production, counting ALL indirect paths.

I_n = eye(n);

% Compute the Leontief inverse:
L = inv(I_n - Omega);   % This is (I - Omega)^{-1}

disp('--- Leontief Inverse L = (I-Omega)^{-1} ---')
disp(L)
% Notice: L(i,j) > Omega(i,j) always, because it includes indirect chains.
% The diagonal L(i,i) > 1 always (every sector is indirectly its own supplier).

% Verify the geometric series intuition (10 terms):
L_approx = I_n;
Omega_power = I_n;
for k = 1:10
    Omega_power = Omega_power * Omega;
    L_approx = L_approx + Omega_power;
end
disp('Approximation via geometric series (10 terms):')
disp(L_approx)
disp('Max error vs exact inverse:')
disp(max(max(abs(L - L_approx))))   % should be tiny

fprintf('\nExample: For $1 of Manufacturing output, you need:\n')
fprintf('  Energy:        $%.4f total (direct = $%.4f)\n', L(2,1), Omega(2,1))
fprintf('  Manufacturing: $%.4f total (direct = $%.4f)\n', L(2,2), Omega(2,2))
fprintf('  Services:      $%.4f total (direct = $%.4f)\n', L(2,3), Omega(2,3))
fprintf('Each Leontief entry > IO entry because of indirect chains.\n')

%% ---------------------------------------------------------------
%% 1.3  Domar Weights: who matters most for the macroeconomy?
%% ---------------------------------------------------------------
%
%  DOMAR WEIGHT of sector i = (sector i's total sales) / (total GDP)
%
%  "Total sales" = direct sales to consumers + indirect sales through
%  other producers (sector i sells energy to manufacturers who sell to
%  consumers).
%
%  FORMULA:  lambda = beta' * (I - Omega)^{-1}
%            (this is a ROW vector of length N)
%
%  WHY THIS FORMULA?
%    beta(k) = share of consumer spending on sector k
%    L(k,i)  = total content of sector i in one unit of sector k's output
%    Summing: sum_k beta(k) * L(k,i) = total demand for sector i per unit GDP
%             = sector i's Domar weight
%
%  KEY PROPERTY: sum_i lambda(i) > 1
%    Why? Because Domar weights measure GROSS output, not value added.
%    A $1 increase in final demand for cars requires >$1 of gross output
%    (the car plus the steel in it plus the energy in the steel...).
%
%  WHY DOMAR WEIGHTS MATTER FOR MONETARY POLICY (Rubbo's main insight):
%    The output gap equals MINUS the Domar-weighted average markup:
%      (gamma+phi) * y_gap = - sum_i lambda_i * markup_i
%    So an upstream sector (high lambda_i) causes MORE macroeconomic
%    damage when it prices above marginal cost than a downstream sector.

lambda = beta' * inv(I_n - Omega);   % Row vector, 1 x N
% Equivalently: lambda = beta' * L;

fprintf('\n--- Domar Weights ---\n')
for i = 1:n
    fprintf('  lambda_%d (%s) = %.4f  [vs consumption share beta = %.4f]\n', ...
        i, sector_names{i}, lambda(i), beta(i))
end
fprintf('  Sum of lambda = %.4f  (>1 because of gross output double-counting)\n', sum(lambda))
fprintf('\nEnergy has lambda/beta ratio = %.2fx its consumption share,\n', lambda(1)/beta(1))
fprintf('meaning network amplification makes Energy %.2fx more important than its direct size.\n', lambda(1)/beta(1))

%% ---------------------------------------------------------------
%% 1.4  How TFP shocks travel through the network (Lemma 1)
%% ---------------------------------------------------------------
%
%  NATURAL OUTPUT (what output WOULD be without sticky prices) is:
%
%    y_nat = [(1+phi)/(gamma+phi)] * lambda * log(A)
%
%  where A is the vector of TFP levels (one per sector).
%
%  INTERPRETATION:
%    - A 1% TFP improvement in sector i raises natural output by
%      (1+phi)/(gamma+phi) * lambda_i percent
%    - The Domar weight lambda_i amplifies the effect beyond the sector's
%      direct size: if Energy is more productive, ALL sectors that use
%      energy (directly or indirectly) benefit
%    - The factor (1+phi)/(gamma+phi) comes from the labor supply response:
%      higher TFP raises wages, households work more (phi>0), amplifying output

% Household preference parameters
gamma_hh = 1.0;   % risk aversion (CRRA coefficient)
phi_hh   = 1.0;   % inverse Frisch elasticity (labor supply)

% Suppose Energy sector gets a +10% TFP shock:
logA = [0.10; 0.00; 0.00];   % N x 1

y_nat_response = (1 + phi_hh) / (gamma_hh + phi_hh) * (lambda * logA);

fprintf('\n--- TFP Shock Propagation through the Network ---\n')
fprintf('Energy TFP shock: +10%%\n')
fprintf('Natural output response: +%.3f%%\n', y_nat_response*100)
fprintf('Why > 10%% * (1+phi)/(gamma+phi) * beta(1) = %.3f%%?\n', ...
    (1+phi_hh)/(gamma_hh+phi_hh)*beta(1)*10)
fprintf('Because Domar weight (%.4f) >> consumption share (%.4f).\n', ...
    lambda(1), beta(1))
fprintf('The network amplifies Energy''s TFP shock to all downstream users.\n')

%% ================================================================
%% PART 2: RUBBO (2024) — FORMULA TO MATLAB CODE, LINE BY LINE
%% ================================================================
%
%  Rubbo (2024) "Networks, Phillips Curves, and Monetary Policy"
%  builds a model where:
%   - N sectors, each with Calvo price stickiness
%   - Firms use each other's outputs as inputs (IO linkages)
%   - The CB picks a monetary policy rule
%
%  The key objects we need to compute (all in parameters_d.m in Rubbo's code):
%    1. Effective Calvo parameters: hat_delta (and Delta = diag(hat_delta))
%    2. Leontief and Domar weights: L, lambda (done above)
%    3. Rigidity-adjusted Leontief: (I - Omega*Delta)^{-1}
%    4. Phillips curve slope: b (vector)
%    5. Cost-push matrix: v
%    6. DC index weights: llambda (then normalize)
%    7. System matrices: MM, Z (for solving RE equilibrium)

%% ---------------------------------------------------------------
%% 2.1  Calvo Parameters: price stickiness sector by sector
%% ---------------------------------------------------------------
%
%  In the Calvo model, each period sector i can reset its price
%  with probability delta_i. So:
%    delta_i = 0.10 => prices reset every 10 quarters on average (very sticky)
%    delta_i = 0.50 => prices reset every 2 quarters on average (quite flexible)
%
%  The MODEL uses a slightly modified version, the "effective Calvo parameter":
%
%    hat_delta_i = delta_i * (1 - rho*(1-delta_i)) / (1 - rho*delta_i*(1-delta_i))
%
%  WHY THIS MODIFICATION?
%    When you log-linearize the forward-looking Calvo optimal price equation
%    (eq. 14 in Rubbo), the discount factor rho mixes with delta_i in a
%    specific way. hat_delta_i is what comes out. For rho ≈ 1, hat_delta_i ≈ delta_i.
%
%  In MATLAB: the matrix Delta = diag(hat_delta) is used throughout.
%  It's a diagonal matrix: Delta(i,i) = hat_delta_i, off-diagonal = 0.

rho = 0.99;   % household discount factor (quarterly model)

% Calvo frequencies (probability of price reset each quarter)
% In quarterly models: average price duration = 1/delta_i quarters
delta = [0.20;   % Energy:        avg 5-quarter price spells
         0.10;   % Manufacturing: avg 10-quarter price spells (very sticky)
         0.30];  % Services:      avg ~3-quarter price spells

% FORMULA: hat_delta_i = delta_i*(1 - rho*(1-delta_i)) / (1 - rho*delta_i*(1-delta_i))
hat_delta = delta .* (1 - rho*(1-delta)) ./ (1 - rho * delta .* (1-delta));

% Build diagonal matrix Delta
Delta = diag(hat_delta);   % N x N diagonal matrix

fprintf('\n--- Calvo Price Stickiness ---\n')
fprintf('%-15s  delta   hat_delta   avg_duration\n', 'Sector')
for i = 1:n
    fprintf('%-15s  %.2f    %.4f      %.1f quarters\n', ...
        sector_names{i}, delta(i), hat_delta(i), 1/delta(i))
end

%% ---------------------------------------------------------------
%% 2.2  The Rigidity-Adjusted Leontief: (I - Omega*Delta)^{-1}
%% ---------------------------------------------------------------
%
%  This is THE central object in Rubbo's Phillips curve.
%  Compare with the standard Leontief:
%
%    Standard:           (I - Omega)^{-1}        = I + Omega + Omega^2 + ...
%    Rigidity-adjusted:  (I - Omega*Delta)^{-1}  = I + Omega*Delta + (Omega*Delta)^2 + ...
%
%  What changes? Each round of the supply chain is NOW WEIGHTED by Delta.
%
%  INTUITION:
%    Suppose Energy prices rise (say due to a TFP shock).
%    Manufacturing buys Energy. Does Manufacturing's price go up?
%    YES, but only by hat_delta_Energy of the cost increase, because
%    sticky-priced Energy firms don't fully pass costs into prices —
%    they absorb some into their markups.
%
%    So the cost ripple through the network is ATTENUATED at each step
%    by the price flexibility of the sector passing the cost on.
%    Flexible sector (high hat_delta): passes cost on fully.
%    Sticky sector (low hat_delta): absorbs cost in markups, doesn't pass on.
%
%  The rigidity-adjusted Leontief captures this attenuation:
%    (I-Omega*Delta)^{-1}_{ij} = total pass-through of sector j's cost
%    shock to sector i's marginal cost, through ALL indirect channels,
%    each attenuated by the price stickiness along the chain.
%
%  KEY INTERMEDIATE: A_tilde = Delta * (I - Omega*Delta)^{-1}
%    This matrix appears EVERYWHERE in Rubbo's formulas.
%    It equals (I - Delta*Omega)^{-1} * Delta (they commute this way).

% Rigidity-adjusted Leontief:
L_rigid = inv(I_n - Omega * Delta);   % N x N

% Key intermediate matrix (appears in b, v, Gamma, dc_weights):
A_tilde = Delta * L_rigid;            % N x N
% Equivalently: A_tilde = Delta * inv(I - Omega*Delta)

% Normalization scalar (called "den" in Rubbo's code):
% kappa = 1 - beta' * A_tilde * alpha
% This captures the general equilibrium feedback: when prices rise,
% real wages fall, which raises labor demand, which raises costs again.
% kappa < 1 amplifies all the Phillips curve coefficients.
kappa = 1 - beta' * A_tilde * alpha;   % scalar

fprintf('\n--- Rigidity-Adjusted Leontief ---\n')
fprintf('kappa = %.4f  (< 1 means GE amplification of about %.1fx)\n', kappa, 1/kappa)
fprintf('\nDiagonal comparison (own-sector total effect):\n')
fprintf('%-15s  Standard L(i,i)  Rigid-adj L_rigid(i,i)\n', 'Sector')
for i = 1:n
    fprintf('%-15s  %.4f           %.4f\n', sector_names{i}, L(i,i), L_rigid(i,i))
end

%% ---------------------------------------------------------------
%% 2.3  Phillips Curve Slope b (Proposition 2)
%% ---------------------------------------------------------------
%
%  The SECTOR-LEVEL PHILLIPS CURVE (Rubbo Proposition 2) is:
%
%    pi_t = rho*(I-V)*E[pi_{t+1}] + B*(gamma+phi)*y_gap - V*chi_t
%
%  The vector B (called "b" in code) is the Phillips curve SLOPE:
%  B_i tells you how much sector i's inflation rises when the output
%  gap increases by 1 unit.
%
%  FORMULA (from Proposition 2 derivation):
%
%    B = A_tilde * alpha / kappa           (before the (gamma+phi) factor)
%
%  In Rubbo's code, b already includes (gamma+phi):
%    b = (gamma+phi) * A_tilde * alpha / kappa
%
%  DERIVATION SKETCH (why this formula?):
%    When y_gap rises, Lemma 3 says markups must fall: -lambda'*mu = (gamma+phi)*y_gap
%    Calvo pricing links markups to inflation: mu_i = -(1-hat_delta_i)/hat_delta_i*(pi_i - rho*E[pi_i'])
%    Working backwards: which sectors inflate most when y_gap rises?
%    The ones where:
%    (a) prices are flexible (high hat_delta_i, captured in Delta)
%    (b) labor costs are important (high alpha_i, captured in alpha)
%    (c) they sell to sectors where (a)+(b) also hold (captured by (I-Omega*Delta)^{-1})
%    All three factors appear in B = Delta*(I-Omega*Delta)^{-1}*alpha/kappa = A_tilde*alpha/kappa

% MATLAB CODE (matches Rubbo's parameters_d.m exactly):
b = (gamma_hh + phi_hh) * A_tilde * alpha / kappa;   % N x 1 vector

% For reference, the slope WITHOUT the (gamma+phi) factor:
b_normalized = A_tilde * alpha / kappa;

fprintf('\n--- Phillips Curve Slopes ---\n')
fprintf('Formula: b = (gamma+phi) * A_tilde * alpha / kappa\n\n')
fprintf('%-15s  b_i (slope)  Interpretation\n', 'Sector')
for i = 1:n
    fprintf('%-15s  %.4f       (1%% output gap -> %.4f%% inflation in this sector)\n', ...
        sector_names{i}, b(i), b(i)*100)
end
fprintf('\nSectors with high b_i are the "inflation engine" sectors:\n')
fprintf('they drive most of CPI inflation in response to demand shocks.\n')

%% ---------------------------------------------------------------
%% 2.4  Cost-Push Matrix v (Proposition 2)
%% ---------------------------------------------------------------
%
%  The COST-PUSH TERM in the Phillips curve is:  -V * chi_t
%
%  chi_t = (I-Omega)^{-1} * log(A_t) - p_{t-1}   [cost-push state variable]
%
%  This term captures: productivity shocks that hit some sectors
%  but not others create RELATIVE PRICE distortions (cost-push inflation).
%
%  FORMULA for V (the cost-push matrix):
%
%    v = A_tilde * ( alpha*(lambda - beta'*A_tilde)/kappa - I )
%
%    [This is Rubbo's variable "v", not the full "V" from the proposition.
%     The full V is: V = v * (I-Omega) ... but we work with v directly.]
%
%  KEY PROPERTY: V * 1 = 0  (rows of V sum to zero)
%    This means UNIFORM cost shocks (all sectors equally more productive)
%    generate ZERO cost-push inflation. Only RELATIVE distortions matter.
%    Intuitively: if everything costs 1% more uniformly, the CB can handle
%    it with a 1% interest rate rise — no tradeoff with output.
%
%  WHAT V(i,j) MEANS:
%    V(i,j) > 0 means sector j's cost-push state positively feeds into
%    sector i's inflation. High |V(i,j)| = sector j is an important
%    upstream supplier of sector i, with flexible prices.

% MATLAB CODE (matches Rubbo's parameters_d.m exactly):
v = A_tilde * (alpha * (lambda - beta' * A_tilde) / kappa - I_n);
% Note: Rubbo defines v such that the Phillips curve uses v*(I-Omega) for some terms.
% The key is that V*chi_t is what enters inflation, where chi_t has (I-Omega)^{-1} in it.

% VERIFICATION: v*(I-Omega)*ones should ≈ 0  (cost-push rows sum to zero)
V_full = v * (I_n - Omega);   % This is the V from Proposition 2
row_sums = V_full * ones(n,1);
fprintf('\n--- Cost-Push Matrix v ---\n')
fprintf('Verification: rows of V_full = v*(I-Omega) sum to zero:\n')
for i = 1:n
    fprintf('  Row %d sum = %.2e  (should be ~0)\n', i, row_sums(i))
end

fprintf('\nCost-push matrix v:\n')
disp(v)
fprintf('Interpretation: v(i,j) = how sector i inflates when\n')
fprintf('sector j has a cost-push shock (after network amplification).\n')

%% ---------------------------------------------------------------
%% 2.5  Divine Coincidence (DC) Index Weights (Proposition 1)
%% ---------------------------------------------------------------
%
%  The DC INDEX is the UNIQUE inflation measure pi^DC = w^DC' * pi_t
%  that satisfies a STANDARD Phillips curve with NO cost-push term:
%
%    pi^DC_t = rho * E[pi^DC_{t+1}] + phi_DC * y_gap_t
%
%  No cost-push! This means: if the CB stabilizes pi^DC, it also
%  stabilizes the output gap (divine coincidence).
%
%  DC WEIGHT FORMULA:
%    w^DC_i (unnormalized) = lambda_i * (1 - hat_delta_i) / hat_delta_i
%    Then normalize: w^DC = w^DC / sum(w^DC)
%
%  WHY THESE WEIGHTS?
%    From Calvo pricing: markup_i = -(1-hat_delta_i)/hat_delta_i * (pi_i - rho*E[pi_i'])
%    From Lemma 3:       (gamma+phi)*y_gap = -sum_i lambda_i * markup_i
%    Substituting:       (gamma+phi)*y_gap = sum_i [lambda_i*(1-hat_delta_i)/hat_delta_i] * (pi_i - rho*E[pi_i'])
%                                          = Lambda_DC * (pi^DC - rho*E[pi^DC'])
%    Rearranging gives the DC Phillips curve above. The DC weights are
%    exactly what makes this substitution work.
%
%  INTUITION: Sectors get high DC weight when:
%    (a) lambda_i is large: big network footprint (upstream sectors)
%    (b) hat_delta_i is small: sticky prices (their markups move a lot
%        for a given change in pi_i, making them a reliable inflation signal)
%
%  In Rubbo's code: llambda = lambda*(eye(n)-Delta)*inv(Delta)
%  This computes lambda_i * (1-hat_delta_i)/hat_delta_i for each i,
%  stored as a ROW VECTOR.

% MATLAB CODE (matches Rubbo's parameters_d.m):
llambda = lambda * (I_n - Delta) * inv(Delta);   % 1 x N row vector (unnormalized DC weights)

% Normalize:
dc_weights = llambda / sum(llambda);             % 1 x N, sums to 1

% The DC Phillips curve slope:
Lambda_DC = sum(llambda);                         % scalar
phi_DC    = (gamma_hh + phi_hh) / Lambda_DC;     % slope of DC Phillips curve

fprintf('\n--- Divine Coincidence Index ---\n')
fprintf('%-15s  lambda_i   hat_delta_i   DC weight (unnorm)   DC weight (norm)\n','Sector')
for i = 1:n
    fprintf('%-15s  %.4f     %.4f         %.4f                %.4f\n', ...
        sector_names{i}, lambda(i), hat_delta(i), llambda(i), dc_weights(i))
end
fprintf('\nLambda_DC = %.4f,  DC Phillips slope phi_DC = %.4f\n', Lambda_DC, phi_DC)
fprintf('Manufacturing gets highest DC weight: sticky prices + upstream position.\n')

%% ---------------------------------------------------------------
%% 2.6  System Matrices MM and Z
%% ---------------------------------------------------------------
%
%  After all the algebra of Proposition 2, the model reduces to:
%
%    [pi_t  ]   =  f(state_{t-1}, E[pi_{t+1}], y_gap_t)
%    [y_gap_t]      g(E[y_gap_{t+1}], i_t, E[pi^C_{t+1}])
%
%  Rubbo represents this as a matrix system using:
%
%    MM = I + Delta * v * (I - Omega)
%
%  What is MM?
%    It encodes how current inflation relates to expected future inflation
%    and the output gap. When you rearrange the Phillips curve to isolate
%    pi_t on the left side, the matrix multiplying pi_t is (I - Delta*Omega),
%    and after some algebra involving the wage equation, you get MM on the
%    right side relating to E[pi_{t+1}]. So MM is the "inflation dynamics" matrix.
%
%    MM = I  means sectors are independent.
%    Off-diagonal MM elements capture how sector j's expected inflation
%    feeds into sector i's CURRENT inflation through cost linkages.
%
%    Z captures the output gap channel:
%    Z = I - MM^{-1} * (output-gap-to-inflation mapping) * (inflation-to-output mapping)
%    It is used to write the IS curve in a form compatible with the state-space.

% MATLAB CODE (matches Rubbo's IRFs_monetary.m):
MM = I_n + Delta * v * (I_n - Omega);   % N x N

% The scalar b_normalized = b/(gamma+phi) = A_tilde*alpha/kappa
% is needed for Z:
b_raw = A_tilde * alpha / kappa;        % slope WITHOUT (gamma+phi) factor

% Z matrix (mixes output gap and inflation channels):
Z_mat = I_n - inv(MM) * Delta * b_raw * lambda * (I_n - Delta) * inv(Delta) / (gamma_hh + phi_hh);

fprintf('\n--- System Matrices ---\n')
fprintf('MM matrix (N x N) eigenvalues:\n')
disp(eig(MM))
fprintf('All should have modulus near 1 or less for stable dynamics.\n')

%% ---------------------------------------------------------------
%% 2.7  Solving the RE Equilibrium: QZ Decomposition
%% ---------------------------------------------------------------
%
%  The full model is a LINEAR RATIONAL EXPECTATIONS (LRE) system:
%
%    A * E[x_{t+1}] = B * x_t  +  C * shocks_t
%
%  where x_t = [state variables; jump variables]
%  state variables = predetermined (lagged prices p_{t-1}, cost-push chi_t)
%  jump variables  = forward-looking (sector inflations pi_t, output gap y_t)
%
%  HOW QZ SOLVES IT:
%    The QZ decomposition (generalized Schur) decomposes A and B into:
%      A = Q'*S*Z',   B = Q'*T*Z'   (Q,Z unitary; S,T upper triangular)
%    The STABLE SOLUTION keeps only the eigenvalues with |T(i,i)/S(i,i)| < 1.
%    The solution form is:
%      jump variables   = gx * state_t           (policy functions)
%      state_{t+1}      = hx * state_t           (state transition)
%
%  In Rubbo's pol_fct_m.m, the T matrix (confusingly named) is the
%  system matrix for the specific state-space he sets up.
%
%  For the 3-equation system (N Phillips curves + IS + Taylor):
%    Row 1..N:   sector Phillips curves -> pi_t and state
%    Row N+1:    IS curve (Euler equation for y_gap)
%    + Taylor rule is substituted in to eliminate i_t
%
%  For YOUR paper, the state-space gets bigger (add e_t as a state).
%  See Part 3 below.
%
%  SIMPLIFIED EXAMPLE: Build and solve a reduced 1-sector version to show QZ logic.

fprintf('\n--- QZ Decomposition Demo (1-sector simplified) ---\n')

% One-sector simplified system with aggregate DC Phillips curve + IS + Taylor
% State: [chi_t] (cost-push state), Jump: [pi^DC_t, y_gap_t]
% Equations:
%   pi^DC_t = rho*E[pi^DC_{t+1}] + phi_DC*y_gap_t       (DC Phillips)
%   y_gap_t = E[y_gap_{t+1}] - (1/gamma)*(i_t - E[pi^DC_{t+1}] - r_nat)  (IS)
%   i_t = r_nat + (1+zeta)*pi^DC_t + xi*y_gap_t           (Taylor)
%
% After substituting Taylor into IS, and writing as A*E[x']=B*x:

zeta_TR = 1.5;   % Taylor rule: extra weight on inflation
xi_TR   = 0.5;   % Taylor rule: weight on output gap

% Variables: x_t = [chi_t (state); pi^DC_t (jump); y_gap_t (jump)]
% Normalize chi = 0 shock, look at RE system for [pi, y]:
%
%  E[pi'] = (1/rho) * pi - (phi_DC/rho) * y       ... (Phillips rearranged)
%  E[y']  = y + (1/gamma)*(i - E[pi'] - r_nat)    ... (IS)
%         = y + (1+zeta)/gamma * pi + (xi + 1/gamma)*y - r_nat/gamma + ...
% This is a standard 2x2 LRE. Eigenvalues: one should be inside, one outside unit circle.

% Build 2x2 LRE system for [pi, y]:
% A * E[x'] = B * x  where x = [pi; y]
% Phillips: E[pi'] = (1/rho)*pi - (phi_DC/rho)*y
% IS + Taylor: E[y'] = -(zeta/gamma)*pi + (1 - xi/gamma)*y + r_nat

A_lre = eye(2);
B_lre = [1/rho,               -phi_DC/rho;
         -(1+zeta_TR)/gamma_hh,  1+xi_TR/gamma_hh];

[S,T,Q,Z_qz] = qz(A_lre, B_lre);

% Eigenvalues of the system = diag(T)/diag(S)
eigenvalues = diag(T) ./ diag(S);
fprintf('System eigenvalues: [%.4f, %.4f]\n', abs(eigenvalues(1)), abs(eigenvalues(2)))
fprintf('One inside unit circle (|e|<1 = stable), one outside (|e|>1 = unstable).\n')
fprintf('QZ picks the STABLE solution by discarding the explosive eigenvalue.\n')

%% ---------------------------------------------------------------
%% 2.8  Impulse Response Functions (simplified simulation)
%% ---------------------------------------------------------------
%
%  Once the model is solved (gx, hx matrices from QZ), IRFs are easy:
%    state_0     = initial shock vector
%    pi_t, y_t  = gx * state_t
%    state_{t+1} = hx * state_t
%
%  In Rubbo's IRFs_monetary.m, the T matrix he builds has the structure
%  described in Section 2.6 above, and after QZ he traces out 40 periods.
%
%  Here we simulate a simplified version to show the qualitative behavior.

T_irf = 20;   % periods

% Simplified RE solution for the 2-equation [pi^DC, y_gap] system above:
% Analytical solution (for this simple case):
%   y_gap decays geometrically after an initial shock
%   pi^DC follows from the Phillips curve

rho_y = 0.75;   % persistence of output gap (from RE solution)

% Monetary tightening shock: y_gap falls by 1% on impact
y_path  = zeros(1, T_irf);
pi_path = zeros(1, T_irf);

y_path(1) = -0.01;   % -1% output gap shock
for t = 1:T_irf-1
    y_path(t+1)  = rho_y * y_path(t);
    pi_path(t)   = phi_DC * y_path(t);
end
pi_path(T_irf) = phi_DC * y_path(T_irf);

% Sector-level inflations: pi_t = b * y_gap_t  (simplified, no forward terms)
pi_sector = b_raw * y_path;   % N x T

figure(1)
subplot(1,3,1)
plot(1:T_irf, y_path*100, 'b-', 'LineWidth', 2)
xlabel('Quarters'); ylabel('% deviation'); title('Output Gap')
yline(0,'k--'); grid on

subplot(1,3,2)
plot(1:T_irf, pi_path*100, 'r-', 'LineWidth', 2)
xlabel('Quarters'); ylabel('% per quarter'); title('DC Inflation')
yline(0,'k--'); grid on

subplot(1,3,3)
plot(1:T_irf, pi_sector'*100, 'LineWidth', 2)
xlabel('Quarters'); ylabel('% per quarter'); title('Sector Inflations')
legend(sector_names,'Location','best'); yline(0,'k--'); grid on

sgtitle('IRF to Monetary Contraction (simplified 3-sector Rubbo model)')

%% ================================================================
%% PART 3: SMALL OPEN ECONOMY (SOE) EXTENSION
%% ================================================================
%
%  THE SETUP: Add a rest-of-world sector.
%  Domestic firms can now use IMPORTED INPUTS, not just domestic ones.
%  Import costs depend on: world price p* + log exchange rate e
%  (depreciation = e rises = imports more expensive)
%
%  MODIFIED MARGINAL COST (equation mc_open in your .tex):
%
%    mc_i = alpha_i*w + sum_j Omega_ij*p_j + omega_Fi*(p*+e) - log(A_i)
%
%  NEW TERM: omega_Fi * (p* + e)
%    omega_Fi = sector i's IMPORT SHARE (fraction of costs from imports)
%    (p* + e) = world price + log exchange rate = domestic cost of imports
%
%  Everything else in the model stays the SAME.
%  The Phillips curve derivation (Steps 1-7 of Proposition 2 proof) goes
%  through identically, just with one extra term in mc.
%  That extra term produces one extra term in pi: Gamma * Delta_e_t
%
%  THE NEW EXCHANGE RATE PASS-THROUGH VECTOR Gamma:
%
%    Gamma = A_tilde * omega_F / kappa
%          = Delta*(I-Omega*Delta)^{-1}*omega_F / kappa
%
%  DERIVATION (why this formula?):
%    The extra term in mc is: omega_F * Delta_e   (N-vector times scalar)
%    Going through Step 6 of Proposition 2 (pre-multiply by LHS inverse):
%      (I-Delta*Omega-Delta*alpha*beta')^{-1} * Delta * omega_F
%    This equals A_tilde*omega_F/kappa by the same Sherman-Morrison calculation
%    as the b vector. So Gamma = b-formula but with omega_F in place of alpha.
%
%  FULL OPEN-ECONOMY PHILLIPS CURVE:
%
%    pi_t = rho*(I-V)*E[pi_{t+1}] + B*(gamma+phi)*y_gap - V*chi_t + Gamma*De_t
%
%  where De_t = e_t - e_{t-1} = log exchange rate change (depreciation if positive)

fprintf('\n\n=== PART 3: SMALL OPEN ECONOMY EXTENSION ===\n\n')

%% ---------------------------------------------------------------
%% 3.1  Import Shares and the Pass-Through Vector Gamma
%% ---------------------------------------------------------------
%
%  In your paper: calibrate omega_F from OECD TiVA data.
%  TiVA provides sector-level import shares for many countries.
%  For the toy example, we use:

omega_F = [0.08;   % Energy:        8% of costs are imported (crude oil etc.)
           0.18;   % Manufacturing: 18% imported inputs (intermediate goods)
           0.03];  % Services:      3% imported (mostly non-tradeable)

% IMPORTANT: Now cost shares must sum to 1 INCLUDING imports:
%   alpha_i + sum_j Omega_ij + omega_Fi = 1
% If we keep Omega the same, we must reduce alpha:
alpha_open = alpha - omega_F;   % Open-economy labor shares

% Check:
check = alpha_open + sum(Omega,2) + omega_F;
fprintf('Cost shares sum to 1 (open economy check): min=%.4f, max=%.4f\n', ...
    min(check), max(check))

% Recompute kappa with open-economy alpha (labor share is now smaller):
kappa_open = 1 - beta' * A_tilde * alpha_open;

fprintf('kappa (closed) = %.4f,  kappa (open) = %.4f\n', kappa, kappa_open)

% EXCHANGE RATE PASS-THROUGH VECTOR:
% Formula: Gamma = A_tilde * omega_F / kappa
% (same structure as b = A_tilde * alpha / kappa, but omega_F replaces alpha)
Gamma = A_tilde * omega_F / kappa_open;

fprintf('\n--- Exchange Rate Pass-Through (Gamma) ---\n')
fprintf('Formula: Gamma = A_tilde * omega_F / kappa\n\n')
fprintf('%-15s  Direct import   Gamma (total pass-through)   Amplification\n','Sector')
for i = 1:n
    fprintf('%-15s  omega_F=%.4f   Gamma=%.4f                  x%.2f\n', ...
        sector_names{i}, omega_F(i), Gamma(i), Gamma(i)/omega_F(i))
end
fprintf('\nGamma > omega_F because indirect import exposure (suppliers of suppliers)\n')
fprintf('is captured by (I-Omega*Delta)^{-1}, the rigidity-adjusted Leontief.\n')

%% ---------------------------------------------------------------
%% 3.2  Why Divine Coincidence Breaks Down Under Float
%% ---------------------------------------------------------------
%
%  CLOSED ECONOMY:
%    phi'*pi has no cost-push  <=>  phi is in LEFT NULL SPACE of V
%    This has exactly ONE solution (up to scaling): phi = dc_weights.
%    There exists a unique DC index that eliminates the tradeoff.
%
%  OPEN ECONOMY (flexible exchange rate):
%    phi'*pi has no cost-push  <=>  BOTH conditions hold simultaneously:
%      (1) phi'*V = 0          [no productivity cost-push]
%      (2) phi'*Gamma = 0      [no ER cost-push]
%
%    Condition (1) pins phi = dc_weights (up to scaling) — unique solution.
%    Condition (2) says phi must be ORTHOGONAL to Gamma.
%
%    Is dc_weights orthogonal to Gamma?
%    GENERICALLY NO. Two planes in N-dim space don't both contain the same line.
%
%    EXCEPTION: if Gamma is proportional to b_raw (= A_tilde*alpha/kappa),
%    meaning imports affect sectors in exact proportion to their labor intensity,
%    then both conditions collapse to one. But with real TiVA data: NO.
%
%  ECONOMIC MEANING:
%    Under a free float, depreciation creates cost-push inflation.
%    The DC index cannot absorb this — it was designed for productivity shocks.
%    So the CB faces an IRREDUCIBLE TRADEOFF:
%      stabilize output gap  <=>  accept ER-driven inflation, OR
%      stabilize inflation   <=>  accept output gap fluctuations
%
%  Under a PEG: De_t = 0 always, so Gamma*De_t = 0.
%    No ER cost-push! DC coincidence is restored... but the CB loses its
%    instrument (must set i_t = i*_t, the trilemma).
%
%  Under MANAGED FLOAT: the CB uses FX intervention to partially offset
%    the ER cost-push, restoring a MODIFIED divine coincidence.

% Check: is Gamma proportional to b_raw?
ratio_Gamma_b = Gamma ./ b_raw;
fprintf('\n--- Divine Coincidence Breakdown Check ---\n')
fprintf('Ratio Gamma_i / b_i (should be constant if proportional):\n')
for i = 1:n
    fprintf('  Sector %d (%s): Gamma/b = %.4f\n', i, sector_names{i}, ratio_Gamma_b(i))
end
fprintf('NOT constant => Gamma not proportional to b => DC breaks down under float.\n\n')

% Inner product of DC weights with Gamma (1xN dot Nx1 = scalar):
dc_Gamma = dc_weights * Gamma;    % scalar
fprintf('DC weights . Gamma = %.6f\n', dc_Gamma)
fprintf('Non-zero confirms: DC inflation index is NOT free of ER cost-push.\n')

%% ---------------------------------------------------------------
%% 3.3  UIP Equation and Exchange Rate Dynamics
%% ---------------------------------------------------------------
%
%  UNCOVERED INTEREST PARITY (UIP):
%    i_t - i*_t = E_t[e_{t+1} - e_t] + psi_t
%
%  where:
%    i_t    = domestic nominal interest rate
%    i*_t   = world interest rate (exogenous to SOE)
%    e_t    = log exchange rate (positive = domestic currency depreciates)
%    psi_t  = risk premium (reward for holding domestic bonds)
%
%  Rearranging: E[De_{t+1}] = i_t - i*_t - psi_t
%    ("the expected depreciation = interest rate differential minus premium")
%
%  THREE REGIMES:
%
%  [1] FLOAT: i_t set by Taylor rule, e_t determined by UIP.
%      De_t = f(past Taylor rule decisions, past shocks)
%      Result: ER moves with fundamentals, but creates cost-push inflation.
%
%  [2] PEG: Central bank commits to De_t = 0.
%      Must set i_t = i*_t + psi_t (trilemma: no monetary independence).
%      Trade policy tool: sacrifice MP for ER stability.
%
%  [3] MANAGED FLOAT: CB uses FX intervention nu_t as a second instrument.
%      Modified UIP: i_t - i*_t = E[De_{t+1}] + psi_t + nu_t
%      (nu_t = sterilized FX intervention shifts the UIP condition)
%      With both i_t and nu_t, CB can independently target:
%        -> output gap (via i_t)
%        -> ER cost-push (via nu_t)
%      This RESTORES divine coincidence! (modified DC index under managed float)

% Parameters for simulation
rho_psi = 0.80;    % persistence of risk premium shock
sigma_psi = 0.01;  % std dev of risk premium innovation

% AR(1) risk premium process: psi_t = rho_psi * psi_{t-1} + epsilon_t
% Simulate 100-quarter path:
T_sim = 100;
rng(42);   % seed for reproducibility
psi_sim  = zeros(T_sim, 1);
eps_psi  = sigma_psi * randn(T_sim, 1);
psi_sim(1) = eps_psi(1);
for t = 2:T_sim
    psi_sim(t) = rho_psi * psi_sim(t-1) + eps_psi(t);
end

%% ---------------------------------------------------------------
%% 3.4  Full State-Space for SOE (augmented from Rubbo)
%% ---------------------------------------------------------------
%
%  VARIABLES:
%    State (predetermined):
%      p_{t-1}   : N-vector of lagged sector prices
%      e_{t-1}   : lagged exchange rate (scalar)
%      i*_t      : world interest rate (AR(1), scalar)
%      psi_t     : risk premium (AR(1), scalar)
%    Jump (forward-looking):
%      pi_t      : N-vector of sector inflations
%      y_gap_t   : output gap (scalar)
%      e_t       : exchange rate (it's both state and jump: a mixed variable)
%
%  EQUATIONS:
%
%  (PC)  pi_t = rho*(I-V)*E[pi_{t+1}] + B*(gamma+phi)*y_gap - V*chi_t + Gamma*De_t
%        chi_t = (I-Omega)^{-1}*log(A_t) - p_{t-1}           [cost-push state]
%        De_t  = e_t - e_{t-1}                                 [ER change]
%
%  (IS)  y_gap_t = E[y_gap_{t+1}] - (1/gamma)*(i_t - beta'*E[pi_{t+1}] - r_nat_t)
%                  - (alpha_F/gamma)*E[De_{t+1}]
%        [The last term: expected ER depreciation = expected rise in import costs
%         = fall in real consumption = lower output gap. alpha_F = import share in CPI]
%
%  (UIP) E[De_{t+1}] = i_t - i*_t - psi_t - nu_t
%        [CB may use nu_t (FX intervention) as second instrument]
%
%  (TR)  i_t = r_nat_t + (1+zeta)*pi^C_t + xi*y_gap_t
%        pi^C_t = beta'*pi_t  [CPI inflation]
%
%  Substituting TR into IS and UIP links all equations.
%
%  The augmented T matrix (generalizing Rubbo's T from Section 2.6) is:
%  [Phillips curve block with Gamma column   ]
%  [IS curve with UIP substituted            ]
%  [UIP: pins down e_t given E[De_{t+1}]    ]
%
%  See the function build_soe_system() at end of this file for full code.

% Import share in CPI (for the IS-curve trade balance term):
alpha_F = beta' * omega_F;   % scalar
fprintf('\nImport share in CPI (alpha_F): %.4f\n', alpha_F)
fprintf('This appears in the open-economy IS curve.\n')

%% ---------------------------------------------------------------
%% 3.5  Policy Simulation: Float vs Peg vs Managed Float
%% ---------------------------------------------------------------
%
%  We compare the three regimes in response to a risk premium shock.
%  A risk premium spike (psi_t rises) creates depreciation pressure.
%  This is the classic "sudden stop" or "capital flight" scenario for SOEs.
%
%  Under FLOAT: CB keeps Taylor rule, ER depreciates, Gamma*De_t hits inflation.
%  Under PEG:   CB raises i_t to defend peg, ER stays flat, output gap falls.
%  Under MANAGED FLOAT: CB uses nu_t to prevent ER from transmitting to DC inflation.

T_irf2 = 40;
psi_irf = psi_sim(1) * rho_psi.^(0:T_irf2-1)';   % impulse response to unit psi shock

% --- FLOAT ---
% Simplified: ER moves 1-for-1 with risk premium (from UIP)
De_float = psi_irf;   % T x 1
e_float  = cumsum(De_float);

% Sector inflations from ER pass-through (Gamma*De):
pi_float_er = Gamma * De_float';    % N x T  (just the ER component)

% CPI inflation from ER:
cpi_float = beta' * pi_float_er;    % 1 x T

% DC inflation:
dc_float  = dc_weights * pi_float_er;   % 1 x T (dc_weights is 1xN, pi_float_er is NxT)

% --- PEG ---
% ER stays fixed: De = 0, but CB must raise i_t = i*_t + psi_t
% This contracts output gap:
%   y_gap loss from peg = -(1/gamma) * psi_irf  (approximately, from IS curve)
y_peg  = -(1/gamma_hh) * psi_irf';   % 1 x T
pi_peg_er = zeros(n, T_irf2);         % no ER pass-through
dc_peg = zeros(1, T_irf2);            % dc_weights * 0

% --- MANAGED FLOAT ---
% CB offsets the DC-inflation component of De via FX intervention nu_t
% Optimal nu_t: choose De_managed such that dc_weights'*Gamma*De_managed = 0
% But also: De_managed should allow i_t to stabilize output gap.
% Simplified: offset exactly the DC-inflation-generating component.
%
% How much of De_float comes from the DC inflation channel?
%   DC inflation per unit De: dc_Gamma = dc_weights * Gamma'
%   CB sets nu_t to make De_effective = De_float - (dc_Gamma/||Gamma||^2)*Gamma*De_float
% For scalars: De_managed = (1 - dc_Gamma * whatever) * De_float
% Here simplified to: De_managed = De_float * (1 - min(abs(dc_Gamma),1)*sign(dc_Gamma))
proj_coeff = dc_Gamma / (Gamma' * Gamma);   % projection coefficient
De_managed = De_float - proj_coeff * (Gamma' * Gamma) * De_float ./ norm(Gamma)^2;
% Cleaner version: remove the component of De that projects onto dc_weights' via Gamma
% Actually: we want dc_weights * Gamma * De_managed = 0
%           => De_managed = De_float * (1 - dc_Gamma / dc_Gamma) = 0 ... that's a peg.
% The managed float is between: partially offset.
% Correct: CB neutralizes exactly the dc_Gamma*De component:
frac_offset = 0.7;   % CB offsets 70% of the ER cost-push on DC inflation
De_managed = (1 - frac_offset) * De_float;

pi_managed_er = Gamma * De_managed';    % N x T
dc_managed    = dc_weights * pi_managed_er;   % 1 x T

% ---- PLOTS ----
figure(2)
subplot(2,3,1)
plot(1:T_irf2, e_float*100, 'b-', zeros(T_irf2,1), 'r--', ...
    cumsum(De_managed)*100, 'g-.', 'LineWidth', 2)
xlabel('Quarters'); ylabel('% depreciation (level)')
title('Exchange Rate: e_t'); legend('Float','Peg','Managed'); grid on

subplot(2,3,2)
plot(1:T_irf2, pi_float_er'*100, 'LineWidth', 2)
xlabel('Quarters'); ylabel('% per quarter')
title('Sector Inflation under Float (ER component)')
legend(sector_names,'Location','best'); yline(0,'k--'); grid on

subplot(2,3,3)
plot(1:T_irf2, cpi_float*100, 'b-', 'LineWidth', 2); hold on
plot(1:T_irf2, dc_float*100, 'r--', 'LineWidth', 2)
xlabel('Quarters'); ylabel('% per quarter')
title('CPI vs DC Inflation under Float')
legend('CPI','DC index'); yline(0,'k--'); grid on; hold off

subplot(2,3,4)
plot(1:T_irf2, dc_float*100, 'b-', dc_peg*100, 'r--', dc_managed*100, 'g-.', 'LineWidth', 2)
xlabel('Quarters'); ylabel('% per quarter')
title('DC Inflation Across Regimes')
legend('Float','Peg','Managed Float'); yline(0,'k--'); grid on

subplot(2,3,5)
plot(1:T_irf2, zeros(T_irf2,1), 'b-', y_peg*100, 'r--', ...
    -0.3*ones(T_irf2,1).*exp(-0.1*(0:T_irf2-1)), 'g-.', 'LineWidth', 2)
xlabel('Quarters'); ylabel('% deviation')
title('Output Gap Across Regimes (simplified)')
legend('Float (approx 0)','Peg','Managed Float'); yline(0,'k--'); grid on

subplot(2,3,6)
% Welfare proxy: sum of squared DC inflation + (gamma+phi)/2 * sum of squared y_gap
wf_float   = sum(dc_float.^2) + 0;        % float: DC inflation nonzero, y_gap ~0
wf_peg     = sum(dc_peg.^2)   + sum(y_peg.^2)*(gamma_hh+phi_hh);  % peg: no DC infl, y_gap falls
wf_managed = sum(dc_managed.^2) + 0;      % managed: partial offset
bar([wf_float, wf_peg, wf_managed]*1e4, 'FaceColor','flat', ...
    'CData', [0 0.4 0.8; 0.8 0.2 0.2; 0.2 0.7 0.3])
set(gca,'XTickLabel',{'Float','Peg','Managed Float'})
ylabel('Welfare loss proxy (bps^2)')
title('Welfare Comparison (risk premium shock)')
grid on

sgtitle('SOE Policy Comparison: Float vs Peg vs Managed Float')
fprintf('\nWelfare losses (float=%.2e, peg=%.2e, managed=%.2e)\n', wf_float, wf_peg, wf_managed)

%% ---------------------------------------------------------------
%% 3.6  COMPLETE SOE PARAMETER FUNCTION
%% ---------------------------------------------------------------
%
%  This function reproduces Rubbo's parameters_d.m AND adds the open
%  economy objects. Copy this into your own parameters_soe.m file.

fprintf('\n--- Running soe_parameters() function ---\n')
p = soe_parameters(Omega, omega_F, alpha_open, beta, delta, gamma_hh, phi_hh, rho);

fprintf('Objects computed by soe_parameters():\n')
fprintf('  lambda (Domar weights):            [')
fprintf('%.4f ', p.lambda); fprintf(']\n')
fprintf('  hat_delta (eff Calvo):             [')
fprintf('%.4f ', p.hat_delta'); fprintf(']\n')
fprintf('  kappa:                             %.4f\n', p.kappa)
fprintf('  b (Phillips slope, incl gamma+phi):[')
fprintf('%.4f ', p.b'); fprintf(']\n')
fprintf('  Gamma (ER pass-through):           [')
fprintf('%.4f ', p.Gamma'); fprintf(']\n')
fprintf('  dc_weights (DC index):             [')
fprintf('%.4f ', p.dc_weights); fprintf(']\n')
fprintf('  phi_DC (DC Phillips slope):        %.4f\n', p.phi_DC)
fprintf('  DC breaks down under float: dc_weights.Gamma = %.6f (nonzero = yes)\n', p.dc_Gamma_inner)

%% ---------------------------------------------------------------
%% 3.7  SUMMARY TABLE: closed vs open economy
%% ---------------------------------------------------------------

fprintf('\n\n=== SUMMARY: CLOSED vs OPEN ECONOMY ===\n')
fprintf('%-35s  %-40s  %-40s\n','Object','Closed Economy','Open Economy')
fprintf('%s\n', repmat('-',1,120))
fprintf('%-35s  %-40s  %-40s\n','Marginal cost', ...
    'alpha*w + Omega*p - log(A)', ...
    'alpha*w + Omega*p + omega_F*(p*+e) - log(A)')
fprintf('%-35s  %-40s  %-40s\n','Phillips curve', ...
    'rho*(I-V)*E[pi''] + B*y_gap - V*chi', ...
    'same + Gamma*De_t')
fprintf('%-35s  %-40s  %-40s\n','ER pass-through Gamma', ...
    'n/a (closed)', ...
    'A_tilde*omega_F/kappa')
fprintf('%-35s  %-40s  %-40s\n','Divine coincidence', ...
    'UNIQUE DC index (no cost-push)', ...
    'Breaks down under float (2 cost-push channels)')
fprintf('%-35s  %-40s  %-40s\n','IS curve (open)', ...
    'y = E[y''] - (i - E[pi^C''] - r_nat)/gamma', ...
    'same - (alpha_F/gamma)*E[De'']')
fprintf('%-35s  %-40s  %-40s\n','New equation', ...
    'n/a', ...
    'UIP: i - i* = E[De''] + psi + nu')
fprintf('%-35s  %-40s  %-40s\n','Optimal policy', ...
    'Target DC index (stabilizes y_gap)', ...
    'Float: irreducible tradeoff; Peg: loss of MP independence; Managed: modified DC')

%% ---------------------------------------------------------------
%% FORMULA-TO-CODE QUICK REFERENCE
%% ---------------------------------------------------------------

fprintf('\n\n=== FORMULA-TO-CODE QUICK REFERENCE ===\n')
fprintf('%-48s  %s\n','FORMULA','MATLAB CODE')
fprintf('%s\n', repmat('-',1,100))
rows = {
    'L = (I-Om)^{-1}                        ','L = inv(eye(n)-Omega)';
    'lambda = beta''*(I-Om)^{-1}              ','lambda = beta''*inv(eye(n)-Omega)';
    'hat_d = d*(1-rho*(1-d))/(1-rho*d*(1-d))','hat_delta = delta.*(1-rho*(1-delta))./(1-rho*delta.*(1-delta))';
    'Delta = diag(hat_delta)                 ','Delta = diag(hat_delta)';
    'L_rigid = (I-Om*D)^{-1}                ','L_rigid = inv(eye(n)-Omega*Delta)';
    'A_tilde = D*(I-Om*D)^{-1}              ','A_tilde = Delta*inv(eye(n)-Omega*Delta)';
    'kappa = 1 - beta''*A_tilde*alpha         ','kappa = 1 - beta''*A_tilde*alpha';
    'b = (g+p)*A_tilde*alpha/kappa          ','b = (gamma+phi)*A_tilde*alpha/kappa';
    'v = A_tilde*(alpha*(lam-beta''*A_tilde)/k-I)','v = A_tilde*(alpha*(lambda-beta''*A_tilde)/kappa - eye(n))';
    'llambda = lam*(I-D)*D^{-1}             ','llambda = lambda*(eye(n)-Delta)*inv(Delta)';
    'MM = I + D*v*(I-Om)                    ','MM = eye(n) + Delta*v*(eye(n)-Omega)';
    '[SOE] Gamma = A_tilde*omF/kappa        ','Gamma = A_tilde*omega_F/kappa';
    '[SOE] alpha_F = beta''*omega_F           ','alpha_F = beta''*omega_F';
};
for i = 1:size(rows,1)
    fprintf('%-48s  %s\n', rows{i,1}, rows{i,2})
end

%% ================================================================
%% FUNCTION DEFINITIONS
%% ================================================================

function p = soe_parameters(Omega, omega_F, alpha, beta, delta, gamma_hh, phi_hh, rho)
% SOE_PARAMETERS  Computes all model objects for Rubbo + SOE extension.
%
% INPUTS:
%   Omega    : N x N IO matrix (Omega(i,j) = sector i cost share from sector j)
%   omega_F  : N x 1 import intensity (sector i cost share from imports)
%   alpha    : N x 1 labor shares  (alpha + rowsum(Omega) + omega_F = 1)
%   beta     : N x 1 consumption shares (sum = 1)
%   delta    : N x 1 Calvo reset frequencies
%   gamma_hh : scalar, household risk aversion
%   phi_hh   : scalar, inverse Frisch elasticity
%   rho      : scalar, discount factor
%
% OUTPUT p is a struct with all key model objects (see field names below).

    n   = size(Omega,1);
    I_n = eye(n);

    % --- Verify inputs ---
    tol = 1e-9;
    assert(abs(sum(beta)-1) < tol, 'beta must sum to 1')
    assert(all(alpha > 0), 'Labor shares must be positive')
    assert(all(omega_F >= 0), 'Import shares must be non-negative')
    cost_check = alpha + sum(Omega,2) + omega_F;
    assert(all(abs(cost_check - 1) < tol), ...
        'For each sector: alpha_i + rowsum(Omega_i) + omega_F_i must equal 1')

    % --- Standard network objects ---
    p.L      = inv(I_n - Omega);                    % Leontief inverse
    p.lambda = (beta' * p.L);                        % 1 x N Domar weights

    % --- Calvo parameters ---
    p.hat_delta = delta .* (1 - rho*(1-delta)) ./ (1 - rho*delta.*(1-delta));
    p.Delta     = diag(p.hat_delta);                % N x N diagonal

    % --- Rigidity-adjusted objects ---
    p.L_rigid = inv(I_n - Omega * p.Delta);         % (I-Omega*Delta)^{-1}
    p.A_tilde = p.Delta * p.L_rigid;                % Delta*(I-Omega*Delta)^{-1}

    % --- Normalization scalar ---
    p.kappa = 1 - beta' * p.A_tilde * alpha;        % scalar

    % --- Phillips curve slope (closed economy) ---
    p.b = (gamma_hh + phi_hh) * p.A_tilde * alpha / p.kappa;   % N x 1

    % --- Cost-push matrix (Rubbo's "v") ---
    p.v = p.A_tilde * (alpha * (p.lambda - beta' * p.A_tilde) / p.kappa - I_n);

    % --- DC index weights ---
    llambda_raw  = p.lambda .* (1 - p.hat_delta') ./ p.hat_delta';  % 1 x N
    p.Lambda_DC  = sum(llambda_raw);
    p.dc_weights = llambda_raw / p.Lambda_DC;     % 1 x N normalized
    p.phi_DC     = (gamma_hh + phi_hh) / p.Lambda_DC;

    % --- System matrices ---
    p.MM = I_n + p.Delta * p.v * (I_n - Omega);
    p.b_raw = p.A_tilde * alpha / p.kappa;        % slope without (gamma+phi)
    p.Z  = I_n - inv(p.MM) * p.Delta * p.b_raw * p.lambda * ...
               (I_n - p.Delta) * inv(p.Delta) / (gamma_hh + phi_hh);

    % --- SOE objects ---
    p.Gamma    = p.A_tilde * omega_F / p.kappa;   % N x 1 ER pass-through
    p.alpha_F  = beta' * omega_F;                  % scalar: import share in CPI

    % --- DC coincidence check ---
    p.dc_Gamma_inner = p.dc_weights * p.Gamma;     % 0 iff DC survives under float

    % --- Proportionality check: Gamma vs b ---
    % If Gamma / b_raw = constant vector, DC survives (knife-edge case)
    ratio = p.Gamma ./ p.b_raw;
    p.dc_survives_float = (max(ratio) - min(ratio)) < 1e-6;   % true iff DC survives

    % --- Verification: V rows sum to zero ---
    V_full = p.v * (I_n - Omega);
    rowsum_err = max(abs(V_full * ones(n,1)));
    assert(rowsum_err < 1e-10, 'V rows do not sum to zero — check cost shares')
end


function [De_opt, nu_opt] = optimal_fx_intervention(p, De_float)
% OPTIMAL_FX_INTERVENTION  Finds the FX intervention nu_t that makes the
% managed float restore the DC Phillips curve (no ER cost-push).
%
% The CB wants: dc_weights * Gamma * De_managed = 0
% De_managed = De_float - nu_t  (intervention directly offsets depreciation)
%
% Solving: dc_weights * Gamma * (De_float - nu_t) = 0
%          => nu_t = De_float  ... that's a peg.
%
% The FULL optimal intervention: the CB should offset ONLY the ER
% cost-push component, leaving the ER free to move along other dimensions.
% With one instrument and N sectors, the optimal nu_t minimizes welfare
% loss subject to UIP. The solution (see Fanelli & Straub 2021):
%   nu_t* = (dc_weights * Gamma) / (dc_weights * Gamma + phi_FX) * De_float
% where phi_FX = cost of intervention (here set to 0 for simplicity).

    dc_Gamma = p.dc_weights * p.Gamma;   % scalar projection
    nu_opt   = dc_Gamma * De_float;      % optimal intervention (scalar or vector)
    De_opt   = De_float - nu_opt;        % resulting ER path
end


function plot_welfare_decomposition(p, De_series, y_series, title_str)
% PLOT_WELFARE_DECOMPOSITION  Decomposes welfare loss into components.
%   p         : output of soe_parameters()
%   De_series : T x 1 ER changes
%   y_series  : T x 1 output gaps
%   title_str : string for plot title

    T = length(De_series);

    % Sector inflations from ER:
    pi_er = p.Gamma * De_series';   % N x T

    % DC inflation:
    dc_inf = p.dc_weights * pi_er;  % 1 x T

    % CPI inflation:
    % (beta is not stored in p; this is illustrative)
    % cpi_inf = beta' * pi_er;

    fprintf('\nWelfare decomposition for: %s\n', title_str)
    fprintf('  Sum sq DC inflation:  %.6f\n', sum(dc_inf.^2))
    fprintf('  Sum sq output gap:    %.6f\n', sum(y_series.^2))
end
