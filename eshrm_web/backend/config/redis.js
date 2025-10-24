import { createClient } from 'redis';
import { REDIS_URL, REDIS_TOKEN } from '../config/env.js';


const redisClient = createClient({
    url: `rediss://default:${REDIS_TOKEN}@${REDIS_URL}`,
    socket: { tls: true, rejectUnauthorized: false }
});

export default redisClient;
