import {
    CrossbarClient,
} from "@switchboard-xyz/common";
import {
    PullFeed,
    getDefaultQueue,
    asV0Tx,
    ON_DEMAND_DEVNET_PID
} from "@switchboard-xyz/on-demand";

import { FeedUpdateType } from "../type";
import { PublicKey } from "@solana/web3.js";
import { Program, AnchorProvider } from "@coral-xyz/anchor";
import { auth } from "../config";

export const udpateFeed = async (param: FeedUpdateType) => {
    const connection = new PublicKey("https://api.devnet.solana.com"); // Placeholder or use config
    const provider = AnchorProvider.env(); // Or proper initialization
    const sbProgram = await Program.at(ON_DEMAND_DEVNET_PID, provider as any) as any;
    const feed = new PublicKey(param.feed);
    const feedAccount = new PullFeed(sbProgram, feed);
    // Get the queue for the network you're deploying on
    let queue = await getDefaultQueue("https://api.devnet.solana.com");

    // Get the crossbar server client
    const crossbarClient = CrossbarClient.default();
} 