import express from 'express';
import { verify } from '../controllers/face.controller.js';

const faceRoutes = express.Router();

faceRoutes.post('/verify', verify);

export default faceRoutes;


