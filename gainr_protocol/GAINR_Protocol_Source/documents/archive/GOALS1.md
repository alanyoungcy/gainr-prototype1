# GAINR Protocol - Development Goals & Roadmap

## Vision Statement
Build a fully-functional Flutter demo for **Back.bet** that demonstrates the GAINR Protocol's core value proposition while serving as a foundation for production development.

---

## Current Status: Demo Refinement (Phase 1 Extension)
**What We Have**: High-fidelity Flutter demo with real odds API, mock wallet, and initial AI Insights.
**What We Need**: Deeper integration of AI features, responsive accessibility, and professional layout consistency.

---

## PHASE 1: Enhanced Demo (Refining ✨)
**Goal**: Create a believable, interactive demo that can be shown to investors/users

### 1.1 Wallet Integration
- [x] Integrate **Phantom Wallet Adapter** (Flutter) — realistic mock with Phantom branding
- [x] Display wallet address (mock address shown on connect)
- [x] Show SOL balance from connected wallet (mock)
- [x] Mock $BET/$GAINR balances (SharedPreferences persistence)
- [x] Implement deposit flow UI (USDC → $BET conversion via DepositModal)
- [x] Implement withdrawal flow UI ($BET → USDC via WithdrawModal)

### 1.2 Enhanced Betting Experience
- [x] **Event Data Service**:
  - [x] Integrate The Odds API (with mock fallback)
  - [x] Display upcoming matches with live odds
  - [x] Show real team logos and league badges (team-colored avatars + league pills)
- [x] **Bet Placement Flow**:
  - [x] Build complete bet slip with dynamic stake input
  - [x] Calculate potential returns dynamically
  - [x] Show confirmation modal with bet summary
  - [x] Animate bet placement with success feedback
  - [x] Persist placed bets via PlacedBetsProvider (SharedPreferences)
- [x] **Bet History**:
  - [x] Store bets in local storage (PlacedBetsProvider)
  - [x] Display "My Bets" screen with pending/settled status + countdown
  - [x] Auto-settlement after 30 seconds with random win/loss (40/60)
  - [x] Wallet auto-credited on win

### 1.3 Token Economy Visualization
- [x] **$BET Chip System**:
  - [x] Visual deposit flow (USDC → $BET via DepositModal)
  - [x] Visual withdrawal flow ($BET → USDC via WithdrawModal)
  - [x] Show conversion rate (1:1 peg)
  - [x] Display chip balance prominently (ProfileScreen + ConnectWalletButton)
- [x] **$GAINR Utility**:
  - [x] Show staking interface (GainrStakingCard in bet slip panel)
  - [x] Display fee tier badges (Bronze/Silver/Gold/Diamond)
  - [x] Animate buyback-and-burn counter (auto-incrementing with fire effect)

### 1.4 AI Layer (Simulated)
- [x] **AI Insights Panel**:
  - [x] Show mock "System 2" reasoning with animated steps
  - [x] Display probability analysis vs current odds
  - [x] Show "Edge %" indicator (aiEdge on Event model)
  - [x] Add "Ask AI" chat interface (ChatGPT-style with keyword responses)
- [x] **Smart Suggestions**:
  - [x] Highlight value bets with AI VALUE badge + green glow border
  - [x] Show social win notifications (SocialWinOverlay)
  - [x] Live bet ticker banner (LiveBetTicker in MainLayout)

### 1.5 User Experience Polish
- [x] Smooth animations (AnimatedSwitcher page transitions, bet slip slide-in)
- [x] Loading states for all async operations
- [x] Error handling with user-friendly messages
- [x] Responsive layout (3-panel desktop, drawer mobile, BottomNavigationBar)
- [x] Dark mode perfection (matching design reference)

**Deliverable**: Demo video showing full user journey (Connect → Deposit → Browse → Bet → Settlement → View History → Withdraw)

---

## PHASE 2: Backend Foundation
**Goal**: Replace mocks with real infrastructure

### 2.1 Solana Smart Contracts (Anchor/Rust)
- [ ] **Player Vault Program**:
  - PDA-based user vaults
  - USDC → $BET minting logic
  - $BET → USDC burning logic
  - Non-transferable token implementation (Token-2022)
- [ ] **Betting Engine (Simplified)**:
  - Single-outcome parimutuel pool
  - Bet placement with atomic state updates
  - Simple payout calculation
  - Event settlement by admin oracle

### 2.2 Backend Services (Node.js/Python)
- [ ] **API Server**:
  - RESTful API for event data
  - WebSocket for live odds updates
  - User session management
- [ ] **Database** (PostgreSQL):
  - Events, markets, bets schema
  - User profiles (off-chain metadata)
- [ ] **Oracle Service**:
  - Fetch live scores from SportRadar/API-Football
  - Trigger on-chain settlement

### 2.3 Integration
- [ ] Connect Flutter app to backend API
- [ ] Implement Solana transaction signing
- [ ] Real-time balance updates via WebSocket
- [ ] Transaction confirmation flows

**Deliverable**: Functional betting on Solana Devnet with real wallet transactions

---

## PHASE 3: Core Features
**Goal**: Add production-ready features

### 3.1 Compliance (Critical for Launch)
- [ ] **zk.Me Integration**:
  - Age verification (>18)
  - Geo-fencing (block restricted regions)
  - On-chain proof verification
- [ ] **Break-Glass PII Storage**:
  - Encrypted user data vault
  - Regulatory access controls
  - Audit trail

### 3.2 Advanced Betting
- [ ] **Multiple Market Types**:
  - Moneyline, Spread, Totals
  - Live in-play betting
  - Parlay/accumulator bets
- [ ] **Cash Out Feature**:
  - Early settlement at current odds
  - Partial cash out

### 3.3 Liquidity-as-a-Service (LaaS)
- [ ] **Reserve Controller**:
  - PID controller for pool balancing
  - Treasury-funded liquidity injection
- [ ] **Reserve Quoter**:
  - Off-chain quote signing
  - Front-running protection

### 3.4 Token Economy (Full)
- [ ] **$GAINR Staking**:
  - Staking pools with fee discounts
  - Tier-based rewards
- [ ] **Buyback-and-Burn**:
  - Automated revenue → $GAINR swap
  - Burn mechanism with tracking

**Deliverable**: Mainnet-ready Back.bet on Solana

---

## PHASE 4: AI & Scale
**Goal**: Differentiation through intelligence

### 4.1 AI Layer 1 & 2 (Foundational)
- [ ] Prompt-based UX agents
- [ ] Predictive models for odds generation
- [ ] RAG pipeline for news/injury updates

### 4.2 Additional dApps
- [ ] **Price.bet** (Prediction markets)
- [ ] **Pick.bet** (Copy trading)

### 4.3 B2B Infrastructure
- [ ] API marketplace for selling liquidity
- [ ] White-label deployment tools

**Deliverable**: Full GAINR Protocol ecosystem

---

## Success Metrics (Phase 1)

| KPI | Target | Notes |
|-----|--------|-------|
| **Demo Completion** | 100% | All Phase 1 tasks done |
| **User Flow Time** | <2 min | Connect → Bet → Confirm |
| **Visual Polish** | A+ | Premium gaming aesthetic |
| **Code Quality** | Clean | Well-structured, documented |
| **Performance** | <100ms | UI interactions |

---

## Tech Stack Decisions

### Frontend (Current)
- **Framework**: Flutter (Web + Mobile PWA)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **UI**: Custom design system (dark theme)
- **Wallet**: Solana Wallet Adapter

### Backend (Phase 2+)
- **Blockchain**: Solana (Anchor framework)
- **API**: Node.js (Express) or Python (FastAPI)
- **Database**: PostgreSQL + Redis
- **Real-time**: WebSocket (Socket.io)
- **Sports Data**: The Odds API / SportRadar
- **Hosting**: AWS / Vercel

### AI (Phase 4)
- **Model Hosting**: Hugging Face / Replicate
- **Vector DB**: Pinecone / Weaviate
- **LLM**: GPT-4 / Claude (via API)

---

## Immediate Next Steps

1. ✅ **Fix UI to match design reference** (DONE)
2. 🔄 **Integrate real sports API** (In Progress)
3. ⏳ **Add Phantom Wallet connection**
4. ⏳ **Build complete bet placement flow**
5. ⏳ **Create demo walkthrough video**

---

## Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Solana dev complexity | High | Use Anchor templates, hire Rust dev |
| Sports data costs | Medium | Start with free tier APIs |
| Compliance delays | High | Engage legal early, use zk.Me SDK |
| AI training data | Medium | Partner with Gainr Analytics syndicate |
| Liquidity bootstrapping | High | Treasury seed + PID controller |

---

## Definition of "Demo Success"

A demo is successful when:
1. ✅ A non-technical person can navigate the full flow
2. ✅ The UI feels indistinguishable from a production app
3. ✅ Core value props are demonstrable (fair odds, instant settlement simulation, AI edge)
4. ✅ The codebase is structured for production scaling
5. ✅ Investors/users say "wow" within 30 seconds

---

## Long-Term Vision

- 🎯 **Mainnet Launch**: Back.bet live on Solana
- 🎯 **10K Active Users**: Monthly active bettors
- 🎯 **$10M TVL**: Total Value Locked in betting pools
- 🎯 **UK/Malta License**: Regulatory approval
- 🎯 **AI SaaS Revenue**: Subscription tier adoption
- 🎯 **Price.bet Launch**: Prediction market live

---

*Last Updated: February 13, 2026*  
*Status: Phase 1 in progress - Demo enhancement*
