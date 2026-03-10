import mongoose, { Schema, Document } from "mongoose";

export interface IAuditLog extends Document {
    userAddress: string;
    action: string;
    detailsHash: string; // Encrypted or hashed details
    timestamp: Date;
}

const AuditLogSchema: Schema = new Schema({
    userAddress: { type: String, required: true, index: true },
    action: { type: String, required: true },
    detailsHash: { type: String, required: true },
    timestamp: { type: Date, default: Date.now }
});

export default mongoose.model<IAuditLog>("AuditLog", AuditLogSchema);
