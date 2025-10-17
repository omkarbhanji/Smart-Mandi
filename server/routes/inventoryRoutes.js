import express from "express";
import {
  addNewCrop,
  deleteItemFromInventory,
  getAllInventory,
  itemForSell,
  updateStatus,
} from "../controllers/inventoryController.js";
import { addNewSales } from "../controllers/salesController.js";
import { protect, restrictTo } from "../controllers/authController.js";

const router = express.Router();

// inventory routes
router.get("/", protect, getAllInventory);
router.post("/", protect, restrictTo("farmer"), addNewCrop);
router.delete(
  "/:inventoryId",
  protect,
  restrictTo("farmer"),
  deleteItemFromInventory
);
router.patch(
  "/updateStatus/:inventoryId",
  protect,
  restrictTo("farmer"),
  updateStatus
);
router.get("/forSell", protect, itemForSell);

//sales routes
router.post("/:id/sales", addNewSales);

export default router;
