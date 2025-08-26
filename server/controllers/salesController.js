const express = require('express');
const pool = require('../db');

exports.addNewSales = async (req,res) => {

    //pool for individual client 
    const client = await pool.connect();


    // const saleId = req.body.sale_id;
    const inventoryId = req.body.inventory_id;
    const quantitySold = Number(req.body.quantity_sold);
    const soldPrice = Number(req.body.sold_price);
    let totalAmount = 0;
    
    try{
        
        if (isNaN(quantitySold) || isNaN(soldPrice) || quantitySold <= 0 || soldPrice <= 0) {
            return res.status(400).json({ message: "Invalid input values" });
        }

        if(quantitySold >= 0 && soldPrice >= 0){
            totalAmount = quantitySold * soldPrice;
        }

          // transaction BEGIN

        await client.query('BEGIN');

        // getting current quantity values
        const currentInventoryRecord = await client.query(`select quantity from inventory where inventory_id = $1`, [inventoryId]);
        // console.log(currentInventoryRecord);

        
        const currentQuantity = Number(currentInventoryRecord.rows[0]?.quantity); // extracting & typecasting quantity
        // console.log('This is current invenory data: ', currentQuantity);


        if(quantitySold > currentQuantity){
            //422 -> unproccessable entity !!
            return res.status(422).json({message: "Sales not possible. Enoguh quantity not available in inventory"});
        }

        if(isNaN(currentQuantity) ){
            return res.status(500).json({message: "Error in current inventory records"});
        }

      
        // inserting record in sales table
        const response = await client.query(`insert into sales
             (inventory_id, quantity_sold, sold_price) 
            values ('${inventoryId}', '${quantitySold}', '${soldPrice}' );
            `);
            
        const remainingStock = currentQuantity - quantitySold;
        // console.log('Remainig stock is : ', remainingStock);

        // updating inventory record
        const updateInventory = await client.query(`
                update inventory set quantity = $1 where inventory_id = $2 returning * 
                `, [remainingStock, inventoryId]);

        await client.query('COMMIT');
        
        return res.status(201).json({updateInventory});
    }catch(err){
        await client.query('ROLLBACK');
        return res.status(500).json({error: err.message});
    }finally{
        client.release();
    }
}   