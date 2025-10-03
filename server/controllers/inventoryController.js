import { Inventory } from "../model/index.js";
import { asyncHandler } from "../middlewares/asyncHandler.js";
import { AppError } from "../utils/appError.js";

export const addNewCrop = asyncHandler(async (req, res, next) => {
  const { farmerId, cropName, quantity, unit, harvestDate } = req.body;

  const vegetableShelfLife = {
    tomatoes: 7,
    onions: 28,
    potatoes: 28,
  };

  const remainingQuantity = quantity;
  const status = "available";

  let expiryDate = null;
  console.log(cropName);
  if (vegetableShelfLife[cropName.toLowerCase()]) {
    const harvestDateObj = new Date(harvestDate);
    harvestDateObj.setDate(
      harvestDateObj.getDate() + vegetableShelfLife[cropName.toLowerCase()]
    );
    expiryDate = harvestDateObj;
  }

  // Insert record using Sequelize
  await Inventory.create({
    farmerId,
    cropName,
    quantity,
    unit,
    harvestDate,
    expiryDate,
    remainingQuantity,
    status,
  });

  res.status(201).json({
    status: "success",
    message: "Record added in inventory successfully",
  });
});

export const getAllInventory = asyncHandler(async (req, res, next) => {
  const { farmerId } = req.body;

  const inventories = await Inventory.findAll({
    where: { farmerId },
  });

  res.status(200).json({
    status: "success",
    inventories,
  });
});

export const getById = asyncHandler(async (req, res, next) => {
  const { inventoryId } = req.params;

  const inventory = await Inventory.findByPk(inventoryId);

  if (!inventory) {
    return next(new AppError("Inventory not found", 404));
  }

  res.status(200).json({
    status: "success",
    inventory,
  });
});

export const deleteItemFromInventory = asyncHandler(async (req, res, next) => {
  const { inventoryId } = req.params;

  const inventory = await Inventory.findByPk(inventoryId);

  if (!inventory) {
    return next(new AppError("Item not found in inventory", 404));
  }

  await inventory.destroy();

  return res.status(204).json({
    status: "success",
    message: "Item deleted from inventory successfully",
    data: null,
  });
});
