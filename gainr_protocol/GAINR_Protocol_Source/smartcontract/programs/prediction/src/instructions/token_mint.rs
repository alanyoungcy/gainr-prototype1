use crate::constants::{GLOBAL_SEED, MARKET_SEED};
use crate::errors::ContractError;
use crate::states::global::Global;
use crate::states::market::{Market, MarketStatus};
use anchor_lang::prelude::*;
use anchor_spl::token::{self, Token as TokenLegacy};
use anchor_spl::token_interface::{self, Mint, TokenAccount, TokenInterface};

#[derive(Accounts)]
#[instruction(market_id: String)]
pub struct TokenMint<'info> {
    #[account(
        init_if_needed,
        payer = user,
        associated_token::mint = token_mint_a,
        associated_token::authority = market
    )]
    pub pda_token_a_account: Box<InterfaceAccount<'info, TokenAccount>>,
    #[account(
        init_if_needed,
        payer = user,
        associated_token::mint = token_mint_b,
        associated_token::authority = market
    )]
    pub pda_token_b_account: Box<InterfaceAccount<'info, TokenAccount>>,

    #[account(mut)]
    pub user: Signer<'info>,

    /// CHECK: global fee authority is checked in constraint
    #[account(
        mut,
        constraint = fee_authority.key() == global.fee_authority @ ContractError::InvalidFeeAuthority
    )]
    pub fee_authority: AccountInfo<'info>,

    #[account(
        mut,
        seeds = [MARKET_SEED.as_bytes(), &market_id.as_bytes()],
        bump
    )]
    /// CHECK: global fee authority is checked in constraint
    pub market: Box<Account<'info, Market>>,

    #[account(
        seeds = [GLOBAL_SEED.as_bytes()],
        bump
    )]
    pub global: Box<Account<'info, Global>>,

    #[account(mut)]
    ///CHECK: Using seed to validate metadata account
    metadata_a: UncheckedAccount<'info>,
    #[account(mut)]
    ///CHECK: Using seed to validate metadata account
    metadata_b: UncheckedAccount<'info>,

    /// CHECK: Yes token mint
    #[account(mut)]
    token_mint_a: Box<InterfaceAccount<'info, Mint>>,
    /// CHECK: No token mint
    #[account(mut)]
    token_mint_b: Box<InterfaceAccount<'info, Mint>>,

    pub token_program: Program<'info, TokenLegacy>,
    pub token_interface_program: Interface<'info, TokenInterface>,
    /// CHECK: associated token program account
    pub associated_token_program: UncheckedAccount<'info>,
    /// CHECK: token metadata program account
    pub token_metadata_program: UncheckedAccount<'info>,
    /// CHECK: rent account
    pub rent: UncheckedAccount<'info>,
    pub system_program: Program<'info, System>,
}

impl TokenMint<'_> {
    pub fn token_mint(ctx: Context<TokenMint>, market_id: String) -> Result<()> {
        let mint_authority_signer: [&[u8]; 3] =
            Market::get_signer(&ctx.bumps.market, &market_id.as_bytes());
        let mint_auth_signer_seeds = &[&mint_authority_signer[..]];

        let decimal_multiplier = 10u64.pow(ctx.accounts.global.decimal as u32);
        let token_a_amount = ctx
            .accounts
            .market
            .token_a_amount
            .checked_mul(decimal_multiplier)
            .ok_or(ContractError::ArithmeticError)?;

        let token_b_amount = ctx
            .accounts
            .market
            .token_b_amount
            .checked_mul(decimal_multiplier)
            .ok_or(ContractError::ArithmeticError)?;
        msg!("🎫token_a_amount 🎫{}", token_a_amount);
        // mint "Yes" token to market
        token_interface::mint_to(
            CpiContext::new_with_signer(
                ctx.accounts.token_interface_program.to_account_info(),
                token_interface::MintTo {
                    authority: ctx.accounts.market.to_account_info(),
                    to: ctx.accounts.pda_token_a_account.to_account_info(),
                    mint: ctx.accounts.token_mint_a.to_account_info(),
                },
                mint_auth_signer_seeds,
            ),
            token_a_amount,
        )?;
        msg!("🎫token_b_amount 🎫{}", token_b_amount);

        // mint "No" token to market
        token_interface::mint_to(
            CpiContext::new_with_signer(
                ctx.accounts.token_interface_program.to_account_info(),
                token_interface::MintTo {
                    authority: ctx.accounts.market.to_account_info(),
                    to: ctx.accounts.pda_token_b_account.to_account_info(),
                    mint: ctx.accounts.token_mint_b.to_account_info(),
                },
                mint_auth_signer_seeds,
            ),
            token_b_amount,
        )?;

        ctx.accounts
            .market
            .update_market_status(MarketStatus::Prepare);
        Ok(())
    }
}
