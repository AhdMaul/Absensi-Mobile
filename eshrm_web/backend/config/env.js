import { config } from "dotenv";

config({ path: `.env.${process.env.NODE_ENV || 'development'}.local` });
export const {
    SERVER_URL, FRONTEND_URL, LBPH_URL, PORT, NODE_ENV, 
    MONGO_URI, DATABASE_NAME,
    JWT_SECRET, JWT_EXPIRES_IN,
    REDIS_URL, REDIS_TOKEN,
} = process.env;
