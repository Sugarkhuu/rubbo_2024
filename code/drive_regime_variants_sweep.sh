#!/usr/bin/env bash
# Tier 3 of the full robustness campaign: regime-rule variants.
# One fresh MATLAB process per point. Run from repo root.
# See code/sweep_regime_variants_chile.m.
set -u

MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"

mkdir -p results

echo "--- 3A/3B/3C: strict inflation targeting (PHI_PI=5, PHI_Y=0), 3 targets x rho{0,1,2} (9 solves) ---"
for regime in float cpi_it ppi_it; do
    for rho in 0 1 2; do
        logfile="results/log_regvar_strict_${regime}_${rho}.log"
        echo "=== strict_it target=$regime rho=$rho ==="
        "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
            "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_regime_variants_chile('strict_it', ${rho}, 5, 0, '${regime}'); catch e; disp(getReport(e)); end; exit"
        tail -3 "$logfile"
    done
done

echo "--- 3D: dual-mandate grid, PHI_PI x PHI_Y at rho=1, float/DC-IT branch (9 solves) ---"
for phi_pi in 1.5 3 5; do
    for phi_y in 0 0.5 1; do
        logfile="results/log_dualmandate_${phi_pi}_${phi_y}.log"
        echo "=== dual_mandate phi_pi=$phi_pi phi_y=$phi_y ==="
        "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
            "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_regime_variants_chile('dual_mandate', 1.0, ${phi_pi}, ${phi_y}, 'float'); catch e; disp(getReport(e)); end; exit"
        tail -3 "$logfile"
    done
done

echo "regime_variants sweep driver complete."
