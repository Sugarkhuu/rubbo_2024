# Project: Small Open Economy Extension of Rubbo (2024)

Extending Rubbo (2024) "Networks, Phillips Curves, and Monetary Policy" to a small open economy
with FX policy analysis. Presentation given **July 22, 2026**. Post-presentation revision phase
(Christian/Benny/Adam feedback) is done, followed by a full robustness campaign (2026-07-30/31,
~350 additional Dynare solves). A full dissertation-style paper draft now exists:
**`dissertation.tex` / `dissertation.pdf`** (47 pages — intro, literature review, model, theory
with proofs, calibration, results, full robustness section, discussion, appendix). It is a
first complete draft, not a referee-ready submission — see its own §8.2 ("Limitations and
Directions for Future Work") for the concrete remaining gaps (genuinely multi-sector calibration,
estimated risk-premium process, empirical validation section). **Read `dissertation.tex` first**
for a from-scratch orientation — it's the single most complete, current summary of the whole
project, more so than any individual `docs_notes/` file.

## Where things live
Detailed project notes have been split out of this file into `docs_notes/` — read the relevant one
before starting work rather than relying on memory of past sessions:

- **[docs_notes/paper_context.md](docs_notes/paper_context.md)** — what this project is, core
  theoretical contribution, planned paper structure, publication-readiness assessment, key files,
  future extensions (not urgent).
- **[docs_notes/decisions.md](docs_notes/decisions.md)** — design/architecture decisions and the
  reasoning behind them (slide order, template choices, sweep-script crash lessons, bugs caught).
  **Check this before restructuring slides or sweep scripts.**
- **[docs_notes/literature_notes.md](docs_notes/literature_notes.md)** — citation list and the full
  literature-check writeups (Qiu/Wang/Xu/Zanetti 2026, Silva 2024).
- **[docs_notes/model_equations.md](docs_notes/model_equations.md)** — quick-reference summary of
  the Phillips curve, DC index, Domar/import-centrality formulas, welfare function. Full proofs
  remain in `rubbo_proofs_and_extension.tex`.
- **[docs_notes/calibration.md](docs_notes/calibration.md)** — data sources, key parameters,
  toolchain invocations, sweep inventory.
- **[docs_notes/results_summary.md](docs_notes/results_summary.md)** — headline welfare numbers,
  the post-presentation-revision findings, the three follow-up exercises, and the full robustness
  campaign (psi/rigidity × network density, alt topologies, regime-rule variants). This is the
  primary source `dissertation.tex`'s results/robustness sections were written from.
- **[docs_notes/slides_outline.md](docs_notes/slides_outline.md)** — deck structure/slide order and
  style constraints to respect when editing `soe_fx_presentation.tex`.
- `speech_feedback_20260722.txt` — raw feedback notes from Christian/Benny/Adam (source of the
  post-presentation revision work), plus a later follow-up reply from Christian appended to it.
- `speech_notes.md` — full talk script + anticipated Q&A, kept in sync with the deck.

## Known gap: the deck is stale relative to the paper
`soe_fx_presentation.tex` does **not** yet reflect the full robustness campaign or
`dissertation.tex` — that was a deliberate scope decision when the campaign was run (paper/
robustness work, not deck content, unless asked). If a next session is asked to update the
presentation, treat it as a fresh, not-yet-started task.

## GitHub
https://github.com/Sugarkhuu/rubbo_2024

## Preferences
- Don't ask before taking actions, just do them.
- For math: write to a `.tex` file and compile rather than showing raw LaTeX in chat.
- VS Code has MiKTeX + LaTeX Workshop installed (Ctrl+Alt+B builds, Ctrl+Alt+V opens preview).
- Python is at `C:\Users\sugarkhuu\anaconda3` (not on PATH for Bash — `python`/`python3`/`py` all
  resolve to non-functional Windows Store stubs). Invoke directly, e.g.
  `"/c/Users/sugarkhuu/anaconda3/python.exe" script.py` from Bash. Has matplotlib/PIL available.
  Used for `figs/*.py` scripts that generate presentation figures — regenerate the `.pdf`/`.png` by
  re-running the script after editing it, then recompile the deck.
- MATLAB is at `C:\Program Files\MATLAB\R2018a\bin\matlab.exe`, Dynare at `C:\dynare\6.3\matlab`
  (`addpath` it, then `addpath('code')`, before calling any sweep function). Typical invocation from
  Bash: `"/c/Program Files/MATLAB/R2018a/bin/matlab.exe" -wait -nosplash -logfile <log> -r "try; addpath('C:\dynare\6.3\matlab'); addpath('code'); <call>; catch e; disp(getReport(e)); end; exit"`.
  One Dynare solve (Chile calibration, order=1) takes ~20-30s wall time including MATLAB startup.
- **Multi-point sweep pattern (load-bearing — see `docs_notes/decisions.md` for the crash history):**
  write sweep `.m` files as a function taking one grid point, called once per fresh MATLAB process
  from a bash driver script, each appending one row to a results CSV. Never loop many `dynare` calls
  inside one MATLAB session — regex-strip `graph_format=pdf`→`nograph` in any generated `.mod` text.
  Also: never edit a master `.mod` file while a background sweep sourced from it is still running.
- Launching a long MATLAB run via Bash: use `run_in_background: true` on the Bash call itself; do
  **not** additionally append `&`/`nohup` inside the command string — that double-backgrounds it and
  loses the ability to track real completion.
