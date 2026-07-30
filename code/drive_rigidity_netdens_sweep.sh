#!/usr/bin/env bash
# Tier 1B of the full robustness campaign (2026-07-27): uniform price-
# rigidity x network density x regime. One fresh MATLAB process per point.
# Run from repo root. See code/sweep_rigidity_netdens_chile.m.
set -u

MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"
REGIMES=(float peg managed)
KAPPA_GRID=(0.5 0.75 1.0 1.5 2.0)
RHO_GRID=(0 1 2)

mkdir -p results

for kappa in "${KAPPA_GRID[@]}"; do
    for rho in "${RHO_GRID[@]}"; do
        for regime in "${REGIMES[@]}"; do
            logfile="results/log_rignet_${kappa}_${rho}_${regime}.log"
            echo "=== kappa=$kappa rho=$rho regime=$regime ==="
            "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
                "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_rigidity_netdens_chile(${kappa}, ${rho}, '${regime}'); catch e; disp(getReport(e)); end; exit"
            tail -3 "$logfile"
        done
    done
done

echo "rigidity_netdens sweep driver complete."
