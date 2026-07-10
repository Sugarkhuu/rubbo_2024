function [resid, out] = soe_ss_resid(W, ALPHA1,ALPHA2,ALPHA3,OH21,OH32,OF1,OF2,OF3, ...
    BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX_SCALE,GAMMA,VARPHI,MU)
% Scalar steady-state residual (labor supply = labor demand) as a
% function of the real wage W alone. Given W, prices are closed-form
% (Cobb-Douglas cost system), EX is closed-form (export demand), and C
% is then closed-form from the zero-trade-balance condition (linear in
% C given W and EX) -- so the whole 46-equation nonlinear steady state
% collapses to a single scalar root-find in W, solvable with fzero (no
% Optimization Toolbox required). See open_economy_network.mod's
% steady_state_model block for how this feeds back into all variables.
PFH = 1;

MC1 = W^ALPHA1 * PFH^OF1;
P1 = MU*MC1;
MC2 = W^ALPHA2 * P1^OH21 * PFH^OF2;
P2 = MU*MC2;
MC3 = W^ALPHA3 * P2^OH32 * PFH^OF3;
P3 = MU*MC3;

PH = P1^BH1 * P2^BH2 * P3^BH3;
PC = (OMEGA*PH^(1-ETA) + (1-OMEGA)*PFH^(1-ETA))^(1/(1-ETA));
k_CH = OMEGA*(PH/PC)^(-ETA);      % CH = k_CH * C
k_CF = (1-OMEGA)*(PFH/PC)^(-ETA); % CF = k_CF * C

EX = KAPEX_SCALE*(PH/PFH)^(-THETA_S);   % DSTAR=1

% Y_i = a_i*C + b_i  (linear in C, given W and EX)
a3 = BH3*PH*k_CH/P3;         b3 = BH3*PH*EX/P3;
a2 = (BH2*PH*k_CH + OH32*MC3*a3)/P2;   b2 = (BH2*PH*EX + OH32*MC3*b3)/P2;
a1 = (BH1*PH*k_CH + OH21*MC2*a2)/P1;   b1 = (BH1*PH*EX + OH21*MC2*b2)/P1;

% IM = A_IM*C + B_IM
A_IM = k_CF + (OF1*MC1*a1 + OF2*MC2*a2 + OF3*MC3*a3)/PFH;
B_IM = (OF1*MC1*b1 + OF2*MC2*b2 + OF3*MC3*b3)/PFH;

% zero trade balance (BSTAR_ss = BSTARBAR forced by UIP+Euler): PH*EX = PFH*IM
C = (PH*EX - B_IM) / A_IM;

Y3 = a3*C + b3;  Y2 = a2*C + b2;  Y1 = a1*C + b1;
L1 = ALPHA1*MC1*Y1/W; L2 = ALPHA2*MC2*Y2/W; L3 = ALPHA3*MC3*Y3/W;
Ltot = L1+L2+L3;

resid = W/PC - C^GAMMA*Ltot^VARPHI;

if nargout > 1
    out = struct('W',W,'C',C,'EX',EX,'PH',PH,'PC',PC,'PFH',PFH, ...
        'P1',P1,'P2',P2,'P3',P3,'MC1',MC1,'MC2',MC2,'MC3',MC3, ...
        'Y1',Y1,'Y2',Y2,'Y3',Y3,'L1',L1,'L2',L2,'L3',L3,'Ltot',Ltot, ...
        'CH',k_CH*C,'CF',k_CF*C);
end
end
