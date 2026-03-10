# GAINR Security Audit Walkthrough

This walkthrough demonstrates the key vulnerabilities discovered during the end-to-end security audit.

## 1. Smart Contract: Missing KYC Enforcement
The [betting](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/controller/market/index.ts#72-122) instruction is missing the logic to verify that a user has passed zkMe KYC. This allows any user to bet, which breaks regulatory compliance.

**Vulnerable Area**: [betting.rs:L142-L144](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs#L142-L144)

```rust
// 2. Verified User Check (zkMe Signature Verification)
// Placeholder for Phase 3 logic
```

## 2. Backend: Referral Reward Theft
The referral reward claim endpoint does not verify the requester's identity, allowing anyone to drain funds from any wallet.

**Vulnerable Area**: [referral/index.ts:L64-L81](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/controller/referral/index.ts#L64-L81)

```typescript
export const claimReward = async(req: Request, res: Response) => {
    try {
        const { wallet, amount } = req.body; // No signature verification!
        await claimFee(wallet, amount);
```

## 3. Backend: Information Leak (IDOR)
Any user's trading history and earnings can be retrieved by simply providing their wallet address in a public GET request.

**Vulnerable Area**: [profile/index.ts:L5-L16](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/controller/profile/index.ts#L5-L16)

---

## 4. Frontend: Exposed Credentials
Hardcoded Pinata API secrets allow full control over the application's IPFS assets.

**Vulnerable Area**: [utils/index.ts:L4-L5](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-frontend/src/utils/index.ts#L4-L5)

```typescript
const PINATA_API_KEY = "6ab09644822193eed05d";
const PINATA_SECRET_KEY = "e920681dec7cb1d967ab69aaff433c1a94d4e4b3da53dc0d169f6736c7292708";
```

## Verification Summary
All identified vulnerabilities have been documented in the [Security Report](file:///C:/Users/Rajes/.gemini/antigravity/brain/e2513f3e-c63b-45d7-b0fd-63858770edb4/security_report.md). Manual code reviews were used to verify these issues, as they represent fundamental logic and configuration flaws.
