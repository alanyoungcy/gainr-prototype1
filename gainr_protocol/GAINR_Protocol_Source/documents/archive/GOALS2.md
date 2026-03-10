# GAINR Protocol — GOALS v2: Pari-Mutuel Transformation

## Problem Statement
The current demo looks and feels like a **traditional fixed-odds sportsbook** (Bet365/DraftKings). A professional gambler immediately recognises this because:
- Fixed decimal odds are displayed (1.85, 3.40, 4.20)
- Returns are guaranteed at bet-placement time (`stake × odds`)
- Odds are sourced from external bookmaker APIs
- No pool state, pool sizes, or dividend estimates are visible
- Settlement pays pre-calculated returns, not pool-derived dividends
- Language uses sportsbook terminology ("Place Bet", "Odds", "Return")

GAINR's whitepaper defines a **parimutuel peer-to-pool** model. The UI must authentically reflect this.

---

## What Makes Pari-Mutuel Different (Reference)

| Concept | Fixed-Odds Sportsbook | Pari-Mutuel (Tote/Pool) |
|---------|----------------------|------------------------|
| **Who sets odds** | Bookmaker | The market (all bettors collectively) |
| **Price guarantee** | Locked at placement | Only known at pool close |
| **Risk bearer** | The house | Distributed across bettors |
| **Payout formula** | `stake × odds` | `(Total Pool − Rake) / Winning Pool` |
| **Odds movement** | Bookmaker adjusts | Automatic as money flows in |
| **Pool visibility** | Hidden (house risk) | Public and transparent |

---

## PHASE 2A: Pari-Mutuel UI Transformation

### 2A.1 — Data Model Changes
- [ ] **New `Pool` model** with fields:
  - `totalPool` (total money across all outcomes)
  - `outcomePools` (map of outcome → amount, e.g. `{home: 22000, draw: 8200, away: 15000}`)
  - `rake` (protocol fee percentage, 5–10%)
  - `status` (open / suspended / closed / settled)
  - `closingTime` (when the pool stops accepting bets)
  - `settledOutcome` (null until result is in)
  - `finalDividend` (null until settled)
- [ ] **Update `Event` model**: Replace `BettingOdds` (fixed homeWin/draw/awayWin) with a reference to `Pool`
- [ ] **Update `Bet` model**: 
  - Remove `odd` field (no fixed odds in pari-mutuel)
  - Add `poolSharePercentage` (user's % of their chosen outcome pool)
  - Add `estimatedDividend` (indicative, recalculated on each pool update)
  - Change `potentialReturn` from `stake × odd` to a getter that calculates from current pool state

### 2A.2 — Pool-Derived Odds Engine (Replace Bookmaker API)
- [ ] **Remove dependency on The Odds API for pricing** — odds must be calculated internally from pool balances
- [ ] **Implement pool odds calculation**:
  ```
  Estimated Dividend (for outcome X) = (Total Pool − Rake) / Pool on X
  ```
- [ ] **Seed initial pools with mock treasury liquidity** (LaaS simulation) to avoid ÷0 and extreme dividends on empty pools
- [ ] **Real-time recalculation**: Every time a user adds to a pool, recalculate all estimated dividends across all outcomes
- [ ] **Optional**: Keep The Odds API as a "Fair Value" reference for the AI Insights panel (show bookmaker price vs pool price gap)

### 2A.3 — Event Card Redesign
- [ ] **Replace fixed odds buttons with pool distribution bars**:
  - Horizontal stacked bar showing % of money on each outcome
  - Color-coded (e.g. Home = blue, Draw = grey, Away = red)
  - Each segment shows: outcome label + estimated dividend + pool amount
- [ ] **Add total pool size** displayed prominently (e.g. "Pool: $45,200")
- [ ] **Add pool closing countdown** (e.g. "Pool closes in 1h 23m")
- [ ] **Show estimated dividend instead of fixed odds** with "EST." label
- [ ] **Add pool movement indicator** — small arrows/animation when money flows in
- [ ] **Value bet badge update**: AI edge should compare AI fair value vs current pool dividend (not vs bookmaker odds)

### 2A.4 — Bet Slip Redesign
- [ ] **Replace "Odds: 4.20" with "Est. Dividend: $4.20"** with a disclaimer
- [ ] **Show user's pool share**: "Your $50 = 2.3% of Away pool"
- [ ] **Show pool impact preview**: What the dividend would become after your bet is added
- [ ] **Add dividend movement warning**: "Adding $50 will move the Away dividend from $4.20 → $3.95"
- [ ] **Replace "Potential Return: $210" with "Estimated Return: ~$210"** with note: *"Final return depends on pool state at close"*
- [ ] **Replace "Place Bet" button with "Add to Pool"**
- [ ] **Add minimum contribution label** (instead of "Min Stake")

### 2A.5 — Bet Confirmation Modal
- [ ] **Show pool contribution summary** instead of traditional bet receipt
- [ ] **Display "Pool Position"**: your contribution as % of outcome pool
- [ ] **Disclaimer**: "Your estimated dividend may change as other participants contribute before pool close"
- [ ] **Show estimated vs guaranteed language clearly** — use amber/yellow for estimates, green only for settled wins
- [ ] **Transaction description**: "Contributing to Away Pool" (not "Placing bet on Away Win")

### 2A.6 — Settlement & Payout Redesign
- [ ] **Calculate payout at settlement time** from final pool state, not at bet placement
- [ ] **Settlement formula**: 
  ```
  User Payout = (User's Stake / Winning Outcome Pool) × (Total Pool − Rake)
  ```
- [ ] **Settlement UI** should show:
  - Final pool breakdown (all outcomes)
  - Total pool size
  - Rake deducted
  - Your share of winning pool
  - Your actual dividend (calculated post-close)
- [ ] **My Bets screen**: Show "Pending dividend" (estimate) for open pools, "Final dividend" for settled
- [ ] **Add "Pool Settled" notification** with full breakdown

### 2A.7 — Language & Terminology Overhaul
| Current (Sportsbook) | New (Pari-Mutuel) |
|----------------------|-------------------|
| Odds | Estimated Dividend |
| Place Bet | Contribute to Pool / Add to Pool |
| Bet Slip | Pool Slip / Contribution Slip |
| Potential Return | Estimated Return |
| Stake | Contribution |
| My Bets | My Positions |
| Bet Placed! | Pool Contribution Confirmed! |
| You Won! | Pool Settled — You Won! |

### 2A.8 — Pool Lifecycle Visualisation
- [ ] **Pool status indicator on event card**: Open → Closing Soon → Closed → Settling → Settled
- [ ] **Pool timeline**: Show when pool opened, current state, expected close, expected settlement
- [ ] **Pool close animation**: Visual lock/seal animation when pool closes (no more contributions)
- [ ] **Post-close view**: Show final pool state, frozen dividends, waiting for result

### 2A.9 — Real-Time Pool Dynamics (Advanced)
- [ ] **Live pool feed**: Simulate other users contributing to pools (mock WebSocket updates)
- [ ] **Pool movement notifications**: "Pool Alert: Away dividend dropped from $4.50 → $3.80 (large contribution detected)"
- [ ] **Pool depth indicator**: Show how "liquid" each outcome is (thin pool = volatile dividend)
- [ ] **Last-minute surge protection**: Visual warning when pool is near closing and dividends are volatile

### 2A.10 — LaaS (Liquidity-as-a-Service) Visualization
- [ ] **Show treasury contribution** in pool breakdown (e.g. "Treasury: $5,000 | Users: $40,200")
- [ ] **PID Controller indicator**: Show when the protocol is actively rebalancing a skewed pool
- [ ] **"Protocol Stabilised" badge**: When LaaS injects liquidity to rebalance, show this on the event card
- [ ] **Pool health meter**: Green (balanced) → Yellow (skewed) → Red (heavily skewed, LaaS activated)

### 2A.11 — Odds Integrity & Mathematical Consistency
> **Origin**: CRO feedback identified that displayed odds (1.45 Man City) implied 69% probability while AI Insights claimed 62% — a negative-edge contradiction. A professional gambler caught this in seconds. In production, every number must tell a consistent, mathematically sound story.

#### Overround Standards
- [ ] **Three-way markets** (Soccer 1X2): Target **106–109%** overround
- [ ] **Two-way markets** (Tennis, NBA, Cricket T20, Horse Racing): Target **103–106%** overround
- [ ] **No sub-100% books**: A book below 100% = guaranteed arbitrage loss. Automated validation must reject this
- [ ] **No extreme single-outcome pricing** below 1.10 or above 20.00 without contextual justification (e.g. live match 3-0 at 85')

#### AI Insights ↔ Displayed Odds Consistency
- [ ] **Market Implied probabilities** must always be derived from the actual displayed odds (remove overround, normalise to 100%)
- [ ] **GAINR AI Prediction** must show a positive edge on at least one outcome vs Market Implied — otherwise the AI has no story to tell
- [ ] **Calculated Edge %** must match `max(GAINR prob − Market prob)` across outcomes — never hardcoded
- [ ] **Confidence %** must be deterministic per event (based on data quality/model certainty), not random
- [ ] **Smart Money Flow** text must reference the actual team/player name, never generic "Home Win"

#### Pool-Derived Dividend Engine (Production)
- [ ] **Dividend calculation** must use the canonical formula:  
  `Estimated Dividend = (Total Pool × (1 − Rake%)) / Outcome Pool`
- [ ] **Zero-pool guard**: If an outcome pool is empty, show "No dividend available" — never divide by zero
- [ ] **Dividend precision**: Display to 2 decimal places, calculate to 6 internally
- [ ] **Rake transparency**: Always show the rake % and deducted amount alongside dividend

#### Validation Pipeline
- [ ] **Automated overround check**: On every pool update, validate that the implied book % is within target range
- [ ] **AI consistency gate**: Before displaying AI Insights, verify that the GAINR prediction shows positive edge on at least one outcome
- [ ] **Regression test suite**: Unit tests that verify dividend calculations, overround ranges, and AI-to-odds consistency for a set of known scenarios
- [ ] **Demo data validator**: A script/tool that audits all mock events for mathematical correctness before any demo deployment

#### Score-Context Realism (Live Markets)
- [ ] **Live odds must reflect the score**: A 0-0 match at 22' should not have the same odds as a pre-match favourite
- [ ] **Time decay factor**: As match progresses, odds should drift toward current scoreline probability
- [ ] **Score-odds plausibility check**: Flag any live event where odds contradict the visible score (e.g. team leading 3-0 priced as underdog)

---

## PHASE 2B: Advanced Pari-Mutuel Features

### 2B.1 — Multi-Pool Market Types
- [ ] **Win Pool**: Standard 1X2 outcome (current scope)
- [ ] **Exacta Pool**: Predict first & second in order (relevant for Horse Racing)
- [ ] **Forecast Pool**: Predict correct score in football
- [ ] **Quaddie Pool**: Pick winners across 4 events (accumulator-like)

### 2B.2 — Pool Analytics Dashboard
- [ ] **Pool history chart**: Show how dividends moved from pool open → close
- [ ] **Smart money indicator**: Highlight when sharp bettors (large contributions) shift the pool
- [ ] **Pool efficiency metric**: Compare pool dividend vs AI fair value (shows market wisdom)
- [ ] **Your ROI tracker**: Track your dividend history vs market average

### 2B.3 — Cash-Out Mechanism (Pool Exit)
- [ ] **Allow early exit from open pools** at current estimated dividend
- [ ] **Exit penalty**: Small fee (1–2%) for early withdrawal to discourage manipulation
- [ ] **Partial exit**: Withdraw portion of contribution while keeping a position
- [ ] **Exit confirmation**: Show current vs original estimated dividend and profit/loss

### 2B.4 — Social Pool Features
- [ ] **Pool leaderboard**: Show top contributors per pool (anonymised wallet prefixes)
- [ ] **Pool chat**: Allow pool participants to discuss before close
- [ ] **Syndicate pools**: Allow group contributions with shared dividend distribution
- [ ] **"Follow the Smart Money"**: Highlight pools where verified analysts have contributed (Pick.bet integration)

### 2B.5 — Compliance & Fairness Indicators
- [ ] **Pool transparency badge**: "This pool is verifiable on-chain"
- [ ] **Rake disclosure**: Always show exact rake % and amount deducted
- [ ] **Audit trail link**: Link to on-chain transaction for each pool (Solscan/Explorer)
- [ ] **No house risk badge**: "GAINR never bets against you — 100% peer-to-pool"

---

## PHASE 2C: Critical Credibility Requirements

> These features are **non-negotiable** for any serious betting platform demo. Without them, regulators, investors, and industry professionals will immediately question credibility.

### 2C.1 — Responsible Gambling
- [ ] **Deposit limits**: Daily / weekly / monthly caps configurable by user
- [ ] **Loss limits**: Auto-pause when threshold reached
- [ ] **Reality checks**: Periodic prompts ("You've been active for 2 hours — take a break?")
- [ ] **Self-exclusion**: Temporary (24h/7d/30d) and permanent options
- [ ] **Cool-off period**: Configurable delay between consecutive contributions
- [ ] **Session timer**: Persistent clock in header showing active session duration
- [ ] **Age verification indicator**: Badge/icon confirming verified status
- [ ] **Problem gambling resources**: GamCare, BeGambleAware, Gambling Therapy links in footer and profile
- [ ] **Pre-commitment tools**: "Set your budget before this session"

### 2C.2 — Pari-Mutuel Education Layer
- [ ] **First-bet onboarding tutorial**: Interactive walkthrough — "This isn't a traditional sportsbook"
- [ ] **Contextual tooltips** on estimated dividends: "Why does this number change?" (tap to learn)
- [ ] **"How Pools Work" modal**: Accessible from every event card via ℹ️ icon
- [ ] **Visual comparison animation**: Side-by-side showing sportsbook vs pari-mutuel mechanics
- [ ] **FAQ section**: Professional-grade explanations for terms like dividend, pool share, rake
- [ ] **"What makes GAINR different?"** persistent CTA for first-time users

### 2C.3 — AI Model Explainability
- [ ] **Factor breakdown panel**: "Form: +4.2% | H2H: +1.8% | Injuries: −2.1% | Sentiment: +3.5%"
- [ ] **Data source indicators**: "Based on 47 data points across 3 providers"
- [ ] **Model version & timestamp**: "GAINR Oracle v2.1 — Updated 12 minutes ago"
- [ ] **Backtested accuracy**: "68% accurate on similar matchups (n=234)"
- [ ] **Contrarian alerts**: "GAINR disagrees with market consensus — here's why"
- [ ] **Confidence breakdown**: Show what drives high/low confidence (data freshness, market agreement, sample size)

### 2C.4 — On-Chain Proof Layer
- [ ] **Transaction hash preview**: "Pool TX: 7xK2...mR4f" (simulated for demo)
- [ ] **Block confirmation indicator**: "Confirmed in 0.4s (Slot #245,012,847)"
- [ ] **Pool state on-chain badge**: "This pool is verifiable on Solana"
- [ ] **Settlement proof**: "Result verified by Oracle consensus (3/5 validators)"
- [ ] **Explorer link**: "View on Solscan →" (link to testnet in demo, mainnet in production)
- [ ] **Wallet activity feed**: Show recent on-chain transactions in profile

---

## PHASE 2D: Professional Polish & Demo-Grade Features

### 2D.1 — Historical AI Performance Dashboard
- [ ] **Hit rate by sport**: "Soccer: 64% | Basketball: 71% | Tennis: 58%"
- [ ] **ROI tracker**: "Following GAINR value bets this month: +8.3% ROI"
- [ ] **Comparison chart**: "GAINR AI vs Market Closing Price" over time (line chart)
- [ ] **Streak tracker**: Current winning/losing streaks for transparency
- [ ] **Leaderboard**: "GAINR AI ranked #3 out of 127 tipster models this quarter"

### 2D.2 — Multi-Jurisdiction Awareness
- [ ] **Jurisdiction selector** in profile (US, UK, EU, LATAM, APAC)
- [ ] **Market availability badges**: "Available in your region" / "Restricted"
- [ ] **Currency display**: $BET pegged to USDC with local currency equivalent
- [ ] **Compliance status indicators**: "KYC: ✅ Verified | Geo: ✅ Approved"
- [ ] **Regulatory badge**: "GLI-33 Bridge Compliant" in footer

### 2D.3 — Professional Data Presentation
- [ ] **Sparkline charts** on each event card showing pool/dividend movement
- [ ] **Market depth visualization**: Trading-style order book view for pools
- [ ] **Tabular view toggle**: Grid mode vs card mode (professionals prefer data density)
- [ ] **Sortable/filterable event list**: Sort by pool size, closing time, AI edge, sport
- [ ] **Watchlist**: Star/favourite events for quick access
- [ ] **Keyboard shortcuts**: Professional users expect rapid navigation

### 2D.4 — Notification & Alert System
- [ ] **Pool closing alerts**: "Arsenal vs Liverpool pool closes in 15 minutes"
- [ ] **Dividend movement alerts**: "Your Home position dividend changed: $3.20 → $2.85"
- [ ] **Settlement notifications**: Push notification with full payout breakdown
- [ ] **AI value alerts**: "New Value Bet detected: Inter Miami +6.2% edge"
- [ ] **Custom thresholds**: "Alert me if Home dividend exceeds $3.00"
- [ ] **Notification centre**: Inbox-style feed of all alerts

### 2D.5 — B2B / LaaS Demo Mode
- [ ] **"Operator View" toggle**: Show pool P&L, rake collected, liquidity utilisation, API throughput
- [ ] **White-label preview**: "See how this looks on YOUR brand" with theme customiser
- [ ] **API playground**: Sample API calls & responses for pool creation, contribution, settlement
- [ ] **Integration guide teaser**: "3 lines of code to embed GAINR pools"
- [ ] **Revenue simulator**: "At $1M daily pool volume, your rake share = $X"

### 2D.6 — Accessibility & Internationalisation
- [ ] **WCAG 2.1 AA** minimum: Screen reader support, contrast ratios, keyboard navigation
- [ ] **RTL language support**: Arabic/Hebrew market readiness
- [ ] **Odds format toggle**: Decimal (EU) / Fractional (UK) / American (US)
- [ ] **Timezone-aware scheduling**: Show event times in user's local timezone
- [ ] **Dark/light mode toggle**: Professional preference support

### 2D.7 — Live Pool Simulation (Demo Mode)
- [ ] **"Demo: Live Mode" toggle**: Simulates 20-50 users contributing in real-time
- [ ] **Pool amounts visibly growing** with smooth count-up animations
- [ ] **Dividend bars shifting** in real-time as simulated money flows
- [ ] **Activity feed**: "New contribution: $250 added to Away pool" (scrolling ticker)
- [ ] **Configurable speed**: Slow (investor demo) / Fast (feature showcase)

### 2D.8 — Split-Screen Comparison Mode
- [ ] **"Compare Mode" CTA**: Side-by-side of Traditional Sportsbook vs GAINR Pools
- [ ] **Left panel**: Fixed-odds UX with locked price, guaranteed return
- [ ] **Right panel**: Pool UX with estimated dividend, pool share, movement
- [ ] **Live delta**: "On a sportsbook you'd get $4.20. GAINR pool dividend: $4.85 (+15.5%)"
- [ ] **"Why Pools Win" footer**: Key benefits summary (no house edge, transparent, verifiable)

---

## Success Metrics (Complete)

| KPI | Target | Notes |
|-----|--------|-------|
| **CRO Validation** | CRO says "This is a pool" | The ultimate litmus test |
| **Pool Visibility** | 100% of events show pool state | No static odds anywhere |
| **Terminology Compliance** | 0 sportsbook terms in UI | Full language overhaul |
| **Dividend Accuracy** | ±0.01 of mathematical model | Settlement matches formula |
| **Pool Animation** | Real-time updates < 500ms | Feels alive and dynamic |
| **LaaS Visibility** | Treasury contribution shown | Users understand the protocol |
| **Overround Compliance** | 100% events within target range | 106–109% (3-way), 103–106% (2-way) |
| **AI-Odds Consistency** | 0 negative-edge contradictions | AI must always find positive edge |
| **No Sub-100% Books** | 0 arbitrage opportunities | Automated validation gate |
| **Score-Context Accuracy** | Live odds match visible score | No logical contradictions |
| **Responsible Gambling** | 100% of RG features present | Regulator/investor readiness |
| **Education Completion** | >60% of new users complete tutorial | Pari-mutuel literacy |
| **AI Explainability** | Factor breakdown on every event | Trust through transparency |
| **On-Chain Proof** | TX hash shown for every action | Web3 credibility |
| **Accessibility** | WCAG 2.1 AA pass | Professional compliance |
| **B2B Demo Ready** | Operator view functional | LaaS pitch readiness |

---

## Technical Considerations

### Files Requiring Major Changes
| File | Change |
|------|--------|
| `event_model.dart` | Replace `BettingOdds` with `Pool` model |
| `bet_model.dart` | Remove `odd`, add pool share + estimated dividend |
| `event_card.dart` | Pool bars, estimated dividends, pool size, countdown |
| `bet_slip_sheet.dart` | Pool contribution UX, share %, dividend impact |
| `bet_confirmation_modal.dart` | Pool contribution receipt, disclaimers |
| `placed_bets_provider.dart` | Settlement from pool state, not pre-calculated return |
| `sports_api_client.dart` | Generate pool data instead of bookmaker odds |
| `event_provider.dart` | Serve pool state, handle real-time updates |
| `ai_insights_panel.dart` | Dynamic probability derivation (already implemented for demo) |
| `main_layout.dart` | Session timer, RG indicators, notification centre |
| `app_theme.dart` | Dark/light mode support, WCAG contrast compliance |

### New Files Needed
| File | Purpose |
|------|---------|
| `pool_model.dart` | Pool data model with dividend calculation |
| `pool_provider.dart` | Pool state management + real-time updates |
| `pool_visualization.dart` | Pool bar chart + distribution widget |
| `pool_countdown.dart` | Pool closing timer widget |
| `dividend_calculator.dart` | Core pari-mutuel math engine |
| `odds_validator.dart` | Overround checker + AI consistency gate |
| `mock_data_auditor.dart` | Pre-deploy validation for demo data |
| `responsible_gambling_provider.dart` | Deposit/loss limits, session tracking, self-exclusion |
| `rg_settings_screen.dart` | Responsible Gambling settings UI |
| `onboarding_tutorial.dart` | Pari-mutuel education walkthrough |
| `ai_explainability_panel.dart` | Factor breakdown, data sources, accuracy display |
| `on_chain_proof_widget.dart` | TX hash, block confirmation, explorer links |
| `notification_provider.dart` | Alert system, dividend movement, pool closing |
| `notification_centre.dart` | Inbox-style notification feed |
| `ai_performance_dashboard.dart` | Historical hit rates, ROI, comparison charts |
| `operator_view.dart` | B2B LaaS demo — pool P&L, rake, API playground |
| `comparison_mode.dart` | Split-screen sportsbook vs pool UX |
| `pool_simulator.dart` | Live demo mode — simulated user activity |

---

*Last Updated: February 17, 2026*  
*Status: Ready for review — Complete roadmap with pari-mutuel transformation, mathematical integrity, responsible gambling, AI explainability, on-chain proof, and professional demo features (updated from CRO feedback)*
