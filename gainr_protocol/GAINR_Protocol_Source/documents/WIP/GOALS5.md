# GAINR Protocol — GOALS v5
*Post-audit, source-verified. All PRD v3.0 / TSRD v2.0 requirements tracked.*
*All transformation recommendations incorporated. Last updated: 2026-02-23.*

---

## 🎯 Project Vision

Transform this monorepo into a high-performance, compliance-first prediction market dApp powered by GAINR Protocol's System-2 AI Intelligence on Solana.

The full GAINR ecosystem (Back.bet · Price.bet · Pick.bet)

---

## 🛠️ Status Indicators
| Icon | Meaning |
|:---|:---|
| ⚪ | Not Started |
| 🟡 | In Progress / Partial (code exists, incomplete or unaudited) |
| 🟢 | Completed (tested, verified, production-ready) |
| 🔴 | Needs Fix (code exists but is broken, mismatched, or insecure) |
| 🟠 | On Hold (waiting for dependency) |

---

## 🔍 Source Code Audit Findings (2026-02-22)

Before reading the roadmap, these **verified facts** from source code must be understood:

| File | Uses Token-2022? | Uses `token_interface`? | Status |
|:---|:---|:---|:---|
| `init_bet_mint.rs` | ✅ `Token2022` | ✅ `token_interface::Mint` | ✅ Correct |
| `deposit_usdc.rs` | ✅ `Token2022` | ✅ `token_interface::*` | ✅ Correct |
| `withdraw_usdc.rs` | ✅ `Token2022` | ✅ `token_interface::*` | ✅ Correct |
| **`betting.rs`** | ❌ `anchor_spl::token::Token` | ❌ `anchor_spl::token::Mint` | 🔴 **Legacy import** |
| **`sell_shares.rs`** | ❌ `anchor_spl::token::Token` | ❌ `anchor_spl::token::*` | 🔴 **Legacy import** |
| `Cargo.toml` | ✅ `features = ["token_2022"]` | — | ✅ Dependency correct |

**Diagnosis**: The $GBET Token-2022 mint is created correctly. Vault deposit/withdraw correctly uses Token-2022 CPIs. But the two **core trading instructions** (`betting.rs`, `sell_shares.rs`) still import the old SPL Token program — creating a **CPI mismatch** that would fail at runtime when interacting with the Token-2022 mint.

---

## 🏛️ TIER 0 — FOUNDATION CLEANUP (Immediate Blockers)

### PHASE 0A: Codebase Identity & Rebrand (Cosmetic → Trust Signal)
| Stage | Task | Status |
|:---|:---|:---|
| **S0A.1** | Rename `frontend/package.json` from `"spaceape"` → `"price-bet-frontend"` | 🟢 Done |
| **S0A.2** | Rename `backend/package.json` from `"prediciton-market-backend"` → `"price-bet-backend"`, remove `husreo` GitHub URLs | 🟢 Done |
| **S0A.3** | Update `layout.tsx` — Price.bet title, SEO meta tags, OpenGraph, Inter font | 🟢 Done |
| **S0A.4** | Update `backend/src/index.ts` — server banner to `"Price.bet API | GAINR Protocol"` | 🟢 Done |
| **S0A.5** | Update `Cargo.toml` program description to `"GAINR Protocol — Price.bet Settlement Engine"` | 🟢 Done |
| **S0A.6** | Consider renaming `prediction-market-*` folder names to `price-bet-*` (optional, monorepo) | ⚪ Not Started |

### PHASE 0B: Security Foundation (Critical — 24–48hr)
| Stage | Task | Status |
|:---|:---|:---|
| **S0B.1** | Implement Solana wallet signature verification middleware on **ALL** POST endpoints (incl. `referral/claim`, `oracle`, `compliance/verify`) | 🔴 Needs Fix — Applied to Market routes only; referral, oracle, profile, and compliance routes are **all unprotected** |
| **S0B.2** | Remove hardcoded `BREAK_GLASS_CODE` fallback — env-only | 🟢 Done |
| **S0B.3** | Replace string `!==` comparison with `crypto.timingSafeEqual()` | 🟢 Done |
| **S0B.4** | Add `helmet` middleware (HTTP security headers) | 🟢 Done |
| **S0B.5** | Add `express-rate-limit` + `express-slow-down` | 🟢 Done |
| **S0B.6** | Fix `betting` controller — fetch on-chain truth; stop trusting client prices | 🟢 Done |
| **S0B.7** | Reduce `express.json({ limit })` from `50mb` → `1mb` | 🟢 Done |
| **S0B.8** | Add `Zod` request body validation schemas | 🟢 Done |
| **S0B.9a** | **Fix Referral Reward Theft**: Add wallet-signature auth to `claimReward` endpoint — prevents anyone from draining funds from arbitrary wallets | 🔴 Needs Fix |
| **S0B.9b** | **Fix Profile IDOR**: Add access-control to `/profile/:wallet` — scope response fields or require auth so users cannot view others' trading history/earnings | 🔴 Needs Fix |
| **S0B.10**| **Credential Hygiene**: Move hardcoded Pinata API keys in Frontend `utils/index.ts` to Backend env vars (AWS Secrets Manager target in S8.8) | 🔴 Needs Fix |
| **S0B.11**| **CORS Origin Restriction**: Configure `Access-Control-Allow-Origin` to `https://price.bet` only; block credential-bearing cross-origin requests | 🔴 Needs Fix |
| **S0B.12**| **XSS / Output Sanitization**: Sanitize user-generated content (market descriptions, metadata) before storage; add output encoding on frontend rendering | ⚪ Not Started |
| **S0B.13**| **Fix zkMe Self-Verification**: `zkme_verify.rs` allows ANY user to call `zkme_verify(true)` to self-mark as verified — no admin/oracle authority check. Entire compliance gate is bypassable. Must require `global.admin` or `global.zkme_oracle_key` as signer | 🔴 Needs Fix |
| **S0B.14**| **Compliance Route Auth**: `/compliance/verify` POST has zero auth middleware; `/compliance/audit` Break-Glass endpoint needs IP whitelisting + wallet auth guard | 🔴 Needs Fix |

---

## 🗺️ TIER 1 — CORE INFRASTRUCTURE

### PHASE 1: $GBET Ecosystem & Token-2022
| Stage | Task | Status |
|:---|:---|:---|
| **S1.1** | Apply `NonTransferable` + `DefaultAccountState::Frozen` extensions to $GBET mint in `init_bet_mint.rs` | 🟡 Partial — `NonTransferable` applied; `DefaultAccountState::Frozen` NOT implemented (zero matches in codebase) |
| **S1.2** | Player Vault: USDC → $GBET Minting (`deposit_usdc.rs`) — Token-2022 CPI correct | 🟢 Correct |
| **S1.3** | Withdrawal: $GBET Burn → USDC Release (`withdraw_usdc.rs`) — Token-2022 CPI correct | 🟢 Correct |
| **S1.4** | Fix `betting.rs` — update to `transfer_checked` CPI for Token-2022 (currently causes mismatch error) | 🟡 Partial — $GBET transfers use `token_interface::transfer_checked` ✅; YES/NO share `mint_to`/`transfer`/`burn` still use legacy `token::` CPI |
| **S1.5** | Fix `sell_shares.rs` — update to `transfer_checked` CPI for Token-2022 | 🟡 Partial — $GBET `transfer_checked` ✅; share `transfer`/`burn` still legacy `token::` CPI |
| **S1.6** | Fix `token_mint.rs` for Token-2022 compatibility (mint_to CPI) | 🟢 Done — uses `token_interface::mint_to` correctly; clean up lingering `TokenLegacy` import |
| **S1.7** | **Arithmetic Audit**: Replace `f64` with fixed-point arithmetic in `betting.rs` (L139–140), `sell_shares.rs` (L124), `deposite_liquidity.rs` (L95), and `get_oracle_res.rs` (L41). **Root cause**: `Global` state struct stores fee percentages as `f64` — requires state migration | 🔴 Needs Fix |
| **S1.8** | Regenerate Anchor IDL + Frontend SDK after Token-2022 fixes | ⚪ Not Started |
| **S1.9** | Devnet integration test — full cycle: Deposit USDC → Withdraw | ⚪ Not Started |

### PHASE 2: CPMM Trading Engine
| Stage | Task | Status |
|:---|:---|:---|
| **S2.1** | CPMM `x * y = k` swap logic in `betting.rs` (lines 208–269) | 🟢 Done — `checked_*` math, `u128` intermediates, `try_into()` casts. Fee handling f64 tracked in S1.7 |
| **S2.2** | Cash Out: `sell_shares.rs` CPMM inverse | 🟢 Done — now uses `integer_sqrt()` from `utils.rs` (Newton's method on `u128`). Fee f64 tracked in S1.7 |
| **S2.3** | LP Fee Distribution (`pool_fee_percentage` in Global) | 🟡 Partial — fee taken, distribution path unverified |
| **S2.4** | **Fix `set_token_price()` placeholder** — replaced with CPMM `compute_prices()` | 🟢 Done |
| **S2.5** | Add `checked_` arithmetic everywhere + replace `as u64` casts with `try_into()` | 🟡 Partial — CPMM swap/sell logic uses `checked_*` + `try_into()` ✅; fee calcs in 3 files still use `(x as f64 * pct) as u64` (tracked in S1.7) |
| **S2.6** | Devnet trading stress test — buy/sell sequence, verify `price_a + price_b = 10,000 bps` invariant | ⚪ Not Started |

---

## 🧬 TIER 2 — COMPLIANCE & INTELLIGENCE

### PHASE 3: Identity & Regulatory Layer (GLI-33 Pathway)
| Stage | Task | Status |
|:---|:---|:---|
| **S3.1** | zkMe SDK Frontend Integration (`ZKMeProvider.tsx`) | 🟡 Partial |
| **S3.2** | **Real on-chain ZK-Proof Validation**: Replace dummy logic in `betting.rs` | 🔴 Needs Fix (Code is placeholder) |
| **S3.3** | Token ACL — `DefaultAccountState::Frozen` on $GBET, thaw only after ZK-SBT verification | 🟡 In Progress |
| **S3.4** | Geo-fencing Middleware (IP filtering) — controller exists, needs production IP database | 🟡 Unverified |
| **S3.5** | **Break-Glass PII Enclave** — fix hardcoded secret (`S0B.2`), add encrypted PII storage with timing-safe auth | 🔴 Needs Fix |
| **S3.6** | Daily Hash-Digest — on-chain immutability proof for regulators | ⚪ Not Started |
| **S3.7** | Off-Chain Regulatory Indexer — CSV/XLS export for GLI-33 audit reports | ⚪ Not Started |
| **S3.8** | **Compliance Verification Testing**: Simulated Break-Glass subpoena flow test + geo-fence verification across restricted/allowed jurisdictions | ⚪ Not Started |

### PHASE 4: AI Reasoning & Data Insight (System-2 Intelligence)
*The market differentiator. Must be a **separate Python/FastAPI microservice**.*
| Stage | Task | Status |
|:---|:---|:---|
| **S4.1** | **Deploy `gainr-ai-oracle` Python FastAPI microservice** — accepts market ID, returns fair-value probability | ⚪ Not Started |
| **S4.2** | Wire `oracle/index.ts` backend controller → REST call to `gainr-ai-oracle` service | ⚪ Not Started |
| **S4.3** | Real-time Market Opportunity Alerts (Edge > 5%) via WebSocket/SSE push | ⚪ Not Started |
| **S4.4** | Syndicate Data Feed (PGI) — secure pipeline from Gainr Analytics → PostgreSQL data lake | ⚪ Not Started |
| **S4.5** | L2 Predictive Model — LORA fine-tuned on syndicate data (HuggingFace PEFT + PyTorch) | ⚪ Not Started |
| **S4.6** | L3 Hybrid RAG Pipeline — real-time news context (injury/weather/social) via LangChain | ⚪ Not Started |
| **S4.7** | L4 System-2 EV Reasoning Engine — multi-model ensemble with confidence scoring | ⚪ Not Started |

---

## 💎 TIER 3 — ARCHITECTURE TRANSFORMATION & UX

### PHASE 5: Backend Architecture Upgrade
*The current Express.js backend lacks production-essential infrastructure.*
| Stage | Task | Status |
|:---|:---|:---|
| **S5.1** | **Add Redis** — session tokens, market data cache, rate-limiting state (target: <50ms auth latency) | ⚪ Not Started |
| **S5.2** | **Add WebSocket layer** (Socket.io or `ws`) — real-time social ticker + AI alerts delivery | ⚪ Not Started |
| **S5.3** | **Add BullMQ + Redis** job queue — on-chain event processing (BettingEvent → DB update → alert trigger) | ⚪ Not Started |
| **S5.4** | **Evaluate NestJS migration** — structured modules, DI, Guards (auth), Interceptors, auto-OpenAPI docs | ⚪ Not Started |
| **S5.5** | Add **SWR or TanStack Query** on frontend — replace raw `axios` with intelligent cache/revalidation | ⚪ Not Started |
| **S5.6** | **Upgrade `@solana/web3.js` v1 → v2** across frontend and backend (tree-shakeable, smaller bundles) | ⚪ Not Started |

### PHASE 6: Professional Trading UI
| Stage | Task | Status |
|:---|:---|:---|
| **S6.1** | Full Price.bet Dark Mode + Glassmorphism Design System | ⚪ Not Started |
| **S6.2** | Advanced Charts — candlestick probability curves + volume bars | ⚪ Not Started |
| **S6.3** | Real-time Social Win/Bet Ticker Overlay (WebSocket backend from S5.2) | ⚪ Not Started |
| **S6.4** | AI Insight Panel — Fair Value display, Edge indicator, Opportunity alerts card | ⚪ Not Started |
| **S6.5** | Mobile PWA manifest + offline support + service worker | ⚪ Not Started |
| **S6.6** | Web Vitals optimization — LCP < 2.5s, CLS < 0.1, FID < 100ms | ⚪ Not Started |
| **S6.7** | Frontend code splitting — lazy load wallet adapter, route-based chunking | ⚪ Not Started |

---

## 🔒 TIER 4 — SECURITY & PRODUCTION HARDENING

### PHASE 7: Smart Contract Security
| Stage | Task | Status |
|:---|:---|:---|
| **S7.1** | **Squads Protocol multi-sig** for admin key — no single-key control of user funds or parameters | ⚪ Not Started |
| **S7.2** | Program upgrade authority → multi-sig (prevents rogue upgrade) | ⚪ Not Started |
| **S7.3** | Time-lock on privileged instructions (`resolve_market` 24hr delay + dispute window) | ⚪ Not Started |
| **S7.4** | Replace all `/// CHECK:` `UncheckedAccount` with explicit PDA derivation constraints | ⚪ Not Started |
| **S7.5** | **Failsafe Oracle**: Replace `.unwrap()` with proper error handling in `get_oracle_res.rs` (L36, L41, L56) | 🔴 Needs Fix |
| **S7.5a** | **Oracle f64 Non-Determinism**: `get_oracle_res.rs` L41 converts feed value to `f64` for on-chain comparison — validators may evaluate differently. Replace with fixed-point integer comparison | 🔴 Needs Fix |
| **S7.6** | Dual independent security audit (OtterSec + Zellic / Neodyme / Trail of Bits) | ⚪ Not Started |

### PHASE 8: Infrastructure & DevOps
| Stage | Task | Status |
|:---|:---|:---|
| **S8.1** | CI/CD Pipeline (GitHub Actions): Lint → TypeCheck → Unit → Anchor Build → Devnet Deploy → Integration → Manual Gate → Mainnet | ⚪ Not Started |
| **S8.2** | Infrastructure as Code (Terraform / AWS CDK) for cloud infra | ⚪ Not Started |
| **S8.3** | Monitoring: Grafana + Prometheus (backend metrics: req/s, error rate, latency) | ⚪ Not Started |
| **S8.4** | Sentry integration — frontend + backend error tracking with source maps | ⚪ Not Started |
| **S8.5** | Helius Webhooks — on-chain event streaming (replace RPC polling) | ⚪ Not Started |
| **S8.6** | PagerDuty / OpsGenie alerting (on-call rotation for production incidents) | ⚪ Not Started |
| **S8.7** | Smart contract monitoring — abnormal bet sizes, oracle failures, vault solvency ratio | ⚪ Not Started |
| **S8.8** | AWS Secrets Manager — move ALL env vars out of `.env` files | ⚪ Not Started |
| **S8.9** | VPC + private subnets for MongoDB/Redis (DB never publicly accessible) | ⚪ Not Started |
| **S8.10** | WAF (Cloudflare or AWS) — Layer 7 DDoS protection in front of API | ⚪ Not Started |
| **S8.11** | **Production Build**: Compile TypeScript to optimized JS (esbuild/swc) — zero `ts-node` in production runtime | ⚪ Not Started |
| **S8.12** | **GitHub Advanced Security**: Enable secret scanning + CodeQL static analysis on all repos | ⚪ Not Started |

### PHASE 9: Performance Engineering
| Stage | Task | Status |
|:---|:---|:---|
| **S9.1** | **2,000+ TPS load testing** (k6 or Artillery against API + Solana devnet) | ⚪ Not Started |
| **S9.2** | Versioned Transactions (V0) + Address Lookup Tables for all complex instructions | ⚪ Not Started |
| **S9.3** | Jito MEV bundles activation for high-value bets (dependency already in `package.json`) | ⚪ Not Started |
| **S9.4** | Horizontal scaling — stateless Express/Fastify behind Nginx or AWS ECS/Fargate | ⚪ Not Started |
| **S9.5** | Redis Cluster (not single node) for production failover | ⚪ Not Started |
| **S9.6** | MongoDB Atlas read replicas for market data reads | ⚪ Not Started |
| **S9.7** | CDN (Cloudflare) for static market metadata edge caching | ⚪ Not Started |
| **S9.8** | Next.js Server Components — use RSC for market lists to reduce client JS bundle | ⚪ Not Started |
| **S9.9** | **Playwright E2E Test Suite** — full bet cycle: wallet connect → deposit USDC → mint $GBET → bet → cash out → withdraw | ⚪ Not Started |

---

## 🌐 TIER 5 — ECOSYSTEM EXPANSION

### PHASE 10: $GAINR Utility Token & Tokenomics Engine
| Stage | Task | Status |
|:---|:---|:---|
| **S10.1** | Deploy $GAINR Token — 100M fixed supply, standard SPL Token | ⚪ Not Started |
| **S10.2** | Buyback-and-Burn Engine (20% of protocol revenue) | ⚪ Not Started |
| **S10.3** | Fee Discount Tiers — Bronze (5%), Silver (10%), Gold (25%) based on $GAINR holdings | ⚪ Not Started |
| **S10.4** | Vesting contracts — Seed (6mo cliff, 24mo vest), Team (12mo cliff, 18mo vest) | ⚪ Not Started |
| **S10.5** | On-chain governance — fee parameters, oracle keys, reserve ratios controlled by $GAINR holders | ⚪ Not Started |

### PHASE 11: Back.bet (P2P Sports Betting Engine)
| Stage | Task | Status |
|:---|:---|:---|
| **S11.1** | Parimutuel Betting Smart Contract (dividend = pool / winning stake) | ⚪ Not Started |
| **S11.2** | LaaS PID Controller — automatic pool rebalancing using treasury reserves | ⚪ Not Started |
| **S11.3** | Reserve Quoter — signed off-chain quotes, MEV/front-running protection | ⚪ Not Started |
| **S11.4** | Exposure Manager — 15% Risk of Ruin atomic circuit breaker | ⚪ Not Started |
| **S11.5** | Back.bet Frontend — sports market UI | ⚪ Not Started |

### PHASE 12: Pick.bet & B2B API
| Stage | Task | Status |
|:---|:---|:---|
| **S12.1** | Signal Provider Smart Contract (staking + reputation system) | ⚪ Not Started |
| **S12.2** | Copy-Trade Execution Engine | ⚪ Not Started |
| **S12.3** | Pick.bet Frontend — signal marketplace UI | ⚪ Not Started |
| **S12.4** | B2B "Bloomberg for Betting" API — sell liquidity/odds to Web2 operators via paid OpenAPI | ⚪ Not Started |
| **S12.5** | SDK published to NPM for B2B partner self-integration | ⚪ Not Started |

### PHASE 13: Integrations & Go-Live
| Stage | Task | Status |
|:---|:---|:---|
| **S13.1** | Chainlink Oracle Integration (alongside Switchboard for redundant result verification) | ⚪ Not Started |
| **S13.2** | BVNK Fiat On-Ramp (Stripe/Skrill/Bank Transfer for non-crypto users) | ⚪ Not Started |
| **S13.3** | Web2 OIDC / Social Login (account abstraction for non-crypto natives) | ⚪ Not Started |
| **S13.4** | Syndicate Pro Terminal — institutional low-latency trading UI | ⚪ Not Started |
| **S13.5** | Squads Protocol multi-sig treasury governance activation | ⚪ Not Started |
| **S13.6** | Mainnet deployment — all three dApps live | ⚪ Not Started |

### PHASE 14: Legal & Compliance Certification
| Stage | Task | Status |
|:---|:---|:---|
| **S14.1** | Crypto-friendly jurisdiction company structure (Cayman / BVI / Gibraltar) | ⚪ Not Started |
| **S14.2** | UK / Malta gambling license application (12–18 month process) | ⚪ Not Started |
| **S14.3** | Howey Test legal opinion letter ($GBET non-transferable, $GAINR utility) | ⚪ Not Started |
| **S14.4** | ISO 27001 + ISO 42001 architecture alignment documentation | ⚪ Not Started |
| **S14.5** | Gitbook documentation — full API reference, smart contract NatSpec, integration guides | ⚪ Not Started |

---

## 📊 Summary Dashboard

| Tier | Phases | Stages | ✅ Done | 🟡 Partial | 🔴 Needs Fix | ⚪ Not Started |
|:---|:---|:---|:---|:---|:---|:---|
| T0 — Foundation | P0A, P0B | 21 | 13 | 0 | 7 | 1 |
| T1 — Core | P1, P2 | 15 | 4 | 5 | 2 | 4 |
| T2 — Compliance/AI | P3, P4 | 15 | 0 | 3 | 1 | 11 |
| T3 — Arch/UX | P5, P6 | 14 | 0 | 0 | 0 | 14 |
| T4 — Security/DevOps/Perf | P7, P8, P9 | 28 | 0 | 0 | 2 | 26 |
| T5 — Ecosystem | P10–P14 | 21 | 0 | 0 | 0 | 21 |
| **TOTAL** | **14 Phases** | **115 Stages** | **17** | **8** | **12** | **78** |

**True Completion: ~15% verified-done, ~7% in progress, ~11% broken/needs-fix, ~68% not started**

---

## ⚙️ Language & Architecture Reality (vs. SRD §5)

| Layer | SRD Target | Current Reality | Verdict |
|:---|:---|:---|:---|
| Smart Contract Runtime | Anchor + Token-2022 Extensions | ✅ Anchor 0.29, Token-2022 `Cargo.toml` feature ON | ✅ Correct (CPI fix needed in 2 files) |
| Token Standard | Token-2022 NonTransferable | ✅ `NonTransferable` applied in `init_bet_mint.rs` | 🟡 Need `DefaultAccountState::Frozen` extension |
| Oracle (Primary) | Chainlink Data Feeds | ❌ Switchboard only (no redundancy) | 🔴 Missing |
| Oracle (Fail-safe) | Bonded multi-signer (Squads) | ❌ Single admin key | 🔴 Missing |
| AI Compute | AWS + LORA Adapters (Python) | ❌ No AI service exists | 🔴 Missing (entirely new Python service) |
| Backend API | Node.js/TypeScript | ✅ Express 5 + TypeScript | ✅ Correct (needs hardening) |
| Backend Auth | Wallet signature middleware | 🟡 Partial — market endpoints only, referral/oracle/profile unprotected | 🔴 Incomplete |
| Backend Cache | Redis (<100ms latency) | ❌ No Redis | 🔴 Missing |
| Backend Security | Helmet, CSP, rate-limit, CORS, XSS | 🟡 Helmet + rate-limit installed; CORS restriction + XSS sanitization missing | 🟡 Partial |
| Backend Queue | Event processing | ❌ No BullMQ / job queue | 🔴 Missing |
| Backend Real-time | WebSocket / SSE | ❌ No WebSocket server | 🔴 Missing |
| Frontend | React + TypeScript | ✅ Next.js 16 + React 19 | ✅ Correct |
| Frontend PWA | Progressive Web App | ❌ No manifest / service worker | 🔴 Missing |
| Fiat On-Ramp | BVNK (Stripe/Skrill) | ❌ None | 🔴 Missing |
| Security Monitoring | Squads Protocol multi-sig | ❌ Single-key governance | 🔴 Missing |
| Solana SDK | Best practices (v2) | 🟡 web3.js v1.98.0 | 🟡 Should upgrade |
| Mobile | React PWA | ❌ Flutter (Dart) — different codebase | 🟡 Strategic fork |

---

## 📅 Execution Timeline

| Phase | Tier | Target |
|:---|:---|:---|
| P0A Rebrand | T0 | ✅ Week 1 (Done) |
| P0B Security + S1.4/S1.5 CPI Fix | T0/T1 | Week 1–2 |
| P1 $GBET Full + P2 CPMM Fix | T1 | Weeks 2–4 |
| P3 zkMe On-Chain + P7 Squads | T2/T4 | Weeks 4–6 |
| P5 Backend Architecture | T3 | Weeks 6–10 |
| P4 AI Oracle MVP | T2 | Weeks 10–16 |
| P6 Trading UI | T3 | Weeks 16–22 |
| P8/P9 DevOps + Performance | T4 | Weeks 22–26 |
| P10–P14 Ecosystem | T5 | Q3–Q4 2026 |

*Version: GOALS v5.0 | Source-verified audit corrections applied | 2026-02-23*
