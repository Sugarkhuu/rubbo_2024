function sweep_risk_premium_chile(scale, regime)
% Adam's feedback (2026-07-22): "effects of the volatility of the
% exchange rate processes" -- Chile-calibrated replacement for
% code/sweep_risk_premium.m (stylized network, never run). Scales
% sd(eps_rp), the risk-premium/UIP shock -- the dominant driver of
% exchange-rate movements in this model (78% of Services' own output-gap
% variance under Peg, 63% under Float, see
% code/services_mechanism_decomposition.py) -- while holding every other
% shock and RHO_RP (persistence) fixed, on the real Chile calibration,
% sector-specific-export version.
%
% One point per call (matches sweep_netdens_chile.m /
% sweep_phi_s_netdens_chile.m's pattern, NOT the old loop-in-one-session
% style of sweep_risk_premium.m, which stacks unclosed IRF figure handles
% across many dynare calls in a single MATLAB session and crashes with an
% out-of-memory graphics error after ~15-18 iterations, 2026-07-23).
%
% scale=0 -> eps_rp shock off entirely; scale=1 -> baseline (sd=0.01).
%
% Usage:
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); sweep_risk_premium_chile(1.0, 'peg')"

addpath('C:\dynare\6.3\matlab');
global oo_

master_files = struct('float', 'open_economy_network_chile_exp.mod', ...
                       'peg', 'open_economy_network_chile_exp_peg.mod', ...
                       'managed', 'open_economy_network_chile_exp_managed.mod');

sd_rp = scale * 0.01;
master_txt = fileread(master_files.(regime));
txt = master_txt;
txt = regexprep(txt, 'var eps_rp\s*=\s*[\d.]+\^2;', sprintf('var eps_rp  = %.8f^2;', sd_rp));
% Sweeps only need oo_.var, never the IRF plots -- strip graph_format=pdf.
txt = regexprep(txt, 'irf=40, periods=0, graph_format=pdf', 'irf=40, periods=0, nograph');

scale_tag = strrep(sprintf('%.4f', scale), '.', 'p');
fname = sprintf('oen_rpchile_%s_%s', scale_tag, regime);
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

out_csv = fullfile('results', 'risk_premium_chile_sweep.csv');
if ~exist(out_csv, 'file')
    fid = fopen(out_csv, 'w');
    fprintf(fid, 'rp_scale,regime,%s\n', strjoin(moment_vars, ','));
    fclose(fid);
end
fid = fopen(out_csv, 'a');
fprintf(fid, '%.6f,%s,%s\n', scale, regime, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
fclose(fid);

fprintf('OK: risk_premium_chile scale=%.4f regime=%s appended to %s\n', scale, regime, out_csv);
end
