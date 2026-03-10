import { Router } from "express";
import { logVerification, breakGlassAudit } from "../controller/compliance";

const router = Router();
router.post("/verify", logVerification);
router.get("/audit", breakGlassAudit);

export default router;
