import { DataTypes } from "sequelize";
import sequelize from "../db.js";
import User from "./User.js";

const CustomerProfile = sequelize.define("CustomerProfile", {
  customerId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: User,
      key: "userId",
    },
  },
  address: {
    type: DataTypes.STRING,
    allowNull: false,
  },
});

export default CustomerProfile;
