import express from 'express';
import connectDB from './config/db.js';
import { PORT } from './config/env.js';
import appMiddleware from './middleware/middleware.js';
import faceRoutes from './routes/face.routes.js';
import authRoutes from './routes/auth.routes.js';

const app = express();
const port = PORT || 5000;

appMiddleware(app);

app.use('/api', faceRoutes);
app.use('/api/auth', authRoutes);
app.get('/', (req, res) => {
    res.send('Express is running...');
});

app.listen(port, async () => {
    await connectDB();
    console.log(`🚀 Server berjalan di http://localhost:${port}`);
});
