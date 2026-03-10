import { z } from 'zod';

export const createMarketSchema = z.object({
    body: z.object({
        data: z.object({
            marketField: z.string(),
            apiType: z.string(),
            question: z.string(),
            task: z.string().nullable(),
            date: z.string(),
            value: z.number(),
            range: z.number(),
            imageUrl: z.string(),
            creator: z.string(),
            feedName: z.string(),
            description: z.string(),
        }),
    }),
});

export const bettingSchema = z.object({
    body: z.object({
        player: z.string(),
        market_id: z.string(),
        amount: z.number().positive(),
        isYes: z.boolean(),
        txSignature: z.string(),
    }),
});

export const addLiquiditySchema = z.object({
    body: z.object({
        market_id: z.string(),
        amount: z.number().positive(),
        investor: z.string(),
        active: z.boolean(),
    }),
});
