// const express = require('express');
import express from "express";
const router = express.Router();

// const {nearByPrices} = require('../controllers/marketController');
import {nearByPrices} from "../controllers/inventoryController";

router.get('/nearby-prices', nearByPrices);

module.exports = router;

