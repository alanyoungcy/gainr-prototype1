import AuditLog from "../model/auditLog";
import crypto from "crypto";

export class ComplianceService {
    // In production, this key should be managed by a HSM or KMS
    private static ENCRYPTION_KEY = Buffer.alloc(32, (process.env.COMPLIANCE_KEY || "gainr_compliance_key_2026_id_layer").substring(0, 32));

    static async logVerification(userAddress: string, data: any) {
        const details = JSON.stringify(data);
        const iv = crypto.randomBytes(16);
        const cipher = crypto.createCipheriv("aes-256-cbc", this.ENCRYPTION_KEY, iv);
        let encrypted = cipher.update(details, "utf8", "hex");
        encrypted += cipher.final("hex");

        const log = new AuditLog({
            userAddress,
            action: "ZKME_VERIFICATION",
            detailsHash: `${iv.toString("hex")}:${encrypted}`,
            timestamp: new Date()
        });

        await log.save();
        console.log(`[Compliance] Securely logged verification for ${userAddress}`);
    }

    static async breakGlassAudit(authCode: string) {
        const MASTER_CODE = process.env.BREAK_GLASS_CODE;
        if (!MASTER_CODE) {
            throw new Error("FATAL: BREAK_GLASS_CODE environment variable is required");
        }

        const codeBuffer = Buffer.from(authCode);
        const masterBuffer = Buffer.from(MASTER_CODE);

        if (codeBuffer.length !== masterBuffer.length ||
            !crypto.timingSafeEqual(codeBuffer, masterBuffer)) {
            throw new Error("Unauthorized access to PII enclave");
        }

        const logs = await AuditLog.find().sort({ timestamp: -1 });
        return logs.map((log: any) => {
            const [ivHex, encrypted] = log.detailsHash.split(":");
            const decipher = crypto.createDecipheriv("aes-256-cbc", this.ENCRYPTION_KEY, Buffer.from(ivHex, "hex"));
            let decrypted = decipher.update(encrypted, "hex", "utf8");
            decrypted += decipher.final("utf8");
            return {
                ...log.toObject(),
                decryptedDetails: JSON.parse(decrypted)
            };
        });
    }
}
