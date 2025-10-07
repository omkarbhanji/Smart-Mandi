// const { DataTypes } = require("sequelize");
// const sequelize = require("../db");

import { DataTypes } from "sequelize";
import sequelize from "../db.js";

const Market = sequelize.define(
  "Market",
  {
    marketId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    name: {
      type: DataTypes.STRING(120),
      allowNull: false,
    },
    state: {
      type: DataTypes.STRING(60),
      allowNull: false,
    },
    district: {
      type: DataTypes.STRING(60),
      allowNull: false,
    },
    address: {
      type: DataTypes.TEXT,
      defaultValue: "unknown",
    },
  },
  {
    tableName: "Markets",
    timestamps: false,
  }
);

export default Market;
