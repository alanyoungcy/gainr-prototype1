# GAINR Protocol — GOALS v3: Price.bet Transformation Roadmap

## 🎯 Project Vision
Transform the `DecentraPredict` foundational codebase into **Price.bet**, a high-performance, compliant prediction market infrastructure that leverages Solana's speed and GAINR’s system-2 AI intelligence.

---

## 🛠️ Tracking Framework
We use a **Tiers & Status** system for granular progress monitoring.

### Status Indicators
- ⚪ **Not Started**: Task is in the backlog.
- 🟡 **In Progress**: Active development or research.
- 🟢 **Completed**: Tested, verified, and merged.
- 🟠 **On Hold**: Waiting for external dependencies or clarification.
- 🔴 **Deferred**: Moved to a later release cycle.

---

## 🗺️ Roadmap & Phases

### TIER 1: CORE INFRASTRUCTURE (The Foundation)

#### PHASE 1: Financial Rails & $BET Ecosystem
**Goal**: Transition from native SOL betting to the $BET stable-chip model.
| Stage | Task Description | Status |
| :--- | :--- | :--- |
| **S1.1** | Create $BET Token-2022 Contract (Non-Transferable) | 🟢 Completed |
| **S1.2** | Implement Player Vault PDA (USDC → $BET Minting) | 🟢 Completed |
| **S1.3** | Develop Burn Logic for Withdrawals ($BET → USDC) | 🟢 Completed |
| **S1.4** | Frontend: Integrate $BET Balance & Conversion UI | 🟢 Completed |

#### PHASE 2: CPMM Trading Engine (The Market)
**Goal**: Re-engineer the betting pool into a Professional Market Maker.
| Stage | Task Description | Status |
| :--- | :--- | :--- |
| **S2.1** | Refactor `betting.rs` to Constant Product (x * y = k) | 🟢 Completed |
| **S2.2** | Implement "Cash Out" (Sale of shares back to the AMM) | 🟢 Completed |
| **S2.3** | Develop Liquidity Provider (LP) fee distribution | 🟢 Completed |
| **S2.4** | Price Impact Calculator for UI (Visualizing Slippage) | 🟢 Completed |

---

### TIER 2: COMPLIANCE & INTELLIGENCE (The "Soul" of GAINR)

#### PHASE 3: Identity & Regulatory Layer
**Goal**: Ensure global legality and tier-1 audit readiness.
| Stage | Task Description | Status |
| :--- | :--- | :--- |
| **S3.1** | zkMe SDK Integration (Verification Flow) | 🟢 Completed |
| **S3.2** | On-chain ZK-Proof Validation in Smart Contract | 🟢 Completed |
| **S3.3** | Geo-fencing Middleware (IP & Region Filtering) | 🟢 Completed |
| **S3.4** | "Break-Glass" PII Enclave (Encrypted Off-chain Audit) | 🟢 Completed |

#### PHASE 4: AI Reasoning & Data Insight
**Goal**: Deliver the "System 2" AI competitive edge to users.
| Stage | Task Description | Status |
| :--- | :--- | :--- |
| **S4.1** | AI "Fair Value" Oracle Bridge (Backend connectivity) | ⚪ Not Started |
| **S4.2** | Real-time Market Opportunity Alerts (Edge > 5%) | ⚪ Not Started |
| **S4.3** | Syndicate Data Feed (PGI) Secure Integration | ⚪ Not Started |

---

### TIER 3: USER EXPERIENCE & SCALE (The Polish)

#### PHASE 5: Professional Trading UI (Aesthetics)
**Goal**: Create a premium, "wow-factor" dashboard.
| Stage | Task Description | Status |
| :--- | :--- | :--- |
| **S5.1** | Implement Dark Mode & Glassmorphism Theme | ⚪ Not Started |
| **S5.2** | Advanced Market Charts (Candlesticks & Volume) | ⚪ Not Started |
| **S5.3** | Real-time Social Win/Bet Ticker Overlay | ⚪ Not Started |

#### PHASE 6: Production Hardening
**Goal**: Final security and performance checks.
| Stage | Task Description | Status |
| :--- | :--- | :--- |
| **S6.1** | 2,000 TPS Performance Load Balancing | ⚪ Not Started |
| **S6.2** | Internal Smart Contract Security Audit | ⚪ Not Started |
| **S6.3** | Mainnet Deployment & TGE Readiness | ⚪ Not Started |

---

## 📅 Estimated Timeline
- **Core Infre (T1)**: Q1 - Q2 2026
- **Compliance & AI (T2)**: Q2 - Q3 2026
- **Scaling (T3)**: Q4 2026

*Last Updated: 2026-02-20*
*Status: Master Roadmap Published*
