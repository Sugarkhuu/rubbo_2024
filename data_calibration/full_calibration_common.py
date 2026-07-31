"""
Shared logic for the FULL-NATIVE-RESOLUTION calibration variant (N=12/33/83
raw sectors, no collapse to 3 macro-sectors), used by build_chile_calibration.py,
build_korea_calibration.py, build_czechia_calibration.py.

Computes, from a raw NxN Omega^H, N-vectors Omega^F/alpha/betaH/export_share,
and a raw-sector -> {0:Resource,1:Manufacturing,2:Services} category map (used
ONLY to assign the literature Calvo reset probability DELTA_i per raw sector,
per CLAUDE.md's task spec -- everything else is genuine N-resolution data):

  - DELTA_i (raw Calvo reset prob, literature default by category)
  - DHAT_i  (adjusted Calvo parameter)
  - LAMBDA_D_i = betaH' * (I - Omega^H)^-1        (Domar / domestic-supplier centrality)
  - MIMP_i     = (I - Omega^H)^-1 * Omega^F       (import centrality)
  - WDC_i      = normalized DC-index weight

Mirrors the exact formulas already used in each build_*.py main() (3-sector
case) and in open_economy_network_chile.mod's derived-parameters block --
just done once here in numpy at full N instead of duplicated three ways.
"""

import numpy as np

BETA = 0.99
# Literature-sourced Calvo reset probabilities by macro-category (Dhyne et al.
# 2005 / ECB IPN, cross-checked vs. Nakamura & Steinsson 2008) -- see the
# DELTA1-3 comment block in open_economy_network_chile.mod for the full
# derivation. NOT identifiable from IO data at ANY resolution, so every raw
# sector inherits its macro-category's literature value; this categorical
# mapping is used for nothing else in the full-resolution calibration.
DELTA_BY_CATEGORY = np.array([0.90, 0.31, 0.16])  # Resource, Manufacturing, Services


def renormalize_shares(alpha, OmegaH, OmegaF):
    """Rescale (alpha_i, Omega^H_i., Omega^F_i) so they sum to exactly 1 per
    row i, absorbing the basic- vs purchaser-price margins/taxes wedge in the
    raw IO/SUT sheets -- identical normalization step used in every build_*.py
    3-sector main()."""
    raw_sum = alpha + OmegaH.sum(axis=1) + OmegaF
    OmegaH = OmegaH / raw_sum[:, None]
    OmegaF = OmegaF / raw_sum
    alpha = alpha / raw_sum
    return alpha, OmegaH, OmegaF


def compute_full_calibration(OmegaH, OmegaF, alpha, betaH, export_share,
                              category_of_sector, sector_names, source,
                              gross_output=None, gross_output_key=None):
    """category_of_sector: length-N array of ints in {0,1,2} (Resource/Manuf/Services)."""
    N = len(alpha)
    assert OmegaH.shape == (N, N)
    assert len(OmegaF) == N and len(betaH) == N and len(export_share) == N
    assert len(category_of_sector) == N

    delta = DELTA_BY_CATEGORY[np.asarray(category_of_sector)]
    dhat = delta * (1 - BETA * (1 - delta)) / (1 - BETA * delta * (1 - delta))

    I = np.eye(N)
    leontief_inv = np.linalg.inv(I - OmegaH)
    domar = betaH @ leontief_inv                 # LAMBDA_D_i
    import_centrality = leontief_inv @ OmegaF    # MIMP_i

    dc_weight_raw = domar * (1 - dhat) / dhat
    dc_weight = dc_weight_raw / dc_weight_raw.sum()

    results = {
        "source": source,
        "N": N,
        "sector_names": list(sector_names),
        "category_of_sector": [int(c) for c in category_of_sector],
        "category_names": ["Resource", "Manufacturing", "Services"],
        "OmegaH": OmegaH.tolist(),
        "OmegaF": OmegaF.tolist(),
        "alpha": alpha.tolist(),
        "betaH": betaH.tolist(),
        "export_share_of_own_output": export_share.tolist(),
        "domar_weight": domar.tolist(),
        "import_centrality": import_centrality.tolist(),
        "delta_raw_used": delta.tolist(),
        "dhat_derived": dhat.tolist(),
        "dc_weight": dc_weight.tolist(),
    }
    if gross_output is not None and gross_output_key is not None:
        results[gross_output_key] = dict(zip(sector_names, np.round(gross_output, 1).tolist()))
    return results
