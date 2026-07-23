% Christian: "he noted about how I miss the between-sector loss. I really
% need to count for that." Runs the three real-Chile-calibration regime
% .mod files (now patched with MARKUPGAP1/2/3, see
% open_economy_network_chile_exp{,_peg,_managed}.mod) and dumps the FULL
% unconditional covariance matrix (not just the diagonal) restricted to
% the three markup-gap variables -- needed because Rubbo's cross-sector
% welfare term Phi_C(mu,mu)/Phi_s(mu,mu) is a quadratic form in the full
% covariance matrix of mu_t = (mu_1t,mu_2t,mu_3t), not just each sector's
% own variance. See code/cross_sector_welfare.py for the Phi_C/Phi_s
% closed-form computation from this covariance matrix.
%
% Run from repo root:
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); run_markupgap_chile"

addpath('C:\dynare\6.3\matlab');
global oo_

master_files = struct('float', 'open_economy_network_chile_exp.mod', ...
                       'peg', 'open_economy_network_chile_exp_peg.mod', ...
                       'managed', 'open_economy_network_chile_exp_managed.mod');
regimes = {'float', 'peg', 'managed'};
% MUST match the (patched) first stoch_simul's var list order exactly:
% piDC PIC y_gap y_gap1 y_gap2 y_gap3 PI1 PI2 PI3 I BSTAR MARKUPGAP1 MARKUPGAP2 MARKUPGAP3
mu_idx = [12, 13, 14];

fid = fopen(fullfile('results', 'markupgap_chile_covar.csv'), 'w');
fprintf(fid, 'regime,i,j,cov\n');

for r = 1:numel(regimes)
    regime = regimes{r};
    fprintf('\n=== markupgap run, regime=%s ===\n', regime);
    eval(sprintf('dynare %s', master_files.(regime)));

    C = oo_.var(mu_idx, mu_idx);
    for i = 1:3
        for j = 1:3
            fprintf(fid, '%s,%d,%d,%.10g\n', regime, i, j, C(i, j));
        end
    end
end
fclose(fid);
fprintf('\nWrote results/markupgap_chile_covar.csv\n');
