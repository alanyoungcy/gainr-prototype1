# GAINR User Onboarding & Lifecycle Workflow

## Complete User Journey: From Landing to Active Bettor

This document explains the entire user lifecycle on GAINR (Back.bet), covering both the **current demo state** and the **future production implementation**.

---

## 🚀 Phase 1: First Visit (Landing)

### User arrives at `back.bet`

**What They See**:
```
┌─────────────────────────────────────────────────────────────┐
│  [GAINR Logo]              BACK.BET              [Connect] │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  🏟️ LIVE: Man City vs Inter Milan                           │
│  "Bet on Sports. No Limits. No BS."                         │
│                                                               │
│  [Browse Events] or [Connect Wallet to Start]               │
└─────────────────────────────────────────────────────────────┘
```

**Two Paths**:
1. **Browse Mode** (No wallet): View events, odds, AI insights (read-only)
2. **Connect Wallet** (Start betting): Full access

---

## 🔐 Phase 2: Wallet Connection (Sign-Up)

### How GAINR Authentication Works (Web3-Native)

**Traditional Apps**: Email + Password  
**GAINR**: Wallet = Identity (No passwords!)

### Step-by-Step Flow:

#### 1. User Clicks "Connect Wallet"

**Demo (Current)**:
```dart
// Mock connection - instant
WalletController.connect() {
  // Simulated delay
  await Future.delayed(Duration(seconds: 1));
  state = WalletState(
    isConnected: true,
    address: "9xQe...abc123", // Demo address
  );
}
```

**Production (Phase 2)**:
```dart
// Real Phantom/Sollet connection
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';

WalletController.connect() async {
  final adapter = PhantomWalletAdapter();
  final account = await adapter.connect();
  
  state = WalletState(
    isConnected: true,
    address: account.publicKey,
    solBalance: await getSolBalance(account.publicKey),
  );
}
```

#### 2. Wallet Prompt Appears

**User sees in Phantom**:
```
┌──────────────────────────────────┐
│  Connect to back.bet?            │
│                                  │
│  This site wants to:             │
│  ✓ View your wallet address      │
│  ✓ Request transaction approval  │
│                                  │
│  [Cancel]  [Connect]             │
└──────────────────────────────────┘
```

✅ User clicks **Connect** → Wallet address is now linked

#### 3. First-Time User: Compliance Check (Production Only)

**Production Flow** (Phase 3):
```
After wallet connection, check if user has zk.Me proof:

IF no_zkme_proof:
  → Redirect to zk.Me verification
  
┌──────────────────────────────────┐
│  Welcome! Quick Verification     │
│                                  │
│  We need to verify:              │
│  • You're 18+ years old          │
│  • You're not in a restricted    │
│    jurisdiction                  │
│                                  │
│  This uses Zero-Knowledge        │
│  Proofs - we never see your      │
│  documents directly.             │
│                                  │
│  [Start Verification] →          │
└──────────────────────────────────┘
```

**zk.Me Flow**:
1. User scans passport/ID on their phone
2. zk.Me generates cryptographic proof:
   - "Age > 18" ✓
   - "Country ≠ Restricted" ✓
3. Proof is stored on-chain
4. GAINR smart contract verifies proof before allowing bets

**Demo**: This is **skipped** (no compliance checks)

---

## 💰 Phase 3: First Deposit (Funding Account)

### The Dual-Token Model

**Production Flow**:

#### 1. User Has 0 $BET Balance

```
┌──────────────────────────────────┐
│  Your Balance                    │
│                                  │
│  💵 USDC: 1,500.00              │
│  🎰 $BET: 0.00                  │
│                                  │
│  [Deposit USDC → $BET]          │
└──────────────────────────────────┘
```

#### 2. Deposit Modal Opens

```
┌──────────────────────────────────┐
│  Deposit USDC                    │
│                                  │
│  Amount: [____] USDC             │
│           500                    │
│                                  │
│  You'll receive: 500 $BET        │
│  (1:1 peg)                       │
│                                  │
│  Fee: 0 USDC (Free deposits)    │
│                                  │
│  [Cancel]  [Confirm Deposit]    │
└──────────────────────────────────┘
```

#### 3. Smart Contract Execution

**On-Chain Transaction**:
```solana
// Anchor Program (Rust)
pub fn deposit(ctx: Context<Deposit>, amount: u64) -> Result<()> {
    // 1. Transfer USDC from user to vault
    token::transfer(
        ctx.accounts.transfer_context(),
        amount,
    )?;
    
    // 2. Mint $BET 1:1
    token::mint_to(
        ctx.accounts.mint_context(),
        amount, // Same amount
    )?;
    
    // 3. $BET is NON-TRANSFERABLE (Token-2022 extension)
    // User can only use it to bet or withdraw
    
    Ok(())
}
```

#### 4. Confirmation

```
✅ Deposit Successful!

500 USDC → 500 $BET

Transaction: abc123...xyz
View on Solscan →
```

**Demo**: This is **simulated** (localStorage update, no blockchain)

---

## 🎲 Phase 4: First Bet

### Complete Betting Lifecycle

#### 1. Browse Events

User scrolls through live events:

```
┌──────────────────────────────────┐
│ 🔴 LIVE  Premier League          │
│                                  │
│ Man City vs Arsenal              │
│ 45' (1-0)                        │
│                                  │
│  HOME    DRAW    AWAY            │
│  [1.85]  [3.40]  [4.20]         │
│                                  │
│ 🤖 AI Edge: +8.2% on Away       │
└──────────────────────────────────┘
```

#### 2. Add to Bet Slip

User clicks **[4.20]** → Bet slip updates:

```
┌──────────────────────────────────┐
│  BET SLIP (1)                    │
│                                  │
│  Arsenal Win                     │
│  Man City vs Arsenal             │
│  Odds: 4.20                      │
│                                  │
│  Stake: [___] $BET              │
│          50                      │
│                                  │
│  Return: 210.00 $BET            │
│                                  │
│  [Place Bet]                     │
└──────────────────────────────────┘
```

#### 3. Place Bet (Production Flow)

**User clicks "Place Bet"**:

```
┌──────────────────────────────────┐
│  Confirm Bet                     │
│                                  │
│  Arsenal Win @ 4.20              │
│  Stake: 50 $BET                 │
│  Potential Return: 210 $BET     │
│                                  │
│  ⚠️ Odds may change until        │
│     transaction confirms         │
│                                  │
│  [Cancel]  [Confirm]            │
└──────────────────────────────────┘
```

**Smart Contract Execution**:

```solana
pub fn place_bet(
    ctx: Context<PlaceBet>,
    event_id: u64,
    outcome: u8, // 0=Home, 1=Draw, 2=Away
    stake: u64,
) -> Result<()> {
    // 1. Burn $BET from user wallet
    token::burn(
        ctx.accounts.burn_context(),
        stake,
    )?;
    
    // 2. Update pool state
    let pool = &mut ctx.accounts.pool;
    pool.outcomes[outcome].stake += stake;
    pool.outcomes[outcome].bettors.push(ctx.accounts.user.key());
    
    // 3. Calculate new odds (parimutuel)
    update_pool_odds(pool)?;
    
    // 4. Emit event for AI indexer
    emit!(BetPlaced {
        user: ctx.accounts.user.key(),
        event_id,
        outcome,
        stake,
        timestamp: Clock::get()?.unix_timestamp,
    });
    
    Ok(())
}
```

**Wallet Prompt**:
```
┌──────────────────────────────────┐
│  Approve Transaction             │
│                                  │
│  back.bet wants to:              │
│  • Burn 50 $BET                 │
│  • Update bet pool               │
│                                  │
│  Estimated fee: 0.00001 SOL     │
│                                  │
│  [Reject]  [Approve]            │
└──────────────────────────────────┘
```

#### 4. Bet Confirmed

```
✅ Bet Placed Successfully!

Arsenal Win @ 4.20
Stake: 50 $BET
Max Return: 210 $BET

[View in My Bets]
```

**Demo**: Transaction is **simulated** (localStorage, auto-settle in 30s)

---

## ⏱️ Phase 5: Bet Settlement

### How Bets Are Resolved

#### 1. Match Ends (90 minutes later)

**Production Flow**:

```
Event: Man City vs Arsenal
Final Score: 1-2 (Arsenal wins!)

1. Oracle Service (Chainlink) fetches result from SportRadar
2. Off-chain validator verifies score
3. Settlement transaction submitted to blockchain
```

**Smart Contract**:
```solana
pub fn settle_event(
    ctx: Context<SettleEvent>,
    event_id: u64,
    winning_outcome: u8,
) -> Result<()> {
    // Only oracle can call this
    require!(
        ctx.accounts.oracle.key() == ORACLE_PUBKEY,
        ErrorCode::Unauthorized
    );
    
    let pool = &mut ctx.accounts.pool;
    
    // Calculate payout per $BET staked on winner
    let total_pool = pool.total_stake();
    let rake = total_pool * RAKE_PERCENTAGE; // 5-10%
    let payout_pool = total_pool - rake;
    let winning_stake = pool.outcomes[winning_outcome].stake;
    
    let payout_per_bet = payout_pool / winning_stake;
    
    pool.settled = true;
    pool.payout_rate = payout_per_bet;
    
    Ok(())
}
```

#### 2. User Claims Winnings

**Automatic or Manual Claim**:

```
┌──────────────────────────────────┐
│  🎉 You Won!                     │
│                                  │
│  Arsenal Win @ 4.20              │
│  Stake: 50 $BET                 │
│                                  │
│  Winnings: 195 $BET             │
│  (210 - 7.5% rake)              │
│                                  │
│  [Claim Now]                     │
└──────────────────────────────────┘
```

**Claim Transaction**:
```solana
pub fn claim_winnings(ctx: Context<Claim>) -> Result<()> {
    let bet = &ctx.accounts.bet;
    let pool = &ctx.accounts.pool;
    
    require!(pool.settled, ErrorCode::EventNotSettled);
    require!(!bet.claimed, ErrorCode::AlreadyClaimed);
    
    let payout = bet.stake * pool.payout_rate;
    
    // Mint $BET to user
    token::mint_to(
        ctx.accounts.mint_context(),
        payout,
    )?;
    
    bet.claimed = true;
    Ok(())
}
```

**User Balance Updates**:
```
Before: 450 $BET (500 - 50 bet)
After:  645 $BET (450 + 195 winnings)
```

#### 3. Lost Bet

If Arsenal lost:
```
❌ Bet Lost

Arsenal Win @ 4.20
Stake: 50 $BET
Return: 0 $BET

[View Match Summary]
```

**Demo**: Auto-settled randomly after 30 seconds (50% win rate)

---

## 💸 Phase 6: Withdrawal

### Converting $BET Back to USDC

#### 1. User Navigates to Wallet

```
┌──────────────────────────────────┐
│  Your Balance                    │
│                                  │
│  🎰 $BET: 645.00                │
│  💵 USDC: 1,000.00              │
│                                  │
│  [Withdraw $BET → USDC]         │
└──────────────────────────────────┘
```

#### 2. Withdrawal Flow

```
┌──────────────────────────────────┐
│  Withdraw to USDC                │
│                                  │
│  Amount: [____] $BET            │
│           645                    │
│                                  │
│  You'll receive: 645.00 USDC    │
│  (1:1 peg, no fees)             │
│                                  │
│  [Cancel]  [Confirm Withdraw]   │
└──────────────────────────────────┘
```

#### 3. Smart Contract

```solana
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    // 1. Burn $BET
    token::burn(
        ctx.accounts.burn_context(),
        amount,
    )?;
    
    // 2. Transfer USDC 1:1
    token::transfer(
        ctx.accounts.transfer_context(),
        amount,
    )?;
    
    Ok(())
}
```

#### 4. Funds in Wallet

```
✅ Withdrawal Complete!

645 $BET → 645 USDC

Transaction: def456...uvw
Funds are now in your Phantom wallet.
```

**Demo**: Simulated (localStorage update)

---

## 🔄 Complete User Lifecycle Summary

### Flowchart

```
┌─────────────────────────────────────────────────────────────┐
│                    NEW USER JOURNEY                         │
└─────────────────────────────────────────────────────────────┘

1. Land on back.bet
   └─> See live events (read-only)

2. Click "Connect Wallet"
   └─> Phantom prompt appears
       └─> User approves
           └─> Wallet address linked ✓

3. [PRODUCTION] Compliance Check
   └─> zk.Me verification
       └─> Age + Geo proof generated
           └─> On-chain proof verified ✓

4. Deposit USDC
   └─> Enter amount (e.g., 500)
       └─> Approve transaction
           └─> Receive 500 $BET ✓

5. Browse Events
   └─> See AI insights
       └─> Click odds
           └─> Add to bet slip

6. Place Bet
   └─> Enter stake (e.g., 50 $BET)
       └─> Confirm bet
           └─> Approve transaction
               └─> Bet active ✓

7. Match Settles
   └─> Oracle fetches result
       └─> Smart contract calculates payout
           └─> IF WIN: Claim winnings (195 $BET)
           └─> IF LOSE: Bet resolved (0 $BET)

8. Withdraw (Optional)
   └─> Convert $BET → USDC
       └─> Funds back to wallet ✓

9. Repeat (Returning User)
   └─> Wallet auto-connects
       └─> Jump to step 5 ✓
```

---

## 🆚 Demo vs Production Comparison

| Step | Demo (Phase 1) | Production (Phase 2+) |
|------|----------------|----------------------|
| **Wallet Connection** | Mock address | Real Phantom/Sollet |
| **Compliance** | Skipped | zk.Me verification |
| **Deposit** | LocalStorage | Solana smart contract |
| **$BET Token** | Fake balance | Real SPL Token-2022 |
| **Betting** | Simulated | On-chain transaction |
| **Settlement** | Auto (30s random) | Oracle + smart contract |
| **Withdrawal** | LocalStorage | Burn $BET → USDC transfer |

---

## 📱 Key User Experience Principles

### 1. **No Email, No Password**
- Wallet = Identity
- 1-click authentication
- Same wallet works across all dApps

### 2. **Instant Feedback**
- Optimistic UI updates
- Transaction status tracking
- Real-time balance changes

### 3. **Transparent Pricing**
- No hidden fees
- Odds displayed prominently
- AI shows when you have "edge"

### 4. **Mobile-First**
- Responsive design
- Phantom mobile wallet support
- PWA for iOS/Android

### 5. **Self-Custody**
- Users control their funds
- No "house" holding money
- Withdraw anytime (no limits)

---

## 🎯 Success Metrics (User Onboarding)

| Metric | Target | Notes |
|--------|--------|-------|
| **Wallet Connection Rate** | >80% | Landing → Connected |
| **zk.Me Completion** | >90% | Started → Verified |
| **First Deposit Time** | <2 min | Connected → Funded |
| **First Bet Placement** | <5 min | Funded → Bet placed |
| **D1 Retention** | >40% | Return next day |
| **D7 Retention** | >20% | Active after week 1 |

---

*Last Updated: February 13, 2026*  
*Status: Phase 2 (Backend) - Transitioning from simulated to real infrastructure*
