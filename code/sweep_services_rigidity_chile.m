function sweep_services_rigidity_chile(delta3, rho, regime)
% Tier 1B (Services-only cut) of the full robustness campaign
% (plan: C:\Users\sugarkhuu\.claude\plans\noble-strolling-feather.md).
% Unlike sweep_rigidity_netdens_chile.m (scales ALL sectors' stickiness
% together), this moves ONLY Services' Calvo reset probability DELTA3,
% holding DELTA1/DELTA2 at their real Chile baseline values -- this is the
% version that most directly answers Christian's original comment ("is it
% specifically Services' own rigidity that matters"). Combined with
% sweep_phi_s_netdens_chile.m's rho-scaling of the domestic IO matrix.
%
% Grid: DELTA3 in {0.05, 0.10, 0.16(baseline), 0.25, 0.40, 0.60} (very
% sticky -> fairly flexible), rho in {0,1,2}, 3 regimes = 54 solves.
%
% Usage (one point per call, fresh MATLAB process):
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); sweep_services_rigidity_chile(0.16, 1.0, 'float')"

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
if delta3 <= 0.01 || delta3 >= 0.99
    error('Infeasible DELTA3=%.4f', delta3);
end

master_txt = fileread(master_files.(regime));
txt = master_txt;
txt = regexprep(txt, 'DELTA3\s*=\s*[\d.]+;', sprintf('DELTA3  = %.6f;', delta3));
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

d3_tag = strrep(sprintf('%.4f', delta3), '.', 'p');
rho_tag = strrep(sprintf('%.4f', rho), '.', 'p');
fname = sprintf('oen_svcrig_chile_%s_%s_%s', d3_tag, rho_tag, regime);
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

out_csv = fullfile('results', 'services_rigidity_netdens_sweep.csv');
if ~exist(out_csv, 'file')
    fid = fopen(out_csv, 'w');
    fprintf(fid, 'delta3,rho,regime,%s\n', strjoin(moment_vars, ','));
    fclose(fid);
end
fid = fopen(out_csv, 'a');
fprintf(fid, '%.6f,%.6f,%s,%s\n', delta3, rho, regime, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
fclose(fid);

fprintf('OK: services_rigidity_chile delta3=%.4f rho=%.4f regime=%s appended to %s\n', delta3, rho, regime, out_csv);
end
