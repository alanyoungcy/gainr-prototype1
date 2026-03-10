import { Request, Response } from "express";
import { ComplianceService } from "../../service/compliance";

export const logVerification = async (req: Request, res: Response) => {
    try {
        const { userAddress, verificationData } = req.body;
        if (!userAddress) {
            res.status(400).json({ error: "Missing userAddress" });
            return;
        }
        await ComplianceService.logVerification(userAddress, verificationData || {});
        res.status(200).json({ success: true });
    } catch (error) {
        console.error("Compliance log error:", error);
        res.status(500).json({ error: "Internal compliance error" });
    }
};

export const breakGlassAudit = async (req: Request, res: Response) => {
    try {
        const { authCode } = req.query;
        const logs = await ComplianceService.breakGlassAudit(authCode as string);
        res.status(200).json({ data: logs });
    } catch (error: any) {
        res.status(401).json({ error: error.message });
    }
};
