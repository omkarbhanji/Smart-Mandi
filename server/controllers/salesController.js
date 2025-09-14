// const { Sales, Inventory, sequelize } = require("../model/index");

import {Sale, Inventory, sequelize } from "../model/index.js";

export const addNewSales = async (req, res) => {
  let { inventoryId, quantitySold, soldPrice } = req.body;

   quantitySold = Number(quantitySold);
   soldPrice = Number(soldPrice);

  if (
    isNaN(quantitySold) ||
    isNaN(soldPrice) ||
    quantitySold <= 0 ||
    soldPrice <= 0
  ) {
    return res.status(400).json({ message: "Invalid input values" });
  }

  const transaction = await sequelize.transaction();

  try {
    // get current inventory record
    const inventory = await Inventory.findByPk(inventoryId, {
      transaction,
      lock: true, // ensures row-level lock during transaction
    });

    if (!inventory) {
      await transaction.rollback();
      return res.status(404).json({ message: "Inventory not found" });
    }

    const currentQuantity = Number(inventory.quantity);

    if (quantitySold > currentQuantity) {
      await transaction.rollback();
      return res.status(422).json({
        message: "Sales not possible. Enough quantity not available in inventory",
      });
    }

    if (isNaN(currentQuantity)) {
      await transaction.rollback();
      return res
        .status(500)
        .json({ message: "Error in current inventory records" });
    }


    const newSale = await Sale.create(
      {
        inventoryId,
        quantitySold: quantitySold,
        soldPrice: soldPrice,
        totalAmount: (soldPrice * quantitySold)
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
  } catch (err) {
    await transaction.rollback();
    return res.status(500).json({ error: err.message });
  }
};
