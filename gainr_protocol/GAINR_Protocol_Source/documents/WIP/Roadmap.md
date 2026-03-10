# GAINR Protocol — Price.bet Product Roadmap

> **GAINR Protocol** is an AI-native, decentralized infrastructure layer on Solana designed to solve the Bettor's Dilemma. Price.bet is the flagship prediction market dApp in the GAINR ecosystem.

---

## 🧭 The Vision

```
The GAINR Ecosystem:

  BACK.BET          PRICE.BET          PICK.BET
  (Sports P2P)  →   (Prediction)   →   (Copy-Trade)
        |                |                |
        └────────────────┴────────────────┘
                         |
              GAINR Protocol Layer
          (LaaS · System 2 AI · Compliance)
                         |
              Solana Settlement Layer
```

---

## 📌 Current Status (Q1 2026)

**Price.bet is in active transformation** from the forked `DecentraPredict` scaffold. The Token-2022 $GBET mint, vault deposit/withdraw, and initial CPMM trading engine exist on Devnet. Critical security hardening and CPI fixes are the immediate priority.

| Component | Status | Detail |
|:---|:---|:---|
| Smart Contract ($GBET Mint) | 🟢 Token-2022 Correct | `init_bet_mint.rs`, `deposit_usdc.rs`, `withdraw_usdc.rs` |
| Smart Contract (Trading) | 🔴 CPI Mismatch | `betting.rs`, `sell_shares.rs` use legacy SPL Token |
| CPMM Engine | 🟡 Math Present | Price calculator is a placeholder |
| Compliance (zkMe) | 🔴 Dummy Bytes | On-chain verification is `[1, 2, 3]` |
| Backend API | 🔴 No Auth | Zero wallet signature verification |
| Frontend | 🟡 Functional | Core UI, needs branding + PWA |
| AI Intelligence | ⚪ Not Started | No Python service exists |

**True Completion: ~6% production-ready**

---

## 🛣️ Milestone Map

### ✅ MILESTONE 0 — Foundation & Rebrand (Week 1) — PARTIALLY DONE
- [x] Full Price.bet rebrand — package.json, layout.tsx, server banner
- [ ] Security foundation — wallet auth, Helmet, rate limiting, secrets fix
- [ ] Fix `betting.rs` + `sell_shares.rs` Token-2022 CPI mismatch
- [ ] Fix CPMM `compute_prices()` placeholder
- [ ] Remove client-trusted price data from backend

---

### 🔷 MILESTONE 1 — Secure Devnet (Weeks 2–6)
*First verified, secure version of all core Price.bet features.*

**Smart Contract**
- Token-2022 $GBET CPI unified across ALL instructions
- Real on-chain zkMe ed25519 precompile verification
- CPMM `compute_prices()` with integer-only arithmetic
- Squads Protocol multi-sig for admin key + upgrade authority
- Arithmetic safety audit — no `as u64` truncation, no `f64` in on-chain math

**Backend**
- Wallet signature authentication on all POST routes
- Redis caching for market data + auth tokens (<50ms target)
- Helmet + CORS + rate limiting + body size limit hardened
- Zod request validation on all API bodies
- Break-Glass secret: env-only + `timingSafeEqual`
- Backend sources truth from Solana, never from client body

---

### 🔷 MILESTONE 2 — Backend Architecture Upgrade (Weeks 7–10)
- WebSocket/SSE layer (Socket.io) for real-time events
- BullMQ + Redis job queue for on-chain event processing
- NestJS evaluation/migration for DI, Guards, auto-OpenAPI docs
- SWR / TanStack Query on frontend (replace raw axios)
- `@solana/web3.js` v1 → v2 migration (tree-shakeable, smaller bundles)

---

### 🔷 MILESTONE 3 — Compliance Certification (Weeks 11–14)
*GLI-33 readiness pass.*
- Token ACL — `DefaultAccountState::Frozen`, thaw via ZK-SBT
- Production geo-fencing middleware (IP database)
- Off-chain Regulatory Indexer (CSV/XLS export for audit reports)
- Daily Hash-Digest — on-chain immutability proof
- Dual smart contract security audit (OtterSec + one more)
- Time-lock on `resolve_market` (24hr delay + dispute window)

---

### 🔷 MILESTONE 4 — AI Layer Alpha (Weeks 15–22)
*The "System 2" competitive edge.*
- **gainr-ai-oracle** Python FastAPI microservice (MVP: any LLM → fair value)
- Wire `oracle/index.ts` → REST call to AI oracle
- Fair Value Alerts — push via WebSocket when market edge > 5%
- L2 Predictive Models — LORA fine-tuned on Gainr Analytics syndicate data
- L3 Hybrid RAG Pipeline — real-time news context (LangChain)
- Syndicate data pipeline → PostgreSQL data lake

---

### 🔷 MILESTONE 5 — Professional Trading UI (Weeks 23–28)
- Price.bet Dark Mode + Glassmorphism Design System
- Advanced candlestick probability charts + volume bars
- Real-time social bet ticker overlay (WebSocket)
- AI Insight Panel — Fair Value, Edge indicator, alerts card
- Mobile PWA manifest + offline support + service worker
- Web Vitals: LCP < 2.5s, CLS < 0.1, FID < 100ms
- Frontend code splitting + lazy load wallet adapter

---

### 🔷 MILESTONE 6 — DevOps & Performance (Q3 2026)
- CI/CD Pipeline: Lint → TypeCheck → Test → Build → Devnet → Manual → Mainnet
- Infrastructure as Code (Terraform / AWS CDK)
- Monitoring: Grafana + Prometheus + Sentry + Helius Webhooks
- PagerDuty alerting for production incidents
- Smart contract monitoring (abnormal bets, oracle failures, vault solvency)
- 2,000+ TPS load testing (k6 / Artillery)
- Horizontal scaling (Nginx LB / AWS ECS)
- Redis Cluster + MongoDB read replicas + CDN edge caching

---

### 🔷 MILESTONE 7 — $GAINR Token & Ecosystem (Q3 2026)
- $GAINR TGE — 100M fixed supply
- Buyback-and-Burn Engine (20% protocol revenue)
- Fee Discount Tiers (Bronze 5% / Silver 10% / Gold 25%)
- Vesting contracts (Seed 6mo cliff/24mo vest, Team 12mo cliff/18mo vest)
- On-chain governance — fee params, oracle keys, reserve ratios governed by $GAINR

---

### 🔷 MILESTONE 8 — Back.bet Launch (Q3–Q4 2026)
- Parimutuel Betting Smart Contract
- LaaS PID Controller — automatic pool rebalancing
- Reserve Quoter — signed off-chain quotes, MEV protection
- Exposure Manager — 15% Risk of Ruin circuit breaker
- Back.bet Frontend — sports market UI

---

### 🔷 MILESTONE 9 — Pick.bet, B2B & Go-Live (Q4 2026)
- Pick.bet — copy-trading from verified signal providers
- B2B "Bloomberg for Betting" API — sell liquidity/odds to Web2 operators
- SDK published to NPM for B2B self-integration
- Syndicate Pro Terminal — institutional low-latency interface
- BVNK fiat on-ramp (Stripe/Skrill/Bank Transfer)
- Chainlink Oracle redundancy (alongside Switchboard)
- Web2 OIDC / Social Login (account abstraction)

---

### 🔷 MILESTONE 10 — Mainnet & Legal (Q4 2026)
- Mainnet deployment — all three dApps live
- Squads Protocol multi-sig treasury governance
- AWS Secrets Manager for all production env vars
- VPC + private subnets + WAF for full infrastructure security
- Crypto-friendly jurisdiction structure (Cayman/BVI/Gibraltar)
- UK / Malta gambling license application
- Howey Test legal opinion letter ($GBET non-transferable, $GAINR utility)
- ISO 27001 + ISO 42001 alignment documentation
- Gitbook documentation — API reference, NatSpec, integration guides

---

## 🏗️ The 6-Layer Stack (Target Architecture)

```
L1 — Interface     │ Web3 Wallets · Web2 OIDC · Syndicate Pro Terminal · Mobile PWA
L2 — Compliance    │ zk.Me ZKP-KYC · Geo-fence · Break-Glass Enclave · GLI-33 Indexer
L3 — Applications  │ Back.bet · Price.bet · Pick.bet · B2B API
L4 — Intelligence  │ 4-Layer System 2 AI Oracle (Prompt → LORA → RAG → EV Reasoning)
L5 — Settlement    │ Solana Anchor · LaaS PID · Exposure Manager · Token-2022 $GBET
L6 — Infrastructure│ Solana RPC · Chainlink · Switchboard · AWS · BVNK · Redis · BullMQ
```

---

## 📊 KPIs (Year 1 Targets per PRD)

| KPI | Target |
|:---|:---|
| Cost Per Install | < $5.00 |
| D30 Retention | > 10% |
| ARPPU | > $50/month |
| Day 1 DEX Volume | > $1M |
| Year 1 Revenue | €1.5M |

---

## 🤝 Ecosystem & Partners

| Partner | Role |
|:---|:---|
| **Gainr Analytics** | Professional Trading Syndicate (AI Data + Treasury Seed) |
| **University of Glasgow** | System 2 AI Research |
| **Coventry University** | Bayesian Inference Research |
| **Solana Foundation** | Infrastructure |
| **Chainlink** | Data Feed Oracles (redundant with Switchboard) |
| **Switchboard** | On-Demand Oracles |
| **zk.Me** | Zero-Knowledge KYC/Identity |
| **BVNK** | Fiat Payment Rails |
| **SportRadar** | Sports Data Feeds |

---

*Last Updated: 2026-02-22 | Version: Roadmap v2.0 (post transformation recommendations)*
