function [resid, out] = soe_ss_resid_dense_N(W, N, varargin)
% N-sector generalization of soe_ss_resid_dense.m -- identical algebra
% (see that file for the full derivation of every line), just N instead of
% hard-coded 3, and OHm/ALPHAv/OFv/BHv reconstructed here from a flat
% varargin list instead of taking a matrix/vector directly, because the
% caller (soe_ss_solve_dense_N.m) is itself invoked from a Dynare
% steady_state_model block that cannot pass bracket literals -- see that
% file's header comment for the exact varargin layout.
k = 1;
OHm = zeros(N, N);
for i = 1:N
    for j = 1:N
        OHm(i, j) = varargin{k}; k = k + 1;
    end
end
ALPHAv = zeros(N, 1);
for i = 1:N
    ALPHAv(i) = varargin{k}; k = k + 1;
end
OFv = zeros(N, 1);
for i = 1:N
    OFv(i) = varargin{k}; k = k + 1;
end
BHv = zeros(N, 1);
for i = 1:N
    BHv(i) = varargin{k}; k = k + 1;
end
OMEGA = varargin{k}; k = k + 1;
ETA = varargin{k}; k = k + 1;
THETA_S = varargin{k}; k = k + 1;
KAPEX_SCALE = varargin{k}; k = k + 1;
GAMMA = varargin{k}; k = k + 1;
VARPHI = varargin{k}; k = k + 1;
MU = varargin{k};

PFH = 1;

% log P_i = log(MU) + ALPHA_i*log(W) + sum_j OH_ij*log(P_j) + OF_i*log(PFH)
% => (I - OHm) * logP = log(MU)*1 + ALPHA*log(W) + OF*log(PFH)
rhs_logP = log(MU)*ones(N,1) + ALPHAv*log(W) + OFv*log(PFH);
logP = (eye(N) - OHm) \ rhs_logP;
P = exp(logP);
MC = P / MU;

PH = exp(BHv' * logP);   % PH = prod_i P_i^BH_i
PC = (OMEGA*PH^(1-ETA) + (1-OMEGA)*PFH^(1-ETA))^(1/(1-ETA));
k_CH = OMEGA*(PH/PC)^(-ETA);       % CH = k_CH * C
k_CF = (1-OMEGA)*(PFH/PC)^(-ETA);  % CF = k_CF * C

EX = KAPEX_SCALE*(PH/PFH)^(-THETA_S);   % DSTAR=1, PX=1

% Y_i = BH_i*PH*(k_CH*C + EX)/P_i + sum_j OH_ji*MC_j*Y_j/P_i
%   => (I - diag(1./P)*OHm'*diag(MC)) * Y = diag(1./P)*BH*PH*(k_CH*C+EX)
% Linear in C: Y = a_vec*C + b_vec
Pinv = diag(1./P);
coef_mat = eye(N) - Pinv*OHm'*diag(MC);
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
        'P',P,'MC',MC,'Y',Y,'L',L,'Ltot',Ltot, ...
        'CH',k_CH*C,'CF',k_CF*C);
end
end
