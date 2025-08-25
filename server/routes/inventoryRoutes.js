const express = require('express');
const router = express.Router();

const {addNewCrop, getAllInventory} = require('../controllers/inventoryController');

router.get('/inventory', getAllInventory); 
router.post('/inventory', addNewCrop); 

module.exports = router;