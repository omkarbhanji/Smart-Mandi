import { Farmer } from "../model/index.js";
import { asyncHandler } from "../middlewares/asyncHandler.js";
import { AppError } from "../utils/appError.js";
// Register user
export const registerUser = asyncHandler(async (req, res, next) => {
  const { name, email, password, phone, location, state, latitude, longitude } =
    req.body;

  await Farmer.create({
    name,
    email,
    password,
    phone,
    location,
    state,
    latitude,
    longitude,
  });

  return res.status(201).json({ message: "User created successfully" });
});

// Login user
export const loginUser = asyncHandler(async (req, res, next) => {
  const { email, password } = req.body;

  const farmer = await Farmer.findOne({ where: { email } });

  if (!farmer) {
    return next(new AppError("User not found!", 400));
  }

  if (farmer.password !== password) {
    return next(
      new AppError("Invalid credentials, password didn't match", 401)
    );
  }

  return res.status(200).json({ message: "Login success" });
});
