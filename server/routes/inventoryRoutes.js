const express = require('express');
const router = express.Router();

const {addNewCrop, getAllInventory} = require('../controllers/inventoryController');
const { addNewSales } = require('../controllers/salesController');

// inventory routes
router.get('/', getAllInventory); 
router.post('/', addNewCrop); 

//sales routes
router.post('/:id/sales', addNewSales);

module.exports = router;