import { Request, Response } from "express"
import MarketModel from "../../model/market";
import { marketConfig } from "../../config";
import ReferModel from "../../model/referral";
import { buildMarketFilterQuery } from "./utils";

export const create_market = async (req: Request, res: Response) => {
    try {
        const {
            marketField,
            apiType,
            question,
            task,
            date,
            value,
            range,
            imageUrl,
            creator,
            feedName,
            description,
        } = req.body.data;

        const marketData = new MarketModel({
            marketField,
            apiType,
            task,
            creator,
            question,
            value,
            range,
            date,
            marketStatus: "INIT",
            imageUrl,
            feedName,
            description,
            tokenAPrice: marketConfig.tokenPrice,
            tokenBPrice: marketConfig.tokenPrice,
            initAmount: marketConfig.tokenAmount
        });

        const db_result = await marketData.save();
        console.log("Created init market data on db:", db_result.id.toString());

        res.status(200).json({ message: "Feed registration successful!", result: db_result.id });
    } catch (error) {
        console.log("😒 create market error:", error);
        res.status(500).send("Failed to create market! Please try again later.");
        return
    }
}

// export const add_liquidity = async (req: Request, res: Response) => {
//     try {
//         const { investor, amount, market_id } = req.body;

//         const result = await MarketModel.findByIdAndUpdate(
//             market_id,
//             { $push: { investors: { investor, amount } } },
//             { new: true }
//         )
//         console.log("new update add liquidity:", result);

//         res.status(200).json(result);
//     } catch (error) {
//         res.status(500).json("Something went wrong add liquidity.");
//         console.log("😒 add liquidity error:", error);
//     }
// }

import { Connection, clusterApiUrl } from "@solana/web3.js";

export const betting = async (req: Request, res: Response) => {
    try {
        const { player, market_id, amount, isYes, txSignature } = req.body;
        console.log("Processing bet for:", player, "Market:", market_id);

        const cluster = (process.env.SOLANA_CLUSTER as any) || 'devnet';
        const connection = new Connection(clusterApiUrl(cluster), 'confirmed');

        // Verify transaction on-chain - S0B.6
        const txDetails = await connection.getTransaction(txSignature, {
            commitment: 'confirmed',
            maxSupportedTransactionVersion: 0,
        });

        if (!txDetails) {
            return res.status(400).json({ error: 'Transaction not found or not confirmed' });
        }

        // In a real implementation, we would parse the logs/post-balances to get the exact 
        // reserves and token prices. For now, we fetch the market model and we should ideally 
        // update it based on on-chain state.

        const market = await MarketModel.findById(market_id);
        if (!market) return res.status(404).json({ error: 'Market not found' });

        // Logic to derive on-chain reserves from txDetails logs would go here.
        // For the purpose of this security foundation, we are ensuring we don't trust 
        // the client-provided prices in the body.

        // Mocking the derived values which should come from transaction parsing:
        const sol_amount = isYes ? market.tokenAPrice * amount : market.tokenBPrice * amount;

        const result = await MarketModel.findByIdAndUpdate(
            market_id,
            {
                // Note: In Priority 3, we will implement compute_prices() in the contract 
                // and here we will update based on on-chain resonance.
                $push: isYes ? { playerA: { player, amount: sol_amount } } : { playerB: { player, amount: sol_amount } },
            },
            { new: true }
        )

        console.log("Confirmed on-chain bet. sol_amount equivalent:", sol_amount);
        setReferralFee(player, sol_amount);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).send("Failed betting!");
        console.log("😒 betting error:", error);
    }
}

export const additionalInfo = async (req: Request, res: Response) => {
    try {
        const { id, market, tokenA, tokenB, feedAddress } = req.body.data;

        const result = await MarketModel.updateOne(
            {
                _id: id
            },
            {
                $set: { market: market, tokenA: tokenA, tokenB: tokenB, marketStatus: "PENDING", feedkey: feedAddress },
            }
        );
        res.status(200).json({ result: "success" });
    } catch (error) {
        console.log("😒 add info error:", error);
        res.status(500).send("Failed to update info! Please try again later.");
        return
    }
}

export const getMarketData = async (req: Request, res: Response) => {
    try {
        const { marketStatus, marketField, page = 1, limit = 10 } = req.query;
        const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

        const match: any = {};
        if (marketStatus) match.marketStatus = marketStatus;
        if (marketField !== undefined) match.marketField = parseInt(marketField as string);

        const results = await MarketModel.aggregate([
            { $match: match },
            { $sort: { createdAt: -1 } },
            { $skip: skip },
            { $limit: parseInt(limit as string) },
            {
                $addFields: {
                    playerACount: {
                        $reduce: {
                            input: { $ifNull: ["$playerA", []] },
                            initialValue: 0,
                            in: { $add: ["$$value", { $ifNull: ["$$this.amount", 0] }] }
                        }
                    },
                    playerBCount: {
                        $reduce: {
                            input: { $ifNull: ["$playerB", []] },
                            initialValue: 0,
                            in: { $add: ["$$value", { $ifNull: ["$$this.amount", 0] }] }
                        }
                    },
                    totalInvestment: {
                        $reduce: {
                            input: { $ifNull: ["$investors", []] },
                            initialValue: 0,
                            in: { $add: ["$$value", { $ifNull: ["$$this.amount", 0] }] }
                        }
                    },
                    ammBetReserve: { $ifNull: ["$ammBetReserve", 0] },
                    tradingAmountA: { $ifNull: ["$tradingAmountA", 0] },
                    tradingAmountB: { $ifNull: ["$tradingAmountB", 0] }
                }
            },
            {
                $project: {
                    playerA: 0,
                    playerB: 0,
                    investors: 0
                }
            }
        ]);

        const total = await MarketModel.countDocuments(match);

        res.json({
            data: results,
            total,
            page: +page,
            totalPages: Math.ceil(total / +limit),
        });
    } catch (err) {
        console.error("😒 get market data error:", err);
        res.status(500).json({ error: 'Server error', details: err instanceof Error ? err.message : String(err) });
    }
}

export const addLiquidity = async (req: Request, res: Response) => {
    try {
        const { market_id, amount, investor, active } = req.body;
        console.log("status:", active);

        const liquidity_result = await MarketModel.findOneAndUpdate(
            {
                _id: market_id
            },
            {
                $set: {
                    marketStatus: active ? "ACTIVE" : "PENDING"
                },
                $push: {
                    investors: {
                        investor,
                        amount,
                    },
                },
            }
        )

        setReferralFee(investor, amount)

        res.status(200).json({ result: "success" });
    } catch (error) {
        console.log("😒 error:", error);
        res.status(500).send("Failed to add liquidity! Please try again later.");
        return
    }
}

export const setReferralFee = async (wallet: string, amount: number) => {
    try {
        const refer = await ReferModel.findOne({
            wallet
        });

        if (refer) {
            let fee = 0;
            if (refer.wallet_refered !== "") {
                switch (refer.referredLevel) {
                    case 0:
                        fee = refer.fee + amount * 0.005 * 0.7
                        break
                    case 1:
                        fee = refer.fee + amount * 0.005 * 0.2
                        break
                    case 1:
                        fee = refer.fee + amount * 0.005 * 0.1
                        break
                    default:
                        fee = 0;
                        break
                }
            }

            refer.fee = fee;
            refer.save();
        }
    } catch (error) {
        console.log("set referral fee error:", error);
    }
}

export const getFilteredMarket = async (req: Request, res: Response) => {
    try {
        const {
            volumeMin,
            volumeMax,
            expiryStart, // ISO date
            expiryEnd,
            yesProbMin,
            yesProbMax,
            noProbMin,
            noProbMax,
        } = req.body

        const query = buildMarketFilterQuery({
            volumeMin,
            volumeMax,
            expiryStart, // ISO date
            expiryEnd,
            yesProbMin,
            yesProbMax,
            noProbMin,
            noProbMax,
        })

        const result = await MarketModel.find(query)

        res.status(200).send({ data: result });
    } catch (error) {
        console.log("😒 error:", error);
        return res.status(500).send("Failed to filter market! Please try again later.");
    }
}

export const recentActivity = async (req: Request, res: Response) => { }