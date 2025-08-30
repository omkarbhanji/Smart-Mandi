const express = require('express');
const router = express.Router();

const {nearByPrices} = require('../controllers/marketController');

router.get('/nearby-prices', nearByPrices);

module.exports = router;

