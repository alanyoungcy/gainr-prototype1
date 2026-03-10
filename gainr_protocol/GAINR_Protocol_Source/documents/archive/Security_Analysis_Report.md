# Security & Risk Analysis Report: GAINR Price.bet

**Date:** February 22, 2026  
**Scope:** `prediction-market-backend`, `prediction-market-frontend`, `prediction-market-smartcontract`

---

## 🛑 Executive Summary (Critical Findings)

The system maintains fund safety on-chain, but the **off-chain state and backend infrastructure are at high risk**. The most critical finding is a **complete lack of authentication** on API endpoints that modify the database, and **hardcoded administrative secrets**.

---

## 1. Backend Vulnerabilities (`prediction-market-backend`)

| Finding | Severity | Description | Risk |
|:---|:---|:---|:---|
| **Broken Access Control (A01)** | 🔴 **CRITICAL** | Endpoints like `/market/betting`, `/market/liquidity`, and `/market/additionalInfo` accept POST requests without wallet signature or JWT verification. | An attacker can flood the DB with fake bets, fake market data, and manipulate referral fees/statistics without ever signing a transaction. |
| **Hardcoded Secrets (A04)** | 🟠 **HIGH** | `BREAK_GLASS_CODE` in [compliance.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/service/compliance.ts) defaults to `"GAINR_EMERGENCY_2026"`. | If the env variable is missing or leaked, the PII/Audit enclave can be bypassed by any attacker knowing this common string. |
| **Insecure Auth Comparison** | 🟠 **HIGH** | `authCode !== MASTER_CODE` uses simple string comparison instead of `crypto.timingSafeEqual`. | Vulnerable to **timing attacks**, allowing an attacker to guess the emergency access code character by character. |
| **Security Misconfiguration (A02)** | 🟡 **MEDIUM** | Missing `helmet` middleware. No CSP, No HSTS, No X-Frame-Options. | Increased risk of clickjacking and XSS. |
| **DoS Risk (A10)** | 🟡 **MEDIUM** | `express.json` limit set to `50mb`. No rate limiting (e.g., `express-rate-limit`). | Vulnerable to resource exhaustion and request flooding. |

---

## 2. Smart Contract Vulnerabilities (`prediction-market-smartcontract`)

| Finding | Severity | Description | Risk |
|:---|:---|:---|:---|
| **Identity Bypass** | 🟠 **HIGH** | [betting.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs) line 110 contains a placeholder for zkMe verification. Currently, identity checks are skipped. | Compliance failure. Any user can bet regardless of KYC/Identity status until Phase 3 is fully implemented. |
| **Unchecked Accounts** | 🟡 **MEDIUM** | [create_market.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/create_market.rs) uses `UncheckedAccount` for metadata accounts without explicit PDA derivation checks in the Anchor macro. | Potential (though limited) risk of account substitution in the metadata layer. |
| **Price Linearity** | 🔵 **LOW** | The price calculation in [betting.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs) is a linear approximation of the CPMM curve. | Can lead to slight discrepancies in UI vs. actual swap rates for very large bets relative to liquidity. |

---

## 3. Frontend / General Risks

| Finding | Severity | Description | Risk |
|:---|:---|:---|:---|
| **Dependency Staleness** | 🔵 **LOW** | Use of older packages (e.g., Solana web3.js v1 while v2 is available). | Potential for missing security patches or performance improvements in newer libraries. |
| **Trust in Client Data** | 🟠 **HIGH** | The frontend sends `token_a_price` and `token_b_price` to the backend during the [betting](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs#104-274) call, which the backend saves directly. | A modified client could send fake prices to the backend, corrupting the dashboard stats and "Recent Activity" feed. |

---

## 🛠️ Recommended Remediation Plan

### Immediate Cleanup (24-48 Hours)
1.  **Implement Signature Authentication**: Middleware must verify a Solana wallet-signed message for every DB-altering POST request.
2.  **Remove Hardcoded Secrets**: Delete fallback strings for `BREAK_GLASS_CODE` and `COMPLIANCE_KEY`. Ensure they are ONLY read from secure env variables.
3.  **Install Helmet**: `npm install helmet` and add `app.use(helmet())` to the backend.

### Mid-Term Hardening
1.  **Timing Safe Comparison**: Use `crypto.timingSafeEqual` for all secret checks.
2.  **Rate Limiting**: Add `express-rate-limit` to all routes.
3.  **Backend-Sourced Truth**: Instead of the client sending prices to the backend, the backend should fetch current pool states from Solana directly after a transaction is confirmed.

### Long-Term
1.  **Fully enable zkMe**: Replace the [betting.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs) placeholder with the production identity verification logic.
