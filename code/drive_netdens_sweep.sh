#!/usr/bin/env bash
set -u
MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"
REGIMES=(float peg managed)
RHOS=(0 0.25 0.5 0.75 1.0 1.5 2.0 3.0)

run_point() {
    local grid_value="$1" regime="$2"
    local logfile="results/log_netdens_${grid_value}_${regime}.log"
    echo "=== netdens rho=$grid_value regime=$regime ==="
    "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
        "try; addpath('C:\dynare\6.3\matlab'); addpath('code'); run_sweep_point('netdens', ${grid_value}, '${regime}'); catch e; disp(getReport(e)); end; exit"
    tail -2 "$logfile"
}

for rho in "${RHOS[@]}"; do
    for regime in "${REGIMES[@]}"; do
        run_point "$rho" "$regime"
    done
done
echo "netdens sweep driver complete."
