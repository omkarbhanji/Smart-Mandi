// const { DataTypes } = require("sequelize");
// const sequelize = require("../db");

import { DataTypes } from "sequelize";
import sequelize from "../db.js";

const Inventory = sequelize.define("Inventory", {
  inventoryId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  farmerId: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  cropName: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  quantity: {
    type: DataTypes.DOUBLE,
    allowNull: false,
  },
  unit: {
    type: DataTypes.STRING(20),
    defaultValue: "kg",
  },
  harvestDate: {
    type: DataTypes.DATEONLY,
    allowNull: false,
  },
  expiryDate: {
    type: DataTypes.DATEONLY,
    allowNull: false,
  },
  remainingQuantity: {
    type: DataTypes.DOUBLE,
    allowNull: false,
  },
  status: {
    type: DataTypes.STRING(20),
    defaultValue: "available",
  },
  createdAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  updatedAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: "inventory",
  timestamps: false, 
});

export default Inventory;
