import express from "express";
import { protect, restrictTo } from "../controllers/authController.js";
import {
  acceptOrRejectRequest,
  getBuyRequestsCustomer,
  getBuyRequestsFarmer,
  getCustomerNotifications,
  getFarmerNotifications,
  markAsSeen,
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

router.get(
  "/getCustomerNotifications",
  protect,
  restrictTo("customer"),
  getCustomerNotifications
);

router.get(
  "/getFarmerNotifications",
  protect,
  restrictTo("farmer"),
  getFarmerNotifications
);

router.patch(
  "/updateStatus/:buyRequestId",
  protect,
  restrictTo("farmer"),
  acceptOrRejectRequest
);

router.patch(
  "/markAsSeen/:buyRequestId",
  protect,
  restrictTo("farmer", "customer"),
  markAsSeen
);

export default router;
