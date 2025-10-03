import bcrypt from "bcrypt";
import { Farmer } from "../model/index.js";
import { asyncHandler } from "../middlewares/asyncHandler.js";
import { AppError } from "../utils/appError.js";
import { sendToken } from "../utils/jwtTokenSend.js";

// Register user
export const registerUser = asyncHandler(async (req, res, next) => {
  const { name, email, password, phone, location, state, latitude, longitude } =
    req.body;

  const farmer = await Farmer.create({
    name,
    email,
    password,
    phone,
    location,
    state,
    latitude,
    longitude,
  });

  sendToken(farmer, 201, res);
});

// Login user
export const loginUser = asyncHandler(async (req, res, next) => {
  const { email, password } = req.body;

  if (!email.trim() || !password.trim()) {
    return next(new AppError("Please enter email and password", 400));
  }

  const farmer = await Farmer.findOne({
    where: { email },
    attributes: { include: ["password"] },
    raw: true,
  });

  if (!farmer) {
    return next(new AppError("Incorrect email or password", 401));
  }

  const isPasswordCorrect = await bcrypt.compare(password, farmer.password);

  if (!isPasswordCorrect) {
    return next(new AppError("Incorrect email or password", 401));
  }

  sendToken(farmer, 200, res);
});

export const getFarmers = asyncHandler(async (req, res, next) => {
  const farmers = await Farmer.findAll();

  res.status(200).json({
    status: "success",
    total: farmers.length,
    data: {
      farmers,
    },
  });
});

export const getFarmer = asyncHandler(async (req, res, next) => {
  const { farmerId } = req.params;
  const farmer = await Farmer.findByPk(farmerId);

  if (!farmer) {
    return next(new AppError("No farmer found with provided ID", 404));
  }

  res.status(200).json({
    status: "success",
    data: {
      farmer,
    },
  });
});
