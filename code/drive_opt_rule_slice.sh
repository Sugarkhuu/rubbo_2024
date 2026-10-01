#!/bin/bash
# Where the import exposure sits relative to price stickiness (Christian's 'rigid + buys from import-heavy' point).
cd /c/Users/sugarkhuu/repo/rubbo_2024
while [ ! -f opt_rule_peg.done ]; do sleep 20; done
OUT=results/opt_rule_slice_placement.csv
rm -f $OUT
for of in base bigres bigman bigserv; do for rho in 1 0; do for rp in 1 0; do
  s="place_${of}_r${rho}_rp${rp}"
  "/c/Program Files/MATLAB/R2018a/bin/matlab.exe" -wait -nosplash -logfile optruleslice_$s.log -r "try; addpath('C:\dynare\6.3\matlab'); addpath('code'); opt_rule_point_slice('$s',$rho,$rp,'base','$of',0.02,'$OUT'); catch e; disp(getReport(e)); end; exit"
  rm -rf oen_optruleslice_*.mod +oen_optruleslice_* oen_optruleslice_*/ optruleslice_$s.log
done; done; done
echo DONE > opt_rule_slice.done
