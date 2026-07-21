#!/usr/bin/env bash
# Drives the psi (risk-premium/UIP closing-device) robustness sweep on the
# REAL Chile calibration, one fresh MATLAB process per (psi, regime) point
# so a Dynare/MEX crash on one point never takes down the whole sweep.
# Run from repo root. See code/sweep_psi_point.m.
set -u

MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"
REGIMES=(float peg managed)
PSI_GRID=(0.005 0.01 0.02 0.04 0.08)

mkdir -p results

for psi in "${PSI_GRID[@]}"; do
    for regime in "${REGIMES[@]}"; do
        logfile="results/log_psi_${psi}_${regime}.log"
        echo "=== psi=$psi regime=$regime ==="
        "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
            "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_psi_point(${psi}, '${regime}'); catch e; disp(getReport(e)); end; exit"
        tail -3 "$logfile"
    done
done

echo "psi sweep driver complete."
