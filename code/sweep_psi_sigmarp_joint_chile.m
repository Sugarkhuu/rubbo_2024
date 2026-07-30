function sweep_psi_sigmarp_joint_chile(psi_scale, rp_scale, regime)
% Tier 1C of the full robustness campaign: does the risk-premium shock
% size (sigma_RP) and the debt-elastic risk-premium coefficient (psi)
% reinforce each other, or are their effects roughly separable? Both
% individually drive Peg's dominance (results/psi_sweep_welfare.csv,
% results/risk_premium_chile_welfare.csv) but have never been varied
% jointly. Peg only -- that's the regime in question.
%
% Grid: psi_scale in {0.5, 1, 2} (x baseline PSI=0.020) x rp_scale in
% {0.5, 1, 2} (x baseline sd(eps_rp)=0.01), Peg regime = 9 solves.
% Real Chile calibration (plain, non-exp master), consistent with
% sweep_psi_point.m.
%
% Usage (one point per call, fresh MATLAB process):
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); sweep_psi_sigmarp_joint_chile(1.0, 1.0, 'peg')"

addpath('C:\dynare\6.3\matlab');
global oo_

master_file = 'open_economy_network_chile_peg.mod';
if ~strcmp(regime, 'peg')
    error('Tier 1C is Peg-only by design; got regime=%s', regime);
end

psi_value = 0.020 * psi_scale;
sd_rp = 0.01 * rp_scale;

master_txt = fileread(master_file);
txt = master_txt;
txt = regexprep(txt, 'PSI\s*=\s*[\d.]+;', sprintf('PSI        = %.8f;', psi_value));
txt = regexprep(txt, 'var eps_rp\s*=\s*[\d.]+\^2;', sprintf('var eps_rp  = %.8f^2;', sd_rp));
txt = regexprep(txt, 'graph_format\s*=\s*pdf', 'nograph');

psi_tag = strrep(sprintf('%.4f', psi_scale), '.', 'p');
rp_tag = strrep(sprintf('%.4f', rp_scale), '.', 'p');
fname = sprintf('oen_psirpjoint_chile_%s_%s_%s', psi_tag, rp_tag, regime);
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

out_csv = fullfile('results', 'psi_sigmarp_joint_peg_sweep.csv');
if ~exist(out_csv, 'file')
    fid = fopen(out_csv, 'w');
    fprintf(fid, 'psi_scale,rp_scale,regime,%s\n', strjoin(moment_vars, ','));
    fclose(fid);
end
fid = fopen(out_csv, 'a');
fprintf(fid, '%.4f,%.4f,%s,%s\n', psi_scale, rp_scale, regime, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
fclose(fid);

fprintf('OK: psi_sigmarp_joint psi_scale=%.4f rp_scale=%.4f regime=%s appended to %s\n', psi_scale, rp_scale, regime, out_csv);
end
