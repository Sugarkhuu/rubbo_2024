# Project: Small Open Economy Extension of Rubbo (2024)

## What this project is
Extending Rubbo (2024) "Networks, Phillips Curves, and Monetary Policy" to a small open economy with FX policy analysis. Presentation deadline: **July 22, 2026**.

## Key files
- `rubbo_2024.pdf` — main paper
- `appendix_website_2.pdf` — appendix with all proofs
- `supplemental_revision.pdf` — supplemental material
- `rubbo_proofs_and_extension.tex` — detailed step-by-step proofs of all Rubbo results + open economy extension outline (compile with Ctrl+Alt+B in VS Code)
- `replication files/` — Rubbo's Matlab replication code and data (gitignored, large)

## GitHub
https://github.com/Sugarkhuu/rubbo_2024

## Current status
User is working through Rubbo's proofs before moving to drafting. All key proofs are already written in the .tex file:
- Lemma 1 (natural output = Domar-weighted TFP)
- Lemma 2 (output gap = employment gap)
- Lemma 3 (output gap = -sales-weighted markup)
- Proposition 2 (sector-level Phillips curves, full Sherman-Morrison derivation)
- Proposition 1 (divine coincidence index, uniqueness proof)
- Proposition 3 (welfare function)
- Lemma 4 (output gap targeting via Taylor rule)
- Open economy extension outline with FX regimes

## Planned paper structure
1. Introduction — position vs Rubbo and La'O & Tahbaz-Salehi (2022, Econometrica)
2. SOE model — N domestic sectors + import sector, UIP, law of one price
3. Phillips curve with ER — Γ·Δe term, network amplification of pass-through
4. Divine coincidence in open economy — breaks down under float (two cost-push channels)
5. Welfare and optimal FX policy — float vs peg vs managed float
6. Quantitative — OECD TiVA data, Matlab simulations reusing Rubbo's code

## Core theoretical contribution
In Rubbo, the DC index is unique because there is one cost-push channel (productivity). In the SOE, there are two channels (productivity + exchange rate). The central result is whether a modified DC index exists under flexible ER, or whether the inflation-output tradeoff is irreducible.

## Key papers to cite
- La'O & Tahbaz-Salehi (2022, Econometrica) — optimal MP in production networks
- Auer, Levchenko & Sauré (2019, ReStud) — international inflation spillovers via IO linkages
- Pasten, Schoenle & Weber (2020, JPE) — MP propagation in heterogeneous production economy
- Fanelli & Straub (2021, JPE) — theory of FX interventions
- Gopinath & Itskhoki (2022) — dominant currency paradigm
- Amiti, Itskhoki & Konings (2019, QJE) — variable markups and pass-through

## Preferences
- Don't ask before taking actions, just do them
- For math: write to .tex file and compile rather than showing raw LaTeX in chat
- VS Code has MiKTeX + LaTeX Workshop installed (Ctrl+Alt+B builds, Ctrl+Alt+V opens preview)
