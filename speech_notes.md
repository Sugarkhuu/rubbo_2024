# Speech Notes — "Exchange Rate and Production Network"

Session: **1 hour**. Target: **~30 min prepared talk**, leaving ~30 min for
discussion/Q&A. Script below runs ~23 minutes read at a natural pace; the
extra ~7 minutes is slack for pauses, pointing at figures, and the audience
jumping in mid-slide (expect this most on the Model slides and on the
Results section — see the per-slide notes there, they're written to be
said with confidence, not read).

Each block = what to actually say, in full sentences, one block per slide,
in the current deck order (21 content slides + title, 22 pages). Say it in
your own words once you know it — this is a rehearsal script, not a thing
to read verbatim on the day.

**Data-provenance note, for you, not the audience:** every Results slide
uses the real **Chile calibration**, sector-specific-export version
(`open_economy_network_chile_exp*.mod`) — Float 25.15, Managed 10.96, Peg
90.45 ($\times10^{-4}$) baseline, confirmed consistent across every Results
slide as of 2026-07-22. Exports are genuinely sector-specific in this
version (each sector has its own $KAPEX_i$ and its own price $P_{it}$ in the
export-demand equation) — don't undersell that if asked, it's the model
actually used for every number you'll show, not a simplification.

---

## Title (0:20)
"Thanks for having me. This is my project extending Rubbo's 2024
Econometrica paper, 'Networks, Phillips Curves, and Monetary Policy,' to a
small open economy with an explicit exchange-rate policy choice. I'll take
about thirty minutes, then I'd love to hear your questions."

---

## Motivation (1:30)
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
debt-elastic risk premium. Three literatures — network only, open economy
only, both together but no regime choice — none overlap fully, and I'm the
first to put all three in one model. I calibrate to Chile's real
input-output table — also Korea and Czechia for robustness. The questions:
how do the three FX regimes rank? How does the network amplify foreign
shocks? How do sector heterogeneity and network structure matter? And so
you have the destination in mind as we build the model — here's the
headline result already: Managed beats Float, which clearly beats Peg. I'll
spend the next twenty minutes building the model and showing you why."

---

## Households (0:45)
"The household side is a standard small-open-economy setup. Representative
household holds a domestic bond and a foreign bond, and the foreign bond's
return carries a debt-elastic wedge — that's the Schmitt-Grohé-Uribe device
that makes net foreign assets stationary, more on that shortly. Consumption
is CES across home and foreign goods, and Cobb-Douglas across the domestic
sectors. Nothing exotic here — the interesting content starts on the firm
side."

---

## Firms: Technology (0:45)
"Firms in each sector combine labor, domestic inputs from other sectors,
and imports, Cobb-Douglas, and price under monopolistic competition.
Marginal cost is a function of the wage, domestic input prices, and the
imported-input price — which is the exchange rate times the foreign price.
That's the whole point of this slide: marginal cost moves with productivity
*and* with the exchange rate. Two cost-push channels instead of one. And to
be upfront about scope — the theory holds for any number of sectors, but
the quantitative results use three: Resource, Manufacturing, Services,
collapsed from Chile's twelve-sector national accounts."

---

## Firms: Price Setting (1:15)
"Calvo pricing through this network delivers a vector Phillips curve — one
inflation equation per sector, linked to each other through the network.
Here's the one idea to take away from this slide: the two slope
coefficients, $\mathcal B$ for the output gap and $\Gamma$ for the exchange
rate, are the *exact same* rigidity-adjusted network operator, just applied
to two different things — labor share for $\mathcal B$, import share for
$\Gamma$. Same amplifier, two shocks. That single fact is doing most of the
theoretical work in this paper: whatever the network does to productivity
shocks, it does to exchange-rate shocks too, because they travel through
literally the same channel."

---

## Firms: Production Network (1:00)
"Here's the machinery behind that operator. The Leontief inverse sums
direct and indirect linkages — sector $i$ buying from $j$, who buys from
$k$, and so on. Apply it to consumption shares and you get each sector's
Domar weight — its total weight in final demand, network-adjusted, and
notice this can exceed one for a downstream sector. Apply the same inverse
to import or export shares instead, and you get import or export
centrality — total, not just direct, exposure. You'll see these three
numbers again in a couple of slides, so keep the definitions in mind:
Domar weight, import centrality, export centrality."

---

## Foreign Sector (1:00)
"The exchange rate is pinned down by two conditions: law of one price for
the imported good, and uncovered interest parity. There are actually two
separate objects in that UIP condition, worth keeping apart. The $\psi$
term is a debt-elastic premium — a small, endogenous function of net
foreign assets, the standard Schmitt-Grohé–Uribe device, and it's there
purely for stationarity, so NFA doesn't wander on a unit root. Then,
separately, there's an exogenous shock to the country risk premium
itself — a genuine stochastic innovation, unrelated to the debt level.
That second one is the one that turns out to matter enormously for Peg, in
the shock decomposition later. Net foreign assets accumulate the trade
balance, and exports are genuinely sector-specific — each sector has its
own export equation, its own price, its own scale parameter, calibrated to
match Chile's actual export pattern, which is Resource-heavy. Two channels
into the domestic economy: a cost-push channel — exchange rate into
marginal cost into inflation — and a demand channel — exchange rate into
exports into the output gap into inflation."

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
rule, which takes one of those three forms depending on the regime. Seven
shocks drive everything from here on: TFP in each of the three sectors,
import price, foreign demand, export price or terms-of-trade, and the risk
premium — each a persistent AR(1), one-percent standard deviation, all the
same size. That's the full list you'll see broken down in the shock
decomposition later — worth remembering that none of them is calibrated
bigger than the others."

---

## Calibration: Chile Data (1:00)
"Calibration. Three sectors — Resource, Manufacturing, Services — collapsed
from Chile's twelve-sector national input-output table, Banco Central de
Chile. Labor shares, import shares, consumption shares, export shares:
straight from the data. Stickiness from the literature, euro-area
price-change frequencies — no Chile-specific price microdata exists, so
that's a genuine, acknowledged limitation, not hidden. Then the key
mechanism parameters: $\psi$, the debt-elastic NFA stabilizer, and the
three Taylor-rule coefficients. To be precise about $\psi$: it's calibrated
small on purpose, purely to pin down a stationary steady state — it's the
*exogenous risk-premium shock*, a separate object, that turns out to matter
a lot, in the shock decomposition later. Everything else — discount factor,
risk aversion, elasticities — standard literature values, nothing
paper-specific."

---

## Network Properties: Import & Export Exposure (1:00)
"One picture before the results. [point at the chart] For each sector,
three network objects: Domar weight, import centrality, export centrality —
next to their raw, non-network-adjusted counterparts. The point of this
chart: the network amplifies exposure well beyond each sector's direct
share. Import exposure roughly doubles for every sector once you count
indirect, network-propagated exposure, not just each sector's own imports.
Keep this picture in mind — it's the reason a sector's own trade share
turns out not to predict its welfare cost later on."

---
---

# RESULTS SECTION — the core of the talk

**General advice for this block:** these eight slides are where the
audience decides whether the paper is right. Each one below is written with
the *causal story*, not just the number, because that's what survives
questions. Say the ranking once, early, and then spend your words on *why*,
not on re-reading bullet points the audience can already see.

---

## Welfare Ranking: Managed Float Dominates (1:30)
"Here's the headline. [point at the chart] Managed beats Float, which beats
Peg by a wide margin — 10.96, 25.15, 90.45, times ten-to-the-minus-four.
Two things to notice beyond the ranking itself. First, look at *what*
drives each regime's loss: Float and Managed's losses are almost entirely
price dispersion — sticky prices failing to adjust uniformly — concentrated
in Services. Peg's loss is almost entirely the output gap instead — a
completely different failure mode. Second — and this is the paper's second
result, not just the first — without the network at all, the same ranking
survives, but every regime's loss is two-to-three times smaller. So the
network isn't just decoration on top of an open-economy story; it's roughly
doubling the stakes of getting the FX regime right. I'll show you exactly
why in a few slides."

---

## Counting the Cross-Sector Term (1:15)
"Christian's last comment after the first round: 'I really need to count
for that,' about a piece of Rubbo's welfare formula I'd been flagging as
missing — the between-sector term, relative-price misallocation across
sectors, as opposed to the within-sector dispersion I'd already built. So
I actually built it. The key move: both of this model's cross-sector
aggregators — how households combine consumption across sectors, how
firms combine inputs across sectors — are Cobb-Douglas. Cobb-Douglas has
an elasticity of substitution of exactly one, by the definition of the
functional form, not an estimate. That collapses Rubbo's general formula,
which needs a whole matrix of cross-sector substitution elasticities I'd
have had to make up, into something I can actually compute: a weighted
variance of the markup gap across the three sectors. I added that markup
gap as a reporting variable to the model — doesn't change anything else,
it's a pure definition — reran the three regimes, and did the sum.
Answer: it adds three to eight percent on top of what I already had.
Real, not zero, but small — and the ranking doesn't move at all. So the
honest update is: I was missing a term, now I'm not, and it doesn't
change the story, it just makes the accounting complete. I want to flag
one caveat honestly — the domestic-versus-import piece of this uses the
outer nest's elasticity as a stand-in for the exact cross-elasticity in a
nested CES structure, which is a standard practical shortcut, not an
exact derivation."

---

## What Drives Each Regime's Loss? Shock Decomposition (1:30)
"What's actually driving these numbers, shock by shock. [point] For Peg,
one shock explains three-quarters of the loss: an exogenous shock to the
country risk premium — the genuinely stochastic piece from the Foreign
Sector slide, not the small debt-elastic $\psi$ stabilizer, which barely
moves anything on its own. And to be clear, this isn't because I gave that
shock a bigger kick — all seven shocks in the model share the same size,
one percent. It's structural: a peg removes the exchange-rate buffer that
would otherwise absorb a risk-premium shock, so the whole thing goes
straight into the interest rate and the output gap instead. For Float and
Managed it's completely different — TFP shocks dominate instead, and the
risk-premium shock barely registers, because the exchange rate, or partial
smoothing under Managed, absorbs it before it reaches output. Import price,
foreign demand, export price — all second-order, in every regime. This is
not a terms-of-trade story — if someone asks about Galí-Monacelli here,
the answer is: their model has complete markets and no risk-premium channel
at all, so this mechanism couldn't exist in their setup to begin with."

---

## How Much Does Peg's Loss Depend on the Risk-Premium Shock? (1:15)
"I want to show you something uncomfortable, because it should be said
plainly rather than buried. The last slide showed risk-premium driving
seventy-six percent of Peg's loss. That shock is calibrated at one
percent standard deviation — same as every other shock in the model. So
the natural question is: how much is that one number doing? [point] If I
switch the risk-premium shock off entirely, Peg is not the worst regime
— it's essentially tied with Float, fractionally better if anything. The
entire 'Peg is dominated' result you've seen all talk rests on this one
shock existing at roughly this size. Turn it on at half strength and Peg
is already worse than Float; at the calibrated size, three-and-a-half
times worse; at three times calibrated, fourteen times worse. Managed
stays cheapest the whole way through and barely notices, which is
itself informative — it's precisely the regime designed to absorb this
channel. Now, why I don't think this is cherry-picked: one percent is
the same size I gave every other shock in the model, not something I
tuned to get this result, and there's real empirical literature —
Broda, Edwards and Levy-Yeyati, Céspedes-Chang-Velasco — documenting
risk-premium volatility of about this order for pegged emerging-market
regimes. But I want to be honest: the *margin* of the result is very
sensitive to this one calibration choice, and if this were going into a
journal submission, that standard deviation needs to be independently
estimated, not assumed equal to everything else. Right now it's a
reasonable default, not a validated number."

---

## Isolating the Network Channel (1:00)
"Does the network's effect scale *continuously*, or was the ON/OFF
comparison a special case? [point] This scales all six cross-sector
$\Omega^H$ entries by a density dial, $\rho$ — one is the real calibration,
zero means each sector only uses its own output and imports, no domestic
cross-buying. Losses rise monotonically with density in every regime, and
Managed stays best throughout the whole range. So the previous slide's
ON/OFF comparison wasn't a special case sitting at some knife-edge — it's
one point on a smooth, monotonic curve."

---

## How the Network Amplifies Shocks (1:30)
"Now the mechanism — why does the network do this at all? [point at table]
Peak impulse response, network on divided by network off, for two shocks
across all three regimes. Read it this way: less than one, the network
shrinks that peak; greater than one, it amplifies it. One-line summary: the
network dampens the inflation peak everywhere, but amplifies the
output-gap peak, in every single cell of this table. This is not the
network inventing new volatility from nothing — it's redirecting it.
Here's the intuition: more network density means a cost shock cascades
through more firms before it becomes a final price, and each of those firms
is only partially sticky, so some of the shock gets absorbed into markups
at every hop instead of passed into prices. That flattens the aggregate
Phillips curve — prices respond less to a given disturbance. But the
disturbance still has to be resolved somewhere, because markets still have
to clear — so with prices responding less, *quantities* have to move more.
That's the redirection: sharper on paper as a smaller price response, but
it shows up as a bigger output swing. Read the two extremes: import-price
hits Peg hardest, no FX buffer at all; risk-premium hits Float hardest, and
Managed blocks that one almost entirely — essentially no amplification,
zero point nine eight."

---

## Why Services? Direct vs. Indirect Import Exposure (1:15)
"Christian's question after the last presentation: Services is the
stickiest sector and has the *lowest* direct import share — so why does it
end up carrying most of the network's welfare cost? [point at left panel]
This decomposes each sector's total import exposure — the object that
governs FX pass-through — into a *direct* part, just its own import cost
share, and an *indirect* part, imports it inherits by buying from other
domestic sectors. At zero network density that indirect part is exactly
zero by construction. As density rises, it grows — and for Services, it
ends up being 41% of its *total* exposure, almost as large a share as
Resource's 50%, even though Services' total exposure is the smallest in
levels. [point at right panel] So Services looks insulated only if you
look at its own import bill. Once you follow the network — it buys 5.8% of
its cost from Manufacturing, the most import-intensive sector in the
economy — a meaningful chunk of whatever FX shock hits Manufacturing
shows up on Services' books too. And because Services can't reprice
quickly — that's the stickiness — whatever cost-push it inherits this way
doesn't clear in a quarter, it lingers: its inflation is the single most
persistent series in the model, autocorrelation around 0.82. Rigidity
doesn't create the exposure, the network does that; rigidity is what turns
a transient inherited shock into a persistent one."

---

## Which Channel Actually Drives Services' Exposure? (1:30)
"After the last talk, Christian wasn't even sure which story he meant —
was it the import network, or something about the peg forcing a monetary
stance that's just wrong for a big sticky sector, or was rigidity beside
the point and it's really just about size? Turns out the honest answer is
all three, and they compound rather than compete. [point left] This is
Dynare's own variance decomposition of Services' output gap, by shock —
not my construction. The import-price channel, the network story from the
last slide, is real but it's *secondary* — two to twenty-two percent of
the variance depending on regime. What actually dominates is the
risk-premium shock — a purely aggregate, financial shock with no import
content in it at all — sixty-three percent under Float, seventy-eight
percent under Peg. [point right] So why does a non-import shock land so
hard on Services specifically? Because of its Domar weight — how central
it is as a supplier to final demand — and that weight is ninety-two
percent already there before the network is even switched on, just from
Services being a huge share of consumption and reusing a lot of its own
output as an input. The cross-sector network adds another nine percent on
top. Compare that to Resource, where the network more than doubles its
weight from a tiny base. So: size explains who gets hit by a generic
shock, rigidity explains why that turns into a lot of welfare cost once it
lands, and the network's role is smaller and more indirect than the first
slide might have suggested on its own — it amplifies an already-large
sector rather than being the primary reason Services is exposed at all."

---

## Persistence, Not Just Size: Why UIP Losses Are So Large (1:30)
"Christian had another comment I want to address directly: persistence of
inflation leading to higher cost, and how that connects to why the UIP
welfare loss is so large. He's right, and I can show you exactly how much
it matters. [point] This is the risk-premium shock's persistence,
crossed with network density. Variance of an AR(1) process scales as
sigma-squared over one minus rho-squared — that's mechanically convex,
not linear. Moving persistence from zero to 0.4 to the calibrated 0.8
raises Peg's loss only gradually. But going from 0.8 to 0.95 — a change
of 0.15 — explodes it five-fold. That's not a bigger shock, it's the
*same* shock lasting longer. And this is exactly the same logic as
Services' own inflation persistence from a few slides back — a rigid
sector hit by a persistent shock doesn't get one bad quarter, it gets a
slow-moving elevated path, and the welfare metric, which is a variance,
prices in the whole path, not just the peak. I want to flag one honest
caution here: at persistence 0.95 I'm right up against a near-unit-root
region, and combined with this model's already-near-unit-root net
foreign asset dynamics, the linear solution starts behaving oddly — at
that one point, and only that one point, having the network on actually
*lowers* Float's loss, which is the opposite of every other result in
this deck. I think that's a numerical fragility symptom near the
knife-edge, not real economics, and I'm flagging it rather than hiding
it. Below 0.8, everything is well-behaved and the persistence story holds
cleanly."

---

## Does the Optimal Managed-Float Response Depend on the Network? (1:15)
"Christian's other question: if the network changes welfare *this* much,
maybe it also changes what the *right policy parameter* is, not just how
costly it is to get wrong. [point at figure] Same welfare-minimizing
$\phi_s$ search as the appendix slide, but now repeated at three network
densities instead of just the baseline. And the answer is yes — the
optimal $\phi_s$ moves: 0.15 with no network, 0.20 at baseline, 0.30 once
the network is twice as dense. That's monotonic and economically sensible
— more network density means more of a shock reaches you indirectly, so
leaning harder against the exchange rate pays off more. But look at the
shape of each curve near its own minimum — it's flat, within two or three
percent across a pretty wide range. So the finding is real: the network
does shift the optimal parameter, not just the loss level. But practically,
being close to right matters far more than being exactly right — you don't
need to know your network density to three decimal places to run a good
managed float."

---

---

## Network Exposure & Sector Welfare Preferences (1:15)
"Do different sectors actually want different regimes? [point at tables]
Short answer: no — every sector, on its own, ranks Managed below Float
below Peg, same as the aggregate. Nobody disagrees with the ranking. What
differs enormously is the *size of the stakes*. Resource barely notices —
all three regimes are cheap for it. Manufacturing has a real but moderate
stake. Services' stake in avoiding a peg is enormous, and it's mostly
network-driven: its output-gap cost goes from about nine to about
thirty-five once the network is switched on. So the heterogeneity in this
paper isn't about *which* regime is optimal — it's entirely about *how
much* each sector has riding on getting it right."

---

## Import Openness & Import Concentration (1:00)
"Two more dimensions of trade structure, and this is where Peg and Float
actually start behaving very differently from each other. [point] Sweep how
open the economy is to imports overall, and how concentrated that exposure
is across sectors. Ranking survives throughout, but look at the direction:
more overall import openness *narrows* the Peg-Float gap — Peg's loss
falls, Float's rises. Here's why: under a peg the exchange rate never
moves, so the direct FX-cost-push channel is switched off regardless of how
big import shares get — Peg can't use it, so more imports can't hurt it
through that channel. What imports *do* to Peg is shrink the labor share,
which flattens the whole Phillips curve a little and slightly helps. Under
Float, the exchange rate genuinely moves every period, so bigger import
exposure means every FX movement now carries a bigger cost-push punch —
Float's own stabilization tool gets more expensive to use. Concentration is
the opposite: same total openness, just less evenly spread across sectors,
and that specifically *widens* the gap and hurts Peg. So it isn't import
volume that's dangerous for a peg — it's how concentrated that exposure is."

---

## Export Openness & Export Concentration (0:45)
"Same exercise on the export side, different mechanism entirely. Exports
don't touch the cost side of the model at all — scaling the export
parameter doesn't change any cost share, so it never touches the Phillips
curve. It's a pure demand-side channel: a bigger, more price-responsive
export sector is a real buffer, letting relative-price shifts reallocate
demand internationally instead of through the exchange rate. Every regime
benefits from more of this buffer, but Peg benefits most, because Peg is
the one regime with no FX-based stabilizer at all — bigger exports are a
partial substitute for the margin it structurally lacks. Concentrating
exports toward the flexible-price sector, Resource, helps Peg a little more
and mildly hurts Float and Managed. Bottom line: the export side matters
much less than the import side, and it pushes all three regimes the same
direction instead of pulling Peg and Float apart."

---

## Robustness: South Korea & Czechia (0:45)
"Does this hold outside Chile? [point] Same exercise, two more real
input-output calibrations, South Korea and Czechia. Same ranking every
time — Managed below Float, well below Peg. Korea's numbers are higher
across the board — denser network, higher import exposure — which is
itself more evidence this is a network story, not a Chile-specific quirk."

---

## Robustness: Is Indirect Exposure a General Pattern? (1:00)
"Adam asked whether the Services story — low direct import, high indirect
import — is a general downstream-sector pattern or a one-off. Honestly:
with only three sectors this is a weak test, and I want to say that
plainly rather than oversell a correlation from nine data points. [point]
Pooling all three calibrations, three sectors each, there's a moderate,
noisy relationship between how much a sector sources domestically and how
much of its import exposure is indirect. What I can say with more
confidence, because it holds in Chile, Korea, and Czechia separately, not
just pooled: Services sources the *least* domestically of any sector in
every single one of these calibrations, and yet still picks up a large
share of its exposure indirectly — because the little it does buy
domestically is concentrated in Manufacturing, the most import-heavy
supplier, not spread evenly across sectors. So it's not the *volume* of
domestic sourcing that predicts inherited exposure, it's *who you buy
from*. That's a real, consistent pattern across three independent
datasets, even if I can't yet call it a general law — that needs a
properly disaggregated calibration, which is on the list as a next step,
not something I have today."

---

## Conclusion (1:30)
"Let me close with four points.

One: the network matters for severity and for who bears the cost, not for
the ranking. FX pass-through and TFP cost-push travel through the exact
same rigidity-adjusted network operator, so switching the network on
substantially raises welfare losses in every regime and reallocates which
sector bears them — but Managed beats Float beats Peg either way.

Two: Peg is dominated by a different mechanism than the textbook story.
It's not terms-of-trade, it's the risk-premium, UIP channel — a hard peg
has zero monetary autonomy, so that shock goes straight into the output
gap.

Three: Managed float wins because it dampens the FX pass-through channel
without fully giving up monetary autonomy the way a peg does.

Four: this is robust — three real-data calibrations, and a genuine
second-order, not just log-linear, solution.

Thank you — happy to take questions."

---

## Timing check
Read the whole script once, out loud, before the day — target 23 minutes.
If you're running long, the first cuts should be the second half of
"Firms: Price Setting" and "Firms: Production Network" (the audience can
absorb the punchline without the full derivation walk-through) — never cut
into the Results section, that's the part they came for.

---

## Post-talk feedback (2026-07-22, Christian & Benny) — what changed and what to watch

Two new Results slides added, both live in the main deck (not gated behind
the currently-uncommented-out appendix `\input`):
**"Why Services? Direct vs. Indirect Import Exposure"** and **"Does the
Optimal Managed-Float Response Depend on the Network?"** — see their notes
above, inserted right after "How the Network Amplifies Shocks" and "Isolating
the Network Channel" respectively.

**Christian's two points, and what actually answers them:**
- *"Services is rigid + low import, but buys from Manufacturing which has
  high import — with/without network comparison of how rigidity and import
  intensity interact."* → the new import-exposure-decomposition slide:
  Services' total import centrality $M_i$ splits 59% direct / 41% indirect;
  indirect is mechanically zero at $\rho{=}0$ and grows with density. This
  is a **pure accounting decomposition of the network object already used
  everywhere else in the deck** ($M_i$ is the same import-centrality vector
  on the "Import Openness" slide), not a new model.
- *"How does the optimal regime parameter change with/without network — if
  welfare changes so much, maybe the parameter is quite different too."* →
  the new $\phi_s$-vs-$\rho$ slide: $\phi_s^*=0.15/0.20/0.30$ at
  $\rho=0/1/2$. Confirms his hypothesis directly — this required 36 fresh
  Dynare solves (`code/sweep_phi_s_netdens_chile.m`,
  `code/drive_phi_s_netdens_chile_sweep.sh`), not just relabeling existing
  output.

**What to be careful about if asked (caveats behind these two new slides):**
1. **$\rho=0$ is not "no trade with these sectors," it's "no domestic
   cross-sector cost share."** Scaling $\Omega^H$'s off-diagonal by $\rho$
   forces $\alpha_i$ (own value-added/labor share) to absorb the freed-up
   cost share so shares still sum to one (`sweep_netdens_chile.m`,
   `sweep_phi_s_netdens_chile.m`). So $\rho=0$ answers "what if this sector
   used only labor and imports as inputs," not "what if these specific
   trade relationships vanished and nothing replaced them." Both are
   defensible counterfactuals, but they're not the same question — say
   this explicitly if a referee-type question probes what $\rho=0$ "means."
2. **Found and fixed a latent bug while building this**: the *existing*
   `analysis_netdens_chile.py` (behind `figs/isolating_network.pdf`, "Isolating
   the Network Channel" slide) computed welfare using $\lambda_{D,i}$ fixed
   at its $\rho{=}1$ value for *every* $\rho$ in the sweep — but
   $\lambda_D=\bm\beta^{H\top}(I-\Omega^H)^{-1}$ is itself a function of
   $\rho$. Corrected version:
   `code/network_exposure_decomposition.py` (closed-form $\lambda_D(\rho)$,
   validated against Dynare's own `LAMBDA_D_i` output to <1% at $\rho=1$)
   and `code/analysis_netdens_chile_v2.py`. Effect: **the network welfare
   premium is understated in the current `isolating_network.pdf`**, not
   overstated — e.g. Float's premium (loss at $\rho{=}1$ minus $\rho{=}0$)
   is +\$3.6$ under the old fixed-$\lambda_D$ calc vs +\$6.1$ corrected
   ($\times10^{-4}$), about 70% bigger. Ranking and monotonicity are
   unaffected; exact levels on that specific slide are a slight
   underestimate. Worth regenerating that figure before a paper draft;
   didn't touch it for this revision since it doesn't change any
   conclusion, just a magnitude.
3. **Same "optimal simple rule, not Ramsey" caveat as the existing appendix
   $\phi_s$ slide applies here too** — this is the best $\phi_s$ *within*
   the fixed linear rule $\hat\imath_t=\phi_\pi\pi_t^{DC}+\phi_y\tilde
   y_t+\phi_s\log S_t$, on a 12-point grid, not a continuous or
   unconstrained optimum. "$\phi_s^*=0.30$ at $\rho=2$" means 0.30 beat its
   grid neighbors (0.20, 0.40), not that 0.30 is exact to the third decimal.
4. **This has not been crossed with the $\psi$ (risk-premium elasticity)
   sweep** flagged in `CLAUDE.md`'s future-extensions list — the risk-premium/
   UIP channel is untouched by $\rho$ in this exercise (it doesn't run
   through $\Omega^H$ at all), so the $\phi_s^*(\rho)$ result should be read
   as "robust to network density," not yet "robust to every calibration
   knob." Don't overclaim this in Q&A as the final word on $\phi_s$
   robustness.
5. **New MATLAB/Python artifacts, for reproducibility**: 
   `code/sweep_phi_s_netdens_chile.m`,
   `code/drive_phi_s_netdens_chile_sweep.sh`,
   `code/network_exposure_decomposition.py`,
   `code/analysis_phi_s_netdens.py`,
   `code/analysis_netdens_chile_v2.py` → `results/phi_s_netdens_chile_sweep.csv`,
   `results/phi_s_netdens_chile_welfare.csv`,
   `results/import_exposure_decomposition.csv`,
   `results/netdens_chile_welfare_v2.csv` →
   `figs/phi_s_netdens.pdf`, `figs/import_exposure_decomposition.pdf`.

**Benny's point — not yet acted on, flag for next revision:** "go through
mechanics, shocks, and model intuition, then show welfare." Right now
Results *opens* with the welfare-ranking slide (numbers first), and the
mechanism slides ("How the Network Amplifies Shocks," the new
import-exposure-decomposition slide, "Network Exposure & Sector Welfare
Preferences") come *after* it. Reordering the whole Results section to lead
with mechanism and land on welfare as the payoff is a bigger, riskier edit
(slide-count/appendix numbering, transitions, timing script) than the two
additions above, and wasn't done here under the July 22 deadline. For the
next pass: candidate reordering is Network Properties (already early, stays)
→ How the Network Amplifies Shocks → the two new mechanism slides → THEN
Welfare Ranking / Shock Decomposition / Isolating the Network Channel /
$\phi_s$-vs-network as the payoff sequence. Worth 15 minutes with a fresh
eye before the next external presentation, not urgent for this internal
revision.
