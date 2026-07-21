function [resid, out] = soe_ss_resid_dense_exp(W, ALPHA1,ALPHA2,ALPHA3, ...
    OH11,OH12,OH13,OH21,OH22,OH23,OH31,OH32,OH33, OF1,OF2,OF3, ...
    BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX1,KAPEX2,KAPEX3,GAMMA,VARPHI,MU)
% TASK #2 (todo_three_exercises.txt), FULL VERSION: sector-specific export
% demand. Generalizes soe_ss_resid_dense.m by replacing the single
% aggregate export object EX = KAPEX_SCALE*(PH/PFH)^(-THETA_S), allocated
% across sectors via household consumption shares BH_i, with three
% sector-specific export equations
%   EX_i = KAPEX_i * (P_i/PFH)^(-THETA_S)
% using each sector's OWN price (not the aggregate PH) and its own scale
% constant KAPEX_i. Because the cost side (prices P, marginal costs MC)
% never depends on demand (Cobb-Douglas cost minimization is a pure supply-
% side block), EX_i can be computed directly from P_i once P is known --
% no new fixed-point coupling is introduced, only extra linearity in the
% Y-system's demand terms (PH*EX_i/P_i replaces BH_i*PH*EX/P_i).
PFH = 1;

OHm = [OH11 OH12 OH13; OH21 OH22 OH23; OH31 OH32 OH33];  % OHm(i,j) = buyer i's cost share on seller j
ALPHAv = [ALPHA1; ALPHA2; ALPHA3];
OFv = [OF1; OF2; OF3];
BHv = [BH1; BH2; BH3];
KAPEXv = [KAPEX1; KAPEX2; KAPEX3];

% log P_i = log(MU) + ALPHA_i*log(W) + sum_j OH_ij*log(P_j) + OF_i*log(PFH)
rhs_logP = log(MU)*ones(3,1) + ALPHAv*log(W) + OFv*log(PFH);
logP = (eye(3) - OHm) \ rhs_logP;
P = exp(logP);
MC = P / MU;

PH = exp(BHv' * logP);
PC = (OMEGA*PH^(1-ETA) + (1-OMEGA)*PFH^(1-ETA))^(1/(1-ETA));
k_CH = OMEGA*(PH/PC)^(-ETA);
k_CF = (1-OMEGA)*(PFH/PC)^(-ETA);

% sector-specific export demand: own price P_i, not aggregate PH
EXv = KAPEXv .* (P/PFH).^(-THETA_S);   % DSTAR=1, PX=1

% Y_i = BH_i*PH*CH/P_i + PH*EX_i/P_i + sum_j OH_ji*MC_j*Y_j/P_i
%   => (I - diag(1./P)*OHm'*diag(MC)) * Y = diag(1./P)*(BH*PH*CH + PH*EX)
% Split into the C-linear part (a_vec) and the EX-driven constant part (b_vec)
Pinv = diag(1./P);
coef_mat = eye(3) - Pinv*OHm'*diag(MC);
rhs_C = Pinv*BHv*PH*k_CH;
rhs_E = Pinv*(PH*EXv);
a_vec = coef_mat \ rhs_C;
b_vec = coef_mat \ rhs_E;

% IM = CF + sum_i OF_i*MC_i*Y_i/PFH, linear in C via Y = a_vec*C + b_vec
A_IM = k_CF + (OFv' * (MC.*a_vec))/PFH;
B_IM = (OFv' * (MC.*b_vec))/PFH;

% zero trade balance (BSTAR_ss = BSTARBAR forced by UIP+Euler): PH*sum(EX_i) = PFH*IM
EX_total = sum(EXv);
C = (PH*EX_total - B_IM) / A_IM;

Y = a_vec*C + b_vec;
L = ALPHAv.*MC.*Y/W;
Ltot = sum(L);

resid = W/PC - C^GAMMA*Ltot^VARPHI;

if nargout > 1
    out = struct('W',W,'C',C,'EX1',EXv(1),'EX2',EXv(2),'EX3',EXv(3),'EX',EX_total, ...
        'PH',PH,'PC',PC,'PFH',PFH, ...
        'P1',P(1),'P2',P(2),'P3',P(3), ...
        'MC1',MC(1),'MC2',MC(2),'MC3',MC(3), ...
        'Y1',Y(1),'Y2',Y(2),'Y3',Y(3), ...
        'L1',L(1),'L2',L(2),'L3',L(3),'Ltot',Ltot, ...
        'CH',k_CH*C,'CF',k_CF*C);
end
end
