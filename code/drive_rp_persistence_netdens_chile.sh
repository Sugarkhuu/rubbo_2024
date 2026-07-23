#!/usr/bin/env bash
# Christian: does risk-premium shock PERSISTENCE (not just size) drive the
# welfare cost, and does that interact with network density? Crosses
# RHO_RP (AR(1) persistence of the risk-premium/UIP shock) with rho
# (network density) for all three regimes. See
# code/sweep_rp_persistence_netdens_chile.m. Run from repo root.
set -u

MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"
RHOS=(0 1.0)
RHO_RP_GRID=(0.00 0.40 0.80 0.95)
REGIMES=(float peg managed)

mkdir -p results

for rho in "${RHOS[@]}"; do
    for rho_rp in "${RHO_RP_GRID[@]}"; do
        for regime in "${REGIMES[@]}"; do
            logfile="results/log_rppers_${rho}_${rho_rp}_${regime}.log"
            echo "=== rho=$rho rho_rp=$rho_rp regime=$regime ==="
            "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
                "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_rp_persistence_netdens_chile(${rho}, ${rho_rp}, '${regime}'); catch e; disp(getReport(e)); end; exit"
            tail -3 "$logfile"
        done
    done
done

echo "RP-persistence x netdens Chile sweep driver complete."
