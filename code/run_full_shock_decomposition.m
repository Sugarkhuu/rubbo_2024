function run_full_shock_decomposition(mod_file, country_tag, regime, N, out_csv)
% Shock-by-shock (well, shock-GROUP) variance decomposition for the
% full-native-resolution Peg output-gap blow-up (see docs_notes/
% results_summary.md's "Full-native-resolution calibration campaign"
% section for why Dynare's built-in oo_.variance_decomposition is not
% usable here: at N=33/81 the analytic (periods=0) moment formulas return
% NaN due to a near-unit-root eigenvalue, so the generated .mod files use
% SIMULATED moments (periods=20000) instead, and oo_.variance_decomposition
% is only populated by the analytic path).
%
% METHOD: parse+solve the model ONCE via `dynare <mod_file>` (this also
% runs the .mod file's own two stoch_simul calls, which we ignore other
% than as a sanity baseline), then for each shock GROUP below, zero out
% every OTHER shock's variance directly in M_.Sigma_e and re-run
% stoch_simul(order=1, periods=20000, ...) on the SAME report-variable
% list, WITHOUT re-invoking `dynare` (re-parsing is unnecessary -- M_/oo_/
% options_ already reflect the solved model; only Sigma_e changes across
% reruns). This isolates each group's contribution to Var(y_gap) and
% Var(PI_i) under linear (order=1) dynamics, where shocks are independent
% and their variance contributions are exactly additive up to simulation
% noise -- checked explicitly against an "all shocks together" rerun done
% here as its own row (shock_group='all_shocks'), which should closely
% match results/full_calib_welfare.csv's total for the same country/regime.
%
% Usage (one call per fresh MATLAB process, per this project's documented
% sweep pattern -- see CLAUDE.md -- but reusing the in-memory model across
% ALL shock-group reruns WITHIN this one process/function call, which is
% the entire point):
%   matlab -wait -nosplash -logfile <log> -r "addpath('C:\dynare\6.3\matlab'); addpath('code'); run_full_shock_decomposition('oen_full_korea_peg.mod','korea','peg',33,'results/full_calib_shock_decomposition.csv'); exit"
global oo_ M_ options_

eval(sprintf('dynare %s', mod_file));

param_names = cellstr(M_.param_names);
exo_names   = cellstr(M_.exo_names);

% Same report-variable list/order as run_full_regime_welfare.m's
% oo_var_order (matches the generated .mod's FIRST stoch_simul call).
var_list_str = [{'piDC', 'PIC', 'y_gap', 'I', 'BSTAR'}, arrayfun(@(i) sprintf('PI%d', i), 1:N, 'UniformOutput', false)];
var_list = var_list_str(:);

% Baseline shock variances as set by the .mod file's `shocks;` block
% (diagonal, no cross-shock correlations declared anywhere in the
% generator -- confirmed by inspecting oen_full_*.mod's shocks block).
full_diag = diag(M_.Sigma_e);

    function idx = shock_idx(name)
        idx = find(strcmp(exo_names, name), 1);
        if isempty(idx)
            error('Shock %s not found in M_.exo_names', name);
        end
    end

tfp_shocks = arrayfun(@(i) sprintf('eps_a%d', i), 1:N, 'UniformOutput', false);

groups = struct();
groups.all_shocks = exo_names;                 % sanity-check row
groups.tfp_all    = tfp_shocks;
groups.eps_pF     = {'eps_pF'};
groups.eps_D      = {'eps_D'};
groups.eps_pX     = {'eps_pX'};
groups.eps_rp     = {'eps_rp'};

group_names = fieldnames(groups);

    function v = get_param(name)
        idx = find(strcmp(param_names, name), 1);
        if isempty(idx)
            error('Parameter %s not found', name);
        end
        v = M_.params(idx);
    end

GAMMA = get_param('GAMMA');
VARPHI = get_param('VARPHI');
EPS = get_param('EPS');

lam = zeros(N,1);
dhat = zeros(N,1);
for i = 1:N
    lam(i) = get_param(sprintf('LAMBDA_D%d', i));
    dhat(i) = get_param(sprintf('DHAT%d', i));
end

if ~exist(fileparts(out_csv), 'dir') && ~isempty(fileparts(out_csv))
    mkdir(fileparts(out_csv));
end
if ~exist(out_csv, 'file')
    fid = fopen(out_csv, 'w');
    fprintf(fid, 'country,regime,N,shock_group,var_ygap,w_output,w_pi_total,total\n');
    fclose(fid);
end

% Options matching the .mod file's FIRST stoch_simul call. CRITICAL: the
% generated .mod file's SECOND stoch_simul call (periods=0, nomoments,
% nocorr, nodecomposition, noprint) is the LAST one dynare executes, so
% options_ is left in that state when this function starts -- if we don't
% explicitly clear nomoments/nodecomposition/noprint here, disp_moments is
% silently skipped inside stoch_simul (gated on `if ~options_.nomoments`,
% see stoch_simul.m) and oo_.var just keeps reporting the STALE moments
% from the very first (baseline, all-shocks) stoch_simul call for every
% subsequent shock-group rerun -- confirmed empirically: an initial version
% of this script without these lines produced byte-identical var_ygap
% across every shock group. nodecomposition=1 additionally skips Dynare's
% own (unused here, and slow) one-shock-at-a-time simulation table.
options_.order = 1;
options_.irf = 0;
options_.periods = 20000;
options_.nograph = 1;
options_.nomoments = 0;
options_.nodecomposition = 1;
options_.nocorr = 1;
options_.noprint = 1;

for g = 1:numel(group_names)
    gname = group_names{g};
    shocks_in_group = groups.(gname);

    new_diag = zeros(size(full_diag));
    for s = 1:numel(shocks_in_group)
        idx = shock_idx(shocks_in_group{s});
        new_diag(idx) = full_diag(idx);
    end
    M_.Sigma_e = diag(new_diag);

    set_dynare_seed(20260731);
    [info, oo_, options_, M_] = stoch_simul(M_, options_, oo_, var_list);
    if info(1) ~= 0
        warning('stoch_simul returned info=%d for group %s -- skipping row', info(1), gname);
        continue
    end

    var_names_out = cellstr(oo_.var_list);
    idx_ygap = find(strcmp(var_names_out, 'y_gap'), 1);
    var_ygap = oo_.var(idx_ygap, idx_ygap);
    w_output = 0.5*(GAMMA+VARPHI)*var_ygap;

    w_pi_total = 0;
    for i = 1:N
        idx_pi = find(strcmp(var_names_out, sprintf('PI%d', i)), 1);
        var_pi = oo_.var(idx_pi, idx_pi);
        w_pi_total = w_pi_total + 0.5*lam(i)*EPS*(1-dhat(i))/dhat(i)*var_pi;
    end

    total = w_output + w_pi_total;

    fid = fopen(out_csv, 'a');
    fprintf(fid, '%s,%s,%d,%s,%.10g,%.10g,%.10g,%.10g\n', ...
        country_tag, regime, N, gname, var_ygap, w_output, w_pi_total, total);
    fclose(fid);

    fprintf('OK: %s %s N=%d group=%s var_ygap=%.10g total=%.10g\n', ...
        country_tag, regime, N, gname, var_ygap, total);
end

% Restore full shock variances (harmless -- process exits after this
% function returns in the documented one-process-per-regime usage, but
% cheap to be tidy in case of future interactive use).
M_.Sigma_e = diag(full_diag);

end
