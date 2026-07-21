# Speech Notes — "Exchange Rate and Production Network"

Session: **1 hour**. Target: **~30 min prepared talk**, leaving ~30 min for
discussion/Q&A. Script below runs ~26 minutes read at a natural pace; the
extra ~4 minutes is slack for pauses, pointing at figures, and the audience
jumping in mid-slide (expect this most on the Model slides and on
"Mechanism").

Each block = what to actually say, in full sentences, one block per slide,
in the current deck order (23 slides total). Say it in your own words once
you know it — this is a rehearsal script, not a thing to read verbatim on
the day.

**Data-provenance flag, for you, not the audience:** as of this rewrite,
every Results slide uses the real **Chile calibration** (Float 25.15,
Managed 10.96, Peg 90.45, $\times10^{-4}$) — including "Isolating the
Network Channel," which was switched from a stylized triangular network to
the real Chile density sweep. **Exception to check before the talk:**
"Import Openness & Import Concentration" and "Export Openness & Export
Concentration" currently caption themselves as "real Chile calibration," but
their baseline numbers (Float 13.64, Managed 5.36, Peg 49.63) don't match
the Chile headline — they match the *old* stylized-network baseline. This
looks like a stale caption, not a stale number: reconfirm which is true
before asserting "real Chile calibration" out loud on those two slides. If
you don't have time to rerun them, the safe move is to just not repeat the
word "Chile" on those two slides specifically and let the qualitative
result (ranking survives, direction of each sweep) carry the point instead.

---

## Title (0:20)
"Thanks for having me. This is my project extending Rubbo's 2024
Econometrica paper, 'Networks, Phillips Curves, and Monetary Policy,' to a
small open economy with an explicit exchange-rate policy choice. I'll take
about thirty minutes, then I'd love to hear your questions."

---

## Motivation (1:45)
"Let me start with the picture that motivates everything. [point at the
diagram] Firms don't just hire labor — they buy inputs from other domestic
firms. A cost shock to one sector mechanically hits everyone downstream of
it, and then everyone downstream of *them*. That's the production-network
idea, and it's the heart of Rubbo's paper.

Now add one more fact. Imported inputs are the norm, not the exception — in
Chile's data, Manufacturing spends up to almost twenty percent of its costs
on imports. So when the exchange rate moves, that is not some abstract
macro aggregate. For the firm, it is a domestic cost shock, exactly like a
productivity shock — and it propagates through the exact same network.

Here's the gap. Network models get the propagation right but ignore the
exchange rate. Open-economy models get the exchange rate right but ignore
the network. This paper puts both together, and asks one question: does
accounting for the production network change which exchange-rate regime is
optimal?"

---

## Literature (1:00)
"Quickly on where this sits. On one side, the closed-economy network
literature — Rubbo, La'O and Tahbaz-Salehi, Pasten-Schoenle-Weber. On the
other side, open-economy macro without a network — Galí-Monacelli,
Schmitt-Grohé-Uribe, Gopinath-Itskhoki. A couple of papers combine network
and open economy — Gnocato-Montes-Galdón-Stamato at the ECB, and especially
Qiu-Wang-Xu-Zanetti, the closest paper: they independently derive an
open-economy divine-coincidence index and also find it breaks down. But
their model is static — no persistence, no UIP, no net foreign assets — and
they don't compare exchange-rate regimes at all. So the gap is: network,
plus open economy, plus an actual regime choice, together. That's what I
do."

---

## This Paper (1:00)
"Briefly, what I do. I extend Rubbo's closed-economy network model to a
small open economy: imported inputs, uncovered interest parity, a
debt-elastic risk premium. I ask two questions — what's the optimal
exchange-rate regime, and does the divine-coincidence result survive once
there are two cost-push channels instead of one? I calibrate to Chile's
real input-output table — also Korea and Czechia for robustness — and I
solve the model nonlinearly, not just log-linearized. Let's build the
model."

---

## Households (0:45)
"Standard small open economy household. Chooses consumption, labor, and
holds a domestic bond and a foreign bond, subject to a budget constraint —
note the debt-elastic term here, I'll come back to why it's there.
Consumption is CES between home and foreign goods, Cobb-Douglas across the
domestic sectors with weights beta-H. Nothing exotic — this is just the
entry point into the network."

---

## Firms: Technology (0:45)
"Firms in sector $i$ use labor, inputs from other domestic sectors, and
imported inputs — Cobb-Douglas, monopolistic competition. The marginal-cost
equation is the key object: it depends on the wage, on domestic input
prices weighted by the network shares, and on the imported input price,
which is the exchange rate times the foreign price. So two things can move
marginal cost: productivity, and the exchange rate. Two cost-push channels.
Hold onto that — it's the whole point of the paper."

---

## Firms: Production Network (0:45)
"Stack those input shares across sectors and you get the input-output
matrix $\Omega^H$, an import-exposure vector, and an export-exposure
vector. The Leontief inverse sums direct and indirect linkages — apply it
to consumption shares and you get each sector's Domar weight; apply it to
import or export shares and you get import or export centrality. Standard
network-macro machinery — I'm just setting notation here."

---

## Firms: Price Setting (1:30)
"Now the key equation. Calvo pricing through this network gives you a
vector Phillips curve. [point] Inflation today depends on expected
inflation tomorrow, the output gap, a TFP cost-push term, and — this is the
new piece — an exchange-rate term, $\Gamma$ times the change in the
exchange rate.

Here's a result I like: $\mathcal B$ and $\Gamma$, the output-gap slope and
the FX pass-through, are literally the *same* operator — this
rigidity-adjusted Leontief inverse — just applied to the labor share on one
hand and the import share on the other. Same amplifier, different shock.

And only *relative* TFP shocks matter — a uniform TFP shock across every
sector creates no cost-push at all, because $\mathcal V\mathbf 1=\mathbf
0$. Only sector-specific gaps do."

---

## Foreign Sector (1:00)
"The exchange rate is pinned down by two conditions: law of one price for
the imported good, and uncovered interest parity with a debt-elastic risk
premium — that's the $\psi$ term, it's what makes net foreign assets
stationary, the standard Schmitt-Grohé–Uribe device. Net foreign assets
accumulate the trade balance, and exports are sector-specific, calibrated
to match Chile's actual export pattern, which is Resource-heavy. Two
channels into the domestic economy: a cost-push channel — exchange rate
into marginal cost into inflation — and a demand channel — exchange rate
into exports into the output gap into inflation."

---

## Monetary Policy Regimes (0:45)
"Three regimes. Free float: standard Taylor rule on inflation and the
output gap, exchange rate moves freely. Hard peg: the exchange rate is
fixed, full stop — the interest rate becomes whatever's needed to keep it
fixed; it isn't chosen for stabilization at all. Managed float: same Taylor
rule, plus a term that leans against exchange-rate movements. Notice Float
and Peg are really the same rule family at two extremes — $\phi_s$ equal to
zero, or $\phi_s$ going to infinity. Managed sits in between."

---

## Equilibrium System (1:00)
"Putting it together: the Phillips curve I just showed, an IS curve with an
extra term for the real exchange rate, the UIP condition, and the policy
rule, which takes one of those three forms depending on the regime. And
here's the welfare loss function I'll report throughout: quadratic in
output-gap variance, plus a weighted sum of sector-level inflation
variances, weights $\kappa_i$ combining each sector's Domar weight and its
stickiness. Second-order approximation to household utility, following
Rubbo's approach, extended to the open economy."

---

## Calibration: Chile Data (1:00)
"Calibration. Three sectors — Resource, Manufacturing, Services — collapsed
from Chile's twelve-sector national input-output table, Banco Central de
Chile. Labor shares, import shares, consumption shares, export shares:
straight from the data. Stickiness from the literature, euro-area
price-change frequencies. Then the key mechanism parameters: $\psi$, the
risk-premium elasticity, and the three Taylor-rule coefficients — I'll come
back to $\psi$, it turns out to matter a lot. Everything else — discount
factor, risk aversion, elasticities — standard literature values, nothing
paper-specific."

---

## Network Properties: Import & Export Exposure (1:00)
"Before results, one picture on what the network actually does to
exposure. [point] Raw import share versus import centrality, the
network-propagated version. It roughly doubles for every sector — a
sector's true exposure to the exchange rate isn't just what it imports
directly, it's also what it buys from sectors that import. Same story on
the export side. This is the mechanical fact that makes the network
matter, and it's what drives everything that follows."

---

# Results

## Welfare Ranking: Managed Float Dominates (1:45)
"Here's the headline result. [point] Managed float dominates both corners —
Managed 10.96, Float 25.15, Peg 90.45, times ten-to-the-minus-four. Peg
isn't competitive: roughly four times worse than Float, eight times worse
than Managed. For Float and Managed, almost the entire loss is price
dispersion, concentrated in Services.

Now look at the hatched bars — same calculation with the network switched
off entirely, $\Omega^H\equiv0$. Losses fall to 5.82, 8.67, 33.66 — same
ranking survives, but the network is roughly doubling to tripling every
regime's loss. So the network isn't decoration, it's doing real work — and
I'll show you exactly how in a few slides."

---

## What Drives Each Regime's Loss? Shock Decomposition (1:15)
"What's actually driving these numbers, shock by shock. [point] For Peg,
one shock explains three-quarters of the loss: the risk-premium, or UIP,
shock. That's the shock that decides everything for a hard peg. For Float
and Managed it's completely different — TFP shocks dominate instead, and
the risk-premium shock barely registers, because the exchange rate, or
partial smoothing under Managed, absorbs it before it reaches output.
Import price, foreign demand, export price — all second-order, in every
regime. This is not a terms-of-trade story."

---

## Isolating the Network Channel (1:15)
"Does the network matter continuously, not just on-or-off? [point] This
scales all six cross-sector links in the real Chile network by a density
dial, $\rho$ — $\rho=1$ is the actual calibration, $\rho=0$ means each
sector only uses its own output and imports, no domestic cross-buying.
Losses rise monotonically with density in every regime, and critically, the
Peg-Float gap *widens* as density increases. Managed stays best throughout.
On the right — the network's price-dispersion premium, concentrated in
Services for Float and Managed, but actually *negative* for Peg — a denser
network shifts Peg's cost out of price dispersion and into the output gap
instead."

---

## Import Openness & Import Concentration (1:00)
"Two more dimensions of trade structure. [point] Sweep how open the economy
is to imports overall, and how concentrated that exposure is across
sectors. Ranking survives throughout. But look at the direction: more
overall import openness actually *narrows* the Peg-Float gap — Peg's loss
falls, Float's rises. More concentration — same total openness, just less
evenly spread across sectors — *widens* the gap and specifically hurts Peg.
So it isn't import volume that's dangerous for a peg, it's how concentrated
that exposure is."

---

## Export Openness & Export Concentration (0:45)
"Same exercise on the export side. Openness helps everyone — exports are a
demand channel, not a cost-push channel, so more trade is close to
unambiguously good, and Peg benefits most. Concentrating exports toward the
flexible-price sector, Resource, helps Peg a little and mildly hurts Float
and Managed. But overall, the export side matters much less than the
import side — the whole story runs through cost-push, through imports, not
through terms of trade."

---

## Mechanism: How the Network Amplifies Shocks (1:30)
"Now let's open the black box — why does the network do this? [point at
table] Peak impulse response, network on divided by network off, for two
shocks and three regimes. Read it this way: less than one means the
network *shrinks* that peak, greater than one means it *amplifies* it.

One-line summary: the network dampens the inflation peak everywhere, but
amplifies the output-gap peak, in every regime, for both shocks. So the
network doesn't create new cost-push out of nothing — it *redirects* it.
Instead of a sharp price spike, you get a more persistent output
distortion, spread across sectors and over time.

Look at the extremes: the import-price shock hits Peg hardest — three point
one five times — no exchange-rate buffer. The risk-premium shock hits Float
hardest — two point five seven times — and Managed blocks it almost
completely, zero point nine eight, essentially no amplification at all."

---

## Network Exposure & Sector Welfare Preferences (1:15)
"Different sectors actually prefer different regimes. [point at tables]
Each cell is network-on versus network-off. Price dispersion: Managed is
best for every sector, on or off. Float's Services cost is mostly
network-driven — twenty point two five on, six point two two off. But
Peg's Services cost is *not* — fifteen point nine versus fourteen point
six, it barely moves.

Now the output gap: Peg's Services number is the outlier of the whole
table — thirty-five — and that one *is* overwhelmingly network-driven:
without the network it falls to under nine, a two-hundred-ninety-percent
difference. Takeaway: a sector's own trade exposure doesn't predict how
much it suffers. Services has the *lowest* direct import share of the
three sectors, and the *highest* welfare cost — because it sits at the top
of the network, buying from everyone."

---

## Robustness: South Korea & Czechia (0:45)
"Does this hold outside Chile? [point] Same exercise, two more real
input-output calibrations, South Korea and Czechia. Same ranking every
time — Managed below Float, well below Peg. UIP dominates Peg's loss
throughout, sixty-five to seventy-six percent. Korea's numbers are higher
across the board — denser network, higher import exposure — which is
itself more evidence this is a network story, not a Chile-specific
quirk."

---

## Robustness Summary: What Drives the Ranking? (1:15)
"Let me pull the robustness together in one place. [point at table] Across
import openness, import concentration, export openness, export
concentration, and network density — Managed beats Float beats Peg, every
single time, no exceptions. What changes is the *size* of the gap. Two
things worth remembering. First: the import side drives everything, the
export side barely matters — consistent with a cost-push story, not a
terms-of-trade story. Second: import volume and import concentration point
in *opposite* directions for Peg — more imports overall narrows the gap,
but concentrating them in one sector widens it. It's exposure structure
that's dangerous, not exposure size."

---

## Conclusion (1:30)
"Let me close with five points.

One: networks change how the exchange rate operates. FX pass-through and
TFP cost-push travel through the exact same rigidity-adjusted network
operator, and once the exchange rate is a second cost-push channel, the
closed-economy divine-coincidence result generically fails.

Two: the network matters for severity and for who bears the cost, not for
the ranking. Switching it on roughly doubles or triples every regime's loss
and reshuffles which sector suffers most — but Managed beats Float beats
Peg either way.

Three: Peg is dominated by a different mechanism than the textbook story.
It's not terms-of-trade, it's the risk-premium, UIP channel — a hard peg
has zero monetary autonomy, so that shock goes straight into the output
gap.

Four: Managed float wins because it's the only regime that dampens the FX
pass-through channel without fully giving up monetary autonomy the way a
peg does.

Five: this is robust — three real-data calibrations, and a genuine
second-order, not just log-linear, solution.

Thank you — happy to take questions."

---

## Timing check
Model section (Households through Network Properties): ~9 slides, ~8:45.
Results section (Welfare Ranking through Robustness Summary): ~9 slides,
~11:15. Intro (Title/Motivation/Literature/This Paper): ~4:35. Conclusion:
~1:30. **Total: ~26:05** of script — leaves buffer to hit 30 minutes at a
natural, unhurried pace, and a full 30 minutes for discussion within the
one-hour session.
