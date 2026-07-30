function sweep_topology_chile(topology, regime, phi_s)
% Tier 2 of the full robustness campaign: alternative network topologies
% (not just density) on the real Chile calibration. topology in
% {'triangle','hub_spoke','chain'} (see code/network_topologies.py for the
% OH_offdiag matrices, matched to the baseline's total off-diagonal mass
% 0.6501). Called two ways:
%   - phi_s = NaN: base 3-regime comparison at each topology's baseline
%     rule -> results/topology_regime_sweep.csv (9 solves: 3 topologies x
%     3 regimes).
%   - phi_s given (managed regime only): phi_s-optimum search per topology
%     -> results/topology_phi_s_sweep.csv (36 solves: 12-point phi_s grid
%     x 3 topologies), mirrors sweep_phi_s_netdens_chile.m's grid.
%
% Usage (one point per call, fresh MATLAB process):
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); sweep_topology_chile('hub_spoke', 'float', NaN)"
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); sweep_topology_chile('chain', 'managed', 0.20)"

addpath('C:\dynare\6.3\matlab');
global oo_

master_files = struct('float', 'open_economy_network_chile.mod', ...
                       'peg', 'open_economy_network_chile_peg.mod', ...
                       'managed', 'open_economy_network_chile_managed.mod');

OH_diag = [0.0750, 0.2022, 0.2661];
OF_base = [0.0767, 0.1945, 0.0704];
mass = 0.1526+0.1932+0.0991+0.1453+0.0018+0.0581;

switch topology
    case 'triangle'
        OH = [0, 0.1526, 0.1932; 0.0991, 0, 0.1453; 0.0018, 0.0581, 0];
    case 'hub_spoke'
        raw = [0, 0.1526, 0; 0.0991, 0, 0.1453; 0, 0.0581, 0];
        OH = raw * (mass / sum(raw(:)));
    case 'chain'
        raw = [0, 0, 0; 0.0991, 0, 0; 0, 0.0581, 0];
        OH = raw * (mass / sum(raw(:)));
    otherwise
        error('Unknown topology: %s', topology);
end
OH12_k=OH(1,2); OH13_k=OH(1,3); OH21_k=OH(2,1); OH23_k=OH(2,3); OH31_k=OH(3,1); OH32_k=OH(3,2);

ALPHA_k = 1 - OH_diag - sum(OH,2)' - OF_base;
if any(ALPHA_k <= 0)
    error('Infeasible shares for topology=%s: ALPHA=[%.4f %.4f %.4f]', topology, ALPHA_k);
end

master_txt = fileread(master_files.(regime));
txt = master_txt;
txt = regexprep(txt, 'ALPHA1\s*=\s*[\d.]+;', sprintf('ALPHA1  = %.6f;', ALPHA_k(1)));
txt = regexprep(txt, 'ALPHA2\s*=\s*[\d.]+;', sprintf('ALPHA2  = %.6f;', ALPHA_k(2)));
txt = regexprep(txt, 'ALPHA3\s*=\s*[\d.]+;', sprintf('ALPHA3  = %.6f;', ALPHA_k(3)));
txt = regexprep(txt, 'OH12\s*=\s*[\d.]+;', sprintf('OH12 = %.6f; ', OH12_k));
txt = regexprep(txt, 'OH13\s*=\s*[\d.]+;', sprintf('OH13 = %.6f;', OH13_k));
txt = regexprep(txt, 'OH21\s*=\s*[\d.]+;', sprintf('OH21 = %.6f; ', OH21_k));
txt = regexprep(txt, 'OH23\s*=\s*[\d.]+;', sprintf('OH23 = %.6f;', OH23_k));
txt = regexprep(txt, 'OH31\s*=\s*[\d.]+;', sprintf('OH31 = %.6f; ', OH31_k));
txt = regexprep(txt, 'OH32\s*=\s*[\d.]+;', sprintf('OH32 = %.6f;', OH32_k));
txt = regexprep(txt, 'graph_format\s*=\s*pdf', 'nograph');

is_phi_search = ~isnan(phi_s);
if is_phi_search
    if ~strcmp(regime, 'managed')
        error('phi_s search is managed-regime only');
    end
    txt = regexprep(txt, 'PHI_S\s*=\s*0\.30;', sprintf('PHI_S   = %.6f;', phi_s));
    phi_tag = strrep(sprintf('%.4f', phi_s), '.', 'p');
    fname = sprintf('oen_topophis_chile_%s_%s', topology, phi_tag);
else
    fname = sprintf('oen_topo_chile_%s_%s', topology, regime);
end
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

if is_phi_search
    out_csv = fullfile('results', 'topology_phi_s_sweep.csv');
    if ~exist(out_csv, 'file')
        fid = fopen(out_csv, 'w');
        fprintf(fid, 'topology,phi_s,%s\n', strjoin(moment_vars, ','));
        fclose(fid);
    end
    fid = fopen(out_csv, 'a');
    fprintf(fid, '%s,%.6f,%s\n', topology, phi_s, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
    fclose(fid);
    fprintf('OK: topology=%s phi_s=%.4f appended to %s\n', topology, phi_s, out_csv);
else
    out_csv = fullfile('results', 'topology_regime_sweep.csv');
    if ~exist(out_csv, 'file')
        fid = fopen(out_csv, 'w');
        fprintf(fid, 'topology,regime,%s\n', strjoin(moment_vars, ','));
        fclose(fid);
    end
    fid = fopen(out_csv, 'a');
    fprintf(fid, '%s,%s,%s\n', topology, regime, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
    fclose(fid);
    fprintf('OK: topology=%s regime=%s appended to %s\n', topology, regime, out_csv);
end
end
