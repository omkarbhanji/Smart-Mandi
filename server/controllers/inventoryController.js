import { FarmerProfile, Inventory, User } from "../model/index.js";
import { asyncHandler } from "../middlewares/asyncHandler.js";
import { AppError } from "../utils/appError.js";
import { Op } from "sequelize";

export const addNewCrop = asyncHandler(async (req, res, next) => {
  const { cropName, quantity, unit, price, status } = req.body;

  // const vegetableShelfLife = {
  //   tomatoes: 7,
  //   onions: 28,
  //   potatoes: 28,
  // };

  // const remainingQuantity = quantity;
  // const status = "available";

  // let expiryDate = null;
  // console.log(cropName);
  // if (vegetableShelfLife[cropName.toLowerCase()]) {
  //   const harvestDateObj = new Date(harvestDate);
  //   harvestDateObj.setDate(
  //     harvestDateObj.getDate() + vegetableShelfLife[cropName.toLowerCase()]
  //   );
  //   expiryDate = harvestDateObj;
  // }

  // // Insert record using Sequelize
  // await Inventory.create({
  //   farmerId,
  //   cropName,
  //   quantity,
  //   unit,
  //   harvestDate,
  //   expiryDate,
  //   remainingQuantity,
  //   status,
  // });

  const data = await Inventory.create({
    farmerId: req.user.userId,
    cropName,
    quantity,
    unit,
    price,
    status,
  });

  res.status(201).json({
    status: "success",
    data: {
      data,
    },
  });
});

export const getAllInventory = asyncHandler(async (req, res, next) => {
  const farmerId = req.user.farmerProfile.farmerId;

  const data = await Inventory.findAll({
    where: { farmerId },
  });

  res.status(200).json({
    status: "success",
    total: data.length,
    data: {
      data,
    },
  });
});

export const getById = asyncHandler(async (req, res, next) => {
  const { inventoryId } = req.params;

  const inventory = await Inventory.findByPk(inventoryId);

  if (!inventory) {
    return next(new AppError("No inventory found with this id", 404));
  }

  res.status(200).json({
    status: "success",
    data: {
      inventory,
    },
  });
});

export const updateStatus = asyncHandler(async (req, res, next) => {
  const { status } = req.body;
  const { inventoryId } = req.params;

  const inv = await Inventory.findByPk(inventoryId);

  if (!inv) {
    return next(new AppError("Inventory not found with this id", 404));
  }

  if (!status) {
    return next(new AppError("Please enter status", 400));
  }

  if (inv.farmerId !== req.user.farmerProfile.farmerId) {
    return next(new AppError("You can't delete this inventory", 403));
  }

  inv.status = status;
  await inv.save();

  res.status(200).json({
    status: "success",
    data: {
      inventory: inv,
    },
  });
});

export const deleteItemFromInventory = asyncHandler(async (req, res, next) => {
  const { inventoryId } = req.params;

  const inventory = await Inventory.findByPk(inventoryId);

  if (!inventory) {
    return next(new AppError("No inventory found with this id", 404));
  }

  if (inventory.farmerId !== req.user.farmerProfile.farmerId) {
    return next(new AppError("You can't delete this inventory", 403));
  }

  await inventory.destroy();

  return res.status(204).json({
    status: "success",
    data: null,
  });
});

export const itemForSell = asyncHandler(async (req, res, next) => {
  const { minQuantity, maxQuantity, cropName } = req.query;

  const whereCondition = { status: "available" };

  if (minQuantity) {
    whereCondition.quantity = {
      ...(whereCondition.quantity || {}),
      [Op.gte]: Number(minQuantity),
    };
  }

  if (maxQuantity) {
    whereCondition.quantity = {
      ...(whereCondition.quantity || {}),
      [Op.lte]: Number(maxQuantity),
    };
  }

  if (cropName) {
    whereCondition.cropName = { [Op.iLike]: `%${cropName}%` };
  }

  const data = await Inventory.findAll({
    where: whereCondition,
    include: [
      {
        model: User,
        as: "farmer",
        attributes: ["userId", "name"],
        include: [
          {
            model: FarmerProfile,
            as: "farmerProfile",
            attributes: ["location", "state"],
          },
        ],
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
