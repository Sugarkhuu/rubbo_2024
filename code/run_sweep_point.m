function run_sweep_point(sweep_type, grid_value, regime)
global oo_
% One (grid_value, regime) point of a structural-generalization sweep.
% Designed to be called in ITS OWN fresh MATLAB process (see
% code/drive_sweeps.sh) so that a Dynare/MEX crash on one point never
% takes down the whole sweep and never loses already-computed rows --
% each call appends exactly one row to results/<sweep_type>_sweep.csv.
%
% sweep_type: 'impint' (import-intensity level), 'ofhet' (import-exposure
%             heterogeneity), 'netdens' (domestic production-network
%             density -- scales OH21/OH32 by rho, holding import exposure
%             OF fixed, so it isolates the pure network-linkage channel;
%             rho=0 is the no-domestic-network counterfactual, rho=1 is
%             the baseline calibration), or 'bhhet' (export/consumption
%             weight BH1/BH2/BH3 heterogeneity -- the demand-side analogue
%             of ofhet: BH_i governs both a sector's domestic-consumption
%             weight and its export weight identically in this model
%             (Y_i includes BH_i*PH*CH/P_i AND BH_i*PH*EX/P_i with the
%             SAME BH_i), so spreading BH_i away from uniform is the
%             cleanest way to isolate how concentrated
%             export/final-demand exposure -- and the indirect demand
%             an upstream sector inherits from a heavily-exporting
%             downstream customer via OH21/OH32 -- shapes regime
%             preference. Holds OH21/OH32/OF fixed at baseline so it does
%             NOT double up with the netdens sweep.
% grid_value: kappa, theta (ofhet), rho, or theta (bhhet) (numeric).
% regime: 'float'|'peg'|'managed'.
%
% Usage (from repo root, one call per point):
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); run_sweep_point('netdens', 0, 'float')"

addpath('C:\dynare\6.3\matlab');

master_files = struct('float', 'open_economy_network.mod', ...
                       'peg', 'open_economy_network_peg.mod', ...
                       'managed', 'open_economy_network_managed.mod');

OF_base = [0.30, 0.10, 0.05];
OH_sum  = [0.00, 0.20, 0.25];
OH21_base = 0.20;
OH32_base = 0.25;
BH_base = [0.05, 0.15, 0.80];
BH_k = BH_base;

switch sweep_type
    case 'impint'
        kappa = grid_value;
        OF_k = kappa * OF_base;
        OH21_k = OH21_base; OH32_k = OH32_base;
    case 'ofhet'
        theta = grid_value;
        OF_mean = mean(OF_base);
        OF_k = OF_mean + theta * (OF_base - OF_mean);
        OH21_k = OH21_base; OH32_k = OH32_base;
    case 'netdens'
        rho = grid_value;
        OF_k = OF_base;
        OH21_k = rho * OH21_base;
        OH32_k = rho * OH32_base;
        OH_sum = [0.00, OH21_k, OH32_k];
    case 'bhhet'
        theta = grid_value;
        OF_k = OF_base;
        OH21_k = OH21_base; OH32_k = OH32_base;
        BH_mean = mean(BH_base);
        BH_k = BH_mean + theta * (BH_base - BH_mean);
    otherwise
        error('Unknown sweep_type %s', sweep_type);
end
ALPHA_k = 1 - OH_sum - OF_k;
if any(ALPHA_k <= 0) || any(OF_k < 0) || any(BH_k <= 0)
    error('Infeasible shares at grid_value=%.4f: ALPHA=[%.3f %.3f %.3f] OF=[%.3f %.3f %.3f] BH=[%.3f %.3f %.3f]', ...
        grid_value, ALPHA_k, OF_k, BH_k);
end

master_txt = fileread(master_files.(regime));
txt = master_txt;
txt = regexprep(txt, 'ALPHA1\s*=\s*[\d.]+;', sprintf('ALPHA1  = %.6f;', ALPHA_k(1)));
txt = regexprep(txt, 'ALPHA2\s*=\s*[\d.]+;', sprintf('ALPHA2  = %.6f;', ALPHA_k(2)));
txt = regexprep(txt, 'ALPHA3\s*=\s*[\d.]+;', sprintf('ALPHA3  = %.6f;', ALPHA_k(3)));
txt = regexprep(txt, 'OF1\s*=\s*[\d.]+;', sprintf('OF1     = %.6f;', OF_k(1)));
txt = regexprep(txt, 'OF2\s*=\s*[\d.]+;', sprintf('OF2     = %.6f;', OF_k(2)));
txt = regexprep(txt, 'OF3\s*=\s*[\d.]+;', sprintf('OF3     = %.6f;', OF_k(3)));
txt = regexprep(txt, 'OH21\s*=\s*[\d.]+;', sprintf('OH21    = %.6f;', OH21_k));
txt = regexprep(txt, 'OH32\s*=\s*[\d.]+;', sprintf('OH32    = %.6f;', OH32_k));
txt = regexprep(txt, 'BH1\s*=\s*[\d.]+;', sprintf('BH1     = %.6f;', BH_k(1)));
txt = regexprep(txt, 'BH2\s*=\s*[\d.]+;', sprintf('BH2     = %.6f;', BH_k(2)));
txt = regexprep(txt, 'BH3\s*=\s*[\d.]+;', sprintf('BH3     = %.6f;', BH_k(3)));

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
grid_col = 'kappa';
if strcmp(sweep_type, 'ofhet'); grid_col = 'theta'; end
if strcmp(sweep_type, 'netdens'); grid_col = 'rho'; end
if strcmp(sweep_type, 'bhhet'); grid_col = 'theta'; end
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
