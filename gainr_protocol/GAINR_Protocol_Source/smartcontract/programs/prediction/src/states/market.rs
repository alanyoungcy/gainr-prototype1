use anchor_lang::prelude::*;

#[account]
#[derive(InitSpace, Debug)]
pub struct Market {
    pub creator: Pubkey,
    pub token_mint_a: Pubkey,
    pub token_mint_b: Pubkey,
    pub market_id: String,
    pub feed: Pubkey,
    pub value: u64,
    pub range: u64,
    pub token_price: u64,
    pub token_price_a: u64,
    pub token_price_b: u64,
    pub token_a_amount: u64,
    pub token_b_amount: u64,
    pub total_reserve: u64,
    pub yes_amount: u64,
    pub no_amount: u64,
    // AMM / CPMM Fields
    pub amm_bet_reserve: u64,    // amount of $BET held as collateral for this market
    pub yes_shares_supply: u64,  // total minted YES shares
    pub no_shares_supply: u64,   // total minted NO shares
    pub date: i64,
    pub market_status: MarketStatus,
    pub bump: u8,
}

#[derive(AnchorSerialize, AnchorDeserialize, Clone, Copy, PartialEq, Eq, Debug, InitSpace)]
pub enum MarketStatus {
    Prepare,
    Active,
    Finished,
}

impl Market {
    pub fn get_signer<'a>(bump: &'a u8, market_id: &'a [u8]) -> [&'a [u8]; 3] {
        [b"market_seed", market_id, std::slice::from_ref(bump)]
    }

    pub fn update_market_settings(
        &mut self,
        value: u64,
        range: u64,
        creator: Pubkey,
        feed: Pubkey,
        token_a: Pubkey,
        token_b: Pubkey,
        token_amount: u64,
        token_price: u64,
        date: i64,
    ) -> Result<()> {
        self.value = value;
        self.range = range;
        self.creator = creator;
        self.feed = feed;
        self.token_mint_a = token_a;
        self.token_mint_b = token_b;
        self.token_a_amount = token_amount;
        self.token_b_amount = token_amount;
        self.token_price_a = token_price;
        self.token_price_b = token_price;
        self.token_price = token_price;
        self.date = date;
        self.market_status = MarketStatus::Prepare;
        Ok(())
    }

    pub fn compute_prices(&mut self) -> Result<()> {
        let total_reserve = (self.token_a_amount as u128) + (self.token_b_amount as u128);
        if total_reserve > 0 {
            // Price in Basis Points (10,000 = 1.0)
            self.token_price_a = ((self.token_b_amount as u128 * 10_000) / total_reserve) as u64;
            self.token_price_b = 10_000 - self.token_price_a;
        }
        Ok(())
    }
}

#[derive(AnchorSerialize, AnchorDeserialize)]
pub struct MarketParams {
    pub value: u64,
    pub market_id: String,
    pub range: u64,
    pub token_amount: u64,
    pub token_price: u64,
    pub name_a: Option<String>,
    pub name_b: Option<String>,
    pub symbol_a: Option<String>,
    pub symbol_b: Option<String>,
    pub url_a: Option<String>,
    pub url_b: Option<String>,
    pub date: i64,
}

#[derive(AnchorSerialize, AnchorDeserialize)]
pub struct BettingParams {
    pub market_id: String,
    pub amount: u64,
    pub is_yes: bool,
    pub signature: [u8; 64],
}

#[derive(AnchorSerialize, AnchorDeserialize)]
pub struct SellParams {
    pub market_id: String,
    pub amount: u64,
    pub is_yes: bool,
}
