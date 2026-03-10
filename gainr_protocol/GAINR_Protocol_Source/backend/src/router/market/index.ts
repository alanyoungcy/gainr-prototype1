import { Router } from "express";
import { market } from "../../controller";
import { proposeValidator } from "../../middleware/proposeValidator";

import { requireWalletSignature } from "../../middleware/authSignature";

import { validateRequest } from "../../middleware/validateRequest";
import { createMarketSchema, bettingSchema, addLiquiditySchema } from "../../controller/market/schemas";

const router = Router();

router.post("/create", requireWalletSignature, validateRequest(createMarketSchema), proposeValidator, (req, res) => { market.create_market(req, res); });
router.post("/add", requireWalletSignature, (req, res) => { market.additionalInfo(req, res); });
router.post("/addLiquidity", requireWalletSignature, validateRequest(addLiquiditySchema), (req, res) => { market.addLiquidity(req, res); });
router.post("/betting", requireWalletSignature, validateRequest(bettingSchema), (req, res) => { market.betting(req, res); });
router.post("/liquidity", requireWalletSignature, validateRequest(addLiquiditySchema), (req, res) => { market.addLiquidity(req, res); });
router.get("/get", market.getMarketData);

export default router;