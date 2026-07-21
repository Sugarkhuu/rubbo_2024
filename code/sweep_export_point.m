function sweep_export_point(sweep_type, grid_value, regime)
global oo_
% Export-side analogue of code/run_sweep_point.m's import-side
% openness/concentration sweep, run on the REAL Chile sector-specific
% export model (open_economy_network_chile_exp*.mod, TASK #2 FULL
% VERSION) instead of the stylized network. Mirrors the "Openness &
% Import Concentration" slide's construction exactly, but reparametrizes
% KAPEX1-3 (export-demand scale constants) instead of OF1-3 (import cost
% shares):
%
%   KAPEX_i(zeta)    = zeta * KAPEX_i^base                          (uniform scaling: export OPENNESS)
%   KAPEX_i(theta_X) = mean(KAPEX^base) + theta_X*(KAPEX_i^base - mean(KAPEX^base))   (mean-preserving: export CONCENTRATION)
%
% zeta=theta_X=1 recovers the real Chile calibration exactly. Unlike OF
% (which is a cost share, requiring ALPHA_i to absorb the change), KAPEX
% only enters the export-demand equation, not the cost side -- so no
% ALPHA adjustment is needed, only a call to the already-generalized
% soe_ss_solve_dense_exp.m for the new steady state.
%
% Designed to be called in ITS OWN fresh MATLAB process (crash isolation,
% same reasoning as run_sweep_point.m). Appends one row to
% results/export_<sweep_type>_sweep.csv.
%
% sweep_type: 'zeta' (export openness/level) or 'thetaX' (export concentration).
% grid_value: zeta or theta_X (numeric).
% regime: 'float'|'peg'|'managed'.
%
% Usage (from repo root, one call per point):
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); sweep_export_point('zeta', 1.5, 'float')"

addpath('C:\dynare\6.3\matlab');

master_files = struct('float', 'open_economy_network_chile_exp.mod', ...
                       'peg', 'open_economy_network_chile_exp_peg.mod', ...
                       'managed', 'open_economy_network_chile_exp_managed.mod');

KAPEX_base = [0.043259, 0.036848, 0.012612];   % Resource, Manuf., Services (real Chile calibration)
KAPEX_mean = mean(KAPEX_base);

switch sweep_type
    case 'zeta'
        zeta = grid_value;
        KAPEX_k = zeta * KAPEX_base;
    case 'thetaX'
        theta_X = grid_value;
        KAPEX_k = KAPEX_mean + theta_X * (KAPEX_base - KAPEX_mean);
    otherwise
        error('Unknown sweep_type %s', sweep_type);
end
if any(KAPEX_k <= 0)
    error('Infeasible KAPEX at grid_value=%.4f: KAPEX=[%.5f %.5f %.5f]', grid_value, KAPEX_k);
end

master_txt = fileread(master_files.(regime));
txt = master_txt;
txt = regexprep(txt, 'KAPEX1 = [\d.]+;[^\n]*', sprintf('KAPEX1 = %.6f;', KAPEX_k(1)));
txt = regexprep(txt, 'KAPEX2 = [\d.]+;[^\n]*', sprintf('KAPEX2 = %.6f;', KAPEX_k(2)));
txt = regexprep(txt, 'KAPEX3 = [\d.]+;[^\n]*', sprintf('KAPEX3 = %.6f;', KAPEX_k(3)));

tag = strrep(sprintf('%.4f', grid_value), '.', 'p');
fname = sprintf('oen_expsw_%s_%s_%s', sweep_type, tag, regime);
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

out_csv = fullfile('results', sprintf('export_%s_sweep.csv', sweep_type));
grid_col = 'zeta';
if strcmp(sweep_type, 'thetaX'); grid_col = 'theta_X'; end
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
