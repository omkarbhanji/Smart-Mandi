import express from "express";
import { protect, restrictTo } from "../controllers/authController.js";
import {
  acceptOrRejectRequest,
  getBuyRequestsCustomer,
  getBuyRequestsFarmer,
  sendBuyRequest,
} from "../controllers/buyRequestController.js";

const router = express.Router();

router.post("/", protect, restrictTo("customer"), sendBuyRequest);
router.get(
  "/getForFarmer",
  protect,
  restrictTo("farmer"),
  getBuyRequestsFarmer
);

router.get(
  "/getForCustomer",
  protect,
  restrictTo("customer"),
  getBuyRequestsCustomer
);

router.patch(
  "/updateStatus/:buyRequestId",
  protect,
  restrictTo("farmer"),
  acceptOrRejectRequest
);

export default router;
