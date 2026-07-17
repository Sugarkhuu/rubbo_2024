% =========================================================================
% ORDER=1 comparison run, same simulation methodology and sample length as
% run_order2.m (periods=260000, drop=10000, same default Dynare RNG seed),
% so the order2-vs-order1sim gap isolates the genuine second-order effect
% net of Monte Carlo sampling noise (rather than comparing order-2 sim
% moments against the OLD order=1 ANALYTIC variances, which used a
% different estimator entirely).
% =========================================================================

regimes  = {'float','peg','managed'};
modfiles = struct('float','chile_float_o1sim', ...
                   'peg','chile_peg_o1sim', ...
                   'managed','chile_managed_o1sim');

log_vars = {'PI1','PI2','PI3','I','PIC'};
raw_vars = {'piDC','y_gap','BSTAR'};

out_dir = 'results_order2';
if ~exist(out_dir,'dir'); mkdir(out_dir); end

welfare_rows = {};

for r = 1:numel(regimes)
    regime = regimes{r};
    fprintf('\n=== ORDER=1 SIM (comparison): regime %s ===\n', regime);
    eval(sprintf('dynare %s.mod', modfiles.(regime)));

    mrow = struct('regime', regime);
    for v = 1:numel(log_vars)
        vn = log_vars{v};
        idx = strcmp(M_.endo_names, vn);
        series = log(oo_.endo_simul(idx, :));
        mrow.([vn '_meansq']) = mean(series.^2);
    end
    for v = 1:numel(raw_vars)
        vn = raw_vars{v};
        idx = strcmp(M_.endo_names, vn);
        series = oo_.endo_simul(idx, :);
        mrow.([vn '_meansq']) = mean(series.^2);
    end

    p = @(name) M_.params(strcmp(M_.param_names, name));
    gamma_phi = p('GAMMA') + p('VARPHI');
    lam  = [p('LAMBDA_D1'), p('LAMBDA_D2'), p('LAMBDA_D3')];
    dhat = [p('DHAT1'), p('DHAT2'), p('DHAT3')];
    eps_ = p('EPS');
    kappa = lam .* eps_ .* (1 - dhat) ./ dhat;

    Ey2 = mrow.y_gap_meansq;
    Epi2 = [mrow.PI1_meansq, mrow.PI2_meansq, mrow.PI3_meansq];

    w_output = 0.5 * gamma_phi * Ey2;
    w_pi = 0.5 * kappa .* Epi2;

    welfare_rows{end+1} = struct('regime', regime, ...
        'output_gap', w_output, 'price_disp_total', sum(w_pi), ...
        'total', w_output + sum(w_pi)); %#ok<AGROW>
end

fid = fopen(fullfile(out_dir,'welfare_order1sim.csv'),'w');
fprintf(fid, 'regime,output_gap,price_disp_total,total\n');
for r = 1:numel(welfare_rows)
    w = welfare_rows{r};
    fprintf(fid, '%s,%.10g,%.10g,%.10g\n', w.regime, w.output_gap, w.price_disp_total, w.total);
end
fclose(fid);

fprintf('\nDone. Wrote welfare_order1sim.csv to %s\n', out_dir);
