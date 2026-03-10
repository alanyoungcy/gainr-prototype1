use anchor_lang::prelude::*;
pub mod constants;
pub mod errors;
pub mod events;
pub mod instructions;
pub mod states;
pub mod utils;

use instructions::{
    betting::*, create_market::*, deposite_liquidity::*, deposit_usdc::*, withdraw_usdc::*, get_oracle_res::*, init::*, init_bet_mint::*, token_mint::*, sell_shares::*, zkme_verify::*,
};
use states::{
    global::GlobalParams,
    market::{BettingParams, MarketParams},
};

declare_id!("Bki3CWk4AmVF78zvh81rup2EK2iJY4WRCUXesAv8TECF");

#[program]
pub mod prediction {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>, params: GlobalParams) -> Result<()> {
        init(ctx, params)
    }

    pub fn get_res(ctx: Context<GetOracleRes>) -> Result<()> {
        get_oracle_res(ctx)
    }

    pub fn init_market(ctx: Context<CreateMarket>, params: MarketParams) -> Result<()> {
        CreateMarket::create_market(ctx, params)
    }

    pub fn add_liquidity(ctx: Context<DepositLiquidity>, amount: u64) -> Result<()> {
        deposit_liquidity(ctx, amount)
    }

    pub fn create_bet(ctx: Context<Betting>, params: BettingParams) -> Result<()> {
        Betting::betting(ctx, params)
    }

    pub fn mint_token(ctx: Context<TokenMint>, market_id: String) -> Result<()> {
        TokenMint::token_mint(ctx, market_id)
    }

    pub fn init_bet_mint(ctx: Context<InitBetMint>) -> Result<()> {
        instructions::init_bet_mint::init_bet_mint(ctx)
    }

    pub fn deposit_usdc(ctx: Context<DepositUsdc>, amount: u64) -> Result<()> {
        instructions::deposit_usdc::deposit_usdc(ctx, amount)
    }

    pub fn withdraw_usdc(ctx: Context<WithdrawUsdc>, amount: u64) -> Result<()> {
        instructions::withdraw_usdc::withdraw_usdc(ctx, amount)
    }

    pub fn sell_shares(ctx: Context<SellShares>, params: SellParams) -> Result<()> {
        instructions::sell_shares::sell_shares(ctx, params)
    }

    pub fn zkme_verify(ctx: Context<ZkMeVerify>, is_verified: bool) -> Result<()> {
        instructions::zkme_verify::zkme_verify(ctx, is_verified)
    }

}
