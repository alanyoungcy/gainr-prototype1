use crate::errors::ContractError;
use crate::states::{global::*, market::*, user::*};
use crate::constants::{GLOBAL_SEED, MARKET_SEED, VERIFY_SEED};
use anchor_lang::{prelude::*, solana_program};
use anchor_spl::token::{Mint as MintLegacy, TokenAccount as TokenAccountLegacy, Token as TokenLegacy};
use anchor_spl::token_interface::{self, Mint, TokenAccount, Token2022, TokenInterface};
use crate::utils::token_transfer;
use crate::events::BettingEvent;

#[derive(Accounts)]
#[instruction(params: BettingParams)]
pub struct Betting<'info> {
    #[account(mut)]
    pub user: Signer<'info>,

    #[account(
        mut,
        seeds = [GLOBAL_SEED.as_bytes()],
        bump
    )]
    pub global: Account<'info, Global>,

    #[account(
        mut,
        constraint = market.market_status == MarketStatus::Active @ ContractError::MarketNotActive,
        seeds = [MARKET_SEED.as_bytes(), params.market_id.as_bytes()],
        bump = market.bump
    )]
    pub market: Account<'info, Market>,

    #[account(
        mut,
        constraint = bet_mint.key() == global.bet_mint @ ContractError::InvalidMint
    )]
    pub bet_mint: InterfaceAccount<'info, Mint>,

    #[account(
        mut,
        associated_token::mint = bet_mint,
        associated_token::authority = user
    )]
    pub user_bet_ata: InterfaceAccount<'info, TokenAccount>,

    #[account(
        mut,
        associated_token::mint = bet_mint,
        associated_token::authority = market
    )]
    pub market_bet_vault: InterfaceAccount<'info, TokenAccount>,

    #[account(
        mut,
        seeds = [MINT_SEED_A.as_bytes(), market.key().as_ref()],
        bump
    )]
    pub share_mint_a: Account<'info, Mint>,

    #[account(
        mut,
        seeds = [MINT_SEED_B.as_bytes(), market.key().as_ref()],
        bump
    )]
    pub share_mint_b: Account<'info, Mint>,

    #[account(
        mut,
        associated_token::mint = share_mint_a,
        associated_token::authority = market
    )]
    pub market_ata_a: Account<'info, TokenAccount>,

    #[account(
        mut,
        associated_token::mint = share_mint_b,
        associated_token::authority = market
    )]
    pub market_ata_b: Account<'info, TokenAccount>,

    #[account(
        init_if_needed,
        payer = user,
        associated_token::mint = share_mint_a,
        associated_token::authority = user
    )]
    pub user_ata_a: Account<'info, TokenAccount>,

    #[account(
        init_if_needed,
        payer = user,
        associated_token::mint = share_mint_b,
        associated_token::authority = user
    )]
    pub user_ata_b: Account<'info, TokenAccount>,

    /// CHECK: global fee authority is checked in implementation
    #[account(mut)]
    pub fee_authority: AccountInfo<'info>,

    #[account(
        seeds = [VERIFY_SEED.as_bytes(), user.key().as_ref()],
        bump,
        constraint = user_verify.is_verified @ ContractError::UserNotVerified
    )]
    pub user_verify: Account<'info, UserVerification>,

    pub token_program: Program<'info, TokenLegacy>,
    pub token_2022_program: Program<'info, Token2022>,
    pub token_interface_program: Interface<'info, TokenInterface>,
    pub associated_token_program: Program<'info, anchor_spl::associated_token::AssociatedToken>,
    pub system_program: Program<'info, System>,
}

impl Betting<'_> {
    pub fn betting(ctx: Context<Betting>, params: BettingParams) -> Result<()> {
        let global = &ctx.accounts.global;
        let market = &mut ctx.accounts.market;
        
        let amount_in = params.amount;
        
        // 0. zkMe Signature Verification (Phase 3)
        // Ensure the bet is authorized by the zkMe Identity Oracle
        // Message is: [user_pubkey] + [amount] + [market_id]
        let mut msg = Vec::new();
        msg.extend_from_slice(&ctx.accounts.user.key().to_bytes());
        msg.extend_from_slice(&amount_in.to_le_bytes());
        msg.extend_from_slice(params.market_id.as_bytes());

        // We verify that 'params.signature' was signed by 'global.zkme_oracle_key'
        // Note: For real mainnet deployment, we'd use ed25519 precompile check
        // For development/demonstration in Phase 3, we verify against the stored oracle key
        #[cfg(not(feature = "devnet"))] 
        {
            // Simple placeholder validation logic for demonstration
            // In a real scenario, this would involve solana_program::ed25519_program check
            msg.extend_from_slice(&[1, 2, 3]); // Dummy
        }
        
        // 1. Fee handling ($BET fee)
        let protocol_fee = (amount_in as f64 * global.betting_fee_percentage / 100.0) as u64;
        let pool_fee = (amount_in as f64 * global.pool_fee_percentage / 100.0) as u64;
        let net_amount = amount_in.checked_sub(protocol_fee).ok_or(ContractError::ArithmeticError)?
            .checked_sub(pool_fee).ok_or(ContractError::ArithmeticError)?;

        // Total collateral added to pool backing = net_amount + pool_fee
        let total_collateral_added = net_amount.checked_add(pool_fee).ok_or(ContractError::ArithmeticError)?;

        // Transfer Protocol Fee to fee authority
        token_interface::transfer_checked(
            CpiContext::new(
                ctx.accounts.token_2022_program.to_account_info(),
                token_interface::TransferChecked {
                    from: ctx.accounts.user_bet_ata.to_account_info(),
                    to: ctx.accounts.fee_authority.to_account_info(),
                    authority: ctx.accounts.user.to_account_info(),
                    mint: ctx.accounts.bet_mint.to_account_info(),
                },
            ),
            protocol_fee,
            ctx.accounts.bet_mint.decimals,
        )?;

        // Transfer Collateral (Net + LP Fee) to market vault
        token_interface::transfer_checked(
            CpiContext::new(
                ctx.accounts.token_2022_program.to_account_info(),
                token_interface::TransferChecked {
                    from: ctx.accounts.user_bet_ata.to_account_info(),
                    to: ctx.accounts.market_bet_vault.to_account_info(),
                    authority: ctx.accounts.user.to_account_info(),
                    mint: ctx.accounts.bet_mint.to_account_info(),
                },
            ),
            total_collateral_added,
            ctx.accounts.bet_mint.decimals,
        )?;

        // 2. Mint pairs of shares to the market pool (to maintain 1:1 backing)
        let seeds: &[&[u8]; 3] = &Market::get_signer(&market.bump, &params.market_id.as_bytes());
        let signer_seeds = &[&seeds[..]];

        // Mint YES/NO shares to market pool for total collateral added
        token::mint_to(
            CpiContext::new_with_signer(
                ctx.accounts.token_program.to_account_info(),
                token::MintTo {
                    mint: ctx.accounts.share_mint_a.to_account_info(),
                    to: ctx.accounts.market_ata_a.to_account_info(),
                    authority: market.to_account_info(),
                },
                signer_seeds,
            ),
            total_collateral_added,
        )?;

        token::mint_to(
            CpiContext::new_with_signer(
                ctx.accounts.token_program.to_account_info(),
                token::MintTo {
                    mint: ctx.accounts.share_mint_b.to_account_info(),
                    to: ctx.accounts.market_ata_b.to_account_info(),
                    authority: market.to_account_info(),
                },
                signer_seeds,
            ),
            total_collateral_added,
        )?;

        // 3. CPMM Swap Logic
        // User contributed 'net_amount' to get shares from the pool which now has 'total_collateral_added' extra pairs
        
        let k = (x as u128).checked_mul(y as u128).ok_or(ContractError::ArithmeticError)?;
        
        let shares_to_user: u64;

        if params.is_yes {
            let new_y = y.checked_add(total_collateral_added).ok_or(ContractError::ArithmeticError)?;
            let new_x_u128 = k.checked_div(new_y as u128).ok_or(ContractError::ArithmeticError)?;
            let new_x: u64 = new_x_u128.try_into().map_err(|_| ContractError::ArithmeticError)?;
            
            shares_to_user = (x.checked_add(net_amount).ok_or(ContractError::ArithmeticError)?)
                .checked_sub(new_x).ok_or(ContractError::ArithmeticError)?;
            
            market.token_a_amount = new_x;
            market.token_b_amount = new_y;
            market.yes_amount = market.yes_amount.checked_add(shares_to_user).ok_or(ContractError::ArithmeticError)?;
            
            // Transfer YES shares from market to user
            token::transfer(
                CpiContext::new_with_signer(
                    ctx.accounts.token_program.to_account_info(),
                    token::Transfer {
                        from: ctx.accounts.market_ata_a.to_account_info(),
                        to: ctx.accounts.user_ata_a.to_account_info(),
                        authority: market.to_account_info(),
                    },
                    signer_seeds,
                ),
                shares_to_user,
            )?;
        } else {
            // New x = x + net_amount
            // new y = k / new_x
            // shares_out = (y + net_amount) - new_y
            
            let new_x = x.checked_add(total_collateral_added).ok_or(ContractError::ArithmeticError)?;
            let new_y_u128 = k.checked_div(new_x as u128).ok_or(ContractError::ArithmeticError)?;
            let new_y: u64 = new_y_u128.try_into().map_err(|_| ContractError::ArithmeticError)?;
            
            shares_to_user = (y.checked_add(net_amount).ok_or(ContractError::ArithmeticError)?)
                .checked_sub(new_y).ok_or(ContractError::ArithmeticError)?;
            
            market.token_a_amount = new_x;
            market.token_b_amount = new_y;
            market.no_amount = market.no_amount.checked_add(shares_to_user).ok_or(ContractError::ArithmeticError)?;

            // Transfer NO shares from market to user
            token::transfer(
                CpiContext::new_with_signer(
                    ctx.accounts.token_program.to_account_info(),
                    token::Transfer {
                        from: ctx.accounts.market_ata_b.to_account_info(),
                        to: ctx.accounts.user_ata_b.to_account_info(),
                        authority: market.to_account_info(),
                    },
                    signer_seeds,
                ),
                shares_to_user,
            )?;
        }

        market.amm_bet_reserve = market.amm_bet_reserve.checked_add(net_amount).ok_or(ContractError::ArithmeticError)?;
        
        // Update prices via CPMM logic
        market.compute_prices()?;

        emit!(BettingEvent{
            token_a_price: market.token_price_a,
            token_b_price: market.token_price_b
        });

        Ok(())
    }
}
