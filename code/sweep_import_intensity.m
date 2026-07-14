% =========================================================================
% Structural generalization exercise #1: IMPORT INTENSITY LEVEL.
%
% Scales the whole import-cost-share vector OF = [OF1,OF2,OF3] by a common
% factor kappa, holding the RELATIVE sectoral pattern fixed (Resource
% still 6x more import-intensive than Services, etc.) and holding the
% domestic network (OH21, OH32) fixed. ALPHA_i absorbs the change so cost
% shares still sum to one: ALPHA_i(kappa) = 1 - OH_i(sum) - kappa*OF_i.
%
% Re-solves all three regimes (float/peg/managed) at each grid point and
% records total welfare loss (Rubbo Prop. 3 formula, same as
% code/analysis.py's compute_welfare). This is the cleanest test of "how
% does the optimal-regime ranking depend on how import-intensive
% production is" -- kappa=1 recovers the baseline calibration exactly.
%
% Run from the REPO ROOT:
%   >> addpath('C:\dynare\7.0\matlab'); addpath('code'); sweep_import_intensity
% =========================================================================

kappa_grid = [0.25, 0.50, 0.75, 1.00, 1.50, 2.00, 2.50];
regimes = {'float', 'peg', 'managed'};
master_files = struct('float', 'open_economy_network.mod', ...
                       'peg', 'open_economy_network_peg.mod', ...
                       'managed', 'open_economy_network_managed.mod');

OF_base = [0.30, 0.10, 0.05];      % Resource, Manuf., Services (baseline)
OH_sum  = [0.00, 0.20, 0.25];      % sector's total domestic-input cost share

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};

rows = {};
row_i = 0;

for k = 1:numel(kappa_grid)
    kappa = kappa_grid(k);
    OF_k = kappa * OF_base;
    ALPHA_k = 1 - OH_sum - OF_k;
    if any(ALPHA_k <= 0)
        fprintf('Skipping kappa=%.2f: ALPHA would be non-positive.\n', kappa);
        continue;
    end

    for r = 1:numel(regimes)
        regime = regimes{r};
        master_txt = fileread(master_files.(regime));

        txt = master_txt;
        txt = regexprep(txt, 'ALPHA1\s*=\s*[\d.]+;', sprintf('ALPHA1  = %.6f;', ALPHA_k(1)));
        txt = regexprep(txt, 'ALPHA2\s*=\s*[\d.]+;', sprintf('ALPHA2  = %.6f;', ALPHA_k(2)));
        txt = regexprep(txt, 'ALPHA3\s*=\s*[\d.]+;', sprintf('ALPHA3  = %.6f;', ALPHA_k(3)));
        txt = regexprep(txt, 'OF1\s*=\s*[\d.]+;', sprintf('OF1     = %.6f;', OF_k(1)));
        txt = regexprep(txt, 'OF2\s*=\s*[\d.]+;', sprintf('OF2     = %.6f;', OF_k(2)));
        txt = regexprep(txt, 'OF3\s*=\s*[\d.]+;', sprintf('OF3     = %.6f;', OF_k(3)));

        fname = sprintf('open_economy_network_impint_%d_%s', k, regime);
        fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

        fprintf('\n=== kappa=%.2f, regime=%s ===\n', kappa, regime);
        eval(sprintf('dynare %s.mod', fname));

        row_i = row_i + 1;
        row = struct('kappa', kappa, 'regime', regime);
        for v = 1:numel(moment_vars)
            row.(moment_vars{v}) = oo_.var(v, v);
        end
        rows{row_i} = row; %#ok<AGROW>
    end
end

fid = fopen(fullfile('results', 'import_intensity_sweep.csv'), 'w');
fprintf(fid, 'kappa,regime,%s\n', strjoin(moment_vars, ','));
for i = 1:numel(rows)
    r = rows{i};
    vals = cellfun(@(v) sprintf('%.10g', r.(v)), moment_vars, 'UniformOutput', false);
    fprintf(fid, '%.6f,%s,%s\n', r.kappa, r.regime, strjoin(vals, ','));
end
fclose(fid);
fprintf('\nWrote results/import_intensity_sweep.csv (%d rows)\n', numel(rows));
