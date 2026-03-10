import rateLimit from 'express-rate-limit';
import slowDown from 'express-slow-down';

export const apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per `window`
    standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
    legacyHeaders: false, // Disable the `X-RateLimit-*` headers
});

export const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 20,
});

export const speedLimiter = slowDown({
    windowMs: 15 * 60 * 1000,
    delayAfter: 50, // allow 50 requests per 15 minutes, then...
    delayMs: (hits) => (hits - 50) * 200, // begin adding 200ms of delay per request after 50
});
