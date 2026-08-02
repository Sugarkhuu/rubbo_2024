"""
Calibrate Omega^H, Omega^F, beta^H (and alpha, export shares, Domar weights)
for the 3-sector SOE model from Chile's official national input-output table.

DATA SOURCE
-----------
Banco Central de Chile, "Cuentas Nacionales de Chile - Matriz Insumo Producto".
**2008-vintage 12x12 CdeR table** (base year 2008 -- this is the table actually
supplied for this project on 2026-08-02; an earlier session's docstring assumed
a "2023 vintage" table that was never actually downloaded/present, and this
replaces that placeholder assumption). Values in millions of 2008 CLP.
Files used:
  - mip_12x12.xlsx  "MIP 12x12"       -> not used by this script (kept for reference)
  - cou_12x12.xlsx  "Cuadros 12x12"   -> Supply-Use tables, 35 numbered sheets across four
        price-basis blocks (user prices 1-13, producer prices 14-22, basic prices 23-31,
        plus production/investment matrices 32-35). This script uses the BASIC-PRICES block:
        sheet 27  Cuadrante de utilizacion intermedia NACIONAL, precios basicos   (domestic use)
        sheet 30  Cuadrante de utilizacion intermedia IMPORTADA, precios basicos  (imported use)
        sheet 28  Cuadrante de utilizacion final NACIONAL, precios basicos        (household
                                                                                    consumption, exports)
        sheet 7   Cuadrante de valor agregado                                    (intermediate
                                                                                    consumption & value
                                                                                    added by activity)
  Layout quirks specific to this vintage (handled in the reader functions below): product/activity
  codes are stored as strings, not ints; zero cells are empty strings, not None; the domestic- and
  imported-use matrices carry an extra 13th PRODUCT row (no matching 13th activity column -- a
  margins/taxes residual, not a real sector) which is dropped rather than aggregated into any of
  the 12 real sectors; the final-use sheet's column headers span 2-3 physical rows per column.

Both tables use the Central Bank's 2008 12-activity classification (see SECTOR_NAMES below) --
NOTE this is a different 12-way split than a later CdeR vintage might use (e.g. this vintage
splits Pesca from Agropecuario, and groups Servicios de vivienda separately from other services).

SECTOR CONCORDANCE (12 CdeR-2008 activities -> our 3 model sectors)
---------------------------------------------------------------
  Resource      = {1 Agropecuario-silvicola, 2 Pesca, 3 Mineria}
  Manufacturing = {4 Industria manufacturera, 5 Electricidad/gas/agua, 6 Construccion}
  Services      = {7 Comercio-hoteles-restaurantes, 8 Transporte y comunicaciones,
                   9 Intermediacion financiera y servicios empresariales, 10 Servicios de
                   vivienda, 11 Servicios personales, 12 Administracion publica}

This mirrors the paper's story: Resource = upstream/tradable primary sector (mining is Chile's
copper-export engine, the real-world analogue of an "oil exporter"), Manufacturing = mid-chain
industrial production, Services = downstream, largely non-tradable, consumption-heavy sector.

MODEL CONVENTION
----------------
The model writes  Y_it = A_it L_it^alpha_i * prod_j X_ijt^Omega^H_ij * M_it^Omega^F_i,
i.e. Omega^H_ij is sector i's (the BUYER's) cost share spent on domestic sector j's output,
and alpha_i + sum_j Omega^H_ij + Omega^F_i = 1 (three cost shares: labor, domestic inputs,
imports -- there is no separate capital factor, so "alpha_i" here is read as the *total*
value-added share, i.e. labor + capital + net taxes together, since the model has no
explicit capital input).

The raw IO sheets are Product (row) x Activity (column), i.e. entry [j, i] = flow FROM
supplying sector j TO using activity i. So Omega^H_ij (buyer i, seller j) = raw[j, i] / Y_i,
which is the TRANSPOSE of the raw sheet.

OUTPUT
------
Prints an old-vs-new comparison table and writes chile_calibration_results.json with the
full aggregated Omega^H (3x3), Omega^F, alpha, beta^H, export shares, Domar weights and
DC weights (using the same formulas as the presentation's Network Properties slide).
"""

import json
from pathlib import Path

import numpy as np
import openpyxl

from full_calibration_common import compute_full_calibration, renormalize_shares

HERE = Path(__file__).parent

SECTOR_NAMES = {
    1: "Agropecuario-silvicola",
    2: "Pesca",
    3: "Mineria",
    4: "Industria manufacturera",
    5: "Electricidad, gas y agua",
    6: "Construccion",
    7: "Comercio, hoteles y restaurantes",
    8: "Transporte y comunicaciones",
    9: "Intermediacion financiera y servicios empresariales",
    10: "Servicios de vivienda",
    11: "Servicios personales",
    12: "Administracion publica",
}

# 12 CdeR-2008 activities -> {0: Resource, 1: Manufacturing, 2: Services}
CONCORDANCE = {
    1: 0, 2: 0, 3: 0,
    4: 1, 5: 1, 6: 1,
    7: 2, 8: 2, 9: 2, 10: 2, 11: 2, 12: 2,
}
MACRO_NAMES = ["Resource", "Manufacturing", "Services"]
N12, N3 = 12, 3


def _cell_num(v):
    """Robust numeric coercion: this vintage stores zero cells as empty strings ('')
    rather than None, and some cells carry stray whitespace."""
    if v is None:
        return 0.0
    if isinstance(v, str):
        v = v.strip()
        if v == "":
            return 0.0
    return float(v)


def _cell_code(v):
    """Robust product/activity code coercion: this vintage stores codes as strings."""
    if v is None:
        return None
    return str(v).strip()


def read_matrix_sheet(wb, sheet_name):
    """Read a 'Producto x Actividad' matrix from a COU sheet (12 activity columns).
    This vintage's domestic/imported-use sheets carry a 13th PRODUCT row (a margins/
    taxes residual with no matching activity column) after the 12 real sectors --
    read only the first 12 product rows and drop the 13th, since it cannot be
    attributed to any of the 12 real selling sectors (see module docstring)."""
    ws = wb[sheet_name]
    # header row holds column activity codes 1..12 in columns C..N (col index 3..14);
    # data rows hold the product code in column C (index 3) and values in D..O (4..15)
    header_row = None
    for r in range(1, 15):
        vals = [ws.cell(row=r, column=c).value for c in range(3, 15)]
        if vals == list(range(1, 13)):
            header_row = r
            break
    if header_row is None:
        raise ValueError(f"Could not locate 1..12 header row in sheet {sheet_name}")

    data_start = None
    for r in range(header_row + 1, header_row + 6):
        if _cell_code(ws.cell(row=r, column=2).value) == "1":
            data_start = r
            break
    if data_start is None:
        raise ValueError(f"Could not locate data start row in sheet {sheet_name}")

    mat = np.zeros((N12, N12))
    for i in range(N12):
        row = data_start + i
        product_code = _cell_code(ws.cell(row=row, column=2).value)
        assert product_code == str(i + 1), (sheet_name, row, product_code)
        for j in range(N12):
            v = ws.cell(row=row, column=3 + j).value
            mat[i, j] = _cell_num(v)
    return mat  # mat[product_row, activity_col] = flow from product (row) to activity (col)


def read_final_use_sheet(wb, sheet_name):
    """Read a 'Utilizacion final ...' sheet: returns dict of column-name -> length-12 vector,
    indexed by product 1..12. This vintage's column headers span 2-3 physical rows per
    column (e.g. 'Consumo' / 'de hogares'), interleaved with blank spacer columns, so the
    header is located by anchoring on the 'Producto' label rather than a fixed row/column
    offset, then concatenating the header rows beneath it."""
    ws = wb[sheet_name]
    anchor_row = None
    for r in range(1, 20):
        if ws.cell(row=r, column=2).value == "Producto":
            anchor_row = r
            break
    if anchor_row is None:
        raise ValueError(f"Could not find 'Producto' header anchor in {sheet_name}")

    col_names = {}
    for c in range(4, 20, 2):
        parts = [str(ws.cell(row=r, column=c).value).strip()
                 for r in range(anchor_row, anchor_row + 3)
                 if ws.cell(row=r, column=c).value]
        name = " ".join(parts).strip()
        if name:
            col_names[c] = name

    data_start = None
    for r in range(anchor_row + 3, anchor_row + 10):
        if _cell_code(ws.cell(row=r, column=2).value) == "1":
            data_start = r
            break
    if data_start is None:
        raise ValueError(f"Could not locate data start row in {sheet_name}")

    out = {name: np.zeros(N12) for name in col_names.values()}
    for i in range(N12):
        row = data_start + i
        product_code = _cell_code(ws.cell(row=row, column=2).value)
        assert product_code == str(i + 1), (sheet_name, row, product_code)
        for c, name in col_names.items():
            out[name][i] = _cell_num(ws.cell(row=row, column=c).value)
    return out


def read_value_added_sheet(wb, sheet_name="7"):
    """Returns (intermediate_consumption[12], value_added[12]) by ACTIVITY (not product)."""
    ws = wb[sheet_name]
    header_row = None
    for r in range(1, 15):
        vals = [ws.cell(row=r, column=c).value for c in range(4, 16)]
        if vals == list(range(1, 13)):
            header_row = r
            break
    if header_row is None:
        raise ValueError("Could not find activity header row in value-added sheet")

    def row_values(label):
        for r in range(header_row + 1, header_row + 6):
            if ws.cell(row=r, column=2).value == label:
                return np.array([float(ws.cell(row=r, column=4 + j).value or 0.0) for j in range(N12)])
        raise ValueError(f"Row '{label}' not found")

    ci = row_values("Consumo intermedio")
    va = row_values("Valor agregado")
    return ci, va


def aggregate_matrix(mat12):
    """Aggregate a 12x12 [product_row, activity_col] flow matrix to 3x3 macro-sector flows."""
    agg = np.zeros((N3, N3))
    for i in range(N12):
        for j in range(N12):
            agg[CONCORDANCE[i + 1], CONCORDANCE[j + 1]] += mat12[i, j]
    return agg


def aggregate_vector(vec12):
    agg = np.zeros(N3)
    for i in range(N12):
        agg[CONCORDANCE[i + 1]] += vec12[i]
    return agg


def main():
    mip = openpyxl.load_workbook(HERE / "mip_12x12.xlsx", data_only=True)
    cou = openpyxl.load_workbook(HERE / "cou_12x12.xlsx", data_only=True)

    dom_use = read_matrix_sheet(cou, "27")   # domestic intermediate use, product x activity (basic prices)
    imp_use = read_matrix_sheet(cou, "30")   # imported intermediate use, product x activity (basic prices)
    final_nat = read_final_use_sheet(cou, "28")  # national final use (household C, exports, ...)
    ci_by_activity, va_by_activity = read_value_added_sheet(cou, "7")

    gross_output_12 = ci_by_activity + va_by_activity  # Y_i, 12 activities

    # --- aggregate to 3 macro-sectors ---
    dom_use_3 = aggregate_matrix(dom_use)     # [product_row, activity_col], 3x3
    imp_use_3 = aggregate_matrix(imp_use)     # [product_row, activity_col], 3x3
    Y3 = aggregate_vector(gross_output_12)    # gross output by macro activity
    VA3 = aggregate_vector(va_by_activity)
    hh_cons_3 = aggregate_vector(final_nat["Consumo de hogares"])
    exports_3 = aggregate_vector(final_nat["Exportaciones"])

    # Omega^H[i,j] = buyer i's cost share spent on domestic sector j
    #              = dom_use_3[j, i] / Y3[i]   (transpose: raw is [seller_row, buyer_col])
    OmegaH = np.zeros((N3, N3))
    OmegaF = np.zeros(N3)
    alpha = np.zeros(N3)
    for i in range(N3):
        for j in range(N3):
            OmegaH[i, j] = dom_use_3[j, i] / Y3[i]
        OmegaF[i] = imp_use_3[:, i].sum() / Y3[i]
        alpha[i] = VA3[i] / Y3[i]

    # Cost shares should sum to ~1; renormalize to absorb margins/taxes wedge (basic- vs
    # purchaser-price gap in the raw sheets), a standard step when mapping SUT data to a
    # Cobb-Douglas cost identity.
    raw_sum = alpha + OmegaH.sum(axis=1) + OmegaF
    OmegaH = OmegaH / raw_sum[:, None]
    OmegaF = OmegaF / raw_sum
    alpha = alpha / raw_sum

    betaH = hh_cons_3 / hh_cons_3.sum()
    export_share = exports_3 / Y3  # share of sector's OWN output that is exported

    # --- network objects, same formulas as the presentation ---
    I3 = np.eye(N3)
    leontief_inv = np.linalg.inv(I3 - OmegaH)          # (I - Omega^H)^{-1}
    domar = betaH @ leontief_inv                        # lambda_D,i
    import_centrality = leontief_inv @ OmegaF           # M_i = [(I-OmegaH)^-1 Omega^F 1]_i

    # Raw Calvo reset probabilities: NOT identifiable from IO data. No
    # country-specific sector-level price-microdata estimate was found for
    # Chile, so this uses the SAME literature-sourced default as the
    # open_economy_network_{chile,korea,czechia}.mod files (kept in sync by
    # hand -- see the DELTA1-3 comment block there for the full derivation):
    # euro-area monthly price-change frequencies (Dhyne et al. 2005/ECB IPN)
    # converted to a quarterly Calvo reset probability via
    # delta_q = 1-(1-f_monthly)^3, cross-checked against Nakamura & Steinsson
    # (2008) US PPI durations for the Manufacturing sector.
    BETA = 0.99
    delta = np.array([0.90, 0.31, 0.16])  # Resource, Manufacturing, Services (see .mod file for sourcing)
    dhat = delta * (1 - BETA * (1 - delta)) / (1 - BETA * delta * (1 - delta))
    dc_weight_raw = domar * (1 - dhat) / dhat
    dc_weight = dc_weight_raw / dc_weight_raw.sum()

    results = {
        "source": "Banco Central de Chile, Cuadros 12x12, ano base 2008 (precios basicos)",
        "sectors": MACRO_NAMES,
        "gross_output_bnCLP2023": dict(zip(MACRO_NAMES, Y3.round(1))),
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

    out_path = HERE / "chile_calibration_results.json"
    out_path.write_text(json.dumps(results, indent=2))

    # --- print old (invented) vs new (data-based) comparison ---
    old = {
        "OmegaH_21": 0.20, "OmegaH_32": 0.25,
        "OmegaF": [0.30, 0.10, 0.05],
        "betaH": [0.05, 0.15, 0.80],
        "export_share": [0.65, 0.20, 0.00],
    }
    print("=" * 70)
    print("OLD (invented) vs NEW (Chile IO 2008-vintage CdeR) calibration")
    print("=" * 70)
    print(f"{'':16s}{'Resource':>12s}{'Manuf.':>12s}{'Services':>12s}")
    print(f"{'Omega^F (new)':16s}" + "".join(f"{v:12.4f}" for v in OmegaF))
    print(f"{'Omega^F (old)':16s}" + "".join(f"{v:12.2f}" for v in old['OmegaF']))
    print(f"{'beta^H (new)':16s}" + "".join(f"{v:12.4f}" for v in betaH))
    print(f"{'beta^H (old)':16s}" + "".join(f"{v:12.2f}" for v in old['betaH']))
    print(f"{'Export sh.(new)':16s}" + "".join(f"{v:12.4f}" for v in export_share))
    print(f"{'Export sh.(old)':16s}" + "".join(f"{v:12.2f}" for v in old['export_share']))
    print(f"{'alpha (new)':16s}" + "".join(f"{v:12.4f}" for v in alpha))
    print(f"{'Domar (new)':16s}" + "".join(f"{v:12.4f}" for v in domar))
    print(f"{'Import cent.new':16s}" + "".join(f"{v:12.4f}" for v in import_centrality))
    print()
    print("Full domestic IO matrix Omega^H[buyer i, seller j] (new, dense, NOT triangular):")
    print(f"{'':16s}" + "".join(f"{n:>12s}" for n in MACRO_NAMES))
    for i, name in enumerate(MACRO_NAMES):
        print(f"{name:16s}" + "".join(f"{OmegaH[i, j]:12.4f}" for j in range(N3)))
    print(f"\n(old model only had Omega^H_21={old['OmegaH_21']}, Omega^H_32={old['OmegaH_32']}, "
          f"rest zero -- i.e. a pure triangular chain)")
    print(f"\nWrote {out_path}")


def build_full():
    """Full-native-resolution (N=12) calibration: skip the Resource/Manuf/
    Services aggregation step entirely and keep the raw 12x12 CdeR activity
    table as-is. This is the new HEADLINE calibration (see CLAUDE.md task);
    the 3-sector main() above is retained for historical/robustness reference."""
    mip = openpyxl.load_workbook(HERE / "mip_12x12.xlsx", data_only=True)
    cou = openpyxl.load_workbook(HERE / "cou_12x12.xlsx", data_only=True)

    dom_use = read_matrix_sheet(cou, "27")
    imp_use = read_matrix_sheet(cou, "30")
    final_nat = read_final_use_sheet(cou, "28")
    ci_by_activity, va_by_activity = read_value_added_sheet(cou, "7")

    Y12 = ci_by_activity + va_by_activity
    hh_cons_12 = final_nat["Consumo de hogares"]
    exports_12 = final_nat["Exportaciones"]

    OmegaH = np.zeros((N12, N12))
    OmegaF = np.zeros(N12)
    alpha = np.zeros(N12)
    for i in range(N12):
        for j in range(N12):
            OmegaH[i, j] = dom_use[j, i] / Y12[i]   # buyer i, seller j (transpose of raw sheet)
        OmegaF[i] = imp_use[:, i].sum() / Y12[i]
        alpha[i] = va_by_activity[i] / Y12[i]

    alpha, OmegaH, OmegaF = renormalize_shares(alpha, OmegaH, OmegaF)

    betaH = hh_cons_12 / hh_cons_12.sum()
    export_share = exports_12 / Y12

    category_of_sector = [CONCORDANCE[i + 1] for i in range(N12)]
    sector_names = [SECTOR_NAMES[i + 1] for i in range(N12)]

    results = compute_full_calibration(
        OmegaH, OmegaF, alpha, betaH, export_share, category_of_sector, sector_names,
        source="Banco Central de Chile, Cuadros 12x12, ano base 2008 (precios basicos) "
               "(FULL 12-activity resolution, no 3-sector aggregation)",
        gross_output=Y12, gross_output_key="gross_output_bnCLP2023",
    )

    out_path = HERE / "chile_calibration_full_results.json"
    out_path.write_text(json.dumps(results, indent=2))
    print(f"\n[full-resolution] N=12 Chile calibration written to {out_path}")
    print(f"  sum(alpha)/N = {np.mean(alpha):.4f}, min/max OmegaH row-sum+alpha+OF = "
          f"{np.min(alpha+OmegaH.sum(1)+OmegaF):.6f}/{np.max(alpha+OmegaH.sum(1)+OmegaF):.6f} (should be 1.0)")
    print(f"  Domar weights (sector-order as in SECTOR_NAMES): {np.round(results['domar_weight'],4)}")
    return results


if __name__ == "__main__":
    main()
    build_full()
