"""
Calibrate Omega^H, Omega^F, beta^H (and alpha, export shares, Domar weights)
for the 3-sector SOE model from Czechia's Eurostat symmetric input-output table.

DATA SOURCE
-----------
Eurostat, dataset naio_10_cp1700 "Symmetric input-output table at basic prices
(product by product)", geo=CZ, time=2022 (latest year with CZ data published;
2021 and 2023 are empty for CZ in this dataset as of the 2026-07-15 vintage
used here), unit=MIO_EUR. Downloaded via the Eurostat JSON-stat API
(https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/naio_10_cp1700)
into czechia_raw/siot_{total,dom,imp}_2022.json:
  - siot_total_2022.json  stk_flow=TOTAL  (all flows: intermediate + final use
                            rows/cols, PLUS value-added rows B1G/D1/etc. and
                            output row P1 -- these are TOTAL-only concepts,
                            not split by domestic/imported origin)
  - siot_dom_2022.json    stk_flow=DOM    (flows of DOMESTICALLY-produced
                            products only -- used for Omega^H)
  - siot_imp_2022.json    stk_flow=IMP    (flows of IMPORTED products only --
                            used for Omega^F)
All three share the same JSON-stat structure: dimensions
[freq, unit, stk_flow, prd_use, prd_ava, geo, time], with prd_use (columns,
121 categories) = using product/industry (CPA codes) + final-demand
categories (P3_S14 household consumption, P6 exports, ...), and prd_ava
(rows, 123 categories) = supplying product (CPA codes) + value-added/output
rows (B1G, D1, P1, ...). Flat value index = prd_use_idx * len(prd_ava) +
prd_ava_idx (all other dimensions have size 1 after filtering), the standard
JSON-stat 2.0 row-major flattening in dimension-id order.

SECTOR CONCORDANCE (NACE Rev.2 / CPA leaf divisions -> our 3 model sectors)
---------------------------------------------------------------
  Resource      = {A01,A02,A03 agriculture/forestry/fishing, B05-B09 mining}
  Manufacturing = {C10-C33 all manufacturing divisions, D electricity/gas/
                    steam, E36-E39 water/sewage/waste, F41-F43 construction}
  Services      = {G45-G47 trade, H49-H53 transport, I55-I56 accommodation/
                    food, J58-J63 info/comms, K64-K66 finance/insurance,
                    L68A/L68B real estate, M69-M75 professional/scientific,
                    N77-N82 admin/support, O public admin, P education,
                    Q86-Q88 health/social, R90-R93 arts/leisure, S94-S96
                    other services, T97-T98 households as employers, U
                    extraterritorial}
Same concordance logic as build_chile_calibration.py / build_korea_calibration.py:
Resource = upstream/tradable primary sector, Manufacturing = mid-chain
industrial production (+ utilities/construction), Services = downstream,
largely non-tradable. Czechia is the "developed, diversified manufacturing
exporter" case, alongside Korea -- both contrast with Chile's commodity
export structure.

MODEL CONVENTION
----------------
Same as the Chile/Korea scripts: Y_it = A_it L_it^alpha_i * prod_j
X_ijt^Omega^H_ij * M_it^Omega^F_i, Omega^H_ij = buyer i's cost share spent on
domestic sector j's output. In this Eurostat table, prd_ava (rows) = supplying
product i and prd_use (columns) = buyer/using product j directly (no
transpose needed, unlike the Chile/Korea raw sheets): Omega^H_ij =
dom_use_3[i, j] / Y3[j] -- wait, cell[prd_ava=i, prd_use=j] = flow of product
i used BY buyer j, so buyer j's cost share on seller i is
dom_use_3[i, j] / Y3[j], i.e. Omega^H_ji, or equivalently indexing
Omega^H[buyer, seller] = dom_use_3[seller, buyer] / Y3[buyer] -- the same
transpose convention as the other two scripts, since raw[row=supplier,
col=buyer].

OUTPUT
------
Writes czechia_calibration_results.json in the same format as
chile_calibration_results.json / korea_calibration_results.json.
"""

import json
from pathlib import Path

import numpy as np

HERE = Path(__file__).parent
RAW = HERE / "czechia_raw"

MACRO_NAMES = ["Resource", "Manufacturing", "Services"]
N3 = 3

RESOURCE_CODES = ["CPA_A01", "CPA_A02", "CPA_A03", "CPA_B05", "CPA_B06", "CPA_B07", "CPA_B08", "CPA_B09"]
MANUF_CODES = (
    [f"CPA_C{n}" for n in [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33]]
    + ["CPA_D", "CPA_E36", "CPA_E37", "CPA_E38", "CPA_E39", "CPA_F41", "CPA_F42", "CPA_F43"]
)
SERVICES_CODES = [
    "CPA_G45", "CPA_G46", "CPA_G47",
    "CPA_H49", "CPA_H50", "CPA_H51", "CPA_H52", "CPA_H53",
    "CPA_I55", "CPA_I56",
    "CPA_J58", "CPA_J59", "CPA_J60", "CPA_J61", "CPA_J62", "CPA_J63",
    "CPA_K64", "CPA_K65", "CPA_K66",
    "CPA_L68A", "CPA_L68B",
    "CPA_M69", "CPA_M70", "CPA_M71", "CPA_M72", "CPA_M73", "CPA_M74", "CPA_M75",
    "CPA_N77", "CPA_N78", "CPA_N79", "CPA_N80", "CPA_N81", "CPA_N82",
    "CPA_O", "CPA_P",
    "CPA_Q86", "CPA_Q87", "CPA_Q88",
    "CPA_R90", "CPA_R91", "CPA_R92", "CPA_R93",
    "CPA_S94", "CPA_S95", "CPA_S96",
    "CPA_T97", "CPA_T98", "CPA_U",
]
CONCORDANCE = {c: 0 for c in RESOURCE_CODES}
CONCORDANCE.update({c: 1 for c in MANUF_CODES})
CONCORDANCE.update({c: 2 for c in SERVICES_CODES})
LEAF_CODES = list(CONCORDANCE.keys())  # the ~83 leaf product codes used (no aggregate double-counting)


def load_jsonstat(path):
    d = json.loads(path.read_text())
    prd_use_index = d["dimension"]["prd_use"]["category"]["index"]   # code -> col position
    prd_ava_index = d["dimension"]["prd_ava"]["category"]["index"]   # code -> row position
    n_ava = d["size"][4]
    value = {}
    for k, v in d["value"].items():
        value[int(k)] = v
    return prd_use_index, prd_ava_index, n_ava, value


def get_cell(prd_use_index, prd_ava_index, n_ava, value, use_code, ava_code):
    u = prd_use_index[use_code]
    a = prd_ava_index[ava_code]
    return value.get(u * n_ava + a, 0.0)


def aggregate_matrix(prd_use_index, prd_ava_index, n_ava, value):
    """3x3: agg[buyer_macro, seller_macro] = sum of flows FROM seller (prd_ava row)
    TO buyer (prd_use col), over all leaf product codes in each macro-sector."""
    agg = np.zeros((N3, N3))
    for seller_code in LEAF_CODES:
        for buyer_code in LEAF_CODES:
            v = get_cell(prd_use_index, prd_ava_index, n_ava, value, buyer_code, seller_code)
            agg[CONCORDANCE[buyer_code], CONCORDANCE[seller_code]] += v
    return agg


def aggregate_row_over_use(prd_use_index, prd_ava_index, n_ava, value, ava_code):
    """3-vector: sum over buyer (prd_use, leaf codes) of flows from a single
    fixed prd_ava row (e.g. B1G value added, or a product row for exports)."""
    agg = np.zeros(N3)
    for buyer_code in LEAF_CODES:
        v = get_cell(prd_use_index, prd_ava_index, n_ava, value, buyer_code, ava_code)
        agg[CONCORDANCE[buyer_code]] += v
    return agg


def aggregate_col_over_ava(prd_use_index, prd_ava_index, n_ava, value, use_code):
    """3-vector: sum over seller (prd_ava, leaf product codes) of flows into a
    single fixed prd_use column (e.g. P3_S14 household consumption, or P6
    exports)."""
    agg = np.zeros(N3)
    for seller_code in LEAF_CODES:
        v = get_cell(prd_use_index, prd_ava_index, n_ava, value, use_code, seller_code)
        agg[CONCORDANCE[seller_code]] += v
    return agg


def main():
    tu, ta, tn, tval = load_jsonstat(RAW / "siot_total_2022.json")
    du, da, dn, dval = load_jsonstat(RAW / "siot_dom_2022.json")
    iu, ia, in_, ival = load_jsonstat(RAW / "siot_imp_2022.json")

    dom_use_3 = aggregate_matrix(du, da, dn, dval)   # domestic intermediate use, [buyer, seller]
    imp_use_3 = aggregate_matrix(iu, ia, in_, ival)  # imported intermediate use, [buyer, seller]

    # Gross output (P1) and value added (B1G) are TOTAL-only rows in prd_ava,
    # read off against each leaf product's own column in prd_use (own-account
    # output/VA of that product-industry).
    Y3 = np.zeros(N3)
    VA3 = np.zeros(N3)
    for code in LEAF_CODES:
        Y3[CONCORDANCE[code]] += get_cell(tu, ta, tn, tval, code, "P1")
        VA3[CONCORDANCE[code]] += get_cell(tu, ta, tn, tval, code, "B1G")

    hh_cons_3 = aggregate_col_over_ava(tu, ta, tn, tval, "P3_S14")  # household final consumption
    exports_3 = aggregate_col_over_ava(tu, ta, tn, tval, "P6")      # exports

    OmegaH = np.zeros((N3, N3))
    OmegaF = np.zeros(N3)
    alpha = np.zeros(N3)
    for i in range(N3):
        for j in range(N3):
            OmegaH[i, j] = dom_use_3[i, j] / Y3[i]
        OmegaF[i] = imp_use_3[i, :].sum() / Y3[i]
        alpha[i] = VA3[i] / Y3[i]

    raw_sum = alpha + OmegaH.sum(axis=1) + OmegaF
    OmegaH = OmegaH / raw_sum[:, None]
    OmegaF = OmegaF / raw_sum
    alpha = alpha / raw_sum

    betaH = hh_cons_3 / hh_cons_3.sum()
    export_share = exports_3 / Y3

    I3 = np.eye(N3)
    leontief_inv = np.linalg.inv(I3 - OmegaH)
    domar = betaH @ leontief_inv
    import_centrality = leontief_inv @ OmegaF

    # Raw Calvo reset probabilities: NOT identifiable from IO data. Uses the
    # SAME literature-sourced default as the Chile/Korea .mod files (kept in
    # sync by hand -- see the DELTA1-3 comment block there for the full
    # derivation): euro-area monthly price-change frequencies (Dhyne et al.
    # 2005/ECB IPN) converted to a quarterly Calvo reset probability via
    # delta_q = 1-(1-f_monthly)^3, cross-checked against Nakamura & Steinsson
    # (2008) US PPI durations for the Manufacturing sector. Note this ECB IPN
    # estimate is arguably the LEAST arbitrary fit for Czechia specifically,
    # since it is a euro-area estimate and Czechia is deeply integrated into
    # the same EU retail/wholesale price-setting environment -- though the
    # original IPN sample itself (Belgium, Germany, Spain, France, Italy,
    # Luxembourg, Netherlands, Austria, Portugal, Finland) did not include
    # Czechia or any other new-EU-member country.
    BETA = 0.99
    delta = np.array([0.90, 0.31, 0.16])  # Resource, Manufacturing, Services (see .mod file for sourcing)
    dhat = delta * (1 - BETA * (1 - delta)) / (1 - BETA * delta * (1 - delta))
    dc_weight_raw = domar * (1 - dhat) / dhat
    dc_weight = dc_weight_raw / dc_weight_raw.sum()

    results = {
        "source": "Eurostat naio_10_cp1700 (Symmetric input-output table at basic prices, product by product), geo=CZ, time=2022",
        "sectors": MACRO_NAMES,
        "gross_output_mnEUR2022": dict(zip(MACRO_NAMES, Y3.round(1))),
        "OmegaH": [[round(x, 4) for x in row] for row in OmegaH],
        "OmegaF": [round(x, 4) for x in OmegaF],
        "alpha": [round(x, 4) for x in alpha],
        "betaH": [round(x, 4) for x in betaH],
        "export_share_of_own_output": [round(x, 4) for x in export_share],
        "domar_weight": [round(x, 4) for x in domar],
        "import_centrality": [round(x, 4) for x in import_centrality],
        "dc_weight_literature_delta": {
            "note": "delta_i (Calvo reset prob.) not identifiable from IO data; literature-sourced default "
                    "(Dhyne et al. 2005 / ECB IPN, cross-checked vs. Nakamura & Steinsson 2008), "
                    "same value used in the .mod file -- see its DELTA1-3 comment for the full derivation.",
            "delta_raw_used": [round(x, 4) for x in delta],
            "dhat_derived": [round(x, 4) for x in dhat],
            "dc_weight": [round(x, 4) for x in dc_weight],
        },
    }

    out_path = HERE / "czechia_calibration_results.json"
    out_path.write_text(json.dumps(results, indent=2))

    print(f"{'':16s}{'Resource':>12s}{'Manuf.':>12s}{'Services':>12s}")
    print(f"{'Omega^F':16s}" + "".join(f"{v:12.4f}" for v in OmegaF))
    print(f"{'beta^H':16s}" + "".join(f"{v:12.4f}" for v in betaH))
    print(f"{'Export sh.':16s}" + "".join(f"{v:12.4f}" for v in export_share))
    print(f"{'alpha':16s}" + "".join(f"{v:12.4f}" for v in alpha))
    print(f"{'Domar':16s}" + "".join(f"{v:12.4f}" for v in domar))
    print(f"{'Import cent.':16s}" + "".join(f"{v:12.4f}" for v in import_centrality))
    print()
    print("Full domestic IO matrix Omega^H[buyer i, seller j] (dense):")
    print(f"{'':16s}" + "".join(f"{n:>12s}" for n in MACRO_NAMES))
    for i, name in enumerate(MACRO_NAMES):
        print(f"{name:16s}" + "".join(f"{OmegaH[i, j]:12.4f}" for j in range(N3)))
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
