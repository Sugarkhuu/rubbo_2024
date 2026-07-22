#!/usr/bin/env bash
# Drives the combined PHI_S x network-density sweep (managed regime only)
# -- Christian's feedback: does the optimal managed-float FX-response
# coefficient PHI_S shift depending on whether the domestic network is
# present? See code/sweep_phi_s_netdens_chile.m. Run from repo root.
set -u

MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"
RHOS=(0 1.0 2.0)
PHI_S_GRID=(0.00 0.05 0.10 0.15 0.20 0.30 0.40 0.50 0.75 1.00 1.50 2.00)

mkdir -p results

for rho in "${RHOS[@]}"; do
    for phi_s in "${PHI_S_GRID[@]}"; do
        logfile="results/log_phisnet_${rho}_${phi_s}.log"
        echo "=== rho=$rho phi_s=$phi_s ==="
        "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
            "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_phi_s_netdens_chile(${rho}, ${phi_s}); catch e; disp(getReport(e)); end; exit"
        tail -3 "$logfile"
    done
done

echo "PHI_S x netdens Chile sweep driver complete."
