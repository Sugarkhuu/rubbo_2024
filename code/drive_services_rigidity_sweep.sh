#!/usr/bin/env bash
# Tier 1B (Services-only cut) of the full robustness campaign. One fresh
# MATLAB process per point. Run from repo root.
# See code/sweep_services_rigidity_chile.m.
set -u

MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"
REGIMES=(float peg managed)
DELTA3_GRID=(0.05 0.10 0.16 0.25 0.40 0.60)
RHO_GRID=(0 1 2)

mkdir -p results

for d3 in "${DELTA3_GRID[@]}"; do
    for rho in "${RHO_GRID[@]}"; do
        for regime in "${REGIMES[@]}"; do
            logfile="results/log_svcrig_${d3}_${rho}_${regime}.log"
            echo "=== delta3=$d3 rho=$rho regime=$regime ==="
            "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
                "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_services_rigidity_chile(${d3}, ${rho}, '${regime}'); catch e; disp(getReport(e)); end; exit"
            tail -3 "$logfile"
        done
    done
done

echo "services_rigidity sweep driver complete."
