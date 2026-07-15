function [resid, out] = soe_ss_resid_dense(W, ALPHA1,ALPHA2,ALPHA3, ...
    OH11,OH12,OH13,OH21,OH22,OH23,OH31,OH32,OH33, OF1,OF2,OF3, ...
    BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX_SCALE,GAMMA,VARPHI,MU)
% Scalar steady-state residual (labor supply = labor demand) as a function
% of the real wage W alone, generalizing soe_ss_resid.m to a DENSE domestic
% IO matrix (not just the two off-diagonal entries OH21, OH32 of a strict
% upstream-to-downstream chain). With a dense Omega^H:
%   - log-prices solve a genuine 3x3 linear system (I-Omega^H)*logP = const,
%     not a simple recursive substitution P1 -> P2 -> P3;
%   - sectoral output Y solves a genuine 3x3 linear system too (every
%     sector buys inputs from every other sector), not a chain recursion.
% Both are ordinary MATLAB matrix solves (backslash) -- there is no
% Dynare-preprocessor restriction here since this runs as a plain .m file.
PFH = 1;

OHm = [OH11 OH12 OH13; OH21 OH22 OH23; OH31 OH32 OH33];  % OHm(i,j) = buyer i's cost share on seller j
ALPHAv = [ALPHA1; ALPHA2; ALPHA3];
OFv = [OF1; OF2; OF3];
BHv = [BH1; BH2; BH3];

% log P_i = log(MU) + ALPHA_i*log(W) + sum_j OH_ij*log(P_j) + OF_i*log(PFH)
% => (I - OHm) * logP = log(MU)*1 + ALPHA*log(W) + OF*log(PFH)
rhs_logP = log(MU)*ones(3,1) + ALPHAv*log(W) + OFv*log(PFH);
logP = (eye(3) - OHm) \ rhs_logP;
P = exp(logP);
MC = P / MU;   % P_i = MU*MC_i => MC_i = P_i/MU

PH = exp(BHv' * logP);   % PH = P1^BH1 * P2^BH2 * P3^BH3
PC = (OMEGA*PH^(1-ETA) + (1-OMEGA)*PFH^(1-ETA))^(1/(1-ETA));
k_CH = OMEGA*(PH/PC)^(-ETA);       % CH = k_CH * C
k_CF = (1-OMEGA)*(PFH/PC)^(-ETA);  % CF = k_CF * C

EX = KAPEX_SCALE*(PH/PFH)^(-THETA_S);   % DSTAR=1, PX=1

% Y_i = BH_i*PH*(k_CH*C + EX)/P_i + sum_j OH_ji*MC_j*Y_j/P_i
%   => (I - diag(1./P)*OHm'*diag(MC)) * Y = diag(1./P)*BH*PH*(k_CH*C+EX)
% Linear in C: Y = a_vec*C + b_vec
Pinv = diag(1./P);
coef_mat = eye(3) - Pinv*OHm'*diag(MC);
rhs_C = Pinv*BHv*PH*k_CH;
rhs_E = Pinv*BHv*PH*EX;
a_vec = coef_mat \ rhs_C;
b_vec = coef_mat \ rhs_E;

% IM = CF + sum_i OF_i*MC_i*Y_i/PFH, linear in C via Y = a_vec*C + b_vec
A_IM = k_CF + (OFv' * (MC.*a_vec))/PFH;
B_IM = (OFv' * (MC.*b_vec))/PFH;

% zero trade balance (BSTAR_ss = BSTARBAR forced by UIP+Euler): PH*EX = PFH*IM
C = (PH*EX - B_IM) / A_IM;

Y = a_vec*C + b_vec;
L = ALPHAv.*MC.*Y/W;
Ltot = sum(L);

resid = W/PC - C^GAMMA*Ltot^VARPHI;

if nargout > 1
    out = struct('W',W,'C',C,'EX',EX,'PH',PH,'PC',PC,'PFH',PFH, ...
        'P1',P(1),'P2',P(2),'P3',P(3), ...
        'MC1',MC(1),'MC2',MC(2),'MC3',MC(3), ...
        'Y1',Y(1),'Y2',Y(2),'Y3',Y(3), ...
        'L1',L(1),'L2',L(2),'L3',L(3),'Ltot',Ltot, ...
        'CH',k_CH*C,'CF',k_CF*C);
end
end
