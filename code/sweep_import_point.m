function sweep_import_point(sweep_type, grid_value, regime)
global oo_
% Chile-calibrated replacement for the old stylized-network import sweep
% (code/sweep_import_intensity.m, code/sweep_import_heterogeneity.m, both
% built on open_economy_network.mod -- a hand-picked triangular network,
% NOT Chile's data). This version reparametrizes OF1-3 (import cost
% shares) starting from the REAL Chile calibration
% (open_economy_network_chile*.mod), exactly mirroring
% code/sweep_export_point.m's construction on the export side:
%
%   OF_i(zeta)    = zeta * OF_i^base                                  (uniform scaling: import OPENNESS)
%   OF_i(theta_M) = mean(OF^base) + theta_M*(OF_i^base - mean(OF^base))  (mean-preserving: import CONCENTRATION)
%
% zeta=theta_M=1 recovers the real Chile calibration exactly. OF is a
% cost share (unlike KAPEX on the export side), so ALPHA_i must absorb
% the change to keep ALPHA_i+OH_sum_i+OF_i=1, holding the domestic
% network OH11-OH33 fixed at Chile's calibrated values (OH_sum_i is each
% row's total domestic-input cost share, computed from the Chile .mod
% file, not assumed).
%
% Designed to be called in ITS OWN fresh MATLAB process (crash isolation,
% same reasoning as sweep_export_point.m). Appends one row to
% results/import_<sweep_type>_sweep.csv.
%
% sweep_type: 'zeta' (import openness/level) or 'thetaM' (import concentration).
% grid_value: zeta or theta_M (numeric).
% regime: 'float'|'peg'|'managed'.
%
% Usage (from repo root, one call per point):
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); sweep_import_point('zeta', 1.5, 'float')"

addpath('C:\dynare\6.3\matlab');

master_files = struct('float', 'open_economy_network_chile_exp.mod', ...
                       'peg', 'open_economy_network_chile_exp_peg.mod', ...
                       'managed', 'open_economy_network_chile_exp_managed.mod');

OF_base = [0.0767, 0.1945, 0.0704];             % Resource, Manuf., Services (real Chile calibration)
OH_sum  = [0.0750+0.1526+0.1932, 0.0991+0.2022+0.1453, 0.0018+0.0581+0.2661];  % Chile OH row sums (fixed)
OF_mean = mean(OF_base);

switch sweep_type
    case 'zeta'
        zeta = grid_value;
        OF_k = zeta * OF_base;
    case 'thetaM'
        theta_M = grid_value;
        OF_k = OF_mean + theta_M * (OF_base - OF_mean);
    otherwise
        error('Unknown sweep_type %s', sweep_type);
end
ALPHA_k = 1 - OH_sum - OF_k;
if any(ALPHA_k <= 0) || any(OF_k <= 0)
    error('Infeasible shares at grid_value=%.4f: ALPHA=[%.4f %.4f %.4f] OF=[%.4f %.4f %.4f]', ...
        grid_value, ALPHA_k, OF_k);
end

master_txt = fileread(master_files.(regime));
txt = master_txt;
txt = regexprep(txt, 'ALPHA1\s*=\s*[\d.]+;', sprintf('ALPHA1  = %.6f;', ALPHA_k(1)));
txt = regexprep(txt, 'ALPHA2\s*=\s*[\d.]+;', sprintf('ALPHA2  = %.6f;', ALPHA_k(2)));
txt = regexprep(txt, 'ALPHA3\s*=\s*[\d.]+;', sprintf('ALPHA3  = %.6f;', ALPHA_k(3)));
txt = regexprep(txt, 'OF1\s*=\s*[\d.]+;[^\n]*', sprintf('OF1     = %.6f;', OF_k(1)));
txt = regexprep(txt, 'OF2\s*=\s*[\d.]+;[^\n]*', sprintf('OF2     = %.6f;', OF_k(2)));
txt = regexprep(txt, 'OF3\s*=\s*[\d.]+;[^\n]*', sprintf('OF3     = %.6f;', OF_k(3)));

tag = strrep(sprintf('%.4f', grid_value), '.', 'p');
fname = sprintf('oen_impsw_%s_%s_%s', sweep_type, tag, regime);
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

out_csv = fullfile('results', sprintf('import_%s_sweep.csv', sweep_type));
grid_col = 'zeta';
if strcmp(sweep_type, 'thetaM'); grid_col = 'theta_M'; end
if ~exist(out_csv, 'file')
    fid = fopen(out_csv, 'w');
    fprintf(fid, '%s,regime,%s\n', grid_col, strjoin(moment_vars, ','));
    fclose(fid);
end
fid = fopen(out_csv, 'a');
fprintf(fid, '%.6f,%s,%s\n', grid_value, regime, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
fclose(fid);

fprintf('OK: %s grid_value=%.4f regime=%s appended to %s\n', sweep_type, grid_value, regime, out_csv);
end
