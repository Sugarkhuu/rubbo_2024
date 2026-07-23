#!/usr/bin/env bash
# Drives the risk-premium volatility sweep (Adam), one fresh MATLAB
# process per (scale, regime) point -- see code/sweep_risk_premium_chile.m
# for why (a shared-session loop crashed MATLAB's graphics subsystem after
# ~15-18 dynare calls, 2026-07-23). Run from repo root.
set -u

MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"
REGIMES=(float peg managed)
SCALE_GRID=(0.00 0.50 1.00 1.50 2.00 3.00)

mkdir -p results

for scale in "${SCALE_GRID[@]}"; do
    for regime in "${REGIMES[@]}"; do
        logfile="results/log_rpchile2_${scale}_${regime}.log"
        echo "=== scale=$scale regime=$regime ==="
        "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
            "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_risk_premium_chile(${scale}, '${regime}'); catch e; disp(getReport(e)); end; exit"
        tail -3 "$logfile"
    done
done

echo "Risk-premium volatility Chile sweep driver complete."
