# Speech Notes — "Exchange Rate Regimes in Production Networks"

Session: 45 min. Target: **~25 min talk**, leaving ~20 min for Q&A.
Timings below sum to ~20.5 min of talking; the extra slack is for pauses,
transitions, and the audience jumping in mid-slide (which they will, on the
Model slides especially).

Each block = what to actually say. It mirrors the slide's bullets — don't add
new claims that aren't on the slide, just say them in full sentences.

Deck is 4:3, single-column throughout except the 7 IRF slides (2-panel pairs,
by design — the only place two columns are used, because a single vertical
stack made the charts illegible).

**One number-hygiene note for the speaker, not the audience:** most results
slides (Headline, Welfare, Shock Decomposition, Network Exposure, Mechanisms,
Robustness) use the actual **Chile calibration** (Float 25.47, Managed 10.17,
Peg 102.05, $\times10^{-4}$). Three slides — the two Generalization sweeps
and Isolating the Network Channel — run on the **stylized triangular
network** instead, because that's the one built to vary continuously (import
scale $\kappa$, exposure concentration $\theta$, network density $\rho$,
$\phi_s$). Its baseline numbers (Float 13.64, Managed 5.36, Peg 49.63) are
smaller than Chile's and intentionally different — the slides now say so
explicitly. Don't accidentally quote a stylized number as if it were Chile's,
or vice versa.

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
4, in consumption-equivalent terms — so 10.17 means a permanent loss of about
0.10% of steady-state consumption. Same scale the whole talk. And this is the
real number: calibrated to Chile's actual national input-output table, not a
stylized economy — Float 25.47, Managed 10.17, Peg 102.05. Solved as the
genuine nonlinear model, not hand-linearized."

## Literature (0:45)
"On the network side: Rubbo gives the unique DC index result in a closed
Calvo network; La'O–Tahbaz-Salehi do optimal policy in networks; Pasten-Schoenle-Weber
show sectoral rigidity heterogeneity drives how monetary policy transmits.

On the open-economy side: Galí–Monacelli is the one-sector benchmark, peg
dominated through a terms-of-trade channel; Fanelli–Straub treat FX
intervention as a second instrument; Schmitt-Grohé–Uribe give the debt-elastic
premium that stationarizes net foreign assets and flag first-order welfare
risk from it — exactly right here. Closest to us: an ECB working paper by
Gnocato, Montes-Galdón & Stamato, and Kalemli-Özcan et al., both put a network
*inside* an open economy — but they fix the Taylor rule and never compare FX
regimes; details are in the appendix if asked.

The gap: nobody puts network, open economy, and FX regime choice together in
one model. We get Galí–Monacelli's ranking — peg dominated — but through a
different channel: the trilemma and risk premium, not terms of trade. A full
paper-by-paper comparison table is in the appendix."

## This Paper (0:45)
"Concretely: we extend Rubbo to a small open economy — imported inputs with
cost share Omega-F, UIP, a debt-elastic premium. We ask the two questions from
before. The novelty is crossing three literatures that don't fully overlap —
network only, open economy only, or network-plus-open-economy without regime
choice — we're the first to put all three together. This is not just
Galí–Monacelli with sectors bolted on: the ranking looks similar, but the
mechanism — trilemma and risk premium — and the sector-level heterogeneity in
preferences are genuinely new. We calibrate to Chile's real input-output
table, cross-check against Korea and Czechia, and solve the nonlinear model
directly, not via hand-linearization."

---

## Model: Overview (1:00)
"Three blocks, quickly. Households: standard CRRA-in-consumption,
disutility of labor, Euler equation, labor supply as usual — the one thing to
flag is that UIP isn't assumed, it's *derived* from the household's
foreign-bond first-order condition, with a debt-elastic risk-premium wedge,
the Schmitt-Grohé–Uribe device that stationarizes net foreign assets.

Firms: Cobb-Douglas in labor, domestic network inputs, and imports. Marginal
cost moves with both sectoral TFP and the exchange-rate-adjusted import cost —
those are the two cost-push channels, that's the whole ballgame for the
DC-index question later. Calvo pricing on top, standard reset-price
recursion, sector-specific stickiness giving heterogeneous slopes.

Open economy: law of one price links the import price to the exchange rate;
UIP closes the FX block; net foreign assets accumulate via the current
account, with exports responding to foreign demand and the terms of trade.

Key takeaway: same network structure as Rubbo, plus an exchange-rate
cost-push channel running through imported inputs. Full equations in the
appendix."

## Model: Policy Regimes and Shocks (0:45)
"Three regimes: Float, standard Taylor rule on DC inflation and the output
gap, exchange rate fully endogenous via UIP; Peg, exchange rate fixed, the
interest rate is whatever residual clears UIP; Managed, Taylor rule plus a
lean against exchange-rate deviations with weight phi-s — that's the dial
we'll optimize over later.

Seven shocks total in the full model, though I'll only walk through the
headline one live — sector TFP shocks at 0.90 persistence, import price at
0.85, foreign demand at 0.80 — plus export price and the risk-premium shock,
which turns out to matter most."

## Theory: Regime Comparison — Predictions (0:35)
"Before showing results, here's the naive theoretical prediction. Float has
full monetary independence and an endogenous exchange rate, so cost-push gets
absorbed by S-t rather than showing up in inflation and output. Naive
conclusion: float should be best. That prediction gets overturned — you'll
see why in the Welfare section."

## Does the DC Index Survive? (1:20)
"This is the theory contribution, so let me slow down here. In Rubbo's closed
economy, there's one cost-push channel — TFP — and that gives you a unique
divine-coincidence index: a Domar-and-stickiness-weighted inflation aggregate
a central bank can target to simultaneously close the output gap and
stabilize welfare-relevant inflation.

Now we have two channels — TFP and FX. For the same DC index to survive, the
same weight vector phi would need to satisfy *two* orthogonality conditions at
once — one for TFP, one for FX. Generically that's infeasible: two conditions,
one set of weights, doesn't work unless the economy sits exactly on a knife
edge.

Answer: no, it doesn't survive generically. In this calibration, the two
directions are close — cosine of about 0.96 — but not proportional. So it's a
real breakdown, not a rounding error.

The fix we use throughout the talk: make the import-pricing node fully
flexible. That collapses the FX channel's own weight to zero and restores a
well-defined DC index — the pi-DC targeted in every Taylor rule from here on.
Full derivation and the knife-edge algebra are in the appendix."

---

## Calibration: Chile, Real IO Data (0:50)
"Calibration is the actual Chilean national input-output table — Banco
Central de Chile, 12 activities collapsed to our 3 sectors: Resource is
mining and agriculture, Chile's export engine — 60% of its own output is
exported, mostly copper; Manufacturing is mid-chain; Services is the largest
value-added sector and the stickiest. Import and export shares, the full
9-entry domestic input-output matrix, consumption shares — all data, no
triangular assumption. Calvo stickiness comes from the literature — euro-area
price-change frequencies, cross-checked against US PPI evidence. Everything
else is standard SOE-literature values. Solved nonlinear, order 1."

## Calibration: Network Properties (1:00)
"Three objects to define once: Domar weight — aggregate importance in the
network; import centrality — how exposed a sector is to imports, directly and
through what it buys; and the DC weight, which combines Domar weight with
stickiness.

[point at bars] The story: FX exposure runs *opposite* to aggregate weight.
Resource has a small Domar weight, 0.07, but it's the most FX-exposed sector
and by far the biggest exporter — 60% of its own output. It's the FX conduit
for the whole network. Services dominates output, Domar weight over 1, but is
almost FX-closed directly — its exposure is entirely indirect, through what it
buys upstream. And because the DC weight loads on Domar weight and
stickiness, it's essentially a Services inflation index — 0.93 — even though
FX shocks enter the economy mainly through Resource."

## IRFs: Foreign Risk-Premium Shock — the Key Mechanism (1:20)
"This is the shock that decides everything — it alone explains 75% of Peg's
total welfare loss in the Chile calibration, you'll see that number again in
a few slides.

[top row] A risk-premium shock hits UIP directly. Under Peg, the exchange
rate can't move, so the whole shock is absorbed through the interest rate and
the output gap — look at that output-gap panel, Peg swings more than 5
percentage points on impact. Under Float, the exchange rate depreciates
immediately and does most of the absorbing.

[bottom two rows, briefly] Sector by sector, same story: Peg's output gap and
inflation swings are an order of magnitude larger than Float's, in every
sector, on impact. Managed sits in between, closer to Float. Same
line-style-for-regime, color-for-sector convention as the rest of the deck."

## Network Exposure & Sector Welfare Preferences (1:05)
"Same exposure numbers as before, now mapped into two economic objects:
Gamma-i, how much of an FX shock actually passes through to that sector's
marginal cost, and kappa-i, the welfare weight sectoral inflation gets in the
loss function.

[point at table] Resource has by far the highest pass-through, 1.09, but the
lowest welfare weight, 0.07 — its inflation barely matters for welfare.
Services is the reverse: pass-through under 0.0001, but a welfare weight of
276 — its inflation is what welfare actually cares about.

[bottom bars] Once you include the risk-premium shock, Managed dominates
every sector. Peg is costliest for Resource and Manufacturing; for Services,
Float is actually costliest — 20.73 versus Peg's 16.79 — because the
near-unit-root exchange rate under Float feeds the stickiest sector's
marginal cost for a long time."

## Welfare: Headline & Persistence (1:10)
"Same headline bar chart as before, now decomposed into output-gap loss
versus sector-by-sector dispersion loss. Peg's loss is now dominated by the
output-gap bar — that 5-plus-point swing you just saw, 79.5 out of Peg's
102.05 total. Welfare itself is the standard Rubbo LQ functional: variance of
the output gap, plus a Domar-and-stickiness-weighted sum of sectoral inflation
variances.

Why is this about persistence, not volatility? Under float, the exchange rate
is pinned down by UIP plus a near-unit-root net-foreign-asset process — so it
feeds *every* sector's marginal cost persistently, even for a pure domestic
TFP shock that has nothing to do with FX. It's that slow decay under Float —
not a bigger initial hit — that pushes Float's Services dispersion cost above
Managed's."

## Shock Decomposition of Welfare Cost (1:00)
"Now decompose the welfare loss by shock source instead of by channel.
[point at stacked bars] TFP dominates Float and Managed's losses — that's the
persistence story from the last slide. But for Peg, the risk-premium/UIP bar
is enormous — 76.83 of Peg's 102.05, about 75%. That single shock is what
reverses the naive ranking: Peg is not remotely competitive with Float or
Managed once it's included.

One check I'll return to at the end: this started as first-order welfare. The
risk-premium channel — a nonlinear debt-elastic premium interacting with a
near-unit-root process — is exactly where a second-order solution could move
this magnitude the most, and it turns out it does move most here, by 0.7% —
small enough that the ranking is untouched."

## Mechanisms: Why Each Regime Costs What It Costs (1:00)
"Zooming out to *why*, in words, before more numbers. Two forces are always
in tension. The Gamma-channel favors Peg: switching off exchange-rate
movement switches off Gamma-i times delta-e in every sector's marginal cost.
But the relocation channel favors Float: Peg's fixed exchange rate doesn't
remove the adjustment, it just forces the same adjustment into upstream
domestic prices instead — that's Peg's exploding output-gap term, 79.5 of its
102.1 total.

Float's cost is persistence — the near-unit-root exchange rate feeds every
sector's marginal cost for a long time, dominated by Services since it's the
most central and stickiest sector. Managed's phi-S term damps the FX
cost-push without fully re-imposing Peg's relocation cost — that's why it
dominates every sector at once, not just on average.

One thing to flag if asked: the channels themselves — Gamma-i, kappa-i, the
DC-survival conditions — are closed-form, straight from the model's
primitives. The magnitudes and the ranking need the full linear
rational-expectations solve; that part is simulated, but it's robust across
all four calibrations on the next slide."

## Robustness: South Korea, Czechia & the Stylized Baseline (0:50)
"Three more input-output calibrations, real data each time: South Korea, a
diversified manufacturing exporter with deeper manufacturing import intensity
than Chile; Czechia, the deepest manufacturing import intensity of the four,
reflecting EU and German supply-chain integration; plus the original
hand-picked stylized triangular network, which checks the result isn't an
artifact of network shape.

Ranking survives in all four: Managed below Float below Peg. And the driver
is the same everywhere — the UIP shock dominates Peg's loss in all four
calibrations: 75% Chile, 72% Korea, 65% Czechia, 81% stylized. All solved
nonlinear, none of them linearized."

---

## Generalization: Optimal FX Stabilization phi-s (1:00)
"So if Managed beats both corners, what's the optimal amount of leaning
against the exchange rate? This sweep is on the stylized network, since it's
the one built to vary continuously. [point at curve] There's a real tradeoff:
too little phi-s and you're close to Float, so the risk-premium shock keeps
leaking into every sector's marginal cost; too much and you're close to Peg,
losing monetary autonomy, letting the same shock through the interest rate
instead.

Loss falls from 13.64 at phi-s equals zero to 4.74 at phi-s equals 0.20 — and
that minimum is peaked, not flat: 0.20 beats our calibrated value of 0.30 by
about 13%. Push past 0.2 and cost rises fast — by phi-s equals 1, you're back
above Float."

## Generalization: Robustness (0:50)
"Two more structural sensitivity checks, also on the stylized network. Ranking
— Managed below Float below Peg — holds everywhere in both panels. But the
*gap* moves in opposite directions. Scale up import intensity kappa, and
Peg's loss falls while Float's rises — they converge. Concentrate FX exposure
more on Resource, raising theta, and it's the opposite — Peg rises, Float
falls, they diverge."

## Isolating the Network Channel (1:10)
"Last question: does the production network actually matter, or is this just
an open-economy result with extra bookkeeping? New sweep, same stylized
network: scale the two domestic input-output links by rho. Rho equals zero
means no domestic network at all; rho equals one is the baseline; rho equals
three is a much denser one.

[point at top chart] Managed is almost network-neutral — turning the network
on adds only 0.35 to Managed's loss, versus 6.98 for Float and 10.30 for Peg.
Phi-S is absorbing the network amplification itself, not just the direct FX
cost-push. And as the network gets denser, the corners diverge from Managed —
by rho equals three, Float has caught up to Peg, both far above Managed.

[bottom chart] The burden also *moves* across sectors depending on the
regime: under Peg and Managed, the network premium lands on upstream
Resource and Manufacturing while Services actually gains; under Float, it's
Services that's hit hardest. So the verdict: yes, the network matters, on two
margins at once — it roughly triples the regime gap as density rises, and it
redirects who bears the cost. A representative-sector open-economy model
cannot produce that reallocation channel at all."

## Conclusion (1:20)
"To summarize. Managed float is optimal — 10.17 versus Float's 25.47 and
Peg's 102.05, on the actual Chile calibration. The driver: risk-premium/UIP
dominates Peg's loss at 75%, while TFP persistence dominates Float and
Managed's; and Managed dominates every single sector, not just on average.

Optimal phi-s is about 0.20, sharply peaked — over-stabilizing the exchange
rate is genuinely costly, not free. The ranking is robust to import intensity,
exposure concentration, network density, and to two more real-data
calibrations — Korea and Czechia — but the *size* of the gap moves a lot
across them.

The network itself matters, not just the open economy: turning the domestic
network off cuts almost all of Peg's and Float's network-driven loss but
barely touches Managed, and it flips which sectors bear the cost across
regimes.

Versus the literature: we get Galí–Monacelli's ranking — peg dominated — but
through a different channel, risk-premium rather than terms of trade.

One thing I checked rather than just flagged: the headline numbers started as
first-order dynamics with a second-order welfare functional — Rubbo's own
approach — valid only if the steady state is efficient. The UIP wedge and the
near-unit-root NFA process are distortions Rubbo's closed economy never had,
exactly the combination Kim–Kim and Schmitt-Grohé–Uribe flag as risky for
this kind of welfare accounting. So I solved the model to a genuine order-2,
pruned, simulated at 260,000 periods, and recomputed welfare from the raw
second moments rather than the linear variance. The loss rises by at most
2% in any regime, Peg's risk-premium channel moves the most as expected, and
the ranking — Managed below Float below Peg — is unchanged.

Next step: a genuinely many-sector calibration from OECD TiVA data, beyond
the 3-sector real IO tables we have now. Thanks — happy to take questions."

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
risk-premium shock is; that persistence, not the psi device itself, is what
makes Peg's loss so large, and it's on the list for robustness checks.

**Q2. How sensitive is the ranking to that near-unit-root persistence
assumption for the risk premium / NFA process?**
A: We haven't swept the shock's own persistence directly — the robustness
slides sweep import intensity, exposure concentration, and network density
instead, all on the stylized network, plus three independent real-data
calibrations (Chile, Korea, Czechia) that each embed their own persistence
estimate. Given the mechanism slide shows persistence, not on-impact
volatility, is the driver, I'd expect lower persistence to shrink Peg's loss
and narrow the gap to Float, but Peg's structural disadvantage — zero
autonomy, so the shock isn't absorbed at all — should survive at any
reasonable persistence. That's a natural next robustness cut.

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
A: I checked this directly rather than leaving it as a disclaimer. Kim–Kim's
point bites hardest when there's a first-order-relevant distortion at steady
state — here that's the UIP wedge and the near-unit-root NFA process, which
Rubbo's closed economy never had to deal with. I re-solved the model to
order 2 with Kim-Kim-Schaumburg pruning (simulated, 260k periods, since the
Taylor rule leaves price levels with a unit root so analytic order-2 moments
aren't available), and recomputed welfare from the raw second moment E[X^2]
rather than the linear variance — so any risk-adjusted mean shift shows up.
It does show up: Peg's risk-adjusted output gap sits about 45 basis points
below zero on average, an order of magnitude bigger than Float or Managed,
and NFA carries a bigger precautionary buffer under Peg too. But because
welfare is quadratic, squaring a small mean shift keeps its contribution
under 0.5% of the loss in every regime — almost all of the ~1-2% correction
is a modest variance increase in the pruned second-order policy function,
not the risk-adjusted-steady-state channel itself. Net effect: loss rises at
most 2%, ranking unchanged.

**Q5. How were phi-pi, phi-y, phi-s, theta-star, and psi chosen — estimated,
or picked?**
A: Calibrated, not estimated — phi-pi and phi-y at conventional Taylor-rule
values, theta-star and psi at standard SOE-literature values (Schmitt-Grohé–
Uribe-style). Phi-s is the one we don't take as given: it's the object we
solve for on the Generalization slide, and 0.30 was our calibrated starting
point before we swept it to find the ~0.20 optimum.

**Q6. Only three sectors — does the ranking survive with a realistic
multi-sector network, e.g. from OECD input-output data?**
A: We already have three independent real-data 3-sector calibrations — Chile,
South Korea, and Czechia — and the ranking (Managed dominant, Peg dominated)
and the mechanism (UIP shock, 65–81% of Peg's loss) survive in all three.
Going to a genuinely many-sector network from OECD TiVA data is the natural
next step and is on the roadmap; I'd expect the qualitative ranking to
survive since it comes from the trilemma/risk-premium mechanism rather than
sector count — but the sector-level heterogeneity result, and the network
density result on the Isolating-the-Network-Channel slide, are exactly where
more granularity could change the picture, since both are driven by how
exposure and Domar weight are distributed across sectors.

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

**Q10. Any comparison to actual inflation-targeting oil/commodity exporters
that run managed floats in practice (Colombia, Chile, etc.)?**
A: Not a formal empirical test yet, but the calibration itself is no longer
stylized — it's Chile's actual national input-output table, and Chile is
exactly this kind of economy: an inflation targeter with a floating-but-not-
fully-free exchange rate and a commodity export sector (copper) playing the
role of Resource here. The natural next validation step is checking whether
the model's optimal phi-s (~0.20) is in the neighborhood of what Chile's
central bank actually does in practice, and repeating that check for Korea
and Czechia.

**Q11. Why do some slides use the Chile calibration and others (Generalization,
Isolating the Network Channel) use a different, "stylized" network — isn't
that inconsistent?**
A: Not inconsistent, but worth being upfront about, and the slides now say so
explicitly. Chile, Korea, and Czechia are three separate real data points —
you can't continuously interpolate between them. The stylized triangular
network is the one built to have a scalar dial ($\kappa$, $\theta$, $\rho$,
or $\phi_s$) so we can trace out a full curve rather than a handful of points.
The Robustness slide puts the stylized bar next to the three real
calibrations explicitly so the difference in levels is visible; the
qualitative conclusions from the stylized sweeps — interior optimal
$\phi_s$, network amplifying the corners more than Managed — are what's
being generalized, not the exact loss numbers.
