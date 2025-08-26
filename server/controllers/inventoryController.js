const express = require('express');
const pool = require('../db');

// Some variables written in camelCase are only in this javascript but in db they are in snake_case

exports.addNewCrop = async (req, res) => {
    const farmerId = req.body.farmer_id; // for now it is taken from json, later it will be taken from json token
    const cropName = req.body.crop_name;
    const quantity = req.body.quantity;
    const unit = req.body.unit;
    const harvestDate = req.body.harvest_date;
    // const expiryDate = harvestDate + (time taken for that veg to rot)
    // const remainingQuantity = req.body.quantity; // initially same as quantity, further will be updated directly by sales function
    // const status = initially available Later can be updated as -> (available, sold out, expired)
    
    const vegetableShelfLife = {
        tomatoes : 7,
        onions: 28,
        potatoes: 28
    }; //all in days -> to be added to harverstDate 

    try{
        const remainingQuantity = quantity;
        // const expiryDate = harvestDate + vegetableShelfLife[cropName];
        const expiryDate = "26-08-2025";
        const status = "available";
        const response = await pool.query(
            `insert into inventory (farmer_id, crop_name, quantity, unit, harvest_date, expiry_date, remaining_quantity, status)
            values ('${farmerId}', '${cropName}', '${quantity}', '${unit}', '${harvestDate}', '${expiryDate}', '${remainingQuantity}', '${status}');
            `);
            return res.status(201).json({message: "Record added in inventory successfully"});
    }
    catch(err){
        return res.status(500).json({error: err.message});
    }

};

exports.getAllInventory = async(req, res) => {
    const farmerId  = req.body.farmer_id;
    try{
        const response = await pool.query(`select * from inventory where farmer_id = $1`, [farmerId]);
        return res.status(200).json({response});
    }catch(err){
        res.status(500).json({message: err.message});
    }
};

exports.getById = async(req, res) => {
    const inventoryId = req.params.inventoryId;

    try{
        const response = await pool.query(`select * from inventory where inventory_id = $1`, [inventoryId]);
        if(response.wors.length === 0){
            return res.status(404).json({ message: "Task not found" });
        }
        return res.status(201).json({response});
    }catch(err){
        return res.status(500).json({error: err.message});
    }
};

exports.deleteItemFromInventory = async (req, res) => {
    const inventoryId = req.params.inventoryId;
    try{
        const response = await pool.query(
      `DELETE FROM inventory WHERE id = $1 RETURNING *`,
      [inventoryId]
    );

    if (response.rows.length === 0) {
      return res.status(404).json({ message: "Item not found in inventory" });
    }

    return res.status(200).json({
      message: "Item deleted from inventory successfully",
      deletedItem: response.rows[0]
    });

    }catch(err){
        return res.status(500).json({ error: err.message });
    }
};