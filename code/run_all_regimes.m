% =========================================================================
% Run the nonlinear open_economy_network.mod under all three FX regimes
% and export IRFs + steady-state/derived objects to CSV for the Python
% analysis code (code/analysis.py). Run this from Matlab/Octave with
% Dynare on the path, working directory = REPO ROOT (not code/):
%
%   >> addpath('code'); run_all_regimes
%
% Nothing here does any "analysis" -- it only runs Dynare three times
% (one per REGIME) and writes out the raw IRFs/parameters. Command-line
% macro quoting (-DREGIME="float") is fragile across Matlab/Octave/Windows,
% so instead we generate one temporary .mod file per regime with the
% @#define REGIME line substituted directly -- simple and portable.
% =========================================================================

regimes = {'float', 'peg', 'managed'};
modfile = 'open_economy_network';
shock_names = {'eps_a1','eps_a2','eps_a3','eps_pF','eps_D'};
report_vars = {'piDC','PIC','y_gap','PI1','PI2','PI3','S','I','BSTAR','GDP'};

out_dir = 'results';
if ~exist(out_dir, 'dir'); mkdir(out_dir); end

master_txt = fileread([modfile '.mod']);

all_irfs = struct();
all_params = struct();

for r = 1:numel(regimes)
    regime = regimes{r};
    fprintf('\n=== Running regime: %s ===\n', regime);

    regime_modfile = sprintf('%s_%s', modfile, regime);
    regime_txt = regexprep(master_txt, ...
        '@#define REGIME = "\w+"', ...
        sprintf('@#define REGIME = "%s"', regime));
    fid = fopen([regime_modfile '.mod'], 'w');
    fwrite(fid, regime_txt);
    fclose(fid);

    eval(sprintf('dynare %s.mod noclearall', regime_modfile));

    % --- collect IRFs: oo_.irfs.<var>_<shock> ------------------------------
    for v = 1:numel(report_vars)
        var = report_vars{v};
        for s = 1:numel(shock_names)
            shk = shock_names{s};
            fname = [var '_' shk];
            if isfield(oo_.irfs, fname)
                all_irfs.(regime).(fname) = oo_.irfs.(fname);
            end
        end
    end

    % --- collect key parameters / derived network objects -------------------
    par_names = {'LAMBDA_D1','LAMBDA_D2','LAMBDA_D3', ...
                 'MIMP1','MIMP2','MIMP3', ...
                 'DHAT1','DHAT2','DHAT3', ...
                 'WDC1','WDC2','WDC3'};
    for p = 1:numel(par_names)
        idx = strmatch(par_names{p}, M_.param_names, 'exact');
        all_params.(regime).(par_names{p}) = M_.params(idx);
    end

    % --- steady state levels, for welfare/moment post-processing ------------
    for v = 1:numel(M_.endo_names)
        vname = M_.endo_names{v};
        all_params.(regime).steady_state.(vname) = oo_.steady_state(v);
    end

    % --- second moments (order=2 stoch_simul reports oo_.var) --------------
    if isfield(oo_, 'var') && ~isempty(oo_.var)
        for v = 1:numel(report_vars)
            idx = strmatch(report_vars{v}, M_.endo_names, 'exact');
            if ~isempty(idx)
                all_params.(regime).variance.(report_vars{v}) = oo_.var(idx, idx);
            end
        end
    end
end

% --- write CSVs (one per regime, one per shock, columns = report_vars) -----
horizon = 40;
for r = 1:numel(regimes)
    regime = regimes{r};
    for s = 1:numel(shock_names)
        shk = shock_names{s};
        M = nan(horizon, numel(report_vars));
        any_data = false;
        for v = 1:numel(report_vars)
            fname = [report_vars{v} '_' shk];
            if isfield(all_irfs.(regime), fname)
                series = all_irfs.(regime).(fname);
                M(1:numel(series), v) = series(:);
                any_data = true;
            end
        end
        if any_data
            fpath = fullfile(out_dir, sprintf('irf_%s_%s.csv', regime, shk));
            fid = fopen(fpath, 'w');
            fprintf(fid, '%s\n', strjoin(report_vars, ','));
            fclose(fid);
            dlmwrite(fpath, M, '-append');
        end
    end
end

% --- write derived network / calibration objects (same across regimes,
%     but saved once for convenience) ---------------------------------------
fid = fopen(fullfile(out_dir, 'network_objects.csv'), 'w');
fprintf(fid, 'object,sector1,sector2,sector3\n');
fprintf(fid, 'lambda_D,%.6f,%.6f,%.6f\n', all_params.float.LAMBDA_D1, all_params.float.LAMBDA_D2, all_params.float.LAMBDA_D3);
fprintf(fid, 'import_centrality,%.6f,%.6f,%.6f\n', all_params.float.MIMP1, all_params.float.MIMP2, all_params.float.MIMP3);
fprintf(fid, 'dhat,%.6f,%.6f,%.6f\n', all_params.float.DHAT1, all_params.float.DHAT2, all_params.float.DHAT3);
fprintf(fid, 'w_dc,%.6f,%.6f,%.6f\n', all_params.float.WDC1, all_params.float.WDC2, all_params.float.WDC3);
fclose(fid);

% --- scalar parameters needed for the welfare formula (Rubbo Prop. 3) ------
scalar_names = {'BETA','GAMMA','VARPHI','EPS'};
fid = fopen(fullfile(out_dir, 'params.csv'), 'w');
fprintf(fid, 'name,value\n');
for p = 1:numel(scalar_names)
    idx = strmatch(scalar_names{p}, M_.param_names, 'exact');
    fprintf(fid, '%s,%.10g\n', scalar_names{p}, M_.params(idx));
end
fclose(fid);

% --- write variances (order-2 unconditional variances, per regime) ---------
fid = fopen(fullfile(out_dir, 'variances.csv'), 'w');
fprintf(fid, 'regime,%s\n', strjoin(report_vars, ','));
for r = 1:numel(regimes)
    regime = regimes{r};
    row = cell(1, numel(report_vars));
    for v = 1:numel(report_vars)
        var = report_vars{v};
        if isfield(all_params.(regime), 'variance') && isfield(all_params.(regime).variance, var)
            row{v} = sprintf('%.10g', all_params.(regime).variance.(var));
        else
            row{v} = 'NaN';
        end
    end
    fprintf(fid, '%s,%s\n', regime, strjoin(row, ','));
end
fclose(fid);

save(fullfile(out_dir, 'all_results.mat'), 'all_irfs', 'all_params', 'report_vars', 'shock_names', 'regimes');

fprintf('\nDone. Results written to %s\n', out_dir);
fprintf('  irf_<regime>_<shock>.csv  (IRFs, %d vars x %d periods)\n', numel(report_vars), horizon);
fprintf('  network_objects.csv       (lambda_D, import centrality, dhat, w_DC)\n');
fprintf('  variances.csv             (order-2 unconditional variances by regime)\n');
fprintf('  all_results.mat           (everything, for further Matlab post-processing)\n');
