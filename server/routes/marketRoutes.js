import express from "express";
import { nearByPrices } from "../controllers/marketController.js";

const router = express.Router();

router.get("/predict-price", nearByPrices);

export default router;
