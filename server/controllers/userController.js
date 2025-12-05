import bcrypt from "bcrypt";
import { CustomerProfile, User, FarmerProfile } from "../model/index.js";
import { asyncHandler } from "../middlewares/asyncHandler.js";
import { AppError } from "../utils/appError.js";
import { sendToken } from "../utils/jwtTokenSend.js";
import sequelize from "../db.js";

// Register user
export const registerUser = asyncHandler(async (req, res, next) => {
  const { name, email, password, phone, role } = req.body;

  const transaction = await sequelize.transaction();
console.log();
  try {
    const user = await User.create(
      {
        name,
        email,
        password,
        phone,
        role,
      },
      { transaction }
    );

    if (role === "farmer") {
      const { location, state, latitude, longitude } = req.body;

      await FarmerProfile.create(
        {
          userId: user.userId,
          location,
          state,
          latitude,
          longitude,
        },
        { transaction }
      );
    } else if (role === "customer") {
      const { address } = req.body;
      await CustomerProfile.create(
        {
          userId: user.userId,
          address,
        },
        { transaction }
      );
    }

    await transaction.commit();

    sendToken(user, 201, res);
  } catch (error) {
    await transaction.rollback();
    res.status(500).json({
      status: "fail",
      message: error.message,
    });
  }
});

// Login user
export const loginUser = asyncHandler(async (req, res, next) => {
  const { email, password, role } = req.body;

  if (!email.trim() || !password.trim()) {
    return next(new AppError("Please enter email and password", 400));
  }

  const user = await User.findOne({
    where: { email },
    attributes: { include: ["password"] },
    raw: true,
  });

  if (!user) {
    return next(new AppError("Incorrect email or password", 401));
  }

  const isPasswordCorrect = await bcrypt.compare(password, user.password);

  if (!isPasswordCorrect) {
    return next(new AppError("Incorrect email or password", 401));
  }

  if (user.role !== role) {
    return next(new AppError("Incorrect email or password", 401));
  }

  sendToken(user, 200, res);
});

export const getUsers = asyncHandler(async (req, res, next) => {
  const users = await User.findAll();

  res.status(200).json({
    status: "success",
    total: users.length,
    data: {
      users,
    },
  });
});

export const getFarmer = asyncHandler(async (req, res, next) => {
  const { userId } = req.params;
  const user = await User.findByPk(userId, {
    include: [
      { model: FarmerProfile, as: "farmerProfile", required: false },
      { model: CustomerProfile, as: "customerProfile", required: false },
    ],
  });

  if (!user) {
    return next(new AppError("No user found with provided ID", 404));
  }

  res.status(200).json({
    status: "success",
    data: {
      user,
    },
  });
});
