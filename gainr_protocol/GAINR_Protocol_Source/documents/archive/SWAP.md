Final "Proper" $BET to $GAINR Swap Protocol
This document outlines the technical implementation of the $BET to $GAINR bridge, moving beyond simple balance subtraction to a "Burn-to-Swap" protocol that aligns with the GAINR Whitepaper.

Technical Context
$BET: Non-transferable internal wagering chip (1:1 with USDC).
$GAINR: Floating utility token (Buyback-and-Burn engine).
The Bridge: Swapping $BET for $GAINR is a two-step process:
Burn BET: The user's wagering chips are burned to release the pegged USDC from the Player Vault.
AMM Swap: The released USDC is routed through an AMM (Raydium/Orca) to purchase $GAINR at market price.
Proposed Changes
[Backend/Solana Simulation] 
gainr_swap_program.rs
 [NEW]
Define the Anchor instruction for the proper swap to show the technical architecture.

rust
pub fn swap_bet_to_gainr(ctx: Context<SwapBetToGainr>, amount: u64) -> Result<()> {
    // 1. Burn the non-transferable $BET tokens
    token::burn(ctx.accounts.into_burn_bet_context(), amount)?;
    
    // 2. Release USDC from Vault to the AMM Bridge
    vault::release_usdc(ctx.accounts.into_release_usdc_context(), amount)?;
    
    // 3. Execute Swap via AMM CPI (e.g., Raydium)
    amm::swap_usdc_for_gainr(ctx.accounts.into_amm_swap_context(), amount)?;
    
    Ok(())
}
[Frontend] 
wallet_provider.dart
Update the 
swap
 method to simulate this three-stage commitment:

Stage 1 (Burning): Animation showing $BET being removed from the wallet.
Stage 2 (DEX Execution): Simulating a call to the "Swap Router".
Stage 3 (Settlement): Final $GAINR balance update.
Verification Plan
Math Verification: 100 $BET burned -> 0.3% fee -> ~117 $GAINR received (at $0.85 rate).
Transaction Log: Verify the logs explicitly state "Burn $BET" and "Purchase $GAINR via AMM Router".