import express from "express";
import {
  protect,
  authUser,
  restrictTo,
} from "../controllers/authController.js";
import {
  registerUser,
  loginUser,
  getFarmer,
  getUsers,
} from "../controllers/userController.js";

const router = express.Router();

router.post("/register", registerUser);
router.post("/login", loginUser);
router.get("/", protect, getUsers);
router.get("/:userId", getFarmer);
router.get("/auth/check", authUser);

export default router;
