import { Request, Response, NextFunction } from 'express';
import nacl from 'tweetnacl';
import bs58 from 'bs58';

export function requireWalletSignature(req: Request, res: Response, next: NextFunction) {
    const walletAddress = req.headers['x-wallet-address'] as string;
    const signature = req.headers['x-wallet-signature'] as string;
    const timestamp = req.headers['x-wallet-timestamp'] as string;

    if (!walletAddress || !signature || !timestamp) {
        res.status(401).json({ error: 'Missing authentication headers' });
        return;
    }

    // Replay protection — reject if timestamp > 30 seconds old
    const now = Date.now();
    if (Math.abs(now - parseInt(timestamp)) > 30_000) {
        res.status(401).json({ error: 'Request expired' });
        return;
    }

    // Reconstruct the message the client signed
    const message = new TextEncoder().encode(
        `GAINR_AUTH:${timestamp}:${req.method}:${req.originalUrl}`
    );

    try {
        const publicKey = bs58.decode(walletAddress);
        const sig = bs58.decode(signature);
        const isValid = nacl.sign.detached.verify(message, sig, publicKey);

        if (!isValid) {
            res.status(401).json({ error: 'Invalid signature' });
            return;
        }

        (req as any).walletAddress = walletAddress;
        next();
    } catch (err) {
        res.status(401).json({ error: 'Authentication failed' });
        return;
    }
}
