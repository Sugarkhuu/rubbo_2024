#!/usr/bin/env bash
# Tier 1C of the full robustness campaign: psi x sigma_RP joint, Peg only.
# One fresh MATLAB process per point. Run from repo root.
# See code/sweep_psi_sigmarp_joint_chile.m.
set -u

MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"
PSI_SCALE_GRID=(0.5 1.0 2.0)
RP_SCALE_GRID=(0.5 1.0 2.0)

mkdir -p results

for psi_s in "${PSI_SCALE_GRID[@]}"; do
    for rp_s in "${RP_SCALE_GRID[@]}"; do
        logfile="results/log_psirpjoint_${psi_s}_${rp_s}.log"
        echo "=== psi_scale=$psi_s rp_scale=$rp_s regime=peg ==="
        "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
            "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_psi_sigmarp_joint_chile(${psi_s}, ${rp_s}, 'peg'); catch e; disp(getReport(e)); end; exit"
        tail -3 "$logfile"
    done
done

echo "psi_sigmarp_joint sweep driver complete."
