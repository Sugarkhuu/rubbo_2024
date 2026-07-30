function sweep_regime_variants_chile(mode, rho, phi_pi, phi_y, regime)
% Tier 3 of the full robustness campaign: regime-rule variants on the
% real Chile calibration, all built on open_economy_network_chile.mod's
% REGIME macro branches (float/cpi_it/ppi_it), scaling network density rho
% the same way as sweep_phi_s_netdens_chile.m.
%
% mode = 'strict_it': strict inflation targeting (PHI_PI=5 proxy for ->inf,
%   PHI_Y=0) applied to 'regime' in {'float' (= strict DC-IT), 'cpi_it',
%   'ppi_it'}, swept over rho in {0,1,2} -> results/regime_variants_sweep.csv
%   (9 solves: 3 rule-targets x 3 rho).
% mode = 'dual_mandate': PHI_PI x PHI_Y grid on the 'float' (DC-IT) branch
%   at baseline rho=1 -> results/dual_mandate_grid_sweep.csv (9 solves:
%   PHI_PI in {1.5,3,5} x PHI_Y in {0,0.5,1}).
%
% Usage (one point per call, fresh MATLAB process):
%   matlab -batch "...; sweep_regime_variants_chile('strict_it', 1.0, 5, 0, 'float')"
%   matlab -batch "...; sweep_regime_variants_chile('dual_mandate', 1.0, 3, 0.5, 'float')"

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

master_txt = fileread('open_economy_network_chile.mod');
txt = master_txt;
txt = regexprep(txt, '@#define REGIME = "float"', sprintf('@#define REGIME = "%s"', regime));
txt = regexprep(txt, 'ALPHA1\s*=\s*[\d.]+;', sprintf('ALPHA1  = %.6f;', ALPHA_k(1)));
txt = regexprep(txt, 'ALPHA2\s*=\s*[\d.]+;', sprintf('ALPHA2  = %.6f;', ALPHA_k(2)));
txt = regexprep(txt, 'ALPHA3\s*=\s*[\d.]+;', sprintf('ALPHA3  = %.6f;', ALPHA_k(3)));
txt = regexprep(txt, 'OH12\s*=\s*[\d.]+;', sprintf('OH12 = %.6f; ', OH12_k));
txt = regexprep(txt, 'OH13\s*=\s*[\d.]+;', sprintf('OH13 = %.6f;', OH13_k));
txt = regexprep(txt, 'OH21\s*=\s*[\d.]+;', sprintf('OH21 = %.6f; ', OH21_k));
txt = regexprep(txt, 'OH23\s*=\s*[\d.]+;', sprintf('OH23 = %.6f;', OH23_k));
txt = regexprep(txt, 'OH31\s*=\s*[\d.]+;', sprintf('OH31 = %.6f; ', OH31_k));
txt = regexprep(txt, 'OH32\s*=\s*[\d.]+;', sprintf('OH32 = %.6f;', OH32_k));
txt = regexprep(txt, 'PHI_PI\s*=\s*[\d.]+;', sprintf('PHI_PI  = %.6f;', phi_pi));
txt = regexprep(txt, 'PHI_Y\s*=\s*[\d.]+;', sprintf('PHI_Y   = %.6f;', phi_y));
txt = regexprep(txt, 'graph_format\s*=\s*pdf', 'nograph');

rho_tag = strrep(sprintf('%.2f', rho), '.', 'p');
pi_tag = strrep(sprintf('%.2f', phi_pi), '.', 'p');
y_tag = strrep(sprintf('%.2f', phi_y), '.', 'p');
mode_tag = 'x';
if strcmp(mode, 'strict_it'); mode_tag = 'si'; end
if strcmp(mode, 'dual_mandate'); mode_tag = 'dm'; end
regime_tag = regime;
if strcmp(regime, 'managed'); regime_tag = 'mgd'; end
fname = sprintf('rv_%s_%s_%s_%s_%s', mode_tag, regime_tag, rho_tag, pi_tag, y_tag);
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

if strcmp(mode, 'strict_it')
    out_csv = fullfile('results', 'regime_variants_sweep.csv');
    if ~exist(out_csv, 'file')
        fid = fopen(out_csv, 'w');
        fprintf(fid, 'target,rho,%s\n', strjoin(moment_vars, ','));
        fclose(fid);
    end
    fid = fopen(out_csv, 'a');
    fprintf(fid, '%s,%.4f,%s\n', regime, rho, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
    fclose(fid);
else
    out_csv = fullfile('results', 'dual_mandate_grid_sweep.csv');
    if ~exist(out_csv, 'file')
        fid = fopen(out_csv, 'w');
        fprintf(fid, 'phi_pi,phi_y,%s\n', strjoin(moment_vars, ','));
        fclose(fid);
    end
    fid = fopen(out_csv, 'a');
    fprintf(fid, '%.4f,%.4f,%s\n', phi_pi, phi_y, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
    fclose(fid);
end

fprintf('OK: mode=%s regime=%s rho=%.4f phi_pi=%.4f phi_y=%.4f appended to %s\n', mode, regime, rho, phi_pi, phi_y, out_csv);
end
