#!/bin/bash
# One fresh MATLAB process per scenario (project sweep pattern). Sequential.
cd /c/Users/sugarkhuu/repo/rubbo_2024
OUT=results/opt_rule_grid.csv
rm -f $OUT
run() { # scen rho rp delta of psi
  "/c/Program Files/MATLAB/R2018a/bin/matlab.exe" -wait -nosplash -logfile optrule_$1.log -r "try; addpath('C:\dynare\6.3\matlab'); addpath('code'); opt_rule_point('$1',$2,$3,'$4','$5',$6,'$OUT'); catch e; disp(getReport(e)); end; exit"
  rm -rf oen_optrule_*.mod +oen_optrule_* oen_optrule_*/ optrule_$1.log
}
# A. network density x risk-premium size
for rho in 0 0.5 1 1.5; do
  for rp in 0 0.5 1 2; do
    run "net_${rho}_rp_${rp}" $rho $rp base base 0.02
  done
done
# B. ablations (rp = 1), each at rho = 1 and rho = 0
for rho in 1 0; do
  run "abl_unifdelta_r${rho}" $rho 1 uniform base 0.02
  run "abl_unifof_r${rho}"    $rho 1 base uniform 0.02
  run "abl_zeroof_r${rho}"    $rho 1 base zero 0.02
  run "abl_flat_r${rho}"      $rho 1 uniform uniform 0.02
  run "abl_flat_norp_r${rho}" $rho 0 uniform uniform 0.02
done
for psi in 0.005 0.1; do
  run "abl_psi${psi}_r1" 1 1 base base $psi
  run "abl_psi${psi}_r0" 0 1 base base $psi
done
echo DONE > opt_rule.done
