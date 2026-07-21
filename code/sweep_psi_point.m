function sweep_psi_point(psi_value, regime)
global oo_ M_
% One (psi_value, regime) point of the risk-premium/UIP closing-device
% robustness sweep (TASK #3, todo_three_exercises.txt), run on the REAL
% Chile calibration (open_economy_network_chile*.mod), not the stylized
% network. PSI (the debt-elastic risk-premium coefficient, Schmitt-Grohe-
% Uribe 2003 style) enters ONLY the UIP condition
%   I = ISTAR*(1 - PSI*(BSTAR - BSTARBAR)) * RP * S(+1)/S
% and never the steady state, so no steady-state re-derivation is needed
% -- this is the cheapest of the three sweeps.
%
% Designed to be called in ITS OWN fresh MATLAB process (mirrors
% code/run_sweep_point.m) so a Dynare/MEX crash on one point never loses
% already-computed rows. Appends one row each to
% results/psi_sweep_variances.csv and results/psi_sweep_vardec.csv.
%
% Usage (from repo root, one call per point):
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); sweep_psi_point(0.02, 'float')"

addpath('C:\dynare\6.3\matlab');

master_files = struct('float', 'open_economy_network_chile.mod', ...
                       'peg', 'open_economy_network_chile_peg.mod', ...
                       'managed', 'open_economy_network_chile_managed.mod');

master_txt = fileread(master_files.(regime));
txt = regexprep(master_txt, 'PSI\s*=\s*[\d.]+;', sprintf('PSI        = %.8f;', psi_value));

tag = strrep(sprintf('%.4f', psi_value), '.', 'p');
fname = sprintf('oen_psi_%s_%s', tag, regime);
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
shock_names = {'eps_a1','eps_a2','eps_a3','eps_pF','eps_D','eps_pX','eps_rp'};

vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

out_var_csv = fullfile('results', 'psi_sweep_variances.csv');
if ~exist(out_var_csv, 'file')
    fid = fopen(out_var_csv, 'w');
    fprintf(fid, 'psi,regime,%s\n', strjoin(moment_vars, ','));
    fclose(fid);
end
fid = fopen(out_var_csv, 'a');
fprintf(fid, '%.8f,%s,%s\n', psi_value, regime, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
fclose(fid);

exo_idx = zeros(1, numel(shock_names));
for s = 1:numel(shock_names)
    exo_idx(s) = find(strcmp(M_.exo_names, shock_names{s}));
end
vardec = oo_.variance_decomposition(:, exo_idx);   % rows=moment_vars order, cols=shock_names order

out_vardec_csv = fullfile('results', 'psi_sweep_vardec.csv');
if ~exist(out_vardec_csv, 'file')
    fid = fopen(out_vardec_csv, 'w');
    fprintf(fid, 'psi,regime,variable,%s\n', strjoin(shock_names, ','));
    fclose(fid);
end
fid = fopen(out_vardec_csv, 'a');
for v = 1:numel(moment_vars)
    row = sprintf('%.10g,', vardec(v, :));
    row(end) = [];
    fprintf(fid, '%.8f,%s,%s,%s\n', psi_value, regime, moment_vars{v}, row);
end
fclose(fid);

fprintf('OK: psi=%.4f regime=%s appended to %s and %s\n', psi_value, regime, out_var_csv, out_vardec_csv);
end
