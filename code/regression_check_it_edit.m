% Regression check (Tier 3 prep, robustness-campaign plan): confirm the
% cpi_it/ppi_it @#elseif branches added to open_economy_network_chile*.mod
% on 2026-07-27 did not perturb the existing float/peg/managed branches.
% Re-runs all three original regimes through the CURRENT master files and
% compares oo_.var against results/variances.csv (the pre-edit baseline).
%
% Run from repo root:
%   >> addpath('C:\dynare\6.3\matlab'); addpath('code'); regression_check_it_edit

regimes = {'float', 'peg', 'managed'};
master_files = struct('float', 'open_economy_network_chile.mod', ...
                       'peg', 'open_economy_network_chile_peg.mod', ...
                       'managed', 'open_economy_network_chile_managed.mod');

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};

out_csv = fullfile('results', 'regression_check_it_edit.csv');
fid = fopen(out_csv, 'w');
fprintf(fid, 'regime,%s\n', strjoin(moment_vars, ','));
fclose(fid);

for r = 1:numel(regimes)
    regime = regimes{r};
    master_txt = fileread(master_files.(regime));
    txt = regexprep(master_txt, 'graph_format\s*=\s*pdf', 'nograph');
    fname = sprintf('oen_regcheck_%s', regime);
    fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

    fprintf('\n=== regression check regime: %s ===\n', regime);
    eval(sprintf('dynare %s.mod', fname));

    vals = zeros(1, numel(moment_vars));
    for v = 1:numel(moment_vars)
        vals(v) = oo_.var(v, v);
    end
    fid = fopen(out_csv, 'a');
    fprintf(fid, '%s,%s\n', regime, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
    fclose(fid);
end

fprintf('\nDone. Results written to %s\n', out_csv);
