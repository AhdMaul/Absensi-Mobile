import express from 'express';
import { register, login, whoAmI } from '../controllers/auth.controller.js';

const authRoutes = express.Router();

authRoutes.post('/register', register);
authRoutes.post('/login', login);
authRoutes.get('/who', whoAmI);

export default authRoutes;