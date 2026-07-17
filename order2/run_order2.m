% =========================================================================
% Second-order (pruned) welfare run for the Chile-calibrated SOE model.
% Runs the 3 regimes at order=2 with Kim-Kim-Schaumburg pruning, long
% simulation (periods=260000, drop=10000), and computes the genuinely
% second-order-accurate welfare loss
%
%   W = 0.5*(gamma+varphi)*E[y_gap^2] + sum_i kappa_i * E[log(PI_i)^2]
%
% using E[X^2] = the raw second moment about ZERO from the simulated
% path (mean(X.^2)), NOT Var(X) -- Rubbo's LQ loss penalizes squared
% deviation from the efficient (zero) point, so any risk-adjusted/
% precautionary shift in E[X] away from zero (which a first-order
% solution cannot see, since first-order dynamics are certainty-
% equivalent and always deliver E[X]=0) shows up here as an extra
% E[X]^2 term on top of Var(X). That extra term is exactly the new
% object a genuine second-order solution adds relative to Rubbo's
% baseline (variance-only, first-order-dynamics) welfare number.
%
% PI1-3, PIC, I are gross rates (~1 in levels) -- log() them first so
% "squared deviation from efficient" means squared LOG deviation from
% zero, consistent with pi_it in the LQ formula. y_gap, BSTAR, piDC are
% already log/ratio deviations, used raw. S (log exchange rate LEVEL)
% is dropped from the float regime's moments: it has a genuine unit
% root there (no price-level/FX anchor in the Taylor rule -- see the
% note at the top of open_economy_network.mod), so its "mean" over any
% finite simulation window is a random-walk realization, not an
% estimate of anything stationary.
%
% Run from repo root:
%   >> addpath('C:\dynare\7.0\matlab'); addpath(pwd); run('order2/run_order2.m')
% =========================================================================

regimes  = {'float','peg','managed'};
modfiles = struct('float','open_economy_network_chile_o2', ...
                   'peg','open_economy_network_chile_peg_o2', ...
                   'managed','open_economy_network_chile_managed_o2');

log_vars = {'PI1','PI2','PI3','I','PIC'};   % gross rates -> log before squaring
raw_vars = {'piDC','y_gap','BSTAR'};        % already log/ratio deviations

out_dir = 'results_order2';
if ~exist(out_dir,'dir'); mkdir(out_dir); end

welfare_rows = {};
moment_rows  = {};

for r = 1:numel(regimes)
    regime = regimes{r};
    fprintf('\n=== ORDER=2 PRUNED SIM: regime %s ===\n', regime);
    eval(sprintf('dynare %s.mod', modfiles.(regime)));

    mrow = struct('regime', regime);
    for v = 1:numel(log_vars)
        vn = log_vars{v};
        idx = strcmp(M_.endo_names, vn);
        series = log(oo_.endo_simul(idx, :));
        mrow.([vn '_mean']) = mean(series);
        mrow.([vn '_meansq']) = mean(series.^2);
    end
    for v = 1:numel(raw_vars)
        vn = raw_vars{v};
        idx = strcmp(M_.endo_names, vn);
        series = oo_.endo_simul(idx, :);
        mrow.([vn '_mean']) = mean(series);
        mrow.([vn '_meansq']) = mean(series.^2);
    end
    moment_rows{end+1} = mrow; %#ok<AGROW>

    % ---- welfare (needs LAMBDA_D, DHAT, EPS, GAMMA, VARPHI from M_.params)
    p = @(name) M_.params(strcmp(M_.param_names, name));
    gamma_phi = p('GAMMA') + p('VARPHI');
    lam  = [p('LAMBDA_D1'), p('LAMBDA_D2'), p('LAMBDA_D3')];
    dhat = [p('DHAT1'), p('DHAT2'), p('DHAT3')];
    eps_ = p('EPS');
    kappa = lam .* eps_ .* (1 - dhat) ./ dhat;

    Ey2 = mrow.y_gap_meansq;
    Epi2 = [mrow.PI1_meansq, mrow.PI2_meansq, mrow.PI3_meansq];

    w_output = 0.5 * gamma_phi * Ey2;
    % compute_welfare() (analysis.py) uses w_pi_by_sector = 0.5*disp_weight*var_pi,
    % i.e. kappa excludes the 0.5 -- match that convention here:
    w_pi = 0.5 * kappa .* Epi2;

    welfare_rows{end+1} = struct('regime', regime, ...
        'output_gap', w_output, ...
        'price_disp_1', w_pi(1), 'price_disp_2', w_pi(2), 'price_disp_3', w_pi(3), ...
        'price_disp_total', sum(w_pi), ...
        'total', w_output + sum(w_pi)); %#ok<AGROW>
end

% ---- write welfare CSV ----------------------------------------------
fid = fopen(fullfile(out_dir,'welfare_order2.csv'),'w');
fprintf(fid, 'regime,output_gap,price_disp_1,price_disp_2,price_disp_3,price_disp_total,total\n');
for r = 1:numel(welfare_rows)
    w = welfare_rows{r};
    fprintf(fid, '%s,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g\n', w.regime, w.output_gap, ...
        w.price_disp_1, w.price_disp_2, w.price_disp_3, w.price_disp_total, w.total);
end
fclose(fid);

% ---- write raw moments CSV (for the risk-adjusted-mean writeup) -----
mnames = fieldnames(moment_rows{1});
fid = fopen(fullfile(out_dir,'moments_order2.csv'),'w');
fprintf(fid, '%s\n', strjoin(mnames, ','));
for r = 1:numel(moment_rows)
    row = moment_rows{r};
    vals = cellfun(@(f) num2str_field(row.(f)), mnames, 'UniformOutput', false);
    fprintf(fid, '%s\n', strjoin(vals, ','));
end
fclose(fid);

fprintf('\nDone. Wrote welfare_order2.csv and moments_order2.csv to %s\n', out_dir);

function s = num2str_field(x)
    if ischar(x)
        s = x;
    else
        s = sprintf('%.10g', x);
    end
end
