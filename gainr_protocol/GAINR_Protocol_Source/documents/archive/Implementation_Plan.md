# GAINR Protocol — Price.bet: Master Implementation Plan

**Version:** 2.0 | **Date:** 2026-02-22 | **GOALS4 Reference:** All Tiers
**Source-verified against**: [init_bet_mint.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/init_bet_mint.rs), [deposit_usdc.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/deposit_usdc.rs), [withdraw_usdc.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/withdraw_usdc.rs), [betting.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs), [sell_shares.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/sell_shares.rs), [market.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/states/market.rs), [Cargo.toml](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/Cargo.toml), [backend/package.json](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/package.json), [frontend/package.json](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-frontend/package.json), [backend/src/index.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/index.ts)

---

## Architecture Gap Summary (SRD §5 vs. Reality)

| SRD Requirement | SRD Target | Current Reality | Gap Level |
|:---|:---|:---|:---|
| Token Standard | Token-2022 (NonTransferable) | ✅ Mint created via Token2022 ([init_bet_mint.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/init_bet_mint.rs)). [deposit_usdc.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/deposit_usdc.rs) + [withdraw_usdc.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/withdraw_usdc.rs) use `token_interface` correctly. **BUT** [betting.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs) + [sell_shares.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/sell_shares.rs) import old `anchor_spl::token::Token` | 🟠 CPI mismatch in 2 files |
| Oracle (Primary) | Chainlink Data Feeds | Switchboard only (`switchboard-solana = 0.29.79`) | 🔴 No redundancy |
| Oracle Fail-safe | Squads Protocol multi-sig | Single admin key (`global.admin`) | 🔴 Critical |
| AI Compute | AWS + LORA + RAG (Python) | Zero AI infrastructure. [oracle/index.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/controller/oracle/index.ts) = 14-line stub | 🔴 Missing |
| Backend Auth | Wallet signature on mutations | Zero authenticated endpoints | 🔴 Critical |
| Backend Cache | Redis (<100ms) | No Redis — MongoDB only | 🔴 Missing |
| Backend HTTP Security | Helmet, CSP, HSTS | Not installed | 🔴 Missing |
| Backend Rate Limit | express-rate-limit | Not installed | 🔴 Missing |
| Backend Real-time | WebSocket / SSE | Not installed | 🔴 Missing |
| Backend Queue | BullMQ for event processing | Not installed | 🔴 Missing |
| Fiat On-Ramp | BVNK | None | 🔴 Missing |
| Frontend PWA | Manifest + Service Worker | None | 🔴 Missing |
| Solana SDK | web3.js v2 | v1.98.0 (both FE + BE) | 🟡 Legacy |
| Security Audit | Dual independent audits | None | 🔴 Missing |

---

## Priority 0 — Security Foundation (24–48 hours)

> **GOALS4 Stages:** S0B.1 through S0B.8

### [NEW] `prediction-market-backend/src/middleware/authSignature.ts`

**Purpose**: Verify that every state-mutating API request is signed by the caller's Solana wallet.

```typescript
import { Request, Response, NextFunction } from 'express';
import nacl from 'tweetnacl';
import bs58 from 'bs58';

export function requireWalletSignature(req: Request, res: Response, next: NextFunction) {
  const walletAddress = req.headers['x-wallet-address'] as string;
  const signature = req.headers['x-wallet-signature'] as string;
  const timestamp = req.headers['x-wallet-timestamp'] as string;

  if (!walletAddress || !signature || !timestamp) {
    return res.status(401).json({ error: 'Missing authentication headers' });
  }

  // Replay protection — reject if timestamp > 30 seconds old
  const now = Date.now();
  if (Math.abs(now - parseInt(timestamp)) > 30_000) {
    return res.status(401).json({ error: 'Request expired' });
  }

  // Reconstruct the message the client signed
  const message = new TextEncoder().encode(
    `GAINR_AUTH:${timestamp}:${req.method}:${req.originalUrl}`
  );

  try {
    const publicKey = bs58.decode(walletAddress);
    const sig = bs58.decode(signature);
    const isValid = nacl.sign.detached.verify(message, sig, publicKey);

    if (!isValid) {
      return res.status(401).json({ error: 'Invalid signature' });
    }

    (req as any).walletAddress = walletAddress;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Authentication failed' });
  }
}
```

### [NEW] `prediction-market-backend/src/middleware/rateLimiter.ts`

```typescript
import rateLimit from 'express-rate-limit';
import slowDown from 'express-slow-down';

export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
});

export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
});

export const speedLimiter = slowDown({
  windowMs: 15 * 60 * 1000,
  delayAfter: 50,
  delayMs: (hits) => hits * 200,
});
```

### [MODIFY] [prediction-market-backend/src/index.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/index.ts)

```diff
+ import helmet from 'helmet';
+ import { apiLimiter, speedLimiter } from './middleware/rateLimiter';
+ import { requireWalletSignature } from './middleware/authSignature';

  // After CORS middleware:
+ app.use(helmet());
+ app.use('/api', apiLimiter);
+ app.use('/api', speedLimiter);

  // On all state-mutating routes:
+ marketRouter.post('/betting', requireWalletSignature, betting);
+ marketRouter.post('/liquidity', requireWalletSignature, addLiquidity);
+ marketRouter.post('/create', requireWalletSignature, createMarket);

  // Reduce body size limit:
- app.use(express.json({ limit: '50mb', ... }));
+ app.use(express.json({ limit: '1mb' }));
```

#### [MODIFY] [compliance.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/service/compliance.ts)
- Remove hardcoded `BREAK_GLASS_CODE` fallback (`"GAINR_EMERGENCY_2026"`) — env-only, crash if missing.
- Replace string comparison with `crypto.timingSafeEqual()` for Break-Glass auth.

#### [NEW] [Zod Schemas]
- Implement request body validation for all `/api` routes (e.g., `/api/market/betting`, `/api/market/liquidity`).

### [MODIFY] [prediction-market-backend/src/controller/market/index.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/controller/market/index.ts) (betting)

```diff
  // Remove client-trusted price data:
- const { player, market_id, amount, isYes, token_a_amount, token_b_amount, token_a_price, token_b_price } = req.body;
+ const { player, market_id, amount, isYes, txSignature } = req.body;

  // Verify transaction on-chain and derive pool state from confirmed tx:
+ const connection = new Connection(clusterApiUrl(cluster), 'confirmed');
+ const txDetails = await connection.getTransaction(txSignature, {
+   commitment: 'confirmed',
+   maxSupportedTransactionVersion: 0,
+ });
+ if (!txDetails) return res.status(400).json({ error: 'Transaction not found' });
+ // Parse pool amounts from transaction logs/post-balances — NEVER trust client

  // When updating MarketModel, derive prices from on-chain reserves:
  const result = await MarketModel.findByIdAndUpdate(
    market_id,
    {
-     $set: { tokenAPrice: token_a_price, tokenBPrice: token_b_price },
+     $set: { /* prices derived from on-chain post-transaction state */ },
    },
  );
```

### Dependencies to install:
```bash
cd prediction-market-backend
npm install tweetnacl bs58 helmet express-rate-limit express-slow-down zod
```

---

## Priority 1 — Token-2022 CPI Fix (Week 1–2)

> **GOALS4 Stages:** S1.4, S1.5

> [!IMPORTANT]
> This is NOT a full Token-2022 migration. The mint ([init_bet_mint.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/init_bet_mint.rs)), deposit ([deposit_usdc.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/deposit_usdc.rs)), and withdraw ([withdraw_usdc.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/withdraw_usdc.rs)) already use Token-2022 correctly. **Only [betting.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs) and [sell_shares.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/sell_shares.rs) use the wrong token program.**

### [MODIFY] [prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs)

**Line 5 — Fix the import:**
```diff
- use anchor_spl::token::{Mint, TokenAccount, Token};
+ use anchor_spl::token_interface::{self, Mint, TokenAccount, Token2022};
+ use anchor_spl::token_interface::TokenInterface;
```

**In the [Betting](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs#11-102) accounts struct — change token program:**
```diff
- pub token_program: Program<'info, Token>,
+ pub token_program: Interface<'info, TokenInterface>,
+ pub token_2022_program: Program<'info, Token2022>,
```

**For $GBET-related accounts (bet_mint, user_bet_ata, market_bet_vault):**
```diff
- pub bet_mint: Account<'info, Mint>,
+ pub bet_mint: InterfaceAccount<'info, Mint>,

- pub user_bet_ata: Account<'info, TokenAccount>,
+ pub user_bet_ata: InterfaceAccount<'info, TokenAccount>,

- pub market_bet_vault: Account<'info, TokenAccount>,
+ pub market_bet_vault: InterfaceAccount<'info, TokenAccount>,
```

**For all token CPI calls involving $GBET:**
```diff
  // Replace token::transfer with token_interface::transfer_checked
- token::transfer(CpiContext::new(ctx.accounts.token_program.to_account_info(), ...));
+ token_interface::transfer_checked(
+     CpiContext::new(ctx.accounts.token_2022_program.to_account_info(), ...),
+     amount,
+     ctx.accounts.bet_mint.decimals,
+ )?;
```

> [!WARNING]
> Share mints (share_mint_a, share_mint_b) are **regular SPL Token mints** — NOT Token-2022. Only $GBET operations need Token-2022 CPIs. The [Betting](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs#11-102) struct therefore needs **both** token programs: `TokenInterface` for share operations and `Token2022` for $GBET operations.

### [MODIFY] [prediction-market-smartcontract/programs/prediction/src/instructions/sell_shares.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/sell_shares.rs)

**Same pattern as [betting.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs):**
```diff
- use anchor_spl::token::{self, Mint, Token, TokenAccount};
+ use anchor_spl::token_interface::{self, Mint as MintInterface, TokenAccount as TokenAccountInterface, Token2022};
+ use anchor_spl::token::{self, Mint, Token, TokenAccount}; // Keep for share mints
```

**$GBET accounts → `InterfaceAccount`, share accounts → stay as `Account`.**

**Token program in struct:**
```diff
- pub token_program: Program<'info, Token>,
+ pub token_program: Program<'info, Token>,           // For shares (standard SPL)
+ pub token_2022_program: Program<'info, Token2022>,  // For $GBET (Token-2022)
```

**$GBET transfers use `token_2022_program`, share burns use `token_program`.**

### After changes:
```bash
anchor build
anchor test
# Regenerate IDL for frontend SDK (S1.7)
```

---

## Priority 2 — Real zkMe On-Chain Verification (Week 2–3)

> **GOALS4 Stage:** S3.2

### [MODIFY] [prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs)

**Replace lines 110–126 (dummy bytes [1, 2, 3]):**

```rust
// ----- Real zkMe Verification via ed25519 precompile -----
// The frontend calls zkMe SDK → gets a signed attestation (sig + timestamp)
// BettingParams must include: zk_signature: [u8; 64], zk_timestamp: i64

// 1. Reject stale attestations (> 5 minutes old)
let clock = Clock::get()?;
let age = clock.unix_timestamp - params.zk_timestamp;
require!(age >= 0 && age < 300, ContractError::ZKProofExpired);

// 2. Build the message zkMe signed: [user_pubkey (32 bytes) | timestamp (8 bytes)]
let mut msg_data = Vec::with_capacity(40);
msg_data.extend_from_slice(&ctx.accounts.user.key().to_bytes());
msg_data.extend_from_slice(&params.zk_timestamp.to_le_bytes());

// 3. Verify via Solana ed25519 precompile instruction introspection
let ix_sysvar = &ctx.accounts.instruction_sysvar;
let current_ix = solana_program::sysvar::instructions::load_current_index_checked(ix_sysvar)?;

// The client MUST prepend an Ed25519 signature verification instruction
// before the betting instruction in the same transaction
require!(current_ix > 0, ContractError::MissingZKVerification);

let ed25519_ix = solana_program::sysvar::instructions::load_instruction_at_checked(
    (current_ix - 1) as usize,
    ix_sysvar,
)?;
require!(
    ed25519_ix.program_id == solana_program::ed25519_program::ID,
    ContractError::InvalidZKProof
);
```

**Add to [Betting](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs#11-102) accounts struct:**
```rust
/// CHECK: Instructions sysvar for ed25519 precompile verification
#[account(address = solana_program::sysvar::instructions::ID)]
pub instruction_sysvar: AccountInfo<'info>,
```

**Update [BettingParams](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/states/market.rs#94-100):**
```rust
pub struct BettingParams {
    pub market_id: String,
    pub amount: u64,
    pub is_yes: bool,
    pub zk_signature: [u8; 64],  // zkMe oracle's signature
    pub zk_timestamp: i64,        // attestation timestamp (must be < 5 minutes old)
}
```

**Add error variants in [errors.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/errors.rs):**
```rust
#[error_code]
pub enum ContractError {
    // ... existing ...
    #[msg("ZK proof attestation has expired (> 5 minutes)")]
    ZKProofExpired,
    #[msg("Missing ed25519 verification instruction in transaction")]
    MissingZKVerification,
    #[msg("Invalid ZK proof — ed25519 verification failed")]
    InvalidZKProof,
}
```

---

## Priority 3 — CPMM Price Impact Calculator (Week 2)

> **GOALS4 Stage:** S2.4

### [MODIFY] [prediction-market-smartcontract/programs/prediction/src/states/market.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/states/market.rs)

**Replace the empty [set_token_price()](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/states/market.rs#70-75) placeholder with real CPMM-derived prices:**

```rust
impl Market {
    /// Compute CPMM-derived probability prices from pool reserves.
    /// YES price = NO_reserve / (YES_reserve + NO_reserve)
    /// Returns prices in basis points (0–10,000 = 0%–100%).
    /// Invariant: price_a + price_b == 10,000 bps always.
    pub fn compute_prices(&mut self) -> Result<()> {
        let x = self.token_a_amount as u128;  // YES reserve
        let y = self.token_b_amount as u128;  // NO reserve
        let total = x.checked_add(y).ok_or(ContractError::ArithmeticError)?;

        require!(total > 0, ContractError::DivisionByZero);

        // YES price = opposite reserve / total (more NO reserve = higher YES demand)
        self.token_price_a = y
            .checked_mul(10_000)
            .ok_or(ContractError::ArithmeticError)?
            .checked_div(total)
            .ok_or(ContractError::ArithmeticError)?
            .try_into()
            .map_err(|_| ContractError::ArithmeticError)?;

        // NO price = complement (guarantees sum = 10,000)
        self.token_price_b = 10_000u64
            .checked_sub(self.token_price_a)
            .ok_or(ContractError::ArithmeticError)?;

        Ok(())
    }
}
```

**Call at end of [betting()](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/controller/market/index.ts#70-99) and [sell_shares()](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/lib.rs#59-62):**
```rust
// At the end of betting() and sell_shares(), replace inline price approximation:
market.compute_prices()?;
```

### Fix integer overflow in [sell_shares.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/sell_shares.rs) line 113:
```diff
- let sqrt_d = (discriminant as f64).sqrt() as u128; // Using float for simplicity
+ let sqrt_d = integer_sqrt(discriminant); // Deterministic integer square root
```

**Add helper in [utils.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/utils.rs):**
```rust
/// Newton's method integer square root — deterministic, no floating point.
pub fn integer_sqrt(n: u128) -> u128 {
    if n == 0 { return 0; }
    let mut x = n;
    let mut y = (x + 1) / 2;
    while y < x {
        x = y;
        y = (x + n / x) / 2;
    }
    x
}
```

---

## Priority 4 — Architecture Upgrades (Weeks 4–10)

### 4A: Redis Integration (S5.1)
```bash
npm install ioredis
```
- Session token cache (JWT → wallet mapping)
- Market data cache (hot markets, 1-second TTL)
- Rate limiting state backend

### 4B: WebSocket Layer (S5.2)
```bash
npm install socket.io
```
- `/ws/ticker` — real-time bet events broadcast
- `/ws/alerts` — AI edge alerts per user subscription
- Integrates with BullMQ event processor

### 4C: BullMQ Job Queue (S5.3)
```bash
npm install bullmq
```
- `processBettingEvent` — on-chain BettingEvent → DB update → WebSocket broadcast
- `processAlertCheck` — periodic AI fair-value check → push alert if edge > 5%

### 4D: AI Oracle Service — New Python Project (S4.1, S4.2)
```
gainr-ai-oracle/
├── app/
│   ├── main.py              # FastAPI entry point
│   ├── routers/
│   │   ├── oracle.py         # GET /api/v1/fair-value/{market_id}
│   │   └── health.py         # GET /health
│   ├── services/
│   │   ├── base_model.py     # L1: Simple prompt-based inference
│   │   ├── lora_model.py     # L2: Fine-tuned LORA model
│   │   └── rag_pipeline.py   # L3: RAG with news context
│   └── config.py
├── requirements.txt          # fastapi, uvicorn, transformers, peft, langchain
├── Dockerfile
└── docker-compose.yml
```

**MVP endpoint (Phase 1 — use any LLM):**
```python
@router.get("/api/v1/fair-value/{market_id}")
async def get_fair_value(market_id: str):
    market = await fetch_market_details(market_id)
    probability = await base_model.estimate_probability(market.question)
    return {
        "market_id": market_id,
        "fair_value": probability,
        "confidence": 0.65,
        "model": "gpt-4o-mini",
        "timestamp": datetime.utcnow().isoformat(),
    }
```

**Backend integration (wire [oracle/index.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/controller/oracle/index.ts)):**
```typescript
export const getFairValue = async (req: Request, res: Response) => {
    const { marketId } = req.params;
    const response = await fetch(`${AI_ORACLE_URL}/api/v1/fair-value/${marketId}`);
    const data = await response.json();
    res.json(data);
};
```

### 4E: NestJS Evaluation (S5.4)
- **Status**: Researching feasibility for better DI and AuthGuard management.

### 4F: Foundation Cleanup (Tier 0A)
- [MODIFY] [Cargo.toml](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/Cargo.toml): Update program description to "GAINR Protocol — Price.bet Settlement Engine". (S0A.5)

---

## File Change Summary (Mapped to GOALS4 Stages)

| Priority | File | Action | GOALS4 Stage |
|:---|:---|:---|:---|
| P0 | `backend/src/middleware/authSignature.ts` | **NEW** | S0B.1 |
| P0 | `backend/src/middleware/rateLimiter.ts` | **NEW** | S0B.5 |
| P0 | [backend/src/index.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/index.ts) | MODIFY — add Helmet, rate limit, reduce body limit | S0B.4, S0B.7 |
| P0 | `backend/src/service/compliance.ts` | MODIFY — remove hardcoded secret, timing-safe | S0B.2, S0B.3 |
| P0 | [backend/src/controller/market/index.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/controller/market/index.ts) | MODIFY — remove client-trusted prices | S0B.6 |
| P1 | `smartcontract/.../instructions/betting.rs` | MODIFY — `token::*` → `token_interface::*` for $GBET | S1.4 |
| P1 | `smartcontract/.../instructions/sell_shares.rs` | MODIFY — `token::*` → `token_interface::*` for $GBET | S1.5 |
| P2 | `smartcontract/.../instructions/betting.rs` | MODIFY — replace dummy [1,2,3] with ed25519 precompile | S3.2 |
| P2 | `smartcontract/.../errors.rs` | MODIFY — add ZKProofExpired, MissingZKVerification | S3.2 |
| P3 | `smartcontract/.../states/market.rs` | MODIFY — replace placeholder with `compute_prices()` | S2.4 |
| P3 | `smartcontract/.../utils.rs` | MODIFY — add `integer_sqrt()` helper | S2.2 |
| P3 | `smartcontract/.../instructions/sell_shares.rs` | MODIFY — replace f64 sqrt with integer_sqrt | S2.2 |
| P4 | `backend/` | INSTALL — `ioredis`, `socket.io`, `bullmq` | S5.1, S5.2, S5.3 |
| P4 | `gainr-ai-oracle/` | **NEW PROJECT** — Python FastAPI service | S4.1 |
| P4 | [backend/src/controller/oracle/index.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/controller/oracle/index.ts) | MODIFY — wire to AI oracle REST endpoint | S4.2 |

---

## Verification Plan

### Priority 0 — Security
```bash
# Confirm no legacy branding remains
grep -r "spaceape\|husreo\|Prediciton" . --include="*.json" --include="*.ts"
# Expected: 0 matches

# Confirm Helmet is active
curl -I http://localhost:9000/ | grep -E "X-Content-Type|Strict-Transport|X-Frame"
# Expected: security headers present

# Confirm unauthenticated POST is rejected
curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:9000/api/market/betting \
  -H "Content-Type: application/json" -d '{}'
# Expected: 401

# Confirm Break-Glass crashes without env var
unset BREAK_GLASS_CODE && npm run start
# Expected: FATAL error on startup
```

### Priority 1 — Token-2022 CPI
```bash
anchor build
anchor test

# Devnet: attempt deposit → bet → sell → withdraw full cycle
# $GBET transfers must route through Token-2022 program, not SPL Token
# Verify by checking transaction logs for "TokenzQdBNbL..." program ID
```

### Priority 2 — zkMe
```bash
# Attempt a bet WITHOUT ed25519 instruction prepended in the transaction
# Expected: ContractError::MissingZKVerification

# Attempt a bet WITH a valid ed25519 instruction
# Expected: Success

# Attempt with expired timestamp (> 5 minutes old)
# Expected: ContractError::ZKProofExpired
```

### Priority 3 — CPMM Prices
```bash
# After each bet, log market.token_price_a + market.token_price_b
# Expected: ALWAYS sums to exactly 10,000 basis points

# Verify no floating point in sell_shares.rs
grep -n "as f64" programs/prediction/src/instructions/sell_shares.rs
# Expected: 0 matches (after integer_sqrt fix)
```

### Priority 4 — Architecture
```bash
# Redis connectivity
redis-cli ping
# Expected: PONG

# WebSocket connection
wscat -c ws://localhost:9000/ws/ticker
# Expected: Connection established

# AI Oracle health
curl http://localhost:8000/health
# Expected: {"status": "ok", "model": "loaded"}
```

---

*Reference: GOALS4.md (all Tiers), PRD v3.0, TSRD v2.0, FIRR.md, security_analysis_report.md*
*Source-verified: 2026-02-22 — ALL code diffs match actual file contents*
