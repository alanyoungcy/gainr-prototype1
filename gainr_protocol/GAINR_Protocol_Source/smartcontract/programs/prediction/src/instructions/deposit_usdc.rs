use crate::states::global::*;
use anchor_lang::prelude::*;
use anchor_spl::token_interface::{self, Mint, TokenAccount, TransferChecked, MintTo, token_2022::Token2022};

#[derive(Accounts)]
pub struct DepositUsdc<'info> {
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
        associated_token::mint = usdc_mint,
        associated_token::authority = user,
    )]
    pub user_usdc: InterfaceAccount<'info, TokenAccount>,

    #[account(
        init_if_needed,
        payer = user,
        associated_token::mint = usdc_mint,
        associated_token::authority = global,
    )]
    pub vault_usdc: InterfaceAccount<'info, TokenAccount>,

    #[account(
        mut,
        associated_token::mint = bet_mint,
        associated_token::authority = user,
        associated_token::token_program = token_2022_program,
    )]
    pub user_bet: InterfaceAccount<'info, TokenAccount>,

    pub token_program: Interface<'info, token_interface::TokenInterface>,
    pub token_2022_program: Program<'info, Token2022>,
    pub associated_token_program: Program<'info, anchor_spl::associated_token::AssociatedToken>,
    pub system_program: Program<'info, System>,
}

pub fn deposit_usdc(ctx: Context<DepositUsdc>, amount: u64) -> Result<()> {
    // 1. Transfer USDC from user to global vault
    let transfer_cpi_accounts = TransferChecked {
        from: ctx.accounts.user_usdc.to_account_info(),
        mint: ctx.accounts.usdc_mint.to_account_info(),
        to: ctx.accounts.vault_usdc.to_account_info(),
        authority: ctx.accounts.user.to_account_info(),
    };
    let cpi_program = ctx.accounts.token_program.to_account_info();
    let cpi_ctx = CpiContext::new(cpi_program, transfer_cpi_accounts);
    token_interface::transfer_checked(cpi_ctx, amount, ctx.accounts.usdc_mint.decimals)?;

    // 2. Mint equal amount of $BET to user
    let mint_cpi_accounts = MintTo {
        mint: ctx.accounts.bet_mint.to_account_info(),
        to: ctx.accounts.user_bet.to_account_info(),
        authority: ctx.accounts.global.to_account_info(),
    };
    
    let global_bump = ctx.bumps.global;
    let seeds = &[
        crate::constants::GLOBAL_SEED.as_bytes(),
        &[global_bump],
    ];
    let signer = &[&seeds[..]];
    
    let cpi_program_2022 = ctx.accounts.token_2022_program.to_account_info();
    let cpi_ctx_mint = CpiContext::new_with_signer(cpi_program_2022, mint_cpi_accounts, signer);
    token_interface::mint_to(cpi_ctx_mint, amount)?;

    msg!("Deposited {} USDC, Minted {} $BET", amount, amount);
    Ok(())
}
