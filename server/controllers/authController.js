import jwt from "jsonwebtoken";
import { Farmer } from "../model/index.js";
import { asyncHandler } from "../middlewares/asyncHandler.js";
import { AppError } from "../utils/appError.js";

export const protect = asyncHandler(async (req, res, next) => {
  const { jwtToken } = req.cookies;

  if (!jwtToken) {
    return next(
      new AppError("You are not logged in please log in to get access", 401)
    );
  }

  const decode = jwt.verify(jwtToken, process.env.JWT_SECRET_KEY);

  const user = await Farmer.findByPk(decode.id);

  if (!user) {
    return next(
      new AppError("The user belonging to this token does no longer exist", 401)
    );
  }

  req.user = user;

  next();
});

export const authUser = asyncHandler(async (req, res, next) => {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) {
    return next(new AppError("Authentication failed", 401));
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET_KEY);
    const user = await Farmer.findByPk(decoded.id);
    return res.status(200).json({
      status: "success",
      authenticated: true,
      user: user,
    });
  } catch (error) {
    return res.status(401).json({ status: "fail", authenticated: false });
  }
});
