function opt_rule_peg_point(scen, rho, rp_scale, delta_mode, of_mode, psi, out_csv)
% Joint (PHI_PI, PHI_Y, PHI_S) grid for the managed-float rule on the 3-sector
% Chile calibration, for ONE structural scenario. Answers Christian/Adam's
% "optimal FX weight, with vs. without the network" and lets us ablate the
% model's ingredients one at a time ("tear the framework apart").
%
% scen        : string tag written to every CSV row
% rho         : domestic-network density (0 = no cross-sector network, 1 = Chile data)
% rp_scale    : multiplier on the risk-premium shock s.d. (0 = shock off, 1 = 1% baseline)
% delta_mode  : 'base' (0.90/0.31/0.16) | 'uniform' (all 0.23 = Domar-weighted mean)
% of_mode     : 'base' | 'uniform' (all 0.10) | 'zero' (no imported inputs)
% psi         : debt-elasticity coefficient of the risk premium (baseline 0.02)
%
% One scenario per fresh MATLAB process (project sweep pattern). Dynare parses
% ONCE; the grid reruns stoch_simul on the solved model after changing
% M_.params (policy coefficients do not enter the steady state), the same
% trick run_full_shock_decomposition.m uses. Welfare = same formula as
% code/analysis.py:compute_welfare, with LAMBDA_D/DHAT read from M_.params
% (they are rho-dependent and recomputed by the .mod at parse time).
%
% Usage:
%  matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); opt_rule_point('base',1,1,'base','base',0.02,'results/opt_rule_grid.csv')"
addpath('C:\dynare\6.3\matlab');
global oo_ M_ options_

OH_diag = [0.0750, 0.2022, 0.2661];
OH_off = [0.1526, 0.1932; 0.0991, 0.1453; 0.0018, 0.0581];
OF_base = [0.0767, 0.1945, 0.0704];
switch of_mode
    case 'base',    OF_k = OF_base;
    case 'uniform', OF_k = [0.10 0.10 0.10];
    case 'zero',    OF_k = [0 0 0];
    otherwise, error('bad of_mode');
end
OH_k = rho * OH_off;
ALPHA_k = 1 - OH_diag - rho * sum(OH_off, 2)' - OF_k;
if any(ALPHA_k <= 0), error('Infeasible shares'); end

txt = fileread('open_economy_network_chile_peg.mod');
sub = @(t, name, val) regexprep(t, [name '\s*=\s*[\d.]+;'], sprintf('%s = %.6f;', name, val));
for i = 1:3
    txt = sub(txt, sprintf('ALPHA%d', i), ALPHA_k(i));
    txt = sub(txt, sprintf('OF%d', i), OF_k(i));
end
txt = sub(txt, 'OH12', OH_k(1,1)); txt = sub(txt, 'OH13', OH_k(1,2));
txt = sub(txt, 'OH21', OH_k(2,1)); txt = sub(txt, 'OH23', OH_k(2,2));
txt = sub(txt, 'OH31', OH_k(3,1)); txt = sub(txt, 'OH32', OH_k(3,2));
if strcmp(delta_mode, 'uniform')
    for i = 1:3, txt = sub(txt, sprintf('DELTA%d', i), 0.23); end
end
txt = regexprep(txt, 'PSI\s*=\s*0\.020;', sprintf('PSI = %.6f;', psi));
txt = regexprep(txt, 'graph_format=pdf', 'nograph');
txt = regexprep(txt, 'irf=40', 'irf=0');

fname = sprintf('oen_optrulepeg_%s', regexprep(scen, '[^A-Za-z0-9]', ''));
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);
eval(sprintf('dynare %s.mod', fname));

pn = cellstr(M_.param_names);
gp = @(n) M_.params(find(strcmp(pn, n), 1));
ip = @(n) find(strcmp(pn, n), 1);
GAMMA = gp('GAMMA'); VARPHI = gp('VARPHI'); EPS = gp('EPS');
lam = [gp('LAMBDA_D1') gp('LAMBDA_D2') gp('LAMBDA_D3')];
dh  = [gp('DHAT1') gp('DHAT2') gp('DHAT3')];
wdc = [gp('WDC1') gp('WDC2') gp('WDC3')];

en = cellstr(M_.exo_names);
Sig = M_.Sigma_e;
irp = find(strcmp(en, 'eps_rp'), 1);
Sig(irp, irp) = Sig(irp, irp) * rp_scale^2;
M_.Sigma_e = Sig;

var_list = {'piDC'; 'PIC'; 'y_gap'; 'PI1'; 'PI2'; 'PI3'; 'I'; 'S'; 'BSTAR'};
options_.order = 1; options_.irf = 0; options_.periods = 0;
options_.nograph = 1; options_.nomoments = 0; options_.nodecomposition = 1;
options_.nocorr = 1; options_.noprint = 1;

phi_pi_g = 1.5;
phi_y_g  = 0.5;
phi_s_g  = 0;

if ~exist(out_csv, 'file')
    fid = fopen(out_csv, 'w');
    fprintf(fid, 'scen,rho,rp_scale,phi_pi,phi_y,phi_s,status,var_ygap,var_pic,var_pidc,var_i,var_s,var_bstar,w_output,w_pi,total,wdc1,wdc2,wdc3,lam1,lam2,lam3\n');
    fclose(fid);
end
fid = fopen(out_csv, 'a');
for a = phi_pi_g
  for b = phi_y_g
    for c = phi_s_g
      M_.params(ip('PHI_PI')) = a; M_.params(ip('PHI_Y')) = b; M_.params(ip('PHI_S')) = c;
      status = 0; v = nan(1, 9);
      try
        [info, oo_, options_, M_] = stoch_simul(M_, options_, oo_, var_list);
        if info(1) ~= 0
            status = info(1);
        else
            vn = cellstr(oo_.var_list);
            d = @(n) oo_.var(find(strcmp(vn, n), 1), find(strcmp(vn, n), 1));
            v = [d('y_gap') d('PIC') d('piDC') d('I') d('S') d('BSTAR') d('PI1') d('PI2') d('PI3')];
        end
      catch
        status = -1;
      end
      wo = 0.5 * (GAMMA + VARPHI) * v(1);
      wp = 0.5 * sum(lam .* EPS .* (1 - dh) ./ dh .* v(7:9));
      fprintf(fid, '%s,%.4f,%.4f,%.4f,%.4f,%.4f,%d,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n', ...
          scen, rho, rp_scale, a, b, c, status, v(1), v(2), v(3), v(4), v(5), v(6), wo, wp, wo + wp, wdc, lam);
    end
  end
end
fclose(fid);
fprintf('OK: %s done\n', scen);
end
