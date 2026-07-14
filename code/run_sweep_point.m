function run_sweep_point(sweep_type, grid_value, regime)
global oo_
% One (grid_value, regime) point of a structural-generalization sweep.
% Designed to be called in ITS OWN fresh MATLAB process (see
% code/drive_sweeps.sh) so that a Dynare/MEX crash on one point never
% takes down the whole sweep and never loses already-computed rows --
% each call appends exactly one row to results/<sweep_type>_sweep.csv.
%
% sweep_type: 'impint' (import-intensity level) or 'ofhet' (import-
%             exposure heterogeneity). grid_value: kappa or theta
%             (numeric). regime: 'float'|'peg'|'managed'.
%
% Usage (from repo root, one call per point):
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); run_sweep_point('impint', 0.25, 'float')"

addpath('C:\dynare\6.3\matlab');

master_files = struct('float', 'open_economy_network.mod', ...
                       'peg', 'open_economy_network_peg.mod', ...
                       'managed', 'open_economy_network_managed.mod');

OF_base = [0.30, 0.10, 0.05];
OH_sum  = [0.00, 0.20, 0.25];

switch sweep_type
    case 'impint'
        kappa = grid_value;
        OF_k = kappa * OF_base;
    case 'ofhet'
        theta = grid_value;
        OF_mean = mean(OF_base);
        OF_k = OF_mean + theta * (OF_base - OF_mean);
    otherwise
        error('Unknown sweep_type %s', sweep_type);
end
ALPHA_k = 1 - OH_sum - OF_k;
if any(ALPHA_k <= 0) || any(OF_k < 0)
    error('Infeasible shares at grid_value=%.4f: ALPHA=[%.3f %.3f %.3f] OF=[%.3f %.3f %.3f]', ...
        grid_value, ALPHA_k, OF_k);
end

master_txt = fileread(master_files.(regime));
txt = master_txt;
txt = regexprep(txt, 'ALPHA1\s*=\s*[\d.]+;', sprintf('ALPHA1  = %.6f;', ALPHA_k(1)));
txt = regexprep(txt, 'ALPHA2\s*=\s*[\d.]+;', sprintf('ALPHA2  = %.6f;', ALPHA_k(2)));
txt = regexprep(txt, 'ALPHA3\s*=\s*[\d.]+;', sprintf('ALPHA3  = %.6f;', ALPHA_k(3)));
txt = regexprep(txt, 'OF1\s*=\s*[\d.]+;', sprintf('OF1     = %.6f;', OF_k(1)));
txt = regexprep(txt, 'OF2\s*=\s*[\d.]+;', sprintf('OF2     = %.6f;', OF_k(2)));
txt = regexprep(txt, 'OF3\s*=\s*[\d.]+;', sprintf('OF3     = %.6f;', OF_k(3)));

tag = strrep(sprintf('%.4f', grid_value), '.', 'p');
fname = sprintf('oen_%s_%s_%s', sweep_type, tag, regime);
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

out_csv = fullfile('results', sprintf('%s_sweep.csv', sweep_type));
grid_col = 'kappa'; if strcmp(sweep_type, 'ofhet'); grid_col = 'theta'; end
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
