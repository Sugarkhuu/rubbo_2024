% =========================================================================
% Runs the two new strict-inflation-targeting regime variants added to the
% base Chile .mod files on 2026-07-27 (cpi_it: targets PIC only; ppi_it:
% targets domestic-bundle PH only), neither previously run through Dynare.
% Regenerates each as a nograph copy (graph_format=pdf crashes headless
% batch runs after repeated calls -- same lesson as every other sweep),
% collects the standard moment_vars, and writes results/it_regimes_chile.csv
% so they can be compared against float/managed/peg/exp via
% code/analysis_it_regimes_chile.py.
%
% Run from the REPO ROOT:
%   >> addpath('C:\dynare\6.3\matlab'); addpath('code'); run_it_regimes_chile
% =========================================================================

regimes = {'cpi_it', 'ppi_it'};
master_files = struct('cpi_it', 'open_economy_network_chile_cpiit.mod', ...
                       'ppi_it', 'open_economy_network_chile_ppiit.mod');

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
shock_names = {'eps_a1','eps_a2','eps_a3','eps_pF','eps_D','eps_pX','eps_rp'};

out_csv = fullfile('results', 'it_regimes_chile.csv');
fid = fopen(out_csv, 'w');
fprintf(fid, 'regime,%s\n', strjoin(moment_vars, ','));
fclose(fid);

out_vardec_csv = fullfile('results', 'it_regimes_chile_vardec.csv');
fid = fopen(out_vardec_csv, 'w');
fprintf(fid, 'regime,variable,%s\n', strjoin(shock_names, ','));
fclose(fid);

for r = 1:numel(regimes)
    regime = regimes{r};
    master_txt = fileread(master_files.(regime));
    txt = regexprep(master_txt, 'graph_format\s*=\s*pdf', 'nograph');

    fname = sprintf('oen_itregime_chile_%s', regime);
    fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

    fprintf('\n=== regime: %s ===\n', regime);
    eval(sprintf('dynare %s.mod', fname));

    vals = zeros(1, numel(moment_vars));
    for v = 1:numel(moment_vars)
        vals(v) = oo_.var(v, v);
    end
    fid = fopen(out_csv, 'a');
    fprintf(fid, '%s,%s\n', regime, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
    fclose(fid);

    exo_idx = zeros(1, numel(shock_names));
    for s = 1:numel(shock_names)
        exo_idx(s) = find(strcmp(M_.exo_names, shock_names{s}));
    end
    vardec = oo_.variance_decomposition(:, exo_idx);
    fid = fopen(out_vardec_csv, 'a');
    for v = 1:numel(moment_vars)
        row = sprintf('%.10g,', vardec(v, :));
        row(end) = [];
        fprintf(fid, '%s,%s,%s\n', regime, moment_vars{v}, row);
    end
    fclose(fid);
end

fprintf('\nDone. Results written to %s\n', out_csv);
