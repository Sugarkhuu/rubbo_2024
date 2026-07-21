function sweep_netdens_chile(rho, regime)
global oo_
% Chile-calibrated replacement for the "Isolating the Network Channel"
% slide's stylized-network rho sweep (code/run_sweep_point.m's 'netdens'
% case, built on open_economy_network.mod's hand-picked triangular chain
% Resource->Manuf.->Services, which only has ONE cross-sector link per
% row). Chile's REAL Omega^H is dense (all 9 cells nonzero, not a chain),
% so there's no single "the link" to dial -- instead this scales ALL SIX
% cross-sector (off-diagonal) entries by rho, holding each sector's own-
% input diagonal (OH11/OH22/OH33 -- not really "network," just within-
% sector input use) and import shares OF1-3 fixed at Chile's calibrated
% values. rho=1 recovers the real Chile calibration exactly; rho=0 is the
% no-domestic-cross-sector-network counterfactual (each sector still uses
% its own output as an input, plus imports, but doesn't buy from the
% OTHER two domestic sectors).
%
% ALPHA_i absorbs the change so cost shares still sum to one:
%   ALPHA_i(rho) = 1 - OH_diag_i - rho*offdiag_sum_i - OF_i
% Max feasible rho is set by row 1 (Resource, offdiag_sum=0.3458) and row
% 2 (Manuf., offdiag_sum=0.2444): both saturate ALPHA_i=0 around
% rho~2.45-2.47 -- Chile's network is far denser than the stylized chain
% (which could scale to rho=3), so the grid here stops at 2.0-2.2, not 3.
%
% Usage (from repo root, one call per point):
%   matlab -batch "addpath('C:\dynare\6.3\matlab'); addpath('code'); sweep_netdens_chile(1.0, 'float')"

addpath('C:\dynare\6.3\matlab');

master_files = struct('float', 'open_economy_network_chile.mod', ...
                       'peg', 'open_economy_network_chile_peg.mod', ...
                       'managed', 'open_economy_network_chile_managed.mod');

OH_diag = [0.0750, 0.2022, 0.2661];               % OH11, OH22, OH33 (own-input use, fixed)
OH_offdiag_base = [0.1526, 0.1932;                % row1: OH12, OH13
                    0.0991, 0.1453;                % row2: OH21, OH23
                    0.0018, 0.0581];               % row3: OH31, OH32
OF_base = [0.0767, 0.1945, 0.0704];                % fixed (real Chile calibration)

OH_k = rho * OH_offdiag_base;
OH12_k = OH_k(1,1); OH13_k = OH_k(1,2);
OH21_k = OH_k(2,1); OH23_k = OH_k(2,2);
OH31_k = OH_k(3,1); OH32_k = OH_k(3,2);

offdiag_sum = sum(OH_offdiag_base, 2)';
ALPHA_k = 1 - OH_diag - rho * offdiag_sum - OF_base;
if any(ALPHA_k <= 0)
    error('Infeasible shares at rho=%.4f: ALPHA=[%.4f %.4f %.4f]', rho, ALPHA_k);
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

tag = strrep(sprintf('%.4f', rho), '.', 'p');
fname = sprintf('oen_netdens_chile_%s_%s', tag, regime);
fid = fopen([fname '.mod'], 'w'); fwrite(fid, txt); fclose(fid);

eval(sprintf('dynare %s.mod', fname));

moment_vars = {'piDC','PIC','y_gap','y_gap1','y_gap2','y_gap3','PI1','PI2','PI3','I','BSTAR'};
vals = zeros(1, numel(moment_vars));
for v = 1:numel(moment_vars)
    vals(v) = oo_.var(v, v);
end

out_csv = fullfile('results', 'netdens_chile_sweep.csv');
if ~exist(out_csv, 'file')
    fid = fopen(out_csv, 'w');
    fprintf(fid, 'rho,regime,%s\n', strjoin(moment_vars, ','));
    fclose(fid);
end
fid = fopen(out_csv, 'a');
fprintf(fid, '%.6f,%s,%s\n', rho, regime, strjoin(cellstr(num2str(vals(:), '%.10g')), ','));
fclose(fid);

fprintf('OK: netdens_chile rho=%.4f regime=%s appended to %s\n', rho, regime, out_csv);
end
