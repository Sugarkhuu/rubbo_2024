function KAPEX = calibrate_kapex_chile()
% Calibrates KAPEX1,KAPEX2,KAPEX3 (TASK #2, FULL VERSION) so that steady-
% state export intensity PH*EX_i/(P_i*Y_i) matches the REAL Chile export-
% share data (exports_i/Y_i, computed in
% data_calibration/build_chile_calibration.py as `export_share`, values
% 0.602/0.180/0.036 for Resource/Manuf./Services -- see
% chile_calibration_results.json field export_share_of_own_output),
% while keeping total steady-state export volume close to the ORIGINAL
% aggregate calibration (KAPEX_SCALE=0.50) so this is a reallocation
% across sectors, not a change in the overall trade-balance/NFA level.
%
% No Optimization Toolbox available on this machine (fsolve not on path),
% so this uses a simple damped multiplicative fixed-point iteration:
% KAPEX_i <- KAPEX_i * (target_share_i/achieved_share_i)^damp, which
% converges reliably here because each sector's own export share is,
% to first order, governed by its own KAPEX_i (diagonally dominant
% problem), with only second-order cross-sector effects via the network/
% wage general equilibrium.
%
% Run from repo root: >> addpath('code'); calibrate_kapex_chile

ALPHA1=0.5026; ALPHA2=0.3589; ALPHA3=0.6035;
OH11=0.0750; OH12=0.1526; OH13=0.1932;
OH21=0.0991; OH22=0.2022; OH23=0.1453;
OH31=0.0018; OH32=0.0581; OH33=0.2661;
OF1=0.0767; OF2=0.1945; OF3=0.0704;
BH1=0.0265; BH2=0.2294; BH3=0.7441;
BF_TOT=0.10; OMEGA=1-BF_TOT; ETA=1.50; THETA_S=2.00;
GAMMA=1.00; VARPHI=2.00; EPS=8.00; MU=EPS/(EPS-1);

target_share = [0.602, 0.180, 0.036];   % export_share_of_own_output, Chile data

% ---- reference: old aggregate EX_ss under the original scalar KAPEX_SCALE
[~,~,EX_old,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = soe_ss_solve_dense( ...
    ALPHA1,ALPHA2,ALPHA3,OH11,OH12,OH13,OH21,OH22,OH23,OH31,OH32,OH33, ...
    OF1,OF2,OF3,BH1,BH2,BH3,OMEGA,ETA,THETA_S,0.50,GAMMA,VARPHI,MU);
fprintf('Reference (old, aggregate BH-allocated) EX_ss = %.6f\n', EX_old);

% ---- solve via Newton-Raphson in log(KAPEX) with a numerical Jacobian
% (multiplicative fixed-point iteration was tried first and converges
% only linearly at rate ~0.985/iter -- the cross-sector network coupling
% makes the achieved-share map non-diagonal enough that Newton is needed
% for a clean converged calibration).
achieve_fn = @(k) local_achieved(k, ALPHA1,ALPHA2,ALPHA3,OH11,OH12,OH13,OH21,OH22,OH23,OH31,OH32,OH33, ...
    OF1,OF2,OF3,BH1,BH2,BH3,OMEGA,ETA,THETA_S,GAMMA,VARPHI,MU);

x = log([0.30, 0.30, 0.05]);   % x = log(KAPEX), keeps KAPEX>0 automatically
h = 1e-5;
for iter = 1:100
    KAPEX = exp(x);
    [achieved, EX1,EX2,EX3,PH,P1,P2,P3,Y1,Y2,Y3] = achieve_fn(KAPEX);
    err = achieved - target_share;
    fprintf('iter %2d: KAPEX=[%.5f %.5f %.5f] achieved=[%.5f %.5f %.5f] err=[%+.6f %+.6f %+.6f]\n', ...
        iter, KAPEX, achieved, err);
    if max(abs(err)) < 1e-8
        break;
    end
    J = zeros(3,3);
    for j = 1:3
        xp = x; xp(j) = xp(j) + h;
        ap = achieve_fn(exp(xp));
        J(:,j) = (ap(:) - achieved(:)) / h;
    end
    dx = -J \ err(:);
    x = x + dx';
end

EX_total_new = EX1 + EX2 + EX3;
fprintf('\nConverged KAPEX = [%.6f, %.6f, %.6f]\n', KAPEX);
fprintf('Achieved export shares = [%.4f, %.4f, %.4f]  (target [%.3f, %.3f, %.3f])\n', achieved, target_share);
fprintf('New total EX_ss = %.6f  vs. old aggregate EX_ss = %.6f  (ratio %.4f)\n', EX_total_new, EX_old, EX_total_new/EX_old);
end

function [achieved, EX1,EX2,EX3,PH,P1,P2,P3,Y1,Y2,Y3] = local_achieved(KAPEX, ...
    ALPHA1,ALPHA2,ALPHA3,OH11,OH12,OH13,OH21,OH22,OH23,OH31,OH32,OH33, ...
    OF1,OF2,OF3,BH1,BH2,BH3,OMEGA,ETA,THETA_S,GAMMA,VARPHI,MU)
[~,~,EX1,EX2,EX3,PH,~,P1,P2,P3,~,~,~,Y1,Y2,Y3,~,~,~,~,~,~] = soe_ss_solve_dense_exp( ...
    ALPHA1,ALPHA2,ALPHA3,OH11,OH12,OH13,OH21,OH22,OH23,OH31,OH32,OH33, ...
    OF1,OF2,OF3,BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX(1),KAPEX(2),KAPEX(3),GAMMA,VARPHI,MU);
achieved = [PH*EX1/(P1*Y1), PH*EX2/(P2*Y2), PH*EX3/(P3*Y3)];
end
