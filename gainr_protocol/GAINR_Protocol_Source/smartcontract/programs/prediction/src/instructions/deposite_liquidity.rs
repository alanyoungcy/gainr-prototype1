use crate::constants::{GLOBAL_SEED, MINT_SEED_A, MINT_SEED_B};
use crate::errors::ContractError;
use crate::events::MarketStatusUpdated;
use crate::states::{
    global::Global,
    market::{Market, MarketStatus},
};
use anchor_spl::token::{self, Mint as MintLegacy, Token as TokenLegacy, TokenAccount as TokenAccountLegacy};
use anchor_spl::token_interface::{self, Mint, TokenAccount, Token2022, TokenInterface};

#[derive(Accounts)]
pub struct DepositLiquidity<'info> {
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
        constraint = market.market_status == MarketStatus::Prepare @ ContractError::NotPreparing,
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

    /// CHECK: global fee authority is checked in implementation
    #[account(mut)]
    pub fee_authority: AccountInfo<'info>,

    pub token_program: Program<'info, TokenLegacy>,
    pub token_2022_program: Program<'info, Token2022>,
    pub token_interface_program: Interface<'info, TokenInterface>,
    pub associated_token_program: Program<'info, anchor_spl::associated_token::AssociatedToken>,
    pub system_program: Program<'info, System>,
}

pub fn deposit_liquidity(ctx: Context<DepositLiquidity>, amount: u64) -> Result<()> {
    require!(amount >= 1000, ContractError::InvalidFundAmount);
    
    let global = &ctx.accounts.global;
    let market = &mut ctx.accounts.market;

    // 1. Fee handling
    let fee_amount = (amount as f64 * global.fund_fee_percentage / 100.0) as u64;
    let net_amount = amount.checked_sub(fee_amount).ok_or(ContractError::ArithmeticError)?;

    // Transfer $BET from user to fee authority
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
        fee_amount,
        ctx.accounts.bet_mint.decimals,
    )?;

    // Transfer net $BET to market vault
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
        net_amount,
        ctx.accounts.bet_mint.decimals,
    )?;

    // 2. Mint shares to pool
    let seeds: &[&[u8]; 3] = &Market::get_signer(&market.bump, &market.market_id.as_bytes());
    let signer_seeds = &[&seeds[..]];

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
        net_amount,
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
        net_amount,
    )?;

    // 3. Update pool state
    market.token_a_amount = market.token_a_amount.checked_add(net_amount).ok_or(ContractError::ArithmeticError)?;
    market.token_b_amount = market.token_b_amount.checked_add(net_amount).ok_or(ContractError::ArithmeticError)?;
    market.amm_bet_reserve = market.amm_bet_reserve.checked_add(net_amount).ok_or(ContractError::ArithmeticError)?;
    
    // Set status to Active once enough liquidity is present (e.g. market_count threshold)
    if market.amm_bet_reserve >= global.market_count {
        market.market_status = MarketStatus::Active;
    }

    market.compute_prices()?;

    emit!(MarketStatusUpdated {
        market_id: market.key(),
        market_status: market.market_status,
    });

    Ok(())
}
