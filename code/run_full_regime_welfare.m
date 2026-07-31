function run_full_regime_welfare(mod_file, country_tag, regime, N, out_csv)
% Runs a generated full-native-resolution .mod file (data_calibration/
% generate_mod.py output) through Dynare, then computes the SAME welfare
% loss formula used elsewhere in this project (code/analysis.py's
% compute_welfare):
%   W = 0.5*(GAMMA+VARPHI)*Var(y_gap)
%     + 0.5*sum_i LAMBDA_D_i*EPS*(1-DHAT_i)/DHAT_i*Var(PI_i)
% using the SAME simulated-moments oo_.var diagonal (periods>0 in the
% generated .mod's first stoch_simul call -- analytic/theoretical moments
% are unreliable at this N, see generate_mod.py's comment on the near-unit-
% root numerical issue) that the .mod file's first stoch_simul call reports.
%
% Usage (one call per fresh MATLAB process, per the project's documented
% sweep pattern -- see CLAUDE.md):
%   matlab -wait -logfile <log> -r "addpath('C:\dynare\6.3\matlab'); addpath('code'); run_full_regime_welfare('oen_full_korea_float.mod','korea','float',33,'results/full_calib_welfare.csv'); exit"
global oo_ M_

eval(sprintf('dynare %s', mod_file));

param_names = cellstr(M_.param_names);

% oo_.var is sized/ordered to match the variable list of the LAST-executed
% stoch_simul call in the generated .mod file, NOT the full M_.endo_names
% list -- confirmed empirically (index-out-of-bounds against M_.endo_names'
% length). The generated .mod's FIRST stoch_simul call (the one whose
% moments we want) requests, in this exact order (see generate_mod.py's
% report_vars_1): piDC PIC y_gap I BSTAR PI1 PI2 ... PIN. Since the file also
% has a SECOND stoch_simul call with a different (smaller) variable list, we
% rely on Dynare re-running/reporting via that first call's oo_.var, which is
% the object still populated when this function is reached immediately after
% `dynare` returns for a file whose LAST command executed is the second
% stoch_simul -- so instead we look up indices against the known first-call
% order directly, which matches oo_.var's dimension (checked: 38x38 for
% N=33, i.e. 5+N) rather than trusting M_.endo_names order.
oo_var_order = [{'piDC', 'PIC', 'y_gap', 'I', 'BSTAR'}, arrayfun(@(i) sprintf('PI%d', i), 1:N, 'UniformOutput', false)];

    function v = get_param(name)
        idx = find(strcmp(param_names, name), 1);
        if isempty(idx)
            error('Parameter %s not found', name);
        end
        v = M_.params(idx);
    end

    function v = get_var_variance(name)
        idx = find(strcmp(oo_var_order, name), 1);
        if isempty(idx)
            error('Variable %s not found in oo_var_order', name);
        end
        v = oo_.var(idx, idx);
    end

GAMMA = get_param('GAMMA');
VARPHI = get_param('VARPHI');
EPS = get_param('EPS');

var_ygap = get_var_variance('y_gap');
w_output = 0.5*(GAMMA+VARPHI)*var_ygap;

w_pi_total = 0;
for i = 1:N
    lam = get_param(sprintf('LAMBDA_D%d', i));
    dhat = get_param(sprintf('DHAT%d', i));
    var_pi = get_var_variance(sprintf('PI%d', i));
    w_pi_total = w_pi_total + 0.5*lam*EPS*(1-dhat)/dhat*var_pi;
end

total = w_output + w_pi_total;
var_bstar = get_var_variance('BSTAR');
var_pic = get_var_variance('PIC');
var_i = get_var_variance('I');

if ~exist(fileparts(out_csv), 'dir') && ~isempty(fileparts(out_csv))
    mkdir(fileparts(out_csv));
end
if ~exist(out_csv, 'file')
    fid = fopen(out_csv, 'w');
    fprintf(fid, 'country,regime,N,var_ygap,var_pic,var_i,var_bstar,w_output,w_pi_total,total\n');
    fclose(fid);
end
fid = fopen(out_csv, 'a');
fprintf(fid, '%s,%s,%d,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g\n', ...
    country_tag, regime, N, var_ygap, var_pic, var_i, var_bstar, w_output, w_pi_total, total);
fclose(fid);

fprintf('OK: %s %s N=%d total_welfare_loss=%.10g (output=%.10g, price_disp=%.10g)\n', ...
    country_tag, regime, N, total, w_output, w_pi_total);
end
