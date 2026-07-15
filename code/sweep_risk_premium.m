% =========================================================================
% Stress test: SIZE OF THE RISK-PREMIUM / UIP SHOCK.
%
% The headline result (adding eps_rp reverses the regime ranking, Peg goes
% from second-best to far worst) rests on ONE calibration choice: eps_rp's
% standard deviation is set equal to every other shock's (0.01), with no
% independent discipline (no target moment, no external estimate). This
% sweep scales sd(eps_rp) by a multiplier `scale` while holding RHO_RP
% (=0.80, persistence) and every other shock fixed, to see how much of the
% risk-premium shock's size is actually needed to flip the ranking.
%
% scale=0    -> eps_rp shock off entirely (isolates the other 6 shocks'
%               ranking, i.e. what the deck showed before eps_rp existed).
% scale=1    -> baseline calibration (sd=0.01, same as every other shock).
%
% Re-solves all three regimes at each grid point and records total welfare
% loss (Rubbo Prop. 3 formula, same as code/analysis.py's compute_welfare).
%
% Run from the REPO ROOT:
%   >> addpath('C:\dynare\7.0\matlab'); addpath('code'); sweep_risk_premium
% =========================================================================

scale_grid = [0.00, 0.25, 0.50, 0.75, 1.00, 1.25, 1.50, 2.00];
regimes = {'float', 'peg', 'managed'};
master_files = struct('float', 'open_economy_network.mod', ...
                       'peg', 'open_economy_network_peg.mod', ...
                       'managed', 'open_economy_network_managed.mod');

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};

rows = {};
row_i = 0;

for k = 1:numel(scale_grid)
    scale = scale_grid(k);
    sd_rp = scale * 0.01;

    for r = 1:numel(regimes)
        regime = regimes{r};
        master_txt = fileread(master_files.(regime));

        txt = master_txt;
        txt = regexprep(txt, 'var eps_rp\s*=\s*[\d.]+\^2;', sprintf('var eps_rp  = %.8f^2;', sd_rp));

        fname = sprintf('open_economy_network_rp_%d_%s', k, regime);
        fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

        fprintf('\n=== rp_scale=%.2f (sd=%.4f), regime=%s ===\n', scale, sd_rp, regime);
        eval(sprintf('dynare %s.mod', fname));

        row_i = row_i + 1;
        row = struct('rp_scale', scale, 'regime', regime);
        for v = 1:numel(moment_vars)
            row.(moment_vars{v}) = oo_.var(v, v);
        end
        rows{row_i} = row; %#ok<AGROW>
    end
end

fid = fopen(fullfile('results', 'risk_premium_sweep.csv'), 'w');
fprintf(fid, 'rp_scale,regime,%s\n', strjoin(moment_vars, ','));
for i = 1:numel(rows)
    r = rows{i};
    vals = cellfun(@(v) sprintf('%.10g', r.(v)), moment_vars, 'UniformOutput', false);
    fprintf(fid, '%.6f,%s,%s\n', r.rp_scale, r.regime, strjoin(vals, ','));
end
fclose(fid);
fprintf('\nWrote results/risk_premium_sweep.csv (%d rows)\n', numel(rows));
