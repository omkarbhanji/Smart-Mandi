import { asyncHandler } from "../middlewares/asyncHandler.js";
import { BuyRequest, Inventory, User } from "../model/index.js";
import { AppError } from "../utils/appError.js";

// for customer
export const sendBuyRequest = asyncHandler(async (req, res, next) => {
  const { inventoryId } = req.body;
  const customerId = req.user.userId;

  const existing = await BuyRequest.findOne({
    where: { customerId, inventoryId },
  });

  if (existing) {
    return next(
      new AppError("You have already sent request for this item", 409)
    );
  }

  const inventory = await Inventory.findByPk(inventoryId);

  if (!inventory) {
    return next(new AppError("No crop found with this id", 404));
  }

  const buyReq = await BuyRequest.create({
    customerId: customerId,
    farmerId: inventory.farmerId,
    inventoryId: inventoryId,
  });

  res.status(201).json({
    status: "success",
    data: {
      buyReq,
    },
  });
});

// for customer
export const getBuyRequestsCustomer = asyncHandler(async (req, res, next) => {
  const customerId = req.user.userId;

  const data = await BuyRequest.findAll({
    where: { customerId },
    include: [
      {
        model: Inventory,
        as: "inventory",
        attributes: ["cropName", "price", "quantity", "unit"],
      },
      {
        model: User,
        as: "farmer",
        attributes: ["name", "phone", "email"],
        required: false, // allow BuyRequests without a farmer included
        where: {
          "$BuyRequest.status$": "accepted", // include farmer only if BuyRequest.status = accepted
        },
      },
    ],
  });

  res.status(200).json({
    status: "success",
    data: {
      data,
    },
  });
});

// for farmers
export const getBuyRequestsFarmer = asyncHandler(async (req, res, next) => {
  const farmerId = req.user.userId;

  const data = await BuyRequest.findAll({
    where: { farmerId },
    include: [
      {
        model: Inventory,
        as: "inventory",
        attributes: ["cropName", "price", "quantity", "unit"],
      },
      {
        model: User,
        as: "customer",
        attributes: ["name", "phone", "email"],
      },
    ],
  });

  res.status(200).json({
    status: "success",
    data: {
      data,
    },
  });
});

// for farmers
export const acceptOrRejectRequest = asyncHandler(async (req, res, next) => {
  const { status } = req.body;
  const { buyRequestId } = req.params;

  const buyRequest = await BuyRequest.findByPk(buyRequestId);

  if (!buyRequest) {
    return next(new AppError("No buy request found with this id", 404));
  }

  if (!status) {
    return next(new AppError("Please enter status", 400));
  }

  if (req.user.userId !== buyRequest.farmerId) {
    return next(
      new AppError("You are not authorized to modify this request", 403)
    );
  }

  buyRequest.status = status;
  await buyRequest.save();

  res.status(200).json({
    status: "success",
    data: {
      buyRequest,
    },
  });
});
