import express from "express";
import { protect, authUser } from "../controllers/authController.js";
import {
  registerUser,
  loginUser,
  getFarmers,
  getFarmer,
} from "../controllers/userController.js";

const router = express.Router();

router.post("/register", registerUser);
router.post("/login", loginUser);
router.get("/", protect, getFarmers);
router.get("/:farmerId", getFarmer);
router.get("/auth/check", authUser);

export default router;
