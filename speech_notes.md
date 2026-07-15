# Speech Notes — "Exchange Rate Regimes in Production Networks"

Session: 45 min. Target: **~25 min talk**, leaving ~20 min for Q&A.
Timings below sum to ~22 min of talking; the extra ~3 min is slack for pauses,
transitions, and the audience jumping in mid-slide (which they will, on the
Model slides especially).

Each block = what to actually say. It mirrors the slide's bullets — don't add
new claims that aren't on the slide, just say them in full sentences.

---

## Title (0:20)
"Thanks for having me. This is joint work extending Rubbo's 2024 paper on
networks, Phillips curves and monetary policy to a small open economy. I'm
Sugarkhuu Radnaa, Bonn Graduate School of Economics."

## Outline (0:20)
"Quick roadmap: motivation and headline result up front, then the model, then
results, then conclusion. I'll flag when I'm skipping derivation detail —
it's all in the appendix if you want to dig in."

---

## Motivation (0:50)
"Two literatures don't talk to each other. Rubbo, and La'O–Tahbaz-Salehi,
give you network Phillips curves — but closed economy, one cost-push channel,
and a clean divine-coincidence result. Galí–Monacelli give you the open-economy
Phillips curve with an FX channel — but no network, one sector. This paper
puts both together: a multi-sector network *with* an import sector and FX.

[point at diagram] Three sectors in a chain — Resource feeds Manufacturing
feeds Services — plus imports hitting Resource and Manufacturing, and Resource
exporting.

Two questions drive the paper: which FX regime is welfare-optimal, and does
the divine-coincidence index survive having a second cost-push channel now
that FX is in the picture?"

## Headline Result (1:10)
"I'll give you the answer before the model, because it's not the answer you'd
guess. [point at bar chart] Managed float dominates both corners — pegging and
free floating are both worse. Peg is not just worse, it's dominated: with zero
monetary autonomy, the risk-premium shock on the UIP condition passes straight
through into the economy. And the reason Peg loses this badly isn't on-impact
volatility — it's persistence, driven by a near-unit-root net foreign asset
process. I'll come back to exactly why persistence and not volatility later —
that's the mechanism slide.

Units note: everything I show is a welfare loss number times 10 to the minus
4, in consumption-equivalent terms — so 13.64 means a permanent loss of about
0.14% of steady-state consumption. Same scale the whole talk."

## Literature (0:55)
"On the network side: Rubbo gives the unique DC index result in a closed
Calvo network; La'O–Tahbaz-Salehi do optimal policy in networks; Pasten-Schoenle-Weber
show sectoral rigidity heterogeneity drives how monetary policy transmits.

On the open-economy side, no network: Galí–Monacelli is the benchmark — one
sector, domestic-inflation targeting is about optimal, peg is dominated
through a terms-of-trade channel. Fanelli–Straub treat FX intervention as a
second instrument. Schmitt-Grohé–Uribe give us the debt-elastic premium device
to stationarize net foreign assets — and they flag that this can matter
first-order for welfare, which turns out to be exactly right here.

The gap: nobody puts network, open economy, and FX regimes together. We get
the same ranking as Galí–Monacelli — peg dominated — but through a different
channel: the trilemma and risk premium, not terms of trade. Managed's
dominance echoes Fanelli–Straub's two-instrument logic. And the sector
heterogeneity in who prefers what regime is the FX-shock analogue of
Pasten-Schoenle-Weber's transmission result."

## This Paper (0:50)
"Concretely: we extend Rubbo to a small open economy — imported inputs with
cost share Omega-F, UIP, a debt-elastic premium. We ask the two questions from
before. This is not just Galí–Monacelli with sectors bolted on: the regime
ranking looks similar, but the *mechanism* — trilemma and risk premium — and
the sector-level heterogeneity in preferences are genuinely new. We calibrate
to a three-sector oil-exporting economy and solve the nonlinear model
directly, not via hand-linearization."

---

## Model: Households (0:40)
"Standard household side: CRRA-in-consumption, disutility of labor, budget
constraint in home and foreign bonds. Euler equation and labor supply as
usual. The one thing to note: UIP isn't assumed, it's *derived* from the
household's foreign-bond first-order condition, with the debt-elastic premium
psi wedge — that's the Schmitt-Grohé–Uribe device that stationarizes net
foreign assets. I'll come back to why that wedge matters a lot."

## Model: Firms — Technology and Cost (0:50)
"Each sector produces with labor, domestic inputs from other sectors, and
imported inputs, Cobb-Douglas. That gives you marginal cost as a function of
the wage, domestic input prices, and the exchange-rate-adjusted import price.
The key line: marginal cost moves with both TFP and the exchange rate, via
the import share Omega-F. Those are the two cost-push channels — that's the
whole ballgame for the DC-index question later."

## Model: Firms — Calvo Pricing (0:40)
"Calvo pricing, standard reset-price recursion — X1 and X2 auxiliary
variables, reset price is a markup over their ratio. One thing to flag: delta-hat,
the derived slope, is not the primitive Calvo probability — it's a
transformation of it, and it's what actually shows up in the DC weights two
slides from now."

## Model: Open Economy (0:50)
"Three equations: law of one price linking the domestic import price to the
exchange rate and foreign price; UIP with the premium wedge; and the net
foreign asset accumulation equation, funded by exports net of imports, with
exports responding to foreign demand and the terms of trade with elasticity
theta-star. Under float, the interest rate follows a Taylor rule and the
exchange rate is free; under peg, the exchange rate is fixed and the interest
rate is whatever residual clears UIP."

## Model: Policy Regimes and Shocks (0:50)
"Three regimes: Float, standard Taylor rule on DC inflation and the output
gap; Peg, exchange rate fixed, rate is residual; Managed, Taylor rule plus a
lean against exchange-rate deviations with weight phi-s. That phi-s is the
dial we'll optimize over later.

Seven shocks total, though I'll only walk through the headline one live —
sector TFP shocks at 0.90 persistence, import price at 0.85, foreign demand
at 0.80, plus export price and the risk-premium shock, which is the one that
matters most."

## Theory: Regime Comparison — Predictions (0:45)
"Before showing results, here's the naive theoretical prediction. Float has
full monetary independence and endogenous exchange rate, so cost-push gets
absorbed by S-t rather than showing up in inflation and output. Naive
conclusion: float should be best, because it targets a well-defined DC index.
That prediction gets overturned — you'll see why in the Welfare section."

## Does the DC Index Survive? (1:30)
"This is the theory contribution, so let me slow down here. In Rubbo's closed
economy, there's one cost-push channel — TFP — and that gives you a unique
divine-coincidence index: a Domar-and-stickiness-weighted inflation aggregate
that a central bank can target to simultaneously close the output gap and
stabilize welfare-relevant inflation.

Now we have two channels — TFP and FX. For the same DC index to survive, you'd
need the same weight vector phi to satisfy *two* orthogonality conditions at
once — one for the TFP channel, one for the FX channel. Generically that's
infeasible: two conditions, one set of weights, doesn't work unless the
economy sits exactly on a knife edge.

Answer: no, it doesn't survive generically. In this calibration, the two
directions are close — cosine of about 0.96 — but not proportional; the ratio
shifts about two-to-one across sectors. So it's a real breakdown, not a
rounding error.

The fix we use throughout the talk: make the import-pricing node fully
flexible. That collapses the FX channel's own weight to zero and restores a
well-defined DC index — that's the pi-DC you see targeted in every Taylor
rule from here on. Full derivation and the knife-edge algebra are in the
appendix."

---

## Calibration: 3-Sector Oil-Exporting Economy (0:45)
"Calibration: standard preference and price-elasticity parameters on the
left. On the right, sector-specific import shares, consumption shares, and
Calvo probabilities — Resource is upstream and flexible, Manufacturing is
mid-chain, Services is sticky and consumption-dominant. We solve the
nonlinear model at first order and pin down steady state by scalar
root-finding."

## Calibration: Network Properties (1:10)
"Three objects to define once: Domar weight — aggregate importance in the
network; import centrality — how exposed a sector is to imports, directly and
through what it buys; and the DC weight, which combines Domar weight with
stickiness.

[point at bars] The story: FX exposure runs *opposite* to aggregate weight.
Resource has a small Domar weight, 0.12, but it's the most import- and
export-exposed sector by far — 0.30 and 0.65. It's the FX conduit for the
whole network. Services dominates output, 0.80 Domar weight, but is almost
FX-closed directly — its exposure is entirely indirect, through what it buys
upstream. And because the DC weight loads on Domar weight and stickiness,
it's essentially a Services inflation index — 0.93 — even though FX shocks
enter the economy mainly through Resource."

## IRFs: Foreign Risk-Premium (UIP) Shock (1:30)
"This is the shock that decides everything — it alone explains 81% of Peg's
total welfare loss, you'll see that number again in two slides.

[walk top row left to right] A risk-premium shock hits UIP directly. Under
Peg, the exchange rate can't move, so the whole shock is absorbed through the
interest rate and the output gap — look at that output-gap panel, Peg
swings nearly 3 percentage points on impact. Under Float, the exchange rate
depreciates immediately and does most of the absorbing — smaller output and
inflation response.

[bottom two rows, briefly] Sector by sector, same story: Peg's output gap and
inflation swings are an order of magnitude larger than Float's, in every
sector, on impact. Managed sits in between, closer to Float."

## Network Exposure & Sector Welfare Preferences (1:10)
"Same exposure numbers as before, now mapped into two economic objects:
Gamma-i, how much of an FX shock actually passes through to that sector's
marginal cost, and kappa-i, the welfare weight sectoral inflation gets in the
loss function.

[point at table] Resource has by far the highest pass-through, 0.234, but the
lowest welfare weight, 0.43 — its inflation barely matters for welfare.
Services is the reverse: pass-through of 0.006, but a welfare weight of 74.6 —
its inflation is what welfare actually cares about.

Once you include the risk-premium shock, Peg no longer wins for *any* sector
— it's the costliest regime for Resource, Manufacturing, and Services alike.
Managed dominates every sector; Float beats Peg everywhere, most narrowly for
Services."

## Welfare: Headline & Persistence (1:20)
"Same headline bar chart as before, now decomposed on the right into output-gap
loss versus sector-by-sector dispersion loss. Peg's loss is now dominated by
the output-gap bar — that near-3-point swing you just saw. Welfare itself is
the standard Rubbo LQ functional: variance of the output gap, plus a
Domar-and-stickiness-weighted sum of sectoral inflation variances.

Why is this about persistence, not volatility? Under float, the exchange rate
is pinned down by UIP plus a near-unit-root net-foreign-asset process — so it
feeds *every* sector's marginal cost persistently, even in response to a pure
domestic TFP shock that has nothing to do with FX. Take a Services TFP shock:
under Peg, DC inflation overshoots and reverts to zero within a year; under
Float, it starts smaller but barely decays. It's that slow decay under
Float — not a bigger initial hit — that pushes Float's dispersion cost above
Managed's."

## Shock Decomposition of Welfare Cost (1:10)
"Now decompose the welfare loss by shock source instead of by channel.
[point at stacked bars] TFP dominates Float and Managed's losses — that's the
persistence story from the last slide. But for Peg, the risk-premium/UIP bar
is enormous — 81% of Peg's entire loss. That single shock is what reverses
the naive ranking: totals are now Managed 5.36, Float 13.64, Peg 49.63 — Peg
is not remotely competitive with Float anymore.

One caveat I'll return to at the end: this is first-order welfare. The
risk-premium channel — a nonlinear debt-elastic premium interacting with a
near-unit-root process — is exactly where a second-order solution could move
this magnitude the most."

## Generalization: Optimal FX Stabilization phi-s (1:10)
"So if Managed beats both corners, what's the optimal amount of leaning
against the exchange rate? [point at curve] There's a real tradeoff: too
little phi-s and you're close to Float, so the risk-premium shock keeps
leaking into every sector's marginal cost; too much and you're close to Peg,
losing monetary autonomy, letting the same shock through the interest rate
instead. A partial lean absorbs the shock without fully giving up the Taylor
rule.

Loss falls from 13.64 at phi-s equals zero to 4.74 at phi-s equals 0.20 — and
that minimum is peaked, not flat: 0.20 beats our calibrated value of 0.30 by
about 13%. Push past 0.2 and cost rises fast — by phi-s equals 1, you're back
above Float."

## Generalization: Robustness (1:00)
"Two structural sensitivity checks, both on the axes you'd expect to matter
most for an SOE. Ranking — Managed below Float below Peg — holds everywhere
in both panels. But the *gap* moves in opposite directions. Scale up import
intensity kappa, and Peg's loss falls while Float's rises — they converge.
Concentrate FX exposure more on Resource, raising theta, and it's the
opposite — Peg rises, Float falls, they diverge."

## Conclusion (1:30)
"To summarize. Managed float is optimal — 5.36 versus Float's 13.64 and Peg's
49.63. The driver: risk-premium/UIP dominates Peg's loss at 81%, while TFP
persistence dominates Float and Managed's; and Managed dominates every single
sector, not just on average.

Optimal phi-s is about 0.20, sharply peaked — over-stabilizing the exchange
rate is genuinely costly, not free. The ranking is robust to import intensity
and exposure concentration, but the *size* of the gap is not.

Versus the literature: we get Galí–Monacelli's ranking — peg dominated — but
through a different channel, risk-premium rather than terms of trade.

Important caveat: this is first-order dynamics with a second-order welfare
functional — Rubbo's own approach — and it's only valid if the steady state
is efficient. The UIP wedge and the near-unit-root NFA process are
distortions Rubbo's closed economy never had, and that's exactly the
combination Kim–Kim and Schmitt-Grohé–Uribe flag as risky for this kind of
welfare accounting.

Next steps, in priority order: a true second-order solution — since the
risk-premium channel is exactly where first- and second-order welfare are
most likely to diverge — then sensitivity to the stickiness and network
parameters. Thanks — happy to take questions."

---

# Anticipated Questions and Answers

**Q1. Isn't the whole "Peg dominated" result just an artifact of the
debt-elastic-premium device (psi) you use to close the model? If you turned
that off, wouldn't Peg look fine?**
A: The psi wedge is what stationarizes net foreign assets — you need *some*
closing device in any SOE model with incomplete markets, and Schmitt-Grohé–
Uribe's is the standard, least-distortionary choice. It's not optional
machinery we added to bias the result — it's what makes the model
well-defined at all. What *is* a modeling choice is how persistent the
risk-premium shock is (rho ≈ 0.994); that persistence, not the psi device
itself, is what makes Peg's loss so large, and it's on the list for
robustness checks.

**Q2. How sensitive is the ranking to that near-unit-root persistence
assumption for the risk premium / NFA process?**
A: We haven't swept rho directly yet — the robustness slide sweeps import
intensity and exposure concentration instead. Given the mechanism slide shows
persistence, not on-impact volatility, is the driver, I'd expect a lower rho
to shrink Peg's loss and narrow the gap to Float, but Peg's structural
disadvantage — zero autonomy, so the shock isn't absorbed at all — should
survive at any reasonable persistence. That's a natural next robustness cut.

**Q3. "Solve the nonlinear model directly" — you're still doing a first-order
perturbation. What's actually different from Rubbo's approach?**
A: Rubbo hand-linearizes the model on paper before ever coding it up — the
Phillips curves and DC index are analytical objects to start. We instead
write out the full nonlinear system — production, pricing, UIP, NFA
accumulation — and let the solver (order-1 perturbation around a numerically
solved nonlinear steady state) do the linearization. It matters for the
open-economy extension specifically because the steady state itself isn't
closed-form once you add imports, exports, and the debt-elastic premium — we
solve that by scalar root-finding rather than assuming it away.

**Q4. You flag first-order welfare as a caveat — how worried should we
actually be, given Kim–Kim's critique of first-order welfare comparisons?**
A: Fairly worried specifically for the risk-premium channel, less so
elsewhere. Kim–Kim's point bites hardest when there's a first-order-relevant
distortion at steady state — here that's the UIP wedge and the near-unit-root
NFA process, which Rubbo's closed economy never had to deal with. TFP and
domestic-network channels should be on firmer ground since they're closer to
Rubbo's original efficient-steady-state setting. That asymmetry is exactly
why second-order is the top item on the next-steps list, not a generic
disclaimer.

**Q5. How were phi-pi, phi-y, phi-s, theta-star, and psi chosen — estimated,
or picked?**
A: Calibrated, not estimated — phi-pi and phi-y at conventional Taylor-rule
values, theta-star and psi at standard SOE-literature values (Schmitt-Grohé–
Uribe-style). Phi-s is the one we don't take as given: it's the object we
solve for on the Generalization slide, and 0.30 was our calibrated starting
point before we swept it to find the ~0.20 optimum.

**Q6. Only three sectors — does the ranking survive with a realistic
multi-sector network, e.g. from OECD input-output data?**
A: That's the natural next step and it's on the roadmap — reusing Rubbo's
Matlab code with OECD TiVA data for a many-sector, empirically disciplined
network. I'd expect the qualitative ranking (Managed dominant, Peg dominated)
to survive, since it comes from the trilemma/risk-premium mechanism rather
than the specific 3-sector chain — but the sector-level heterogeneity result
is exactly where more granularity could change the picture, since it's driven
by how exposure and Domar weight are distributed across sectors.

**Q7. The DC-index fix relies on import pricing being fully flexible
(delta-hat-M = 1). What if imported inputs are Calvo-sticky too?**
A: Then the FX channel gets its own non-zero DC weight, and you're back to
needing two orthogonality conditions with one set of weights — generically
infeasible, same as the general case on the DC slide. Flexible import pricing
is the assumption that lets a well-defined pi-DC exist at all in this
calibration; it's a modeling choice, not a free result, and I flag it
explicitly for that reason.

**Q8. Isn't "Managed float" just a relabeling of the trilemma tradeoff — you
still don't have independent monetary policy, capital mobility, and a fixed
rate all at once?**
A: Right, Managed doesn't escape the trilemma — it's a point on the
continuum between the two corners, not a fourth option. The result isn't that
you can beat the trilemma; it's that with two cost-push channels the
interior point is welfare-preferred to either corner, which isn't obvious
ex ante — the naive prediction on the Theory slide says corner solutions
(full float) should win.

**Q9. Since the DC weight loads almost entirely on Services, is the central
bank effectively "ignoring" Resource inflation — and is there a welfare cost
to that choice itself, separate from the regime question?**
A: That's a sharp question and it's implicit rather than answered directly
here. The DC weight is derived, not chosen — it falls out of Rubbo's
insulation logic once you fix which sector is FX-flexible. Whether a
central bank targeting pi-DC is leaving welfare on the table by
under-weighting Resource is a distinct question from Float-vs-Peg-vs-Managed,
and it's the kind of thing the appendix's DC-index derivation would let you
probe by comparing pi-DC targeting against the full welfare-optimal
targeting rule directly — we haven't run that comparison yet.

**Q10. Any comparison to actual inflation-targeting oil exporters that run
managed floats in practice (Colombia, Chile, etc.)?**
A: Not yet quantitatively — the calibration is stylized (three sectors, oil
exporter in spirit) rather than fit to a specific country. That's a natural
validation step once the OECD TiVA multi-sector version is running: check
whether the model's optimal phi-s is in the neighborhood of what inflation
targeters with FX intervention actually do.
