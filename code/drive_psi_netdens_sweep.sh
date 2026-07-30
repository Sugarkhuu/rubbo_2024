#!/usr/bin/env bash
# Tier 1A of the full robustness campaign (2026-07-27): psi x network
# density x regime. One fresh MATLAB process per point. Run from repo root.
# See code/sweep_psi_netdens_chile.m.
set -u

MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"
REGIMES=(float peg managed)
PSI_GRID=(0.005 0.01 0.02 0.04 0.08)
RHO_GRID=(0 1 2)

mkdir -p results

for psi in "${PSI_GRID[@]}"; do
    for rho in "${RHO_GRID[@]}"; do
        for regime in "${REGIMES[@]}"; do
            logfile="results/log_psinet_${psi}_${rho}_${regime}.log"
            echo "=== psi=$psi rho=$rho regime=$regime ==="
            "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
                "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_psi_netdens_chile(${psi}, ${rho}, '${regime}'); catch e; disp(getReport(e)); end; exit"
            tail -3 "$logfile"
        done
    done
done

echo "psi_netdens sweep driver complete."
