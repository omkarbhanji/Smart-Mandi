// const express = require('express');
// const router = express.Router();
// const {addNewCrop, getAllInventory} = require('../controllers/inventoryController');
// const { addNewSales } = require('../controllers/salesController');
import express from "express";
import {
  addNewCrop,
  getAllInventory,
} from "../controllers/inventoryController.js";
import { addNewSales } from "../controllers/salesController.js";

const router = express.Router();

// inventory routes
router.get("/", getAllInventory);
router.post("/", addNewCrop);

//sales routes
router.post("/:id/sales", addNewSales);

export default router;
