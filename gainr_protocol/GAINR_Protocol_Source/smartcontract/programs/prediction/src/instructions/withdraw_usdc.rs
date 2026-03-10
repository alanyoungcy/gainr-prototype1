use crate::states::global::*;
use anchor_lang::prelude::*;
use anchor_spl::token_interface::{self, Mint, TokenAccount, TransferChecked, Burn, token_2022::Token2022};

#[derive(Accounts)]
pub struct WithdrawUsdc<'info> {
    #[account(mut)]
    pub user: Signer<'info>,

    #[account(
        seeds = [crate::constants::GLOBAL_SEED.as_bytes()],
        bump,
    )]
    pub global: Account<'info, Global>,

    #[account(
        mut,
        constraint = usdc_mint.key() == global.usdc_mint
    )]
    pub usdc_mint: InterfaceAccount<'info, Mint>,

    #[account(
        mut,
        constraint = bet_mint.key() == global.bet_mint
    )]
    pub bet_mint: InterfaceAccount<'info, Mint>,

    #[account(
        mut,
        associated_token::mint = bet_mint,
        associated_token::authority = user,
        associated_token::token_program = token_2022_program,
    )]
    pub user_bet: InterfaceAccount<'info, TokenAccount>,

    #[account(
        mut,
        associated_token::mint = usdc_mint,
        associated_token::authority = global,
    )]
    pub vault_usdc: InterfaceAccount<'info, TokenAccount>,

    #[account(
        mut,
        associated_token::mint = usdc_mint,
        associated_token::authority = user,
    )]
    pub user_usdc: InterfaceAccount<'info, TokenAccount>,

    pub token_program: Interface<'info, token_interface::TokenInterface>,
    pub token_2022_program: Program<'info, Token2022>,
    pub system_program: Program<'info, System>,
}

pub fn withdraw_usdc(ctx: Context<WithdrawUsdc>, amount: u64) -> Result<()> {
    // 1. Burn $BET from user
    let burn_cpi_accounts = Burn {
        mint: ctx.accounts.bet_mint.to_account_info(),
        from: ctx.accounts.user_bet.to_account_info(),
        authority: ctx.accounts.user.to_account_info(),
    };
    let cpi_program_2022 = ctx.accounts.token_2022_program.to_account_info();
    let cpi_ctx_burn = CpiContext::new(cpi_program_2022, burn_cpi_accounts);
    token_interface::burn(cpi_ctx_burn, amount)?;

    // 2. Transfer USDC from global vault to user
    let transfer_cpi_accounts = TransferChecked {
        from: ctx.accounts.vault_usdc.to_account_info(),
        mint: ctx.accounts.usdc_mint.to_account_info(),
        to: ctx.accounts.user_usdc.to_account_info(),
        authority: ctx.accounts.global.to_account_info(),
    };
    
    let global_bump = ctx.bumps.global;
    let seeds = &[
        crate::constants::GLOBAL_SEED.as_bytes(),
        &[global_bump],
    ];
    let signer = &[&seeds[..]];
    
    let cpi_program = ctx.accounts.token_program.to_account_info();
    let cpi_ctx_transfer = CpiContext::new_with_signer(cpi_program, transfer_cpi_accounts, signer);
    token_interface::transfer_checked(cpi_ctx_transfer, amount, ctx.accounts.usdc_mint.decimals)?;

    msg!("Burned {} $BET, Withdrawn {} USDC", amount, amount);
    Ok(())
}
