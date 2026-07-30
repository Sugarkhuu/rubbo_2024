#!/usr/bin/env bash
# Tier 2 of the full robustness campaign: alternative network topologies.
# One fresh MATLAB process per point. Run from repo root.
# See code/sweep_topology_chile.m.
set -u

MATLAB="/c/Program Files/MATLAB/R2018a/bin/matlab.exe"
TOPOLOGIES=(triangle hub_spoke chain)
REGIMES=(float peg managed)
PHI_S_GRID=(0.00 0.05 0.10 0.15 0.20 0.30 0.40 0.50 0.75 1.00 1.50 2.00)

mkdir -p results

echo "--- Part 1: base 3-regime comparison per topology (9 solves) ---"
for topo in "${TOPOLOGIES[@]}"; do
    for regime in "${REGIMES[@]}"; do
        logfile="results/log_topo_${topo}_${regime}.log"
        echo "=== topology=$topo regime=$regime ==="
        "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
            "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_topology_chile('${topo}', '${regime}', NaN); catch e; disp(getReport(e)); end; exit"
        tail -3 "$logfile"
    done
done

echo "--- Part 2: phi_s-optimum search per topology, managed only (36 solves) ---"
for topo in "${TOPOLOGIES[@]}"; do
    for phi_s in "${PHI_S_GRID[@]}"; do
        logfile="results/log_topophis_${topo}_${phi_s}.log"
        echo "=== topology=$topo phi_s=$phi_s ==="
        "$MATLAB" -wait -nosplash -logfile "$logfile" -r \
            "try; addpath('C:\\dynare\\6.3\\matlab'); addpath('code'); sweep_topology_chile('${topo}', 'managed', ${phi_s}); catch e; disp(getReport(e)); end; exit"
        tail -3 "$logfile"
    done
done

echo "topology sweep driver complete."
