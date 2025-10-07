// const { DataTypes } = require("sequelize");
// const sequelize = require("../db.js");

import { DataTypes } from "sequelize";
import sequelize from "../db.js";

const Sale = sequelize.define(
  "Sale",
  {
    saleId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    inventoryId: {
      type: DataTypes.INTEGER,
      allowNull: true, // since in your table it's not marked NOT NULL
    },
    quantitySold: {
      type: DataTypes.DOUBLE,
      allowNull: false,
    },
    soldPrice: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    totalAmount: {
      type: DataTypes.DECIMAL(12, 2),
    },
    saleDate: {
      type: DataTypes.DATEONLY,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: "Sale",
    timestamps: false,
  }
);

export default Sale;
