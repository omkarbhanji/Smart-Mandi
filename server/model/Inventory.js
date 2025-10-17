import { DataTypes } from "sequelize";
import sequelize from "../db.js";
import User from "./User.js";

const Inventory = sequelize.define(
  "Inventory",
  {
    inventoryId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    farmerId: {
      // farmer profile id
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: User,
        key: "userId",
      },
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
    price: {
      // pre unit
      type: DataTypes.FLOAT,
      allowNull: false,
    },
    status: {
      type: DataTypes.ENUM("available", "sold", "stock"),
      allowNull: false,
    },
    // harvestDate: {
    //   type: DataTypes.DATEONLY,
    //   allowNull: false,
    // },
    // expiryDate: {
    //   type: DataTypes.DATEONLY,
    //   allowNull: false,
    // },
    // remainingQuantity: {
    //   type: DataTypes.DOUBLE,
    //   allowNull: false,
    // },
    // createdAt: {
    //   type: DataTypes.DATE,
    //   allowNull: false,
    //   defaultValue: DataTypes.NOW,
    // },
    // updatedAt: {
    //   type: DataTypes.DATE,
    //   allowNull: false,
    //   defaultValue: DataTypes.NOW,
    // },
  },
  {
    tableName: "Inventory",
    timestamps: false,
  }
);

export default Inventory;
