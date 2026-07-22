function sweep_phi_s_netdens_chile(rho, phi_s)
% Christian's feedback (2026-07-22): does the OPTIMAL managed-float FX
% response PHI_S depend on whether the domestic production network is
% present? Combines code/sweep_netdens_chile.m's rho-scaling of the
% domestic IO matrix (ALPHA_i/OH_ij, rho=0 -> no cross-sector network,
% rho=1 -> real Chile calibration) with code/sweep_phi_s_chile.m's PHI_S
% substitution, both applied to the SAME master file
% (open_economy_network_chile_exp_managed.mod) so results are directly
% comparable to the existing netdens/phi_s sweeps.
%
% Usage (one point per call, mirrors sweep_netdens_chile.m):
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); sweep_phi_s_netdens_chile(1.0, 0.30)"

addpath('C:\dynare\6.3\matlab');
global oo_

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

master_txt = fileread('open_economy_network_chile_exp_managed.mod');
txt = master_txt;
txt = regexprep(txt, 'ALPHA1\s*=\s*[\d.]+;', sprintf('ALPHA1  = %.6f;', ALPHA_k(1)));
txt = regexprep(txt, 'ALPHA2\s*=\s*[\d.]+;', sprintf('ALPHA2  = %.6f;', ALPHA_k(2)));
txt = regexprep(txt, 'ALPHA3\s*=\s*[\d.]+;', sprintf('ALPHA3  = %.6f;', ALPHA_k(3)));
txt = regexprep(txt, 'OH12\s*=\s*[\d.]+;', sprintf('OH12 = %.6f; ', OH12_k));
txt = regexprep(txt, 'OH13\s*=\s*[\d.]+;', sprintf('OH13 = %.6f;', OH13_k));
txt = regexprep(txt, 'OH21\s*=\s*[\d.]+;', sprintf('OH21 = %.6f; ', OH21_k));
txt = regexprep(txt, 'OH23\s*=\s*[\d.]+;', sprintf('OH23 = %.6f;', OH23_k));
txt = regexprep(txt, 'OH31\s*=\s*[\d.]+;', sprintf('OH31 = %.6f; ', OH31_k));
txt = regexprep(txt, 'OH32\s*=\s*[\d.]+;', sprintf('OH32 = %.6f;', OH32_k));
txt = regexprep(txt, 'PHI_S\s*=\s*0\.30;', sprintf('PHI_S   = %.6f;', phi_s));

rho_tag = strrep(sprintf('%.4f', rho), '.', 'p');
phi_tag = strrep(sprintf('%.4f', phi_s), '.', 'p');
fname = sprintf('oen_phisnet_chile_%s_%s', rho_tag, phi_tag);
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

out_csv = fullfile('results', 'phi_s_netdens_chile_sweep.csv');
if ~exist(out_csv, 'file')
    fid = fopen(out_csv, 'w');
    fprintf(fid, 'rho,phi_s,%s\n', strjoin(moment_vars, ','));
    fclose(fid);
end
fid = fopen(out_csv, 'a');
fprintf(fid, '%.6f,%.6f,%s\n', rho, phi_s, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
fclose(fid);

fprintf('OK: phi_s_netdens_chile rho=%.4f phi_s=%.4f appended to %s\n', rho, phi_s, out_csv);
end
