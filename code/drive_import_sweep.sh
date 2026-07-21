#!/usr/bin/env bash
# Drives the Chile-calibrated import-openness/concentration sweep (replaces
# the old stylized-network "Openness & Import Concentration" slide data),
# one fresh MATLAB process per (grid_value, regime) point so a Dynare/MEX
# crash on one point never takes down the whole sweep.
# Run from repo root. See code/sweep_import_point.m.
set -u

MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"
REGIMES=(float peg managed)
ZETAS=(0.25 0.5 0.75 1.0 1.5 2.0 2.5)
THETAS=(0 0.25 0.5 0.75 1.0 1.25 1.5)

mkdir -p results

for zeta in "${ZETAS[@]}"; do
    for regime in "${REGIMES[@]}"; do
        logfile="results/log_impzeta_${zeta}_${regime}.log"
        echo "=== zeta=$zeta regime=$regime ==="
        "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
            "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_import_point('zeta', ${zeta}, '${regime}'); catch e; disp(getReport(e)); end; exit"
        tail -3 "$logfile"
    done
done

for theta in "${THETAS[@]}"; do
    for regime in "${REGIMES[@]}"; do
        logfile="results/log_impthetaM_${theta}_${regime}.log"
        echo "=== theta_M=$theta regime=$regime ==="
        "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
            "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_import_point('thetaM', ${theta}, '${regime}'); catch e; disp(getReport(e)); end; exit"
        tail -3 "$logfile"
    done
done

echo "Import sweep driver complete."
