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
    }; //all in days 

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