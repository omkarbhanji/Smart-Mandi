import { asyncHandler } from "../middlewares/asyncHandler.js";
import { BuyRequest, Inventory } from "../model/index.js";
import { AppError } from "../utils/appError.js";

export const sendBuyRequest = asyncHandler(async (req, res, next) => {
  const { inventoryId } = req.body;

  const inventory = await Inventory.findByPk(inventoryId);

  if (!inventory) {
    return next(new AppError("No crop found with this id", 404));
  }

  const buyReq = await BuyRequest.create({
    customerId: req.user.userId,
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

// for farmers
export const getBuyRequests = asyncHandler(async (req, res, next) => {
  const farmerId = req.user.userId;

  const data = await BuyRequest.findAll({ where: { farmerId } });

  res.status(200).json({
    status: "success",
    data: {
      data,
    },
  });
});

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

  buyRequest.status = status;
  await buyRequest.save();

  res.status(200).json({
    status: "success",
    data: {
      buyRequest,
    },
  });
});
