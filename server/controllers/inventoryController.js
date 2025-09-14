import express from "express";
import {Inventory} from "../model/index.js";


// exports.addNewCrop = async (req, res) => {
//     const farmerId = req.body.farmerId; // for now it is taken from json, later it will be taken from json token
//     const cropName = req.body.cropName;
//     const quantity = req.body.quantity;
//     const unit = req.body.unit;
//     const harvestDate = req.body.harvestDate;
//     // const expiryDate = harvestDate + (time taken for that veg to rot)
//     // const remainingQuantity = req.body.quantity; // initially same as quantity, further will be updated directly by sales function
//     // const status = initially available Later can be updated as -> (available, sold out, expired)
    
//     const vegetableShelfLife = {
//         tomatoes : 7,
//         onions: 28,
//         potatoes: 28
//     }; //all in days -> to be added to harverstDate 

//     try{
//         const remainingQuantity = quantity;
//         // const expiryDate = harvestDate + vegetableShelfLife[cropName];
//         const expiryDate = "26-08-2025";
//         const status = "available";
//         const response = await pool.query(
//             `insert into inventory (farmerId, cropName, quantity, unit, harvestDate, expiryDate, remainingQuantity, status)
//             values ('${farmerId}', '${cropName}', '${quantity}', '${unit}', '${harvestDate}', '${expiryDate}', '${remainingQuantity}', '${status}');
//             `);
//             return res.status(201).json({message: "Record added in inventory successfully"});
//     }
//     catch(err){
//         return res.status(500).json({error: err.message});
//     }

// };

export const addNewCrop = async (req, res) => {
  try {
    const {
      farmerId,
      cropName,
      quantity,
      unit,
      harvestDate
    } = req.body;

   
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

    return res
      .status(201)
      .json({ message: "Record added in inventory successfully" });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

export const getAllInventory = async (req, res) => {
  const { farmerId } = req.body;

  try {
    const inventories = await Inventory.findAll({
      where: { farmerId }, 
    });

    return res.status(200).json({ inventories });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

export const getById = async (req, res) => {
  const { inventoryId } = req.params;

  try {
    const inventory = await Inventory.findByPk(inventoryId); 

    if (!inventory) {
      return res.status(404).json({ message: "Inventory not found" });
    }

    return res.status(200).json({ inventory });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

export const deleteItemFromInventory = async (req, res) => {
  const { inventoryId } = req.params;

  try {
    const inventory = await Inventory.findByPk(inventoryId);

    if (!inventory) {
      return res.status(404).json({ message: "Item not found in inventory" });
    }

   
    await inventory.destroy();

    return res.status(200).json({
      message: "Item deleted from inventory successfully",
      deletedItem: inventory, 
    });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};
