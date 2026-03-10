import web3, { PublicKey, TransactionMessage, AddressLookupTableProgram, TransactionInstruction, SystemProgram } from "@solana/web3.js";
import * as anchor from "@project-serum/anchor";
import { PullFeed, getDefaultDevnetQueue, asV0Tx } from "@switchboard-xyz/on-demand";
import { CrossbarClient } from "@switchboard-xyz/common";
import { auth } from "../config";
import {
  PREDICTION_ID,
  GLOBAL_SEED,
} from "./constants";
import { GlobalSettingType, WithdrawType, OracleType, FeedUpdateType } from "../type";
import { VersionedTransaction } from "@solana/web3.js";

import { IDL } from "./idl/idl";
import { BN } from 'bn.js';

let solConnection: web3.Connection;
let provider: anchor.Provider;
let program: anchor.Program;
let globalPDA: PublicKey;
let feeAuthority: string;

export const setClusterConfig = async (cluster: web3.Cluster, rpc?: string) => {
  if (!rpc) {
    solConnection = new web3.Connection(web3.clusterApiUrl(cluster));
  } else {
    solConnection = new web3.Connection(rpc);
  }

  anchor.setProvider(
    new anchor.AnchorProvider(solConnection, auth, {
      skipPreflight: true,
      commitment: "confirmed",
    })
  );

  provider = anchor.getProvider();
  program = new anchor.Program(IDL as anchor.Idl, PREDICTION_ID);
  feeAuthority = process.env.FEE_AUTHORITY || "";

  globalPDA = PublicKey.findProgramAddressSync(
    [Buffer.from(GLOBAL_SEED)],
    PREDICTION_ID
  )[0];
};

export const global = async (param: GlobalSettingType) => {
  try {
    const globalInfo = await solConnection.getAccountInfo(globalPDA);
    if (globalInfo) {
      return { new: false, globalPDA };
    }

    const tx = await program.methods
      .initialize({
        feeAuthority: new PublicKey(feeAuthority),
        usdcMint: new PublicKey(param.usdcMint), // Added usdcMint
        creatorFeeAmount: new BN(param.creatorFeeAmount),
        marketCount: new BN(param.marketCount),
        decimal: param.decimal,
        fundFeePercentage: param.fundFeePercentage,
        bettingFeePercentage: param.bettingFeePercentage,
        poolFeePercentage: param.poolFeePercentage,
        zkmeOracleKey: new PublicKey(param.zkmeOracleKey),
      })
      .accounts({
        global: globalPDA,
        payer: auth.publicKey,
        systemProgram: web3.SystemProgram.programId,
      })
      .instruction();
    const creatTx = new web3.Transaction();
    creatTx.add(tx);
    creatTx.recentBlockhash = (await solConnection.getLatestBlockhash()).blockhash;
    creatTx.feePayer = auth.publicKey;

    const sig = await solConnection.sendTransaction(creatTx, [auth.payer], { skipPreflight: true });
    await solConnection.confirmTransaction(sig, "confirmed");
    return { new: true, globalPDA };
  } catch (error) {
    return null;
  }
};

export const depositUsdc = async (amount: number) => {
  const betMint = PublicKey.findProgramAddressSync([Buffer.from("bet_mint_seed")], PREDICTION_ID)[0];
  const globalData = await program.account.global.fetch(globalPDA);
  const userUsdc = await anchor.utils.token.associatedAddress({ mint: (globalData as any).usdcMint, owner: auth.publicKey });
  const vaultUsdc = await anchor.utils.token.associatedAddress({ mint: (globalData as any).usdcMint, owner: (globalPDA as any) });
  const userBet = await anchor.utils.token.associatedAddress({ mint: betMint, owner: auth.publicKey });

  return await program.methods.depositUsdc(new BN(amount))
    .accounts({
      user: auth.publicKey,
      global: globalPDA,
      usdcMint: (globalData as any).usdcMint,
      betMint: betMint,
      userUsdc: userUsdc,
      vaultUsdc: vaultUsdc,
      userBet: userBet,
      tokenProgram: anchor.utils.token.TOKEN_PROGRAM_ID,
      token2022Program: new PublicKey("TokenzQdBNbmeEkvY6Cc44LEnDUuzSshYJpR3VL"),
      associatedTokenProgram: anchor.utils.token.ASSOCIATED_PROGRAM_ID,
      systemProgram: SystemProgram.programId,
    })
    .instruction();
};

export const withdrawUsdc = async (amount: number) => {
  const betMint = PublicKey.findProgramAddressSync([Buffer.from("bet_mint_seed")], PREDICTION_ID)[0];
  const globalData = await program.account.global.fetch(globalPDA);
  const userBet = await anchor.utils.token.associatedAddress({ mint: betMint, owner: auth.publicKey });
  const vaultUsdc = await anchor.utils.token.associatedAddress({ mint: (globalData as any).usdcMint, owner: (globalPDA as any) });
  const userUsdc = await anchor.utils.token.associatedAddress({ mint: (globalData as any).usdcMint, owner: auth.publicKey });

  return await program.methods.withdrawUsdc(new BN(amount))
    .accounts({
      user: auth.publicKey,
      global: globalPDA,
      usdcMint: (globalData as any).usdcMint,
      betMint: betMint,
      userBet: userBet,
      vaultUsdc: vaultUsdc,
      userUsdc: userUsdc,
      tokenProgram: anchor.utils.token.TOKEN_PROGRAM_ID,
      token2022Program: new PublicKey("TokenzQdBNbmeEkvY6Cc44LEnDUuzSshYJpR3VL"),
      systemProgram: SystemProgram.programId,
    })
    .instruction();
};

export const depositLiquidity = async (marketId: string, amount: number) => {
  const marketAddress = PublicKey.findProgramAddressSync(
    [Buffer.from("market_seed"), Buffer.from(marketId)],
    PREDICTION_ID
  )[0];
  const betMint = PublicKey.findProgramAddressSync([Buffer.from("bet_mint_seed")], PREDICTION_ID)[0];
  const shareMintA = PublicKey.findProgramAddressSync([Buffer.from("mint_a_seed"), marketAddress.toBuffer()], PREDICTION_ID)[0];
  const shareMintB = PublicKey.findProgramAddressSync([Buffer.from("mint_b_seed"), marketAddress.toBuffer()], PREDICTION_ID)[0];

  const userBetAta = await anchor.utils.token.associatedAddress({ mint: betMint, owner: auth.publicKey });
  const marketBetVault = await anchor.utils.token.associatedAddress({ mint: betMint, owner: marketAddress });
  const marketAtaA = await anchor.utils.token.associatedAddress({ mint: shareMintA, owner: marketAddress });
  const marketAtaB = await anchor.utils.token.associatedAddress({ mint: shareMintB, owner: marketAddress });

  return await (program.methods as any).addLiquidity(new BN(amount))
    .accounts({
      user: auth.publicKey,
      global: globalPDA,
      market: marketAddress,
      betMint,
      userBetAta,
      marketBetVault,
      shareMintA,
      shareMintB,
      marketAtaA,
      marketAtaB,
      feeAuthority: new PublicKey(feeAuthority),
      tokenProgram: anchor.utils.token.TOKEN_PROGRAM_ID,
      associatedTokenProgram: anchor.utils.token.ASSOCIATED_PROGRAM_ID,
      systemProgram: SystemProgram.programId,
    })
    .instruction();
};

export const createBet = async (marketId: string, amount: number, isYes: boolean, signature: number[]) => {
  const marketAddress = PublicKey.findProgramAddressSync(
    [Buffer.from("market_seed"), Buffer.from(marketId)],
    PREDICTION_ID
  )[0];
  const betMint = PublicKey.findProgramAddressSync([Buffer.from("bet_mint_seed")], PREDICTION_ID)[0];
  const shareMintA = PublicKey.findProgramAddressSync([Buffer.from("mint_a_seed"), marketAddress.toBuffer()], PREDICTION_ID)[0];
  const shareMintB = PublicKey.findProgramAddressSync([Buffer.from("mint_b_seed"), marketAddress.toBuffer()], PREDICTION_ID)[0];

  const userBetAta = await anchor.utils.token.associatedAddress({ mint: betMint, owner: auth.publicKey });
  const marketBetVault = await anchor.utils.token.associatedAddress({ mint: betMint, owner: marketAddress });
  const marketAtaA = await anchor.utils.token.associatedAddress({ mint: shareMintA, owner: marketAddress });
  const marketAtaB = await anchor.utils.token.associatedAddress({ mint: shareMintB, owner: marketAddress });
  const userAtaA = await anchor.utils.token.associatedAddress({ mint: shareMintA, owner: auth.publicKey });
  const userAtaB = await anchor.utils.token.associatedAddress({ mint: shareMintB, owner: auth.publicKey });

  return await (program.methods as any).createBet({
    marketId,
    time: new BN(Math.floor(Date.now() / 1000)),
    amount: new BN(amount),
    isYes,
    signature,
  })
    .accounts({
      user: auth.publicKey,
      global: globalPDA,
      market: marketAddress,
      betMint,
      userBetAta,
      marketBetVault,
      shareMintA,
      shareMintB,
      marketAtaA,
      marketAtaB,
      userAtaA,
      userAtaB,
      feeAuthority: new PublicKey(feeAuthority),
      tokenProgram: anchor.utils.token.TOKEN_PROGRAM_ID,
      associatedTokenProgram: anchor.utils.token.ASSOCIATED_PROGRAM_ID,
      systemProgram: SystemProgram.programId,
    })
    .instruction();
};

export const sellShares = async (marketId: string, amount: number, isYes: boolean) => {
  const marketAddress = PublicKey.findProgramAddressSync(
    [Buffer.from("market_seed"), Buffer.from(marketId)],
    PREDICTION_ID
  )[0];
  const betMint = PublicKey.findProgramAddressSync([Buffer.from("bet_mint_seed")], PREDICTION_ID)[0];
  const shareMintA = PublicKey.findProgramAddressSync([Buffer.from("mint_a_seed"), marketAddress.toBuffer()], PREDICTION_ID)[0];
  const shareMintB = PublicKey.findProgramAddressSync([Buffer.from("mint_b_seed"), marketAddress.toBuffer()], PREDICTION_ID)[0];

  const userBetAta = await anchor.utils.token.associatedAddress({ mint: betMint, owner: auth.publicKey });
  const marketBetVault = await anchor.utils.token.associatedAddress({ mint: betMint, owner: marketAddress });
  const marketAtaA = await anchor.utils.token.associatedAddress({ mint: shareMintA, owner: marketAddress });
  const marketAtaB = await anchor.utils.token.associatedAddress({ mint: shareMintB, owner: marketAddress });
  const userShareAta = await anchor.utils.token.associatedAddress({ mint: isYes ? shareMintA : shareMintB, owner: auth.publicKey });

  return await (program.methods as any).sellShares({
    marketId,
    amount: new BN(amount),
    isYes
  })
    .accounts({
      user: auth.publicKey,
      global: globalPDA,
      market: marketAddress,
      betMint,
      userBetAta,
      marketBetVault,
      shareMintA,
      shareMintB,
      marketAtaA,
      marketAtaB,
      userShareAta,
      tokenProgram: anchor.utils.token.TOKEN_PROGRAM_ID,
      associatedTokenProgram: anchor.utils.token.ASSOCIATED_PROGRAM_ID,
      systemProgram: SystemProgram.programId,
    })
    .instruction();
};

export const claimFee = async (address: String, amount: number) => {
  try {
    const claimPubkey = new PublicKey(address);
    const transferIx = SystemProgram.transfer({
      fromPubkey: auth.publicKey,
      toPubkey: claimPubkey,
      lamports: Math.floor(amount),
    });

    let latestBlockHash = await provider.connection.getLatestBlockhash(provider.connection.commitment);
    const lutMsg1 = new TransactionMessage({
      payerKey: auth.publicKey,
      recentBlockhash: latestBlockHash.blockhash,
      instructions: [transferIx]
    }).compileToV0Message();

    const lutVTx1 = new VersionedTransaction(lutMsg1);
    lutVTx1.sign([auth.payer]);
    const lutId1 = await provider.connection.sendTransaction(lutVTx1);
    await provider.connection.confirmTransaction(lutId1 as any, 'finalized');
  } catch (error) { }
};

export const withdraw = async (param: WithdrawType) => {
  return await program.methods.withdraw(new BN(param.amount))
    .accounts({
      admin: auth.publicKey,
      reciever: param.reciever,
      global: globalPDA,
      market: param.market_id,
      systemProgram: SystemProgram.programId,
    })
    .instruction();
}

export const buildVT = async (list: TransactionInstruction[]) => {
  const result: TransactionInstruction[][] = [];
  for (let i = 0; i < list.length; i += 20) {
    result.push(list.slice(i, i + 20));
  }

  for (let index = 0; index < result.length; index++) {
    const chunk = result[index];
    let latestBlockHash = await provider.connection.getLatestBlockhash(provider.connection.commitment);
    const addressesMain: PublicKey[] = [];
    chunk.forEach((ixn) => {
      ixn.keys.forEach((key) => {
        addressesMain.push(key.pubkey);
      });
    });

    const slot = await provider.connection.getSlot();
    const [lookupTableInst, lookupTableAddress] = AddressLookupTableProgram.createLookupTable({
      authority: auth.publicKey,
      payer: auth.publicKey,
      recentSlot: slot - 200,
    });

    const addAddressesInstruction1 = AddressLookupTableProgram.extendLookupTable({
      payer: auth.publicKey,
      authority: auth.publicKey,
      lookupTable: lookupTableAddress,
      addresses: addressesMain.slice(0, 30)
    });

    const lutMsg1 = new TransactionMessage({
      payerKey: auth.publicKey,
      recentBlockhash: latestBlockHash.blockhash,
      instructions: [lookupTableInst, addAddressesInstruction1]
    }).compileToV0Message();

    const lutVTx1 = new VersionedTransaction(lutMsg1);
    lutVTx1.sign([auth.payer]);
    const lutId1 = await provider.connection.sendTransaction(lutVTx1);
    await provider.connection.confirmTransaction(lutId1, 'finalized');

    await sleep(2000);
    const lookupTableAccount = await provider.connection.getAddressLookupTable(lookupTableAddress, { commitment: 'finalized' });

    const messageV0 = new TransactionMessage({
      payerKey: auth.publicKey,
      recentBlockhash: latestBlockHash.blockhash,
      instructions: chunk,
    }).compileToV0Message([lookupTableAccount.value!]);

    const vtx = new VersionedTransaction(messageV0);
    vtx.sign([auth.payer]);
    const createV0Tx = await solConnection.sendTransaction(vtx);
    await solConnection.confirmTransaction(createV0Tx, 'finalized');
  }
};

export const getOracleResult = async (params: OracleType) => {
  const res_instruction = await program.methods.getRes().accounts({
    user: auth.publicKey,
    market: new PublicKey(params.market_id),
    global: globalPDA,
    feed: new PublicKey("EzXYYhb6K5JyPGLiBChL2e84gHWoWfXCjM6iujKCgyAY"),
    systemProgram: SystemProgram.programId,
  }).instruction();

  const udpateFeedData = await udpateFeed(params.feed);
  if (!udpateFeedData.pullIx) return;

  const tx = await asV0Tx({
    connection: solConnection,
    ixs: [...udpateFeedData.pullIx, res_instruction],
    signers: [auth.payer],
    computeUnitPrice: 200_000,
    computeUnitLimitMultiple: 1.3,
    lookupTables: udpateFeedData.luts,
  });

  const info: any = await program.account.market.fetch(new PublicKey(params.market_id), "confirmed");
  console.log("market info:", info.result);
};

export const udpateFeed = async (feedKey: String) => {
  let queue = await getDefaultDevnetQueue("https://api.devnet.solana.com");
  const feedAccount = new PullFeed(queue.program, "4ZM78DGSfS8AtZ3UKGyfKN6vw7ZJSpRueYE6kPLbKsTK");
  const crossbar = CrossbarClient.default();

  const [pullIx, responses, success, luts] = await feedAccount.fetchUpdateIx({
    crossbarClient: crossbar,
    gateway: "",
    chain: "solana"
  }, false, auth.publicKey);

  return { pullIx, luts };
};

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}