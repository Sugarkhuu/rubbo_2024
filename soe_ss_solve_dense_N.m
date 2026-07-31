function varargout = soe_ss_solve_dense_N(N, varargin)
% N-sector generalization of soe_ss_solve_dense.m. Two Dynare
% steady_state_model restrictions drove this exact signature (both confirmed
% empirically via preprocessor syntax errors, not assumed):
%   (1) no bracket matrix/vector literals ("[a;b;c]") as call arguments
%       -> inputs are a FLAT scalar list via varargin (see soe_ss_resid_dense_N.m
%          for the exact order: OH row-major N^2, ALPHA N, OF N, BH N, then
%          the 7 aggregate scalars OMEGA/ETA/THETA_S/KAPEX_SCALE/GAMMA/VARPHI/MU).
%   (2) a temp variable "SSPv(1)" cannot be indexed in steady_state_model
%       ("Symbol SSPv cannot take arguments") -- only declared model
%       variables/parameters can appear there -- so outputs are individual
%       scalars P1..PN, MC1..MCN, Y1..YN, L1..LN (varargout, N-generic),
%       exactly mirroring soe_ss_solve_dense.m's P1,P2,P3/MC1,MC2,MC3/...
%       pattern, just for N instead of 3.
% Output order: W, C, EX, PH, PC, P(1..N), MC(1..N), Y(1..N), L(1..N), Ltot, CH, CF
f = @(WW) soe_ss_resid_dense_N(WW, N, varargin{:});
W = fzero(f, [0.02, 10]);
[~, ss] = soe_ss_resid_dense_N(W, N, varargin{:});

vals = [W, ss.C, ss.EX, ss.PH, ss.PC, ss.P(:)', ss.MC(:)', ss.Y(:)', ss.L(:)', ss.Ltot, ss.CH, ss.CF];
varargout = cell(1, nargout);
for k = 1:nargout
    varargout{k} = vals(k);
end
end
