#!/bin/bash
cd /c/Users/sugarkhuu/repo/rubbo_2024
for r in float managed peg; do
  "/c/Program Files/MATLAB/R2018a/bin/matlab.exe" -wait -nosplash -logfile chile_full_decomp_$r.log -r "try; addpath('C:\dynare\6.3\matlab'); addpath('code'); run_full_shock_decomposition('oen_full_chile_$r.mod','chile','$r',12,'results/full_calib_shock_decomposition.csv'); catch e; disp(getReport(e)); end; exit"
done
echo DONE > chile_full_decomp.done
