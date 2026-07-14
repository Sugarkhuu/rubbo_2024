% =========================================================================
% Structural generalization exercise #2: IMPORT-EXPOSURE HETEROGENEITY.
%
% Holds TOTAL import intensity fixed (sum OF_i = 0.45, same as baseline)
% but varies how UNEVENLY that exposure is spread across sectors:
%   OF_i(theta) = OF_mean + theta*(OF_i_base - OF_mean)
% theta=0 -> uniform exposure (Resource = Manuf. = Services = 0.15);
% theta=1 -> baseline calibration (0.30/0.10/0.05); theta>1 extrapolates
% to MORE uneven than baseline. ALPHA_i absorbs the change so cost shares
% still sum to one, exactly as in sweep_import_intensity.m.
%
% This is the direct quantitative test of the paper's own Theory-section
% result: the DC index breaks down under a float because the FX cost-push
% vector Gamma is not proportional to labor intensity B once import
% exposure is unevenly distributed across the network. theta indexes how
% far the calibration is from the knife-edge case (theta=0 is the closest
% feasible approximation here -- uniform Omega^F is a necessary but not
% sufficient condition for Gamma proportional to B in general, since OH21/
% OH32 still differ across sectors; treat theta as an economically
% meaningful dispersion index, not an exact distance to the knife edge).
%
% Run from the REPO ROOT:
%   >> addpath('C:\dynare\7.0\matlab'); addpath('code'); sweep_import_heterogeneity
% =========================================================================

theta_grid = [0.00, 0.25, 0.50, 0.75, 1.00, 1.25, 1.50];
regimes = {'float', 'peg', 'managed'};
master_files = struct('float', 'open_economy_network.mod', ...
                       'peg', 'open_economy_network_peg.mod', ...
                       'managed', 'open_economy_network_managed.mod');

OF_base = [0.30, 0.10, 0.05];
OF_mean = mean(OF_base);
OH_sum  = [0.00, 0.20, 0.25];

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};

rows = {};
row_i = 0;

for k = 1:numel(theta_grid)
    theta = theta_grid(k);
    OF_k = OF_mean + theta * (OF_base - OF_mean);
    ALPHA_k = 1 - OH_sum - OF_k;
    if any(ALPHA_k <= 0) || any(OF_k < 0)
        fprintf('Skipping theta=%.2f: infeasible shares.\n', theta);
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

        fname = sprintf('open_economy_network_ofhet_%d_%s', k, regime);
        fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

        fprintf('\n=== theta=%.2f, regime=%s ===\n', theta, regime);
        eval(sprintf('dynare %s.mod', fname));

        row_i = row_i + 1;
        row = struct('theta', theta, 'regime', regime);
        for v = 1:numel(moment_vars)
            row.(moment_vars{v}) = oo_.var(v, v);
        end
        rows{row_i} = row; %#ok<AGROW>
    end
end

fid = fopen(fullfile('results', 'import_heterogeneity_sweep.csv'), 'w');
fprintf(fid, 'theta,regime,%s\n', strjoin(moment_vars, ','));
for i = 1:numel(rows)
    r = rows{i};
    vals = cellfun(@(v) sprintf('%.10g', r.(v)), moment_vars, 'UniformOutput', false);
    fprintf(fid, '%.6f,%s,%s\n', r.theta, r.regime, strjoin(vals, ','));
end
fclose(fid);
fprintf('\nWrote results/import_heterogeneity_sweep.csv (%d rows)\n', numel(rows));
