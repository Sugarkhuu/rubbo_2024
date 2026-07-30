"""
Tier 2 of the full robustness campaign (plan:
C:\\Users\\sugarkhuu\\.claude\\plans\\noble-strolling-feather.md): every
existing sweep varies network DENSITY (rho dial) on one triangular-shaped
domestic IO matrix. This module defines two alternative SHAPES, at matched
total off-diagonal mass (sum OH_offdiag_base = 0.6501, same as the
baseline triangular network), to test whether the "Services absorbs most
of the welfare cost via indirect exposure" finding is specific to the
triangular shape or general to having a dense domestic network at all.

Sector order: 1=Resource, 2=Manufacturing, 3=Services.
OH[i,j] = sector i's cost share bought from sector j (row i's supplier
mix), matching the convention in network_exposure_decomposition.py.

- TRIANGLE (baseline): all six off-diagonal entries populated (real Chile
  calibration).
- HUB_SPOKE: Manufacturing is the hub -- Resource<->Manufacturing and
  Manufacturing<->Services links carry all the mass, Resource<->Services
  set to 0.
- CHAIN: Resource->Manufacturing->Services one-directional pass-through
  only (Manufacturing buys from Resource, Services buys from
  Manufacturing); all back-links and cross-links set to 0.

Run: C:\\Users\\sugarkhuu\\anaconda3\\python.exe code/network_topologies.py
"""
import os
import numpy as np
import pandas as pd

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS = os.path.join(REPO_ROOT, "results")
SECTORS = ["Resource", "Manufacturing", "Services"]

OH_diag = np.array([0.0750, 0.2022, 0.2661])
OF_base = np.array([0.0767, 0.1945, 0.0704])
BH = np.array([0.027, 0.229, 0.744])
TOTAL_MASS = 0.1526 + 0.1932 + 0.0991 + 0.1453 + 0.0018 + 0.0581  # = 0.6501

# indices: [0,1]=OH12, [0,2]=OH13, [1,0]=OH21, [1,2]=OH23, [2,0]=OH31, [2,1]=OH32
TRIANGLE = np.array([[0.0000, 0.1526, 0.1932],
                      [0.0991, 0.0000, 0.1453],
                      [0.0018, 0.0581, 0.0000]])

_hub_raw = np.array([[0.0000, 0.1526, 0.0000],
                      [0.0991, 0.0000, 0.1453],
                      [0.0000, 0.0581, 0.0000]])
HUB_SPOKE = _hub_raw * (TOTAL_MASS / _hub_raw.sum())

_chain_raw = np.array([[0.0000, 0.0000, 0.0000],
                        [0.0991, 0.0000, 0.0000],
                        [0.0000, 0.0581, 0.0000]])
CHAIN = _chain_raw * (TOTAL_MASS / _chain_raw.sum())

TOPOLOGIES = {"triangle": TRIANGLE, "hub_spoke": HUB_SPOKE, "chain": CHAIN}


def alpha_of(oh_offdiag):
    return 1 - OH_diag - oh_offdiag.sum(axis=1) - OF_base


def M_total(oh_offdiag):
    OmH = np.diag(OH_diag) + oh_offdiag
    Minv = np.linalg.inv(np.eye(3) - OmH)
    return Minv @ OF_base


def lambda_D(oh_offdiag):
    OmH = np.diag(OH_diag) + oh_offdiag
    Minv = np.linalg.inv(np.eye(3) - OmH)
    return BH @ Minv


def main():
    rows = []
    for name, oh in TOPOLOGIES.items():
        alpha = alpha_of(oh)
        M = M_total(oh)
        lam = lambda_D(oh)
        indirect = M - OF_base
        print(f"\n=== {name} ===")
        print("OH_offdiag:\n", np.round(oh, 4))
        print("off-diag mass:", round(oh.sum(), 4), " ALPHA:", np.round(alpha, 4))
        print("M_i (total import centrality):", np.round(M, 4))
        print("indirect share:", np.round(indirect / M, 4))
        print("lambda_D:", np.round(lam, 4))
        if any(alpha <= 0):
            print(f"  WARNING: infeasible ALPHA for {name}")
        for i, sec in enumerate(SECTORS):
            rows.append({"topology": name, "sector": sec, "direct": OF_base[i],
                         "total": M[i], "indirect": indirect[i],
                         "indirect_share": indirect[i] / M[i], "lambda_D": lam[i],
                         "alpha": alpha[i]})
    df = pd.DataFrame(rows)
    df.to_csv(os.path.join(RESULTS, "topology_exposure_decomposition.csv"), index=False)
    print(f"\nSaved results/topology_exposure_decomposition.csv")


if __name__ == "__main__":
    main()
