% =========================================================================
% Run the DENSE-Omega^H, Czechia-data-calibrated nonlinear model
% (open_economy_network_czechia*.mod) under all three FX regimes and export
% IRFs, theoretical variances, and derived network objects to
% results_czechia/*.csv -- mirrors code/run_all_regimes.m exactly, just
% pointed at the Czechia-calibrated .mod files and a separate output folder
% so the original (stylized-calibration) results/ is untouched.
%
% Run from the REPO ROOT (not code/):
%   >> addpath('C:\dynare\6.3\matlab'); addpath('code'); run_czechia_regimes
% =========================================================================

regimes = {'float', 'peg', 'managed'};
modfiles = struct('float', 'open_economy_network_czechia', ...
                   'peg', 'open_economy_network_czechia_peg', ...
                   'managed', 'open_economy_network_czechia_managed');
shock_names = {'eps_a1','eps_a2','eps_a3','eps_pF','eps_D','eps_pX','eps_rp'};
moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
irf_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','S','I','BSTAR','GDP','EX','IM','C','P1','P2','P3','PX','RP','A1','A2','A3','PF','DSTAR'};

out_dir = 'results_czechia';
if ~exist(out_dir, 'dir'); mkdir(out_dir); end

all_irfs = struct();
all_var = struct();
all_vardec = struct();
all_params = struct();

for r = 1:numel(regimes)
    regime = regimes{r};
    fprintf('\n=== Running regime: %s ===\n', regime);
    eval(sprintf('dynare %s.mod', modfiles.(regime)));

    for v = 1:numel(irf_vars)
        var = irf_vars{v};
        for s = 1:numel(shock_names)
            shk = shock_names{s};
            fname = [var '_' shk];
            if isfield(oo_.irfs, fname)
                all_irfs.(regime).(fname) = oo_.irfs.(fname);
            end
        end
    end

    for v = 1:numel(moment_vars)
        all_var.(regime).(moment_vars{v}) = oo_.var(v, v);
    end

    exo_idx = zeros(1, numel(shock_names));
    for s = 1:numel(shock_names)
        exo_idx(s) = find(strcmp(M_.exo_names, shock_names{s}));
    end
    all_vardec.(regime) = oo_.variance_decomposition(:, exo_idx);

    par_names = {'LAMBDA_D1','LAMBDA_D2','LAMBDA_D3','MIMP1','MIMP2','MIMP3', ...
                 'DHAT1','DHAT2','DHAT3','WDC1','WDC2','WDC3','BETA','GAMMA','VARPHI','EPS'};
    for p = 1:numel(par_names)
        idx = strcmp(M_.param_names, par_names{p});
        all_params.(regime).(par_names{p}) = M_.params(idx);
    end
end

% ---- write IRF CSVs ------------------------------------------------------
horizon = 40;
for r = 1:numel(regimes)
    regime = regimes{r};
    for s = 1:numel(shock_names)
        shk = shock_names{s};
        M = nan(horizon, numel(irf_vars));
        any_data = false;
        for v = 1:numel(irf_vars)
            fname = [irf_vars{v} '_' shk];
            if isfield(all_irfs.(regime), fname)
                series = all_irfs.(regime).(fname);
                M(1:numel(series), v) = series(:);
                any_data = true;
            end
        end
        if any_data
            fpath = fullfile(out_dir, sprintf('irf_%s_%s.csv', regime, shk));
            fid = fopen(fpath, 'w');
            fprintf(fid, '%s\n', strjoin(irf_vars, ','));
            fclose(fid);
            dlmwrite(fpath, M, '-append');
        end
    end
end

% ---- write variances.csv --------------------------------------------------
fid = fopen(fullfile(out_dir, 'variances.csv'), 'w');
fprintf(fid, 'regime,%s\n', strjoin(moment_vars, ','));
for r = 1:numel(regimes)
    regime = regimes{r};
    row = cell(1, numel(moment_vars));
    for v = 1:numel(moment_vars)
        if isfield(all_var.(regime), moment_vars{v})
            row{v} = sprintf('%.10g', all_var.(regime).(moment_vars{v}));
        else
            row{v} = 'NaN';
        end
    end
    fprintf(fid, '%s,%s\n', regime, strjoin(row, ','));
end
fclose(fid);

% ---- write variance_decomposition.csv -------------------------------------
fid = fopen(fullfile(out_dir, 'variance_decomposition.csv'), 'w');
fprintf(fid, 'regime,variable,%s\n', strjoin(shock_names, ','));
for r = 1:numel(regimes)
    regime = regimes{r};
    for v = 1:numel(moment_vars)
        row = sprintf('%.10g,', all_vardec.(regime)(v, :));
        row(end) = [];
        fprintf(fid, '%s,%s,%s\n', regime, moment_vars{v}, row);
    end
end
fclose(fid);

% ---- write network_objects.csv (identical across regimes, from float) ----
fid = fopen(fullfile(out_dir, 'network_objects.csv'), 'w');
fprintf(fid, 'object,sector1,sector2,sector3\n');
fprintf(fid, 'lambda_D,%.6f,%.6f,%.6f\n', all_params.float.LAMBDA_D1, all_params.float.LAMBDA_D2, all_params.float.LAMBDA_D3);
fprintf(fid, 'import_centrality,%.6f,%.6f,%.6f\n', all_params.float.MIMP1, all_params.float.MIMP2, all_params.float.MIMP3);
fprintf(fid, 'dhat,%.6f,%.6f,%.6f\n', all_params.float.DHAT1, all_params.float.DHAT2, all_params.float.DHAT3);
fprintf(fid, 'w_dc,%.6f,%.6f,%.6f\n', all_params.float.WDC1, all_params.float.WDC2, all_params.float.WDC3);
fclose(fid);

fid = fopen(fullfile(out_dir, 'params.csv'), 'w');
fprintf(fid, 'name,value\n');
fprintf(fid, 'BETA,%.10g\n', all_params.float.BETA);
fprintf(fid, 'GAMMA,%.10g\n', all_params.float.GAMMA);
fprintf(fid, 'VARPHI,%.10g\n', all_params.float.VARPHI);
fprintf(fid, 'EPS,%.10g\n', all_params.float.EPS);
fclose(fid);

save(fullfile(out_dir, 'all_results.mat'), 'all_irfs', 'all_var', 'all_vardec', 'all_params', 'moment_vars', 'irf_vars', 'shock_names', 'regimes');

fprintf('\nDone. Results written to %s\n', out_dir);
