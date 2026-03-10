# Comprehensive Production Readiness & Security Plan

This plan outlines the steps required to transition GAINR Protocol (Price.bet) from its current state to a 100% production-ready, secure platform.

## User Review Required

> [!IMPORTANT]
> **Key Management Transition:** Move all hardcoded secrets (Solana Private Keys, Pinata API Keys) to a managed secret store or [.env](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/.env) variables before any public deployment.
> **Infrastructure Setup:** A centralized logging server (e.g., Winston/ELK) and specialized monitoring (e.g., Sentry) must be integrated for production stability.

## Proposed Changes

### [prediction-market-smartcontract]
- [MODIFY] [betting.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/betting.rs)
    - Implement safe fixed-point integer math for fee management.
    - Finalize Ed25519 signature checks (phase 3).
    - Add slippage protection logic.
- [MODIFY] [get_oracle_res.rs](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-smartcontract/programs/prediction/src/instructions/get_oracle_res.rs)
    - Add defensive checks and remove `.unwrap()` calls to prevent DoS.

### [prediction-market-backend]
- [MODIFY] [config.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/config.ts)
    - Decouple administrative private keys from the codebase (remove [prediction.json](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/prediction.json) dependency).
- [NEW] [logger.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/utils/logger.ts)
    - Implement a structured logging service using `winston` or `pino`.
- [MODIFY] [errorHandler.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-backend/src/middleware/errorHandler.ts)
    - Enhance error reporting to include structured logs and sanitized production messages.

### [prediction-market-frontend]
- [MODIFY] [src/utils/index.ts](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-frontend/src/utils/index.ts)
    - Implement a backend proxy for Pinata uploads to prevent API key exposure.
- [NEW] [.env.example](file:///d:/mBITS/GAINR_Pred/Price/prediction-market-frontend/.env.example)
    - Document all required `NEXT_PUBLIC_` variables including RPC endpoints and contract IDs.

## Verification Plan

### Automated Tests
- `anchor test`: Validate fixed-point math and slippage protection.
- `vitest`/`jest`: Verify backend environment variable loading and middleware security.

### Manual Verification
- **Network Audit:** Inspect browser network traffic to confirm no API secrets are transmitted.
- **Log Verification:** Confirm structured logs are correctly generated on the server during simulated errors.
