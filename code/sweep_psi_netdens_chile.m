function sweep_psi_netdens_chile(psi_value, rho, regime)
% Full-robustness-campaign Tier 1A (2026-07-27): does the psi-sensitivity
% result (results/psi_sweep_welfare.csv, real Chile calibration, rho=1
% only) depend on whether the domestic production network is present?
% Combines sweep_psi_point.m's PSI substitution with
% sweep_phi_s_netdens_chile.m's rho-scaling of the domestic IO matrix
% (rho=0 -> no cross-sector network, rho=1 -> real Chile calibration),
% applied per-regime to the plain (non-exp) open_economy_network_chile*
% master family so results are directly comparable to psi_sweep_welfare.csv
% at rho=1.
%
% Usage (one point per call, fresh MATLAB process):
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); sweep_psi_netdens_chile(0.02, 1.0, 'float')"

addpath('C:\dynare\6.3\matlab');
global oo_

master_files = struct('float', 'open_economy_network_chile.mod', ...
                       'peg', 'open_economy_network_chile_peg.mod', ...
                       'managed', 'open_economy_network_chile_managed.mod');

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
txt = regexprep(txt, 'PSI\s*=\s*[\d.]+;', sprintf('PSI        = %.8f;', psi_value));
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

psi_tag = strrep(sprintf('%.4f', psi_value), '.', 'p');
rho_tag = strrep(sprintf('%.4f', rho), '.', 'p');
fname = sprintf('oen_psinet_chile_%s_%s_%s', psi_tag, rho_tag, regime);
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

out_csv = fullfile('results', 'psi_netdens_regime_sweep.csv');
if ~exist(out_csv, 'file')
    fid = fopen(out_csv, 'w');
    fprintf(fid, 'psi,rho,regime,%s\n', strjoin(moment_vars, ','));
    fclose(fid);
end
fid = fopen(out_csv, 'a');
fprintf(fid, '%.8f,%.6f,%s,%s\n', psi_value, rho, regime, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
fclose(fid);

fprintf('OK: psi_netdens_chile psi=%.4f rho=%.4f regime=%s appended to %s\n', psi_value, rho, regime, out_csv);
end
