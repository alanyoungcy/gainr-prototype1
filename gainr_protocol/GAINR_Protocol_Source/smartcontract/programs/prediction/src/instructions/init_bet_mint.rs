use crate::constants::BET_MINT_SEED;
use crate::states::global::*;
use anchor_lang::prelude::*;
use anchor_spl::token_2022::Token2022;
use anchor_spl::token_interface::{Mint, token_metadata_initialize};

#[derive(Accounts)]
pub struct InitBetMint<'info> {
    #[account(mut)]
    pub admin: Signer<'info>,

    #[account(
        seeds = [crate::constants::GLOBAL_SEED.as_bytes()],
        bump,
        has_one = admin,
    )]
    pub global: Account<'info, Global>,

    #[account(
        init,
        payer = admin,
        mint::decimals = 6,
        mint::authority = global,
        mint::token_program = token_2022_program,
        mint::non_transferable,
        seeds = [BET_MINT_SEED.as_bytes()],
        bump,
    )]
    pub bet_mint: InterfaceAccount<'info, Mint>,

    pub token_2022_program: Program<'info, Token2022>,
    pub system_program: Program<'info, System>,
    pub rent: Sysvar<'info, Rent>,
}

pub fn init_bet_mint(ctx: Context<InitBetMint>) -> Result<()> {
    let global = &mut ctx.accounts.global;
    global.bet_mint = ctx.accounts.bet_mint.key();
    
    msg!("$BET Token-2022 Mint initialized: {}", global.bet_mint);
    Ok(())
}
