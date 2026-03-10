# GAINR PROTOCOL: MASTER PRODUCT REQUIREMENTS DOCUMENT (PRD)

**Version:** 3.0 (Consolidated) | **Date:** January 28, 2026 | **Status:** Ready for Engineering

> *Consolidated from PRD v2.1, Whitepaper v1.4, and TSRD v2.0.*

---
1. EXECUTIVE SUMMARY
Product Vision: To build the "Intelligent Infrastructure Layer" for decentralized sports betting. Gainr is not just a sportsbook; it is a liquidity and technology protocol that unifies professional syndicate trading flow with Solana’s speed to solve four market failures: Shallow AI, Weak Compliance, Poor Edge, and Fragmented Liquidity.
Core Value Proposition:
1. Smarter: "System 2" AI reasoning (not just chatbots) driving pricing and risk.
2. Faster: Instant settlement via Solana Sealevel runtime.
3. Fairer: No house edge/conflict; peer-to-pool model with no limits for winners.
4. Compliant: Architecture built for Tier-1 regulation (GLI-33 readiness).

--------------------------------------------------------------------------------
2. TARGET AUDIENCE (PERSONAS)
Defined in the PRD and aligned with the Whitepaper's market strategy:
Persona
Archetype
Pain Points
Goal using Gainr
Alex
The Sharp (Pro Bettor)
Bans for winning, stake limits, slow payouts.
Access deep liquidity, execute high-volume bets without limits, and utilize API access.
Ben
The Enthusiast (Retail)
Losing money to "The House," confusing UI.
Fair odds, simplified AI insights, and copy-trading professional signals.
Chloe
The Builder (Dev/Partner)
High cost of liquidity bootstrapping & licensing.
Integrate Gainr’s LaaS (Liquidity-as-a-Service) and compliance stack to launch white-label dApps.

--------------------------------------------------------------------------------
3. SYSTEM ARCHITECTURE (THE 6-LAYER STACK)
Derived from TSRD v2.0 and Whitepaper.
• L1 Interface: React.js Web Client & Mobile PWA.
• L2 Compliance: zk.Me (Identity) + Geo-Fencing + "Break-Glass" PII Vault.
• L3 Application: Back.bet, Price.bet, Pick.bet.
• L4 Intelligence: 4-Layer AI Oracle (Prompt, Fine-Tuned, Hybrid, System 2).
• L5 Settlement: Solana Smart Contracts (Betting Engine, Liquidity Engine).
• L6 Infrastructure: Chainlink Oracles, RPC Nodes, AWS Data Lake.

--------------------------------------------------------------------------------
4. FUNCTIONAL REQUIREMENTS (EPICS & STORIES)
Epic 1: Compliance & Onboarding (The Gatekeeper)
Source: PRD Epic 1 & TSRD Compliance Layer.
Objective: Onboard users in <30 seconds while satisfying GLI-33 Audit standards.
• REQ 1.1: ZK-Identity Integration
    ◦ User Story: As a user, I want to verify my age/location without uploading documents to the blockchain.
    ◦ Tech Spec: Integrate zk.Me SDK. The smart contract must verify the ZK-Proof (Age > 18, Region != Restricted) before allowing any interaction with the Betting Engine.
• REQ 1.2: The "Break-Glass" Mechanism (Critical)
    ◦ User Story: As a regulator, I must be able to audit user identity upon subpoena.
    ◦ Tech Spec: Store encrypted PII in a secure off-chain enclave (Postgres/Blob). Implement a "Permanent Delegate" function in the smart contract that grants decryption keys only to authorized regulatory wallets.
• REQ 1.3: Geo-Fencing
    ◦ Tech Spec: Implement component-level blocks based on IP and on-chain "Region" assertions.
Epic 2: Dual-Token Economy (The Financial Rails)
Source: PRD Epic 2 & Whitepaper Tokenomics.
Objective: Separate "Gameplay" from "Speculation" to navigate the Howey Test.
• REQ 2.1: The Player Vault ($BET)
    ◦ User Story: As a user, I want to deposit USDC and bet with a stable chip.
    ◦ Tech Spec: Develop a Program Derived Address (PDA) "Vault."
    ◦ Logic: Deposit 1 USDC → Mint 1 $BET.
    ◦ Constraint: $BET must use Token-2022 Non-Transferable Extensions. It cannot be transferred between wallets, only burned by the Betting Engine.
• REQ 2.2: $GAINR Utility & Deflation
    ◦ User Story: As a holder, I want reduced fees and staking rewards.
    ◦ Tech Spec: Implement the Buyback-and-Burn Engine. The Revenue Contract must automatically swap 20% of protocol rake for $GAINR on DEXs and burn it.
    ◦ Tiers: Bronze (5% off), Silver (10% off), Gold (25% off) based on wallet holdings.
Epic 3: Back.bet (Sports Betting & LaaS)
Source: PRD Epic 3 & TSRD LaaS.
Objective: A peer-to-pool betting engine with zero house risk and automated liquidity.
• REQ 3.1: Parimutuel Betting Engine
    ◦ Logic: Dividend = (Total Pool - Rake) / Winning Outcome Stake.
    ◦ Tech Spec: Smart contract must accept $BET, update pool state atomically, and emit BetPlaced events for the AI indexer.
• REQ 3.2: Liquidity-as-a-Service (LaaS) - The PID Controller
    ◦ Problem: New pools have volatile odds.
    ◦ Tech Spec: Implement an on-chain PID Controller.
        ▪ Input: Pool Skew (Difference between Pool Odds and AI "Fair Value").
        ▪ Action: If skew > threshold, the Treasury automatically injects $BET into the underweight side to rebalance odds.
• REQ 3.3: Reserve Quoter (Front-Running Protection)
    ◦ Tech Spec: The AI Oracle must generate cryptographically signed quotes off-chain. The Betting Contract must reject any bet that does not carry a valid signature matching the current block window.
Epic 4: Price.bet (Prediction Markets)
Source: PRD Epic 4 & Whitepaper.
Objective: A trader-centric interface for sports/politics.
• REQ 4.1: AMM Trading
    ◦ Tech Spec: Implement a Constant Product Market Maker (CPMM) for binary outcomes (YES/NO).
    ◦ Feature: "Cash Out" capability allowing users to sell shares back to the AMM before event resolution.
• REQ 4.2: AI "Fair Value" Alerts
    ◦ User Story: As a trader, I want to know when the market is wrong.
    ◦ Tech Spec: The Level 2 AI Model (Fine-Tuned) scans real-time probability vs. market price. If Edge > X%, push a notification to the frontend.
Epic 5: The Intelligent Layer (System 2 AI)
Source: TSRD L4 & Whitepaper.
Objective: Move beyond chatbots to strategic reasoning.
• REQ 5.1: 4-Layer Integration
    ◦ L1 (UX): Prompt-based agents for "Next Click" prediction.
    ◦ L2 (Predictive): Models fine-tuned via LORA (Low-Rank Adaptation) on Gainr Analytics syndicate data.
    ◦ L3 (Hybrid): RAG (Retrieval Augmented Generation) pipeline fetching injury/weather news.
    ◦ L4 (System 2): Latent reasoning engine performing Expected Value (EV) calculations across multiple bets.
• REQ 5.2: Syndicate Data Feed (PGI)
    ◦ Tech Spec: Build a secure Permissionless Game Integration (PGI) adapter to ingest anonymized trading logs from the Gainr Analytics Syndicate into the Data Lake for model retraining.

--------------------------------------------------------------------------------
5. NON-FUNCTIONAL REQUIREMENTS
• Performance:
    ◦ Latency: Authentication flow < 100ms via Redis caching.
    ◦ Throughput: Betting Engine must handle > 2,000 transactions per second (TPS).
• Security:
    ◦ Audit: Smart contracts must pass dual audits (Certik/Trail of Bits).
    ◦ ISO Standards: Architecture must align with ISO/IEC 27001 (InfoSec) and ISO/IEC 42001 (AI Management).
• Reporting (GLI-33):
    ◦ Requirement: An "Off-Chain Regulatory Indexer" must be built to export data in CSV/XLS format for Operator Liability and Revenue Taxation reports.

--------------------------------------------------------------------------------
6. KPIs & SUCCESS METRICS (Year 1)
Source: PRD Section 5 & Whitepaper Financials.
1. Acquisition: Cost Per Install (CPI) < $5.00.
2. Retention: D30 Retention > 10%.
3. Monetization: ARPPU (Average Revenue Per Paying User) > $50/month.
4. Liquidity: Day 1 DEX Volume > $1M.
5. Revenue: Year 1 Target: €1.5M.

--------------------------------------------------------------------------------
7. DEVELOPMENT ROADMAP
Source: Whitepaper Roadmap.
• Phase 1 (Now - Q2 2026):
    ◦ Develop Player Vault & Dual-Token Contracts ($BET non-transferability).
    ◦ Integrate zk.Me & "Break-Glass" Storage.
    ◦ Launch MVP (Back.bet) on Devnet.
• Phase 2 (Q2 2026):
    ◦ Mainnet Launch: Back.bet Live.
    ◦ TGE: Token Generation Event & Liquidity Seeding.
    ◦ LaaS: Activate PID Controller for automatic pool balancing.
• Phase 3 (Q3 2026 - Q4 2026):
    ◦ Launch Price.bet (Prediction Markets).
    ◦ Activate AI Subscription Tiers (SaaS).
    ◦ Secure UK/Malta Licenses.