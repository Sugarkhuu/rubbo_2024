% Real sensitivity sweep: re-solve the managed-float regime for a grid of
% PHI_S values (0 = pure float limit, large = approaches a peg) and record
% welfare-relevant variances at each point. PHI_S does not enter the
% steady state at all (pure policy-response coefficient), so each point
% only requires re-solving the dynamics, not a fresh steady-state search.
% Run from repo root: addpath('C:\dynare\7.0\matlab'); addpath('code'); sweep_phi_s

phi_s_grid = [0.00, 0.10, 0.20, 0.30, 0.50, 0.75, 1.00, 1.50, 2.00];
moment_vars = {'piDC','PIC','y_gap','PI1','PI2','PI3','I','BSTAR'};

master_txt = fileread('open_economy_network_managed.mod');
rows = {};

for k = 1:numel(phi_s_grid)
    phi_s = phi_s_grid(k);
    txt = regexprep(master_txt, 'PHI_S\s*=\s*0\.30;', sprintf('PHI_S   = %.6f;', phi_s));
    fname = sprintf('open_economy_network_phis_%d', k);
    fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);
    eval(sprintf('dynare %s.mod', fname));

    row = struct('phi_s', phi_s);
    for v = 1:numel(moment_vars)
        row.(moment_vars{v}) = oo_.var(v, v);
    end
    rows{k} = row; %#ok<AGROW>
    fprintf('phi_s=%.2f  Var(piDC)=%.3e  Var(y_gap)=%.3e  Var(PI3)=%.3e\n', ...
        phi_s, row.piDC, row.y_gap, row.PI3);
end

fid = fopen(fullfile('results', 'phi_s_sweep.csv'), 'w');
fprintf(fid, 'phi_s,%s\n', strjoin(moment_vars, ','));
for k = 1:numel(rows)
    r = rows{k};
    vals = cellfun(@(v) sprintf('%.10g', r.(v)), moment_vars, 'UniformOutput', false);
    fprintf(fid, '%.6f,%s\n', r.phi_s, strjoin(vals, ','));
end
fclose(fid);
fprintf('Wrote results/phi_s_sweep.csv\n');
