import express from 'express';
import cors from 'cors';
import session from 'express-session';
import { FRONTEND_URL, SERVER_URL, LBPH_URL } from '../config/env.js';
import { RedisStore } from 'connect-redis';
import redisClient from '../config/redis.js';


(async () => {
    try {
        await redisClient.connect();
        console.log("✅ Redis Connected!");
    } catch (err) {
        console.error("❌ Connection Redis Failed:", err);
    }
})();

export default (app) => {
    app.use(express.json({ limit: '50mb' }));
    app.use(express.urlencoded({ extended: true, limit: '50mb' }));
    app.use(express.static("public"));
    app.use(cors({
        origin: [FRONTEND_URL, SERVER_URL, LBPH_URL],
        methods: ["GET", "POST", "PUT", "DELETE"],
        credentials: true,
    }));
    app.use(
        session({
            store: new RedisStore({ client: redisClient }),
            secret: 'supersecretkey.com.aja.id',
            resave: false,
            saveUninitialized: false,
            cookie: {
                secure: true, // set true jika https
                httpOnly: true,
                maxAge: 1000 * 60 * 60 * 24,
            }
        })
    );
};
