import { DataTypes } from "sequelize";
import sequelize from "../db.js";
import User from "./User.js";
import Inventory from "./Inventory.js";

const BuyRequest = sequelize.define(
  "BuyRequest",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    customerId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: User,
        key: "userId",
      },
    },
    farmerId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: User,
        key: "userId",
      },
    },

    inventoryId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Inventory,
        key: "inventoryId",
      },
    },

    status: {
      type: DataTypes.ENUM("pending", "accepted", "rejected"),
      allowNull: false,
      defaultValue: "pending",
    },

    seenByCustomer: {
      type: DataTypes.BOOLEAN,
      allowNull: true,
      defaultValue: null,
    },

    seenByFarmer: {
      type: DataTypes.BOOLEAN,
      allowNull: true,
      defaultValue: false,
    },
  },
  {
    tableName: "BuyRequest",
  }
);

export default BuyRequest;
