use crate::constants::VERIFY_SEED;
use crate::states::user::*;
use anchor_lang::prelude::*;

#[derive(Accounts)]
pub struct ZkMeVerify<'info> {
    #[account(mut)]
    pub user: Signer<'info>,

    #[account(
        init_if_needed,
        payer = user,
        space = 8 + UserVerification::INIT_SPACE,
        seeds = [VERIFY_SEED.as_bytes(), user.key().as_ref()],
        bump
    )]
    pub user_verify: Account<'info, UserVerification>,

    pub system_program: Program<'info, System>,
}

pub fn zkme_verify(ctx: Context<ZkMeVerify>, is_verified: bool) -> Result<()> {
    let user_verify = &mut ctx.accounts.user_verify;
    user_verify.user = ctx.accounts.user.key();
    user_verify.is_verified = is_verified;
    user_verify.timestamp = Clock::get()?.unix_timestamp;

    msg!("User {} verification status updated: {}", user_verify.user, is_verified);
    Ok(())
}
