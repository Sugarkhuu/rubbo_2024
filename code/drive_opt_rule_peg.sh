#!/bin/bash
cd /c/Users/sugarkhuu/repo/rubbo_2024
OUT=results/opt_rule_peg.csv
rm -f $OUT
for rho in 0 0.5 1 1.5; do for rp in 0 1 2; do
  s="peg_${rho}_rp_${rp}"
  "/c/Program Files/MATLAB/R2018a/bin/matlab.exe" -wait -nosplash -logfile optrulepeg_$s.log -r "try; addpath('C:\dynare\6.3\matlab'); addpath('code'); opt_rule_peg_point('$s',$rho,$rp,'base','base',0.02,'$OUT'); catch e; disp(getReport(e)); end; exit"
  rm -rf oen_optrulepeg_*.mod +oen_optrulepeg_* oen_optrulepeg_*/ optrulepeg_$s.log
done; done
echo DONE > opt_rule_peg.done
