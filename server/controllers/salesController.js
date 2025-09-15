import sequelize from "../db.js";
import { asyncHandler } from "../middlewares/asyncHandler.js";
import { Sale, Inventory } from "../model/index.js";
import { AppError } from "../utils/appError.js";

export const addNewSales = asyncHandler(async (req, res, next) => {
  let { inventoryId, quantitySold, soldPrice } = req.body;

  quantitySold = Number(quantitySold);
  soldPrice = Number(soldPrice);

  if (
    isNaN(quantitySold) ||
    isNaN(soldPrice) ||
    quantitySold <= 0 ||
    soldPrice <= 0
  ) {
    return next(new AppError("Invalid input values", 400));
  }

  const transaction = await sequelize.transaction();

  // get current inventory record
  const inventory = await Inventory.findByPk(inventoryId, {
    transaction,
    lock: true, // ensures row-level lock during transaction
  });

  if (!inventory) {
    await transaction.rollback();
    return next(new AppError("Inventory not found", 404));
  }

  const currentQuantity = Number(inventory.quantity);

  if (quantitySold > currentQuantity) {
    await transaction.rollback();
    return next(
      new AppError(
        "Sales not possible. Enough quantity not available in inventory",
        422
      )
    );
  }

  if (isNaN(currentQuantity)) {
    await transaction.rollback();
    return next(new AppError("Error in current inventory records", 500));
  }

  const newSale = await Sale.create(
    {
      inventoryId,
      quantitySold: quantitySold,
      soldPrice: soldPrice,
      totalAmount: soldPrice * quantitySold,
    },
    { transaction }
  );

  const remainingStock = currentQuantity - quantitySold;

  inventory.quantity = remainingStock;
  inventory.updatedAt = new Date();
  await inventory.save({ transaction });

  await transaction.commit();

  return res.status(201).json({
    message: "Sale recorded successfully",
    sale: newSale,
    updatedInventory: inventory,
  });
});
