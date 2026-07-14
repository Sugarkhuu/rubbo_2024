#!/usr/bin/env bash
# Drives the two structural-generalization sweeps (see run_sweep_point.m),
# one fresh MATLAB process per (grid_value, regime) point so a Dynare/MEX
# crash on one point never takes down the whole sweep. Run from repo root.
set -u

MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"
REGIMES=(float peg managed)
KAPPAS=(0.25 0.5 0.75 1.0 1.5 2.0 2.5)
THETAS=(0 0.25 0.5 0.75 1.0 1.25 1.5)

run_point() {
    local sweep_type="$1" grid_value="$2" regime="$3"
    local logfile="results/log_${sweep_type}_${grid_value}_${regime}.log"
    echo "=== $sweep_type grid_value=$grid_value regime=$regime ==="
    "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
        "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); run_sweep_point('${sweep_type}', ${grid_value}, '${regime}'); catch e; disp(getReport(e)); end; exit"
    tail -3 "$logfile"
}

for kappa in "${KAPPAS[@]}"; do
    for regime in "${REGIMES[@]}"; do
        run_point impint "$kappa" "$regime"
    done
done

for theta in "${THETAS[@]}"; do
    for regime in "${REGIMES[@]}"; do
        run_point ofhet "$theta" "$regime"
    done
done

echo "Sweep driver complete."
