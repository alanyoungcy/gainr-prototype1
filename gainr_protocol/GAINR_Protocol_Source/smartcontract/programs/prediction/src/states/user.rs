use anchor_lang::prelude::*;

#[account]
#[derive(InitSpace)]
pub struct UserVerification {
    pub user: Pubkey,
    pub is_verified: bool,
    pub timestamp: i64,
}
