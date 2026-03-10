import { TransactionInstruction, Keypair, PublicKey } from "@solana/web3.js";

export type GlobalSettingType = {
    creatorFeeAmount: number;
    marketCount: number;
    decimal: number;
    fundFeePercentage: number,
    bettingFeePercentage: number,
    poolFeePercentage: number,
    usdcMint: string;
    zkmeOracleKey: string;
};

export type CreateMarketType = {
    creator: string;
    marketID: string;
    tokenAmount: number;
    tokenPrice: number;
    nameA: string;
    nameB: string;
    symbolA: string;
    symbolB: string;
    urlA: string;
    urlB: string;
    quest: number;
    date: string;
    value: number;
    range: number;
    feed: Keypair;
    oracle: TransactionInstruction;
};

export type DepositeLiquidityType = {
    creator: string,
    investor: string,
    amount: number,
}

export type BetType = {
    creator: string,
    player: string,
    amount: number,
    isYes: boolean,
    token: string,
    signature?: number[]
}

export type OracleType = {
    market_id: string,
    feed: string
}

export type FeedUpdateType = {
    creator: string,
    url: string,
    task: string,
    name: string,
    feed: string,
    cluster: 'Devnet' | 'Mainnet'
}

export type WithdrawType = {
    signer: PublicKey,
    market_id: PublicKey,
    amount: number,
    reciever: PublicKey
}

export type SellType = {
    market_id: string,
    amount: number,
    isYes: boolean,
}

export interface MarketFilter {
    volumeMin?: number;
    volumeMax?: number;
    expiryStart?: string; // ISO date
    expiryEnd?: string;
    yesProbMin?: number;
    yesProbMax?: number;
    noProbMin?: number;
    noProbMax?: number;
}

export type MarketStatus =
    "INIT" |
    "PENDING" |
    "ACTIVE" |
    "CLOSED"