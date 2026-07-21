#!/usr/bin/env bash
# Drives the Chile-calibrated network-density sweep (replaces the
# stylized-network "Isolating the Network Channel" slide data), one fresh
# MATLAB process per (rho, regime) point. Run from repo root.
# See code/sweep_netdens_chile.m. Grid stops at 2.2 (not 3, as in the
# stylized version) because Chile's real Omega^H is denser and ALPHA_i
# hits zero around rho~2.45-2.47 (row 1/2 binding).
set -u

MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"
REGIMES=(float peg managed)
RHOS=(0 0.5 1.0 1.5 2.0 2.2)

mkdir -p results

for rho in "${RHOS[@]}"; do
    for regime in "${REGIMES[@]}"; do
        logfile="results/log_netdenschile_${rho}_${regime}.log"
        echo "=== rho=$rho regime=$regime ==="
        "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
            "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_netdens_chile(${rho}, '${regime}'); catch e; disp(getReport(e)); end; exit"
        tail -3 "$logfile"
    done
done

echo "Netdens Chile sweep driver complete."
