import mongoose from "mongoose";
import { MONGO_URI, DATABASE_NAME } from "./env.js";

async function connectDB() {
    try {
        await mongoose.connect(MONGO_URI, {
            dbName: DATABASE_NAME,
        });

        console.log(`Connected to MongoDB | DataBase : ${DATABASE_NAME}`);
    } catch (err) {
        console.error("MongoDB Connection Failed:", err);
        process.exit(1);
    }
}

export default connectDB;
