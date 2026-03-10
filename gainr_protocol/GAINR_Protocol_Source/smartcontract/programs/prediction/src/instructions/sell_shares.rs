use crate::constants::{GLOBAL_SEED, MARKET_SEED, MINT_SEED_A, MINT_SEED_B};
use crate::errors::ContractError;
use crate::states::{global::*, market::*};
use crate::utils::integer_sqrt;
use anchor_lang::prelude::*;
use anchor_spl::token::{self, Mint as MintLegacy, Token as TokenLegacy, TokenAccount as TokenAccountLegacy};
use anchor_spl::token_interface::{self, Mint, TokenAccount, Token2022, TokenInterface};

#[derive(Accounts)]
#[instruction(params: SellParams)]
pub struct SellShares<'info> {
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
        mut,
        associated_token::mint = if params.is_yes { share_mint_a.key() } else { share_mint_b.key() },
        associated_token::authority = user
    )]
    pub user_share_ata: Account<'info, TokenAccountLegacy>,

    pub token_program: Program<'info, TokenLegacy>,
    pub token_2022_program: Program<'info, Token2022>,
    pub associated_token_program: Program<'info, anchor_spl::associated_token::AssociatedToken>,
    pub system_program: Program<'info, System>,
}

#[derive(AnchorSerialize, AnchorDeserialize)]
pub struct SellParams {
    pub market_id: String,
    pub amount: u64, // amount of shares to sell
    pub is_yes: bool,
}

pub fn sell_shares(ctx: Context<SellShares>, params: SellParams) -> Result<()> {
    let market = &mut ctx.accounts.market;
    let s = params.amount;

    let x = market.token_a_amount;
    let y = market.token_b_amount;

    // b = ((x+y+s) - sqrt((x+y+s)^2 - 4sy)) / 2
    // For YES sell, swap s and y in logic if b depends on NO.
    // Wait, the formula I derived was for selling YES.
    
    let (res_x, res_y) = if params.is_yes { (x, y) } else { (y, x) };
    
    let sum = (res_x as u128).checked_add(res_y as u128).ok_or(ContractError::ArithmeticError)?
        .checked_add(s as u128).ok_or(ContractError::ArithmeticError)?;
    let term1 = sum.checked_mul(sum).ok_or(ContractError::ArithmeticError)?;
    let term2 = (4 as u128).checked_mul(s as u128).ok_or(ContractError::ArithmeticError)?
        .checked_mul(res_y as u128).ok_or(ContractError::ArithmeticError)?;
    
    let discriminant = term1.checked_sub(term2).ok_or(ContractError::ArithmeticError)?;
    let sqrt_d = integer_sqrt(discriminant);
    
    let b_u128 = sum.checked_sub(sqrt_d).ok_or(ContractError::ArithmeticError)? / 2;
    let b = b_u128 as u64;

    // LP Fee handling on sell
    let pool_fee = (b as f64 * ctx.accounts.global.pool_fee_percentage / 100.0) as u64;
    let b_net = b.checked_sub(pool_fee).ok_or(ContractError::ArithmeticError)?;

    // Transfer s shares from user to market pool
    token::transfer(
        CpiContext::new(
            ctx.accounts.token_program.to_account_info(),
            token::Transfer {
                from: ctx.accounts.user_share_ata.to_account_info(),
                to: if params.is_yes { ctx.accounts.market_ata_a.to_account_info() } else { ctx.accounts.market_ata_b.to_account_info() },
                authority: ctx.accounts.user.to_account_info(),
            },
        ),
        s,
    )?;

    // Transfer b_net $BET from market vault to user
    let seeds: &[&[u8]; 3] = &Market::get_signer(&market.bump, &params.market_id.as_bytes());
    let signer_seeds = &[&seeds[..]];

    token_interface::transfer_checked(
        CpiContext::new_with_signer(
            ctx.accounts.token_2022_program.to_account_info(),
            token_interface::TransferChecked {
                from: ctx.accounts.market_bet_vault.to_account_info(),
                to: ctx.accounts.user_bet_ata.to_account_info(),
                authority: market.to_account_info(),
                mint: ctx.accounts.bet_mint.to_account_info(),
            },
            signer_seeds,
        ),
        b_net,
        ctx.accounts.bet_mint.decimals,
    )?;

    // Update pool reserves and total collateral
    // The pool holds 'b' worth of burned pairs, but gave out only 'b_net' $BET.
    // The 'pool_fee' amount of $BET remains in the vault, and its corresponding shares remain in the pool.
    if params.is_yes {
        market.token_a_amount = x.checked_add(s).ok_or(ContractError::ArithmeticError)? - b_net;
        market.token_b_amount = y.checked_sub(b_net).ok_or(ContractError::ArithmeticError)?;
        market.yes_amount = market.yes_amount.checked_sub(s).ok_or(ContractError::ArithmeticError)?;
    } else {
        market.token_a_amount = x.checked_sub(b_net).ok_or(ContractError::ArithmeticError)?;
        market.token_b_amount = y.checked_add(s).ok_or(ContractError::ArithmeticError)? - b_net;
        market.no_amount = market.no_amount.checked_sub(s).ok_or(ContractError::ArithmeticError)?;
    }
    
    market.amm_bet_reserve = market.amm_bet_reserve.checked_sub(b_net).ok_or(ContractError::ArithmeticError)?;

    // Burn the b_net pairs from the pool inventory (the fee remains as liquidity)
    token::burn(
        CpiContext::new_with_signer(
            ctx.accounts.token_program.to_account_info(),
            token::Burn {
                mint: ctx.accounts.share_mint_a.to_account_info(),
                from: ctx.accounts.market_ata_a.to_account_info(),
                authority: market.to_account_info(),
            },
            signer_seeds,
        ),
        b_net,
    )?;

    token::burn(
        CpiContext::new_with_signer(
            ctx.accounts.token_program.to_account_info(),
            token::Burn {
                mint: ctx.accounts.share_mint_b.to_account_info(),
                from: ctx.accounts.market_ata_b.to_account_info(),
                authority: market.to_account_info(),
            },
            signer_seeds,
        ),
        b_net,
    )?;

    market.compute_prices()?;

    Ok(())
}
