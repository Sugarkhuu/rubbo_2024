#!/bin/bash
cd /c/Users/sugarkhuu/repo/rubbo_2024
while [ ! -f chile_full_decomp.done ]; do sleep 20; done
for c in chile:12 korea:33 czechia:81; do
 cc=${c%%:*}; n=${c##*:}
 for r in float managed peg; do
  "/c/Program Files/MATLAB/R2018a/bin/matlab.exe" -wait -nosplash -logfile scaled_${cc}_$r.log -r "try; addpath('C:\dynare\6.3\matlab'); addpath('code'); run_full_regime_welfare('oen_fullscaled_${cc}_$r.mod','$cc','$r',$n,'results/full_calib_welfare_scaledtfp.csv'); catch e; disp(getReport(e)); end; exit"
 done
done
echo DONE > scaled.done
