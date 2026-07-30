function sweep_rigidity_netdens_chile(kappa, rho, regime)
% Full-robustness-campaign Tier 1B (2026-07-27): uniform price-rigidity
% sensitivity x network density x regime. Scales ALL THREE sectors'
% stickiness (1-DELTA_i) by a common multiplier kappa (kappa>1 = stickier
% economy overall, kappa<1 = more flexible), holding relative cross-sector
% rigidity heterogeneity fixed, combined with sweep_phi_s_netdens_chile.m's
% rho-scaling of the domestic IO matrix. Baseline DELTA = [0.90, 0.31, 0.16]
% (Resource, Manufacturing, Services).
%
% Usage (one point per call, fresh MATLAB process):
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); sweep_rigidity_netdens_chile(1.0, 1.0, 'float')"

addpath('C:\dynare\6.3\matlab');
global oo_

master_files = struct('float', 'open_economy_network_chile.mod', ...
                       'peg', 'open_economy_network_chile_peg.mod', ...
                       'managed', 'open_economy_network_chile_managed.mod');

DELTA_base = [0.90, 0.31, 0.16];
DELTA_k = 1 - kappa * (1 - DELTA_base);
if any(DELTA_k <= 0.01) || any(DELTA_k >= 0.99)
    error('Infeasible/near-degenerate DELTA at kappa=%.4f: DELTA=[%.4f %.4f %.4f]', kappa, DELTA_k);
end

OH_diag = [0.0750, 0.2022, 0.2661];
OH_offdiag_base = [0.1526, 0.1932;
                    0.0991, 0.1453;
                    0.0018, 0.0581];
OF_base = [0.0767, 0.1945, 0.0704];

OH_k = rho * OH_offdiag_base;
OH12_k = OH_k(1,1); OH13_k = OH_k(1,2);
OH21_k = OH_k(2,1); OH23_k = OH_k(2,2);
OH31_k = OH_k(3,1); OH32_k = OH_k(3,2);

offdiag_sum = sum(OH_offdiag_base, 2)';
ALPHA_k = 1 - OH_diag - rho * offdiag_sum - OF_base;
if any(ALPHA_k <= 0)
    error('Infeasible shares at rho=%.4f: ALPHA=[%.4f %.4f %.4f]', rho, ALPHA_k);
end

master_txt = fileread(master_files.(regime));
txt = master_txt;
txt = regexprep(txt, 'DELTA1\s*=\s*[\d.]+;', sprintf('DELTA1  = %.6f;', DELTA_k(1)));
txt = regexprep(txt, 'DELTA2\s*=\s*[\d.]+;', sprintf('DELTA2  = %.6f;', DELTA_k(2)));
txt = regexprep(txt, 'DELTA3\s*=\s*[\d.]+;', sprintf('DELTA3  = %.6f;', DELTA_k(3)));
txt = regexprep(txt, 'ALPHA1\s*=\s*[\d.]+;', sprintf('ALPHA1  = %.6f;', ALPHA_k(1)));
txt = regexprep(txt, 'ALPHA2\s*=\s*[\d.]+;', sprintf('ALPHA2  = %.6f;', ALPHA_k(2)));
txt = regexprep(txt, 'ALPHA3\s*=\s*[\d.]+;', sprintf('ALPHA3  = %.6f;', ALPHA_k(3)));
txt = regexprep(txt, 'OH12\s*=\s*[\d.]+;', sprintf('OH12 = %.6f; ', OH12_k));
txt = regexprep(txt, 'OH13\s*=\s*[\d.]+;', sprintf('OH13 = %.6f;', OH13_k));
txt = regexprep(txt, 'OH21\s*=\s*[\d.]+;', sprintf('OH21 = %.6f; ', OH21_k));
txt = regexprep(txt, 'OH23\s*=\s*[\d.]+;', sprintf('OH23 = %.6f;', OH23_k));
txt = regexprep(txt, 'OH31\s*=\s*[\d.]+;', sprintf('OH31 = %.6f; ', OH31_k));
txt = regexprep(txt, 'OH32\s*=\s*[\d.]+;', sprintf('OH32 = %.6f;', OH32_k));
txt = regexprep(txt, 'graph_format\s*=\s*pdf', 'nograph');

kappa_tag = strrep(sprintf('%.4f', kappa), '.', 'p');
rho_tag = strrep(sprintf('%.4f', rho), '.', 'p');
fname = sprintf('oen_rignet_chile_%s_%s_%s', kappa_tag, rho_tag, regime);
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

out_csv = fullfile('results', 'rigidity_netdens_regime_sweep.csv');
if ~exist(out_csv, 'file')
    fid = fopen(out_csv, 'w');
    fprintf(fid, 'kappa,rho,regime,%s\n', strjoin(moment_vars, ','));
    fclose(fid);
end
fid = fopen(out_csv, 'a');
fprintf(fid, '%.6f,%.6f,%s,%s\n', kappa, rho, regime, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
fclose(fid);

fprintf('OK: rigidity_netdens_chile kappa=%.4f rho=%.4f regime=%s appended to %s\n', kappa, rho, regime, out_csv);
end
