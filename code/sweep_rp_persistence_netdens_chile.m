function sweep_rp_persistence_netdens_chile(rho, rho_rp, regime)
% Christian's feedback (2026-07-22/23): "persistence of inflation leading
% to higher cost... same conclusion on why UIP welfare loss is so high."
% Tests this directly: scales RHO_RP (the risk-premium/UIP shock's AR(1)
% persistence, baseline 0.80), crossed with network density rho (0 = no
% cross-sector network, 1 = baseline Chile calibration), for all three
% regimes. Mirrors sweep_phi_s_netdens_chile.m's rho-scaling of
% ALPHA_i/OH_ij, but substitutes RHO_RP instead of PHI_S, and needs all
% three regimes' master files (not just managed) since welfare needs a
% Float/Peg/Managed comparison at each (rho, rho_rp) point.
%
% Usage (one point per call):
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); sweep_rp_persistence_netdens_chile(1.0, 0.80, 'peg')"

addpath('C:\dynare\6.3\matlab');
global oo_

master_files = struct('float', 'open_economy_network_chile_exp.mod', ...
                       'peg', 'open_economy_network_chile_exp_peg.mod', ...
                       'managed', 'open_economy_network_chile_exp_managed.mod');

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
txt = regexprep(txt, 'ALPHA1\s*=\s*[\d.]+;', sprintf('ALPHA1  = %.6f;', ALPHA_k(1)));
txt = regexprep(txt, 'ALPHA2\s*=\s*[\d.]+;', sprintf('ALPHA2  = %.6f;', ALPHA_k(2)));
txt = regexprep(txt, 'ALPHA3\s*=\s*[\d.]+;', sprintf('ALPHA3  = %.6f;', ALPHA_k(3)));
txt = regexprep(txt, 'OH12\s*=\s*[\d.]+;', sprintf('OH12 = %.6f; ', OH12_k));
txt = regexprep(txt, 'OH13\s*=\s*[\d.]+;', sprintf('OH13 = %.6f;', OH13_k));
txt = regexprep(txt, 'OH21\s*=\s*[\d.]+;', sprintf('OH21 = %.6f; ', OH21_k));
txt = regexprep(txt, 'OH23\s*=\s*[\d.]+;', sprintf('OH23 = %.6f;', OH23_k));
txt = regexprep(txt, 'OH31\s*=\s*[\d.]+;', sprintf('OH31 = %.6f; ', OH31_k));
txt = regexprep(txt, 'OH32\s*=\s*[\d.]+;', sprintf('OH32 = %.6f;', OH32_k));
txt = regexprep(txt, 'RHO_RP\s*=\s*0\.80;', sprintf('RHO_RP  = %.6f;', rho_rp));

rho_tag = strrep(sprintf('%.4f', rho), '.', 'p');
rp_tag = strrep(sprintf('%.4f', rho_rp), '.', 'p');
fname = sprintf('oen_rppers_chile_%s_%s_%s', rho_tag, rp_tag, regime);
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

out_csv = fullfile('results', 'rp_persistence_netdens_chile_sweep.csv');
if ~exist(out_csv, 'file')
    fid = fopen(out_csv, 'w');
    fprintf(fid, 'rho,rho_rp,regime,%s\n', strjoin(moment_vars, ','));
    fclose(fid);
end
fid = fopen(out_csv, 'a');
fprintf(fid, '%.6f,%.6f,%s,%s\n', rho, rho_rp, regime, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
fclose(fid);

fprintf('OK: rp_persistence_netdens_chile rho=%.4f rho_rp=%.4f regime=%s appended to %s\n', rho, rho_rp, regime, out_csv);
end
